'use strict'

const wantsJson = (req) => req.accepts(['html', 'json']) === 'json'

const requireAuth = (req, res, next) => {
    if (req.session && req.session.user) {
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
