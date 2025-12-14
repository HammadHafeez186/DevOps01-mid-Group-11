# Session/Login Routing Fix for AWS K8s Deployment

## Problem
After successful registration/login, the app wasn't routing properly on AWS K8s deployment. This was caused by:

1. **Secure cookie flag**: The app was setting `secure: true` on session cookies in production, which requires HTTPS. Without HTTPS (using HTTP LoadBalancer), browsers reject the cookies, preventing session persistence.

2. **Wrong APP_URL**: The configmap had `http://localhost:3000` instead of the actual LoadBalancer URL.

## Solution Applied

### 1. Modified Session Cookie Configuration
**File: [app.js](app.js#L42-L50)**

Changed from:
```javascript
secure: isProduction,  // Always true in production
```

To:
```javascript
secure: process.env.COOKIE_SECURE === 'true',  // Explicitly controlled
```

This allows HTTP deployments without SSL/TLS to work correctly.

### 2. Updated Kubernetes ConfigMaps
Added `COOKIE_SECURE` environment variable to both configmaps:
- [k8s/01-configmap.yaml](k8s/01-configmap.yaml)
- [k8s/01-configmap.aws.yaml](k8s/01-configmap.aws.yaml)

### 3. Updated Deployments
Added the COOKIE_SECURE env var to both deployment files:
- [k8s/06-app-deployment.yaml](k8s/06-app-deployment.yaml)
- [k8s/06-app-deployment.aws.yaml](k8s/06-app-deployment.aws.yaml)

## Deployment Steps

### Step 1: Get Your LoadBalancer URL
```bash
kubectl get svc -n devops-articles app-service
```

Look for the `EXTERNAL-IP` column. It will be something like:
- `a1234567890abcdef.us-east-1.elb.amazonaws.com` (Classic LB)
- `k8s-devopsart-appservi-1234567890.us-east-1.elb.amazonaws.com` (ALB/NLB)

### Step 2: Update the ConfigMap
Edit [k8s/01-configmap.aws.yaml](k8s/01-configmap.aws.yaml) and replace:
```yaml
APP_URL: "http://REPLACE_WITH_LOADBALANCER_URL"
```

With your actual LoadBalancer URL:
```yaml
APP_URL: "http://your-actual-loadbalancer-url"
```

**Note**: If you have HTTPS configured on your LoadBalancer:
- Change `http://` to `https://`
- Change `COOKIE_SECURE: "false"` to `COOKIE_SECURE: "true"`

### Step 3: Apply the Updated ConfigMap
```bash
kubectl apply -f k8s/01-configmap.aws.yaml
```

### Step 4: Restart the App Pods
```bash
kubectl rollout restart deployment/app -n devops-articles
```

### Step 5: Verify
Wait for pods to be ready:
```bash
kubectl get pods -n devops-articles -w
```

Test the login flow:
1. Register a new account
2. Verify with OTP
3. Login
4. You should now be redirected to `/articles` successfully

## Troubleshooting

### Still Not Working?
1. **Check pod logs**:
   ```bash
   kubectl logs -n devops-articles -l app=devops-articles --tail=50
   ```

2. **Verify environment variables**:
   ```bash
   kubectl exec -n devops-articles deployment/app -- env | grep -E 'APP_URL|COOKIE_SECURE|NODE_ENV'
   ```

3. **Check browser cookies**:
   - Open DevTools → Application → Cookies
   - Look for `connect.sid` cookie
   - If missing after login, the session isn't being saved

4. **Database connection**:
   ```bash
   kubectl exec -n devops-articles deployment/app -- node -e "
   const {sequelize} = require('./models');
   sequelize.authenticate().then(() => console.log('DB OK')).catch(e => console.error(e))
   "
   ```

### For HTTPS Setup
If you want to enable HTTPS (recommended for production):

1. **Set up an ALB with ACM certificate** (via Terraform or AWS Console)
2. Update the configmap:
   ```yaml
   APP_URL: "https://your-domain.com"
   COOKIE_SECURE: "true"
   ```
3. Update the service to use target type `ip` for ALB
4. Apply changes and restart pods

## Testing Locally
For local testing with the fix:
```bash
# Don't set COOKIE_SECURE or set it to false
export COOKIE_SECURE=false
export APP_URL=http://localhost:3000
npm start
```

## Security Note
- `COOKIE_SECURE: "false"` is acceptable for internal/development HTTP deployments
- For production with public access, **always use HTTPS** and set `COOKIE_SECURE: "true"`
- The `httpOnly` and `sameSite: 'lax'` settings are still enforced for security
