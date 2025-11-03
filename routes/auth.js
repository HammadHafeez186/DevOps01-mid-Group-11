'use strict'

const express = require('express')
const bcrypt = require('bcryptjs')
const crypto = require('crypto')
const { User } = require('../models')
const { redirectIfAuthenticated } = require('../middleware/auth')
const { sendMail } = require('../utils/email')

const router = express.Router()

const OTP_EXPIRY_MINUTES = 10

const asyncHandler = (handler) => (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next)
}

const setFlash = (req, type, message) => {
    if (req.session) {
        req.session.flash = { type, message }
    }
}

const normalizeEmail = (email) => (email || '').trim().toLowerCase()

const issueOtp = async(user) => {
    const otp = crypto.randomInt(100000, 1000000).toString()
    const otpHash = await bcrypt.hash(otp, 10)
    user.otpHash = otpHash
    user.otpExpiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000)
    await user.save()
    return otp
}

const sendVerificationEmail = async(email, otp) => {
    const from = process.env.EMAIL_FROM || 'no-reply@example.com'
    const appName = process.env.APP_NAME || 'DevOps Articles'

    await sendMail({
        from,
        to: email,
        subject: `${appName} verification code`,
        text: [
            `Welcome to ${appName}!`,
            '',
            `Your verification code is: ${otp}`,
            '',
            `This code will expire in ${OTP_EXPIRY_MINUTES} minutes.`,
            'If you did not request this code, you can safely ignore this email.'
        ].join('\n'),
        html: [
            `<p>Welcome to <strong>${appName}</strong>!</p>`,
            `<p>Your verification code is: <strong>${otp}</strong></p>`,
            `<p>This code will expire in ${OTP_EXPIRY_MINUTES} minutes.</p>`,
            '<p>If you did not request this code, you can safely ignore this email.</p>'
        ].join('')
    })
}

router.get('/signup', redirectIfAuthenticated, (req, res) => {
    res.render('auth/signup', {
        email: req.query.email || '',
        errors: []
    })
})

router.post('/signup', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const emailRaw = req.body.email || ''
    const email = normalizeEmail(emailRaw)
    const errors = []

    if (!email) {
        errors.push('Email is required.')
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        errors.push('Please provide a valid email address.')
    }

    if (errors.length > 0) {
        res.status(400).render('auth/signup', {
            email: emailRaw,
            errors
        })
        return
    }

    let user = await User.findOne({ where: { email } })

    if (user && user.isVerified) {
        setFlash(req, 'info', 'An account with that email already exists. Please sign in instead.')
        res.redirect('/auth/login')
        return
    }

    if (!user) {
        user = await User.create({ email })
    }

    const otp = await issueOtp(user)

    try {
        await sendVerificationEmail(email, otp)
    } catch (error) {
        console.error('Failed to send verification email:', error.message)
        setFlash(req, 'danger', 'We were unable to send the verification email. Please try again later.')
        res.redirect(`/auth/signup?email=${encodeURIComponent(email)}`)
        return
    }

    setFlash(req, 'success', 'Verification code sent! Please check your email.')
    res.redirect(`/auth/verify?email=${encodeURIComponent(email)}`)
}))

router.post('/resend', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const email = normalizeEmail(req.body.email)

    if (!email) {
        setFlash(req, 'danger', 'Provide an email address to resend the verification code.')
        res.redirect('/auth/signup')
        return
    }

    const user = await User.findOne({ where: { email } })

    if (!user) {
        setFlash(req, 'danger', 'No pending account found for that email. Please sign up first.')
        res.redirect(`/auth/signup?email=${encodeURIComponent(email)}`)
        return
    }

    if (user.isVerified) {
        setFlash(req, 'info', 'This account is already verified. You can sign in now.')
        res.redirect('/auth/login')
        return
    }

    const otp = await issueOtp(user)

    try {
        await sendVerificationEmail(email, otp)
    } catch (error) {
        console.error('Failed to send verification email:', error.message)
        setFlash(req, 'danger', 'We were unable to send the verification email. Please try again later.')
        res.redirect(`/auth/verify?email=${encodeURIComponent(email)}`)
        return
    }

    setFlash(req, 'success', 'We sent a new verification code to your email.')
    res.redirect(`/auth/verify?email=${encodeURIComponent(email)}`)
}))

