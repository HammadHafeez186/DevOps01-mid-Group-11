# Railway Deployment Configuration

## Environment Variables Setup

To fix the email sending issue on Railway, you need to add the following environment variables to your Railway project:

### 1. Access Railway Dashboard
1. Go to [railway.app](https://railway.app)
2. Navigate to your project: `web-production-cf2cb`
3. Click on your service
4. Go to the **Variables** tab

### 2. Add Email Configuration Variables

Add these exact environment variables:

```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=hammad.jack@gmail.com
EMAIL_PASS=ecsoonsmxmokiuoq
EMAIL_SECURE=false
EMAIL_FROM=DevOps Articles <hammad.jack@gmail.com>
```

### 3. Gmail Security Setup

**IMPORTANT**: For Gmail SMTP to work, ensure:

1. **2-Factor Authentication** is enabled on your Google account
2. **App Password** is generated:
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Select "2-Step Verification" → "App passwords"
   - Generate a new app password for "Mail"
   - Replace `EMAIL_PASS` with the 16-character app password

### 4. Current Issue Analysis

The error "Connection timeout" indicates:
- ❌ Environment variables are missing on Railway
- ❌ Possible Gmail security blocking the connection
- ❌ Network timeout due to Railway's infrastructure

### 5. Alternative Email Solutions

If Gmail continues to have issues, consider these alternatives:

**Option A: SendGrid (Recommended)**
```
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USER=apikey
EMAIL_PASS=your_sendgrid_api_key
EMAIL_SECURE=false
```

**Option B: Mailgun**
```
EMAIL_HOST=smtp.mailgun.org
EMAIL_PORT=587
EMAIL_USER=your_mailgun_username
EMAIL_PASS=your_mailgun_password
EMAIL_SECURE=false
```

### 6. Testing Email Functionality

After adding environment variables:
1. Railway will automatically redeploy
2. Test signup at: https://web-production-cf2cb.up.railway.app/auth/signup
3. Check Railway logs for any remaining errors

### 7. Troubleshooting

If emails still fail:
1. Check Railway logs: `View Deployments` → `View Logs`
2. Verify environment variables are set correctly
3. Test with a different email service
4. Check if your IP is blocked by Gmail

## Current Environment Variables Needed

Make sure Railway has ALL these variables:

```bash
# Database (Already configured)
DATABASE_URL=postgresql://...

# Email Configuration (MISSING - ADD THESE)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=hammad.jack@gmail.com
EMAIL_PASS=ecsoonsmxmokiuoq
EMAIL_SECURE=false
EMAIL_FROM=DevOps Articles <hammad.jack@gmail.com>

# Application
NODE_ENV=production
PORT=3000
```

## Next Steps

1. ✅ Add email environment variables to Railway
2. ✅ Generate Gmail app password (if not already done)
3. ✅ Test email sending on Railway
4. ✅ Monitor Railway logs for success