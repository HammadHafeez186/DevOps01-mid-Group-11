const express = require('express')
const morgan = require('morgan')
const methodOverride = require('method-override')
const articlesRouter = require('./routes/articles')

const app = express()
const isProduction = process.env.NODE_ENV === 'production'

app.disable('x-powered-by')
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(methodOverride('_method'))
app.use(morgan(isProduction ? 'combined' : 'dev'))

app.set('view engine', 'ejs')

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() })
})

app.get('/', (req, res) => {
    res.redirect('/articles')
})

app.use('/articles', articlesRouter)

app.use((req, res) => {
    const message = 'Route Not Found'
    const details = 'The page you requested could not be found.'

    if (req.accepts(['html', 'json']) === 'json') {
        res.status(404).json({ message, details })
        return
    }

    res.status(404).render('error', { message, error: details })
})

app.use((err, req, res, next) => { // eslint-disable-line no-unused-vars
    const status = err.status || 500
    const message = err.message || 'Internal Server Error'
    const details = Array.isArray(err.details)
        ? err.details.join(', ')
        : err.details || 'An unexpected error occurred.'

    if (req.accepts(['html', 'json']) === 'json') {
        const payload = { message }

        if (Array.isArray(err.details)) {
            payload.details = err.details
        } else if (details !== 'An unexpected error occurred.') {
            payload.details = details
        }

        res.status(status).json(payload)
        return
    }

    res.status(status).render('error', { message, error: details })
})

module.exports = app