router.get('/verify', redirectIfAuthenticated, (req, res) => {
    const emailRaw = req.query.email || ''

    if (!emailRaw) {
        setFlash(req, 'warning', 'Start verification by entering your email first.')
        res.redirect('/auth/signup')
        return
    }

    res.render('auth/verify', {
        email: emailRaw,
        errors: []
    })
})

router.post('/verify', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const emailRaw = req.body.email || ''
    const email = normalizeEmail(emailRaw)
    const otp = (req.body.otp || '').trim()
    const password = req.body.password || ''
    const confirmPassword = req.body.confirmPassword || ''
    const errors = []

    if (!email) {
        errors.push('Email is required.')
    }
    if (!otp) {
        errors.push('Verification code is required.')
    }
    if (!password) {
        errors.push('Password is required.')
    } else if (password.length < 8) {
        errors.push('Password must be at least 8 characters long.')
    }
    if (password && confirmPassword && password !== confirmPassword) {
        errors.push('Password confirmation does not match.')
    }

    if (errors.length > 0) {
        res.status(400).render('auth/verify', {
            email: emailRaw,
            errors
        })
        return
    }

    const user = await User.findOne({ where: { email } })

    if (!user) {
        setFlash(req, 'danger', 'We could not find an account for that email. Please sign up first.')
        res.redirect(`/auth/signup?email=${encodeURIComponent(emailRaw)}`)
        return
    }

    if (user.isVerified) {
        setFlash(req, 'info', 'Your account is already verified. Please sign in.')
        res.redirect('/auth/login')
        return
    }

    if (!user.otpHash || !user.otpExpiresAt || user.otpExpiresAt <= new Date()) {
        setFlash(req, 'danger', 'Your verification code expired. We sent you a new one.')
        const newOtp = await issueOtp(user)

        try {
            await sendVerificationEmail(email, newOtp)
        } catch (error) {
            console.error('Failed to resend verification email:', error.message)
            setFlash(req, 'danger', 'We were unable to send the verification email. Please try again later.')
        }

        res.redirect(`/auth/verify?email=${encodeURIComponent(email)}`)
        return
    }

    const otpMatches = await bcrypt.compare(otp, user.otpHash)

    if (!otpMatches) {
        res.status(400).render('auth/verify', {
            email: emailRaw,
            errors: ['Verification code is invalid.']
        })
        return
    }

    user.passwordHash = await bcrypt.hash(password, 10)
    user.isVerified = true
    user.otpHash = null
    user.otpExpiresAt = null
    await user.save()

    req.session.user = { id: user.id, email: user.email }
    const redirectTarget = req.session.redirectTo || '/articles'
    delete req.session.redirectTo

    setFlash(req, 'success', 'Your account is ready! You are now signed in.')
    res.redirect(redirectTarget)
}))

router.get('/login', redirectIfAuthenticated, (req, res) => {
    res.render('auth/login', {
        email: req.query.email || '',
        errors: []
    })
})

router.post('/login', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const emailRaw = req.body.email || ''
    const email = normalizeEmail(emailRaw)
    const password = req.body.password || ''
    const errors = []

    if (!email) {
        errors.push('Email is required.')
    }
    if (!password) {
        errors.push('Password is required.')
    }

    if (errors.length > 0) {
        res.status(400).render('auth/login', {
            email: emailRaw,
            errors
        })
        return
    }

    const user = await User.findOne({ where: { email } })

    if (!user || !user.isVerified || !user.passwordHash) {
        res.status(401).render('auth/login', {
            email: emailRaw,
            errors: ['Invalid email or password.']
        })
        return
    }

    const passwordMatches = await bcrypt.compare(password, user.passwordHash)

    if (!passwordMatches) {
        res.status(401).render('auth/login', {
            email: emailRaw,
            errors: ['Invalid email or password.']
        })
        return
    }

    req.session.user = { id: user.id, email: user.email }
    const redirectTarget = req.session.redirectTo || '/articles'
    delete req.session.redirectTo

    setFlash(req, 'success', 'Signed in successfully.')
    res.redirect(redirectTarget)
}))

