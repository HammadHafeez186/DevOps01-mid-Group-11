// Load environment variables from .env file if available
try {
    require('dotenv').config()
} catch (error) {
    // dotenv not available or .env file not found - use environment variables directly
    console.log('dotenv not available, using environment variables directly')
}

module.exports = {
    development: {
        // All values come from environment variables; no hardcoded secrets here.
        username: process.env.DB_USERNAME || null,
        password: process.env.DB_PASSWORD || null,
        database: process.env.DB_NAME || null,
        host: process.env.DB_HOST || null,
        port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: false
        }
    },
    test: {
        // Use DATABASE_URL if available (Railway/production), otherwise individual env vars
        use_env_variable: process.env.DATABASE_URL ? 'DATABASE_URL' : undefined,
        username: process.env.TEST_DB_USERNAME || process.env.DB_USERNAME || null,
        password: process.env.TEST_DB_PASSWORD || process.env.DB_PASSWORD || null,
        database: process.env.TEST_DB_NAME || process.env.DB_NAME || null,
        host: process.env.TEST_DB_HOST || process.env.DB_HOST || null,
        port: process.env.TEST_DB_PORT ? Number(process.env.TEST_DB_PORT) : (process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined),
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: process.env.DATABASE_URL ? { require: true, rejectUnauthorized: false } : false
        }
    },
    docker: {
        username: process.env.DB_USERNAME || null,
        password: process.env.DB_PASSWORD || null,
        database: process.env.DB_NAME || null,
        host: process.env.DB_HOST || null,
        port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: false
        }
    },
    production: {
        use_env_variable: 'DATABASE_URL',
        dialect: 'postgres',
        dialectOptions: {
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        }
    }
}
