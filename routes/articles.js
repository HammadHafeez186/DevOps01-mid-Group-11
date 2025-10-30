'use strict'

const express = require('express')
const { Article } = require('../models')

const router = express.Router()

const wantsJson = (req) => req.accepts(['html', 'json']) === 'json'

const normalizeApproved = (value) => {
    if (typeof value === 'string') {
        return ['true', '1', 'yes', 'on'].includes(value.toLowerCase())
    }

    return Boolean(value)
}

const asyncHandler = (handler) => (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next)
}

router.get('/', asyncHandler(async(req, res) => {
    const articles = await Article.findAll({
        order: [['createdAt', 'DESC']]
    })

    if (wantsJson(req)) {
        res.status(200).json(articles)
        return
    }

    res.status(200).render('index', { articles })
}))

router.get('/create', (req, res) => {
    res.render('create')
})

router.get('/update/:id', asyncHandler(async(req, res, next) => {
    const article = await Article.findByPk(req.params.id)

    if (!article) {
        const error = new Error('Article Not Found')
        error.status = 404
        error.details = 'The article you are trying to update does not exist.'
        return next(error)
    }

    res.render('update', { article })
}))

router.get('/:id', asyncHandler(async(req, res, next) => {
    const article = await Article.findByPk(req.params.id)

    if (!article) {
        const error = new Error('Article Not Found')
        error.status = 404
        error.details = 'The article you are looking for could not be located.'
        return next(error)
    }

    if (wantsJson(req)) {
        res.status(200).json(article)
        return
    }

    res.status(200).render('show', {
        id: article.id,
        title: article.title,
        body: article.body,
        approved: article.approved,
        createdAt: article.createdAt,
        updatedAt: article.updatedAt
    })
}))

router.post('/', asyncHandler(async(req, res, next) => {
    const payload = {
        title: req.body.title,
        body: req.body.body,
        approved: normalizeApproved(req.body.approved)
    }

    try {
        const article = await Article.create(payload)

        if (wantsJson(req)) {
            res.status(201).json(article)
            return
        }

        res.redirect('/articles')
    } catch (error) {
        if (error.name === 'SequelizeValidationError') {
            error.status = 400
            error.details = error.errors.map((validationError) => validationError.message)
        }

        next(error)
    }
}))

router.put('/:id', asyncHandler(async(req, res, next) => {
    const article = await Article.findByPk(req.params.id)

    if (!article) {
        const error = new Error('Article Not Found')
        error.status = 404
        error.details = 'The article you are trying to update does not exist.'
        return next(error)
    }

    const updates = {
        title: req.body.title,
        body: req.body.body,
        approved: normalizeApproved(req.body.approved)
    }

    try {
        await article.update(updates)

        if (wantsJson(req)) {
            res.status(200).json(article)
            return
        }

        res.redirect('/articles')
    } catch (error) {
        if (error.name === 'SequelizeValidationError') {
            error.status = 400
            error.details = error.errors.map((validationError) => validationError.message)
        }

        next(error)
    }
}))

router.delete('/:id', asyncHandler(async(req, res, next) => {
    const article = await Article.findByPk(req.params.id)

    if (!article) {
        const error = new Error('Article Not Found')
        error.status = 404
        error.details = 'The article you are trying to delete does not exist.'
        return next(error)
    }

    await article.destroy()

    if (wantsJson(req)) {
        res.status(204).end()
        return
    }

    res.redirect('/articles')
}))

module.exports = router
