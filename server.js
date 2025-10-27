// Railway deployment debugging
console.log('🚂 Railway Environment Check:')
console.log('NODE_ENV:', process.env.NODE_ENV)
console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL)
console.log('PORT:', process.env.PORT)

const app = require('./app')
const http = require('http')

const PORT = process.env.PORT || 3000
const server = http.createServer(app)

server.listen(PORT, () => {
    console.log(`Server listening on http://localhost:${PORT}`)
})
