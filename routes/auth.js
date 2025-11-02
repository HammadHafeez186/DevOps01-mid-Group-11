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

module.exports = router
