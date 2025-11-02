'use strict'

const nodemailer = require('nodemailer')

let transportPromise

const buildTransport = async() => {
    if (transportPromise) {
        return transportPromise
    }

    const {
        EMAIL_HOST,
        EMAIL_PORT,
        EMAIL_USER,
        EMAIL_PASS,
        EMAIL_SECURE
    } = process.env

    if (EMAIL_HOST && EMAIL_PORT && EMAIL_USER && EMAIL_PASS) {
        transportPromise = Promise.resolve(
            nodemailer.createTransport({
                host: EMAIL_HOST,
                port: Number(EMAIL_PORT),
                secure: EMAIL_SECURE === 'true',
                connectionTimeout: 10000, // 10 seconds
                greetingTimeout: 5000,    // 5 seconds
                socketTimeout: 10000,     // 10 seconds
                auth: {
                    user: EMAIL_USER,
                    pass: EMAIL_PASS
                },
                // Gmail specific settings
                ...(EMAIL_HOST === 'smtp.gmail.com' && {
                    service: 'gmail',
                    tls: {
                        rejectUnauthorized: false
                    }
                })
            })
        )
        return transportPromise
    }

    transportPromise = nodemailer.createTestAccount()
        .then((testAccount) => {
            console.warn(
                'Email credentials are not configured. Using a Nodemailer Ethereal test account instead.'
            )

            return nodemailer.createTransport({
                host: testAccount.smtp.host,
                port: testAccount.smtp.port,
                secure: testAccount.smtp.secure,
                auth: {
                    user: testAccount.user,
                    pass: testAccount.pass
                }
            })
        })
        .catch((error) => {
            console.error('Failed to create test email account:', error.message)
            return nodemailer.createTransport({
                streamTransport: true,
                newline: 'unix',
                buffer: true
            })
        })

    return transportPromise
}

const sendMail = async(options) => {
    const transporter = await buildTransport()
    const info = await transporter.sendMail(options)

    const previewUrl = nodemailer.getTestMessageUrl(info)
    if (previewUrl) {
        console.log(`Email preview available at: ${previewUrl}`)
    } else if (transporter.options.streamTransport && info && info.message) {
        console.log('Mock email content:\n', info.message.toString())
    }

    return info
}

module.exports = {
    sendMail
}
