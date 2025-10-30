const app = require('./app')
const http = require('http')
const { sequelize } = require('./models')

const PORT = process.env.PORT || 3000

async function start() {
    try {
        await sequelize.authenticate()
        // Ensure tables exist in environments where migrations aren't run (e.g., Railway)
        await sequelize.sync()
    } catch (err) {
        console.error('Database initialization failed:', err.message)
        process.exit(1)
    }

    const server = http.createServer(app)

    server.on('error', (error) => {
        console.error('Server failed to start:', error.message)
        process.exit(1)
    })

    server.listen(PORT, () => {
        console.log(`Server listening on http://localhost:${PORT}`)
    })
}

start()