router.post('/logout', asyncHandler(async(req, res) => {
    if (!req.session) {
        res.redirect('/auth/login')
        return
    }

    req.session.user = null

    req.session.destroy((error) => {
        if (error) {
            console.error('Failed to destroy session on logout:', error.message)
        }

        res.redirect('/auth/login')
    })
}))

// Password Reset Token Constants
const RESET_TOKEN_EXPIRY_HOURS = 1

const generateResetToken = () => {
    return crypto.randomBytes(32).toString('hex')
}

const sendPasswordResetEmail = async(email, resetToken, req) => {
    const from = process.env.EMAIL_FROM || 'DevOps Articles <noreply@tabeeb.email>'
    const appName = process.env.APP_NAME || 'DevOps Articles'
    
    // Build base URL from request or environment variable
    let baseUrl = process.env.APP_URL
    
    if (!baseUrl) {
        // Try to detect Railway domain
        if (process.env.RAILWAY_STATIC_URL) {
            baseUrl = process.env.RAILWAY_STATIC_URL
        } else if (process.env.RAILWAY_PUBLIC_DOMAIN) {
            baseUrl = `https://${process.env.RAILWAY_PUBLIC_DOMAIN}`
        } else {
            // Fallback to request headers
            const protocol = req.get('x-forwarded-proto') || req.protocol || 'https'
            const host = req.get('x-forwarded-host') || req.get('host')
            baseUrl = `${protocol}://${host}`
        }
    }
    
    const resetUrl = `${baseUrl}/auth/reset-password?token=${resetToken}`

    await sendMail({
        from,
        to: email,
        subject: `${appName} - Password Reset Request`,
        html: `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { text-align: center; padding: 20px 0; border-bottom: 1px solid #eee; }
                    .content { padding: 30px 0; }
                    .button { display: inline-block; background: #6366f1; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 600; }
                    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 14px; color: #666; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1 style="color: #6366f1; margin: 0;">🔐 Password Reset Request</h1>
                    </div>
                    
                    <div class="content">
                        <p>Hello,</p>
                        
                        <p>We received a request to reset your password for your <strong>${appName}</strong> account.</p>
                        
                        <p>Click the button below to create a new password:</p>
                        
                        <p style="text-align: center; margin: 30px 0;">
                            <a href="${resetUrl}" class="button">Reset My Password</a>
                        </p>
                        
                        <p><strong>This link will expire in ${RESET_TOKEN_EXPIRY_HOURS} hour${RESET_TOKEN_EXPIRY_HOURS > 1 ? 's' : ''}.</strong></p>
                        
                        <p>If you didn't request a password reset, you can safely ignore this email. Your password won't be changed.</p>
                        
                        <p>For security, this reset link can only be used once.</p>
                    </div>
                    
                    <div class="footer">
                        <p>If the button doesn't work, copy and paste this link into your browser:</p>
                        <p style="word-break: break-all; color: #6366f1;">${resetUrl}</p>
                        
                        <p style="margin-top: 20px;">
                            <strong>${appName}</strong><br>
                            This is an automated email, please don't reply.
                        </p>
                    </div>
                </div>
            </body>
            </html>
        `,
        text: [
            `Password Reset Request - ${appName}`,
            '',
            'We received a request to reset your password.',
            '',
            `Reset your password by clicking this link: ${resetUrl}`,
            '',
            `This link expires in ${RESET_TOKEN_EXPIRY_HOURS} hour${RESET_TOKEN_EXPIRY_HOURS > 1 ? 's' : ''}.`,
            '',
            'If you didn\'t request this reset, you can ignore this email.',
            'Your password will not be changed until you create a new one.',
            '',
            `- ${appName} Team`
        ].join('\n')
    })
}

// GET /auth/forgot-password - Show forgot password form
router.get('/forgot-password', redirectIfAuthenticated, (req, res) => {
    res.render('auth/forgot-password', {
        email: req.query.email || '',
        errors: []
    })
})

