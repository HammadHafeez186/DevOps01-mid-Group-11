const express = require('express')
const router = express.Router()
const { requireAdmin } = require('../middleware/admin')
const { Article, User } = require('../models')
const asyncHandler = require('../utils/asyncHandler')

// Admin Dashboard
router.get('/', requireAdmin, asyncHandler(async(req, res) => {
    const articleCount = await Article.count()
    const userCount = await User.count()
    const adminCount = await User.count({ where: { isAdmin: true } })

    res.render('admin/dashboard', {
        articleCount,
        userCount,
        adminCount
    })
}))

// Advertisement Management
router.get('/ads', requireAdmin, (req, res) => {
    res.render('admin/ads', {
        ads: [] // Will implement Advertisement model later
    })
})

module.exports = router
