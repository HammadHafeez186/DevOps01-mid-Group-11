'use strict'

const { User } = require('../models')

const wantsJson = (req) => req.accepts(['html', 'json']) === 'json'

const requireAuth = async(req, res, next) => {
    if (req.session && req.session.user) {
        // Check if user is blocked
        try {
            const user = await User.findByPk(req.session.user.id)
            if (user && user.isBlocked) {
                // Clear session for blocked user
                req.session.destroy()

                if (wantsJson(req)) {
                    res.status(403).json({ message: 'Your account has been blocked.' })
                    return
                }

                res.status(403).render('auth/blocked')
                return
            }
        } catch (error) {
            console.error('Error checking user status:', error)
        }

        next()
        return
    }

    if (wantsJson(req)) {
        res.status(401).json({ message: 'Authentication required.' })
        return
    }

    if (req.session) {
        req.session.redirectTo = req.originalUrl
        req.session.flash = {
            type: 'warning',
            message: 'Please sign in to continue.'
        }
    }

    res.redirect('/auth/login')
}

const redirectIfAuthenticated = (req, res, next) => {
    if (req.session && req.session.user) {
        res.redirect('/articles')
        return
    }

    next()
}

module.exports = {
    requireAuth,
    redirectIfAuthenticated
}
