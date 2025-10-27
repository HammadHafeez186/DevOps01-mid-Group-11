const { Sequelize } = require('sequelize')

// Database connection configuration
const sequelize = new Sequelize('devops_db', 'postgres', 'Hammad1234', {
    host: 'localhost',
    port: 5433,
    dialect: 'postgres',
    logging: console.log
})

async function testConnection() {
    try {
        console.log('Testing database connection...')
        await sequelize.authenticate()
        console.log('✅ Database connection successful!')

        // Test query
        const [results] = await sequelize.query('SELECT version()')
        console.log('PostgreSQL version:', results[0].version)
    } catch (error) {
        console.error('❌ Database connection failed:')
        console.error('Error:', error.message)
        console.error('Details:', {
            host: 'localhost',
            port: 5433,
            database: 'devops_db',
            username: 'postgres'
        })
    } finally {
        await sequelize.close()
    }
}

testConnection()
