# 📧 Email Configuration Quick Reference

## Configuration Status
- ✅ **Postal** - Primary email service (SMTP + HTTP API)
- ✅ **Resend** - Backup email forwarding service
- ✅ **OTP Emails** - Professional verification emails
- ✅ **Password Reset** - Secure token-based reset
- ✅ **Docker Support** - Full containerization

## Current Configuration

```
PRIMARY SERVICE
├─ Type: Postal (postal.mailsytems.live)
├─ Domain: tabeeb.email
├─ API Key: YzpDpWMnPtswA6wNWQLaIirB
├─ Port: 587 (TLS)
└─ From: DevOps Articles <noreply@tabeeb.email>

BACKUP SERVICE
├─ Type: Resend API
├─ API Key: re_8AmZ4VaA_Kw2gnEeCVpwZYdWWqASPuZrw
└─ Purpose: Email forwarding fallback

FALLBACK ORDER
1. Postal HTTP API (postal.mailsytems.live/api/v1/send/message)
2. Postal SMTP (postal.mailsytems.live:587)
3. Resend API (resend.com)
4. Mock Service (development/testing only)
```

## Test Endpoints

| Endpoint | Purpose | Example |
|----------|---------|---------|
| `/auth/test-email-services` | View all configured services | http://localhost:3000/auth/test-email-services |
| `/auth/test-email-services?email=X&send=true` | Send test email | http://localhost:3000/auth/test-email-services?email=test@gmail.com&send=true |
| `/auth/test-otp-email?email=X` | Send OTP verification | http://localhost:3000/auth/test-otp-email?email=test@gmail.com |
| `/auth/test-email?email=X` | Quick test | http://localhost:3000/auth/test-email?email=test@gmail.com |

## Email Features

### OTP Verification
- **Format**: 6-digit code
- **Expiry**: 10 minutes
- **Template**: Professional HTML email
- **Hashing**: bcrypt (secure storage)

### Password Reset
- **Type**: Token-based
- **Token Fields**: `resetTokenHash`, `resetTokenExpiresAt`
- **Security**: Bcrypt hashed, time-limited
- **Fallback**: Works with all 3 email services

### Professional Templates
- Medical/healthcare branding
- Mobile-responsive design
- Security information included
- Clear call-to-action buttons

## Environment Variables (Production)

```bash
# Postal Configuration
export POSTAL_API_KEY="YzpDpWMnPtswA6wNWQLaIirB"
export POSTAL_SERVER="postal.mailsytems.live"
export POSTAL_PORT="587"
export POSTAL_USERNAME="apikey"

# Resend Configuration
export RESEND_API_KEY="re_8AmZ4VaA_Kw2gnEeCVpwZYdWWqASPuZrw"

# Application
export EMAIL_FROM="DevOps Articles <noreply@tabeeb.email>"
export APP_URL="https://your-domain.com"
```

## Docker Deployment

```bash
# Build and run
docker-compose up --build

# Check logs
docker-compose logs app

# Run migrations (automatic)
# Email services configured automatically from .env
```

## Monitoring

### Check Service Status
```bash
curl http://localhost:3000/auth/test-email-services
```

### Test Email Delivery
```bash
curl "http://localhost:3000/auth/test-email-services?email=your@email.com&send=true"
```

### View Logs
```bash
# Development
npm run dev  # See logs in terminal

# Docker
docker-compose logs app -f
```

## File Locations

| File | Purpose |
|------|---------|
| `utils/email.js` | Email service implementation |
| `routes/auth.js` | Authentication with email routes |
| `migrations/20241103000000-add-password-reset-fields.js` | Password reset fields |
| `.env` | Email credentials (local development) |
| `docker-compose.yml` | Docker email configuration |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "resetTokenHash does not exist" | Run migrations: `NODE_ENV=docker npx sequelize-cli db:migrate` |
| Postal API fails | Check DNS records for tabeeb.email (SPF, DKIM, MX) |
| Emails not delivered | Check `/auth/test-email-services` endpoint status |
| Can't send OTP | Verify RESEND_API_KEY is set and valid |

## Key Files Modified

1. **utils/email.js** - Email service with fallback chain
2. **routes/auth.js** - Email endpoints and OTP routes
3. **docker-compose.yml** - Email env variables for Docker
4. **Dockerfile** - Migrations run before app start
5. **.env** - Resend API key added

## Ready to Use Features

✅ User Registration with OTP verification
✅ Password Reset with email confirmation
✅ Admin Notifications
✅ Multi-service fallback
✅ Professional email templates
✅ Docker containerization
✅ Production-ready configuration

## Next Steps

1. Test with: `http://localhost:3000/auth/test-email-services?email=your@email.com&send=true`
2. Deploy to Docker: `docker-compose up --build`
3. Deploy to production (Railway/Render): Set env variables
4. Monitor: Check email service logs in console

---

**Last Updated**: December 13, 2025
**Status**: ✅ Production Ready
