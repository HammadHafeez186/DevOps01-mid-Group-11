require('dotenv').config()

module.exports = {
    development: {
        username: process.env.DB_USERNAME || 'postgres',
        password: process.env.DB_PASSWORD || 'Hammad1234',
        database: process.env.DB_NAME || 'devops_db',
        host: process.env.DB_HOST || '127.0.0.1',
        port: process.env.DB_PORT || 5433,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: false
        }
    },
    test: {
        username: process.env.TEST_DB_USERNAME || 'devops_user',
        password: process.env.TEST_DB_PASSWORD || 'secure_password_123',
        database: process.env.TEST_DB_NAME || 'devops_test_db',
        host: process.env.TEST_DB_HOST || 'postgres-test',
        port: process.env.TEST_DB_PORT || 5432,
        dialect: 'postgres',
        dialectOptions: {
            connectTimeout: 60000,
            ssl: false
        }
    },
    docker: {
        username: process.env.DB_USERNAME || 'postgres',
        password: process.env.DB_PASSWORD || 'Hammad1234',
        database: process.env.DB_NAME || 'devops_db',
        host: process.env.DB_HOST || 'host.docker.internal',
        port: process.env.DB_PORT || 5433,
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
