// Detect Railway environment
const isRailway = process.env.RAILWAY_ENVIRONMENT || process.env.PORT
const isProduction = process.env.NODE_ENV === 'production' || isRailway

if (!isProduction) {
    try {
        require('dotenv').config()
        console.log('✅ Loaded .env file for development')
    } catch (error) {
        console.log('⚠️ No .env file found - using environment variables directly')
    }
} else {
    console.log('🚂 Production/Railway mode - using Railway environment variables only')
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
        use_env_variable: process.env.DATABASE_URL && process.env.NODE_ENV === 'production' ? 'DATABASE_URL' : undefined,
        username: process.env.TEST_DB_USERNAME || process.env.DB_USERNAME || null,
        password: process.env.TEST_DB_PASSWORD || process.env.DB_PASSWORD || null,
        database: process.env.TEST_DB_NAME || process.env.DB_NAME || null,
        host: process.env.TEST_DB_HOST || process.env.DB_HOST || null,
        port: process.env.TEST_DB_PORT ? Number(process.env.TEST_DB_PORT) : (process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined),
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: process.env.DATABASE_URL && process.env.NODE_ENV === 'production' ? { require: true, rejectUnauthorized: false } : false
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
        // Railway PostgreSQL connection - use DATABASE_URL if available
        use_env_variable: process.env.DATABASE_URL ? 'DATABASE_URL' : undefined,
        username: process.env.PGUSER || 'postgres',
        password: process.env.PGPASSWORD || 'ivimUeIKQLYmRUkRuWYMxgFKgUgHYMHh',
        database: process.env.PGDATABASE || 'railway',
        host: process.env.PGHOST || 'mainline.proxy.rlwy.net',
        port: process.env.PGPORT ? parseInt(process.env.PGPORT) : 10238,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        },
        logging: console.log // Enable logging to see connection attempts
    },
    // Add Railway-specific environment
    railway: {
        use_env_variable: process.env.DATABASE_URL ? 'DATABASE_URL' : undefined,
        username: 'postgres',
        password: 'ivimUeIKQLYmRUkRuWYMxgFKgUgHYMHh',
        database: 'railway',
        host: 'mainline.proxy.rlwy.net',
        port: 10238,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        },
        logging: console.log
    }
}