// POST /auth/forgot-password - Send password reset email
router.post('/forgot-password', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const emailRaw = req.body.email || ''
    const email = normalizeEmail(emailRaw)
    const errors = []

    if (!email || !/\S+@\S+\.\S+/.test(email)) {
        errors.push('Please provide a valid email address.')
    }

    if (errors.length > 0) {
        res.status(400).render('auth/forgot-password', {
            email: emailRaw,
            errors
        })
        return
    }

    try {
        const user = await User.findOne({ where: { email } })

        if (user && user.isVerified) {
            // Generate reset token
            const resetToken = generateResetToken()
            const resetTokenHash = await bcrypt.hash(resetToken, 10)

            // Save token to user
            user.resetTokenHash = resetTokenHash
            user.resetTokenExpiresAt = new Date(Date.now() + RESET_TOKEN_EXPIRY_HOURS * 60 * 60 * 1000)
            await user.save()

            // Send reset email
            await sendPasswordResetEmail(email, resetToken, req)
        }

        // Always show success message for security (don't reveal if email exists)
        setFlash(req, 'success', 'If an account with that email exists, we\'ve sent password reset instructions.')
        res.redirect('/auth/forgot-password')
    } catch (error) {
        console.error('Failed to send password reset email:', error.message)
        setFlash(req, 'danger', 'Unable to process password reset request. Please try again later.')
        res.redirect('/auth/forgot-password')
    }
}))

// GET /auth/reset-password - Show reset password form
router.get('/reset-password', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const token = req.query.token

    if (!token) {
        setFlash(req, 'danger', 'Invalid or missing reset token.')
        res.redirect('/auth/forgot-password')
        return
    }

    // Find user with valid token
    const users = await User.findAll({
        where: {
            resetTokenExpiresAt: {
                [require('sequelize').Op.gt]: new Date()
            }
        }
    })

    let validUser = null
    for (const user of users) {
        if (user.resetTokenHash && await bcrypt.compare(token, user.resetTokenHash)) {
            validUser = user
            break
        }
    }

    if (!validUser) {
        setFlash(req, 'danger', 'Invalid or expired reset token. Please request a new password reset.')
        res.redirect('/auth/forgot-password')
        return
    }

    res.render('auth/reset-password', {
        token,
        errors: []
    })
}))

// POST /auth/reset-password - Process password reset
router.post('/reset-password', redirectIfAuthenticated, asyncHandler(async(req, res) => {
    const token = req.body.token
    const password = req.body.password || ''
    const confirmPassword = req.body.confirmPassword || ''
    const errors = []

    // Validation
    if (!token) {
        errors.push('Invalid reset token.')
    }

    if (!password || password.length < 8) {
        errors.push('Password must be at least 8 characters long.')
    }

    if (password !== confirmPassword) {
        errors.push('Passwords do not match.')
    }

    if (errors.length > 0) {
        res.status(400).render('auth/reset-password', {
            token,
            errors
        })
        return
    }

    try {
        // Find user with valid token
        const users = await User.findAll({
            where: {
                resetTokenExpiresAt: {
                    [require('sequelize').Op.gt]: new Date()
                }
            }
        })

        let validUser = null
        for (const user of users) {
            if (user.resetTokenHash && await bcrypt.compare(token, user.resetTokenHash)) {
                validUser = user
                break
            }
        }

        if (!validUser) {
            setFlash(req, 'danger', 'Invalid or expired reset token. Please request a new password reset.')
            res.redirect('/auth/forgot-password')
            return
        }

        // Update password and clear reset token
        const passwordHash = await bcrypt.hash(password, 10)
        validUser.passwordHash = passwordHash
        validUser.resetTokenHash = null
        validUser.resetTokenExpiresAt = null
        await validUser.save()

        setFlash(req, 'success', 'Password updated successfully! You can now sign in with your new password.')
        res.redirect('/auth/login')
    } catch (error) {
        console.error('Failed to reset password:', error.message)
        setFlash(req, 'danger', 'Unable to reset password. Please try again.')
        res.status(500).render('auth/reset-password', {
            token,
            errors: ['Unable to reset password. Please try again.']
        })
    }
}))

module.exports = router
