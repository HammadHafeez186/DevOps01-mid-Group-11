'use strict'

const { Resend } = require('resend')

/**
 * Secure email service using Resend API
 * This is Railway-compatible and doesn't have SMTP timeout issues
 */
const getEmailService = () => {
    const apiKey = process.env.RESEND_API_KEY

    if (apiKey) {
        return new Resend(apiKey)
    }

    console.warn('RESEND_API_KEY not configured. Email sending will be mocked.')
    return null
}

/**
 * Send email using Resend API or mock service
 * @param {Object} options - Email options
 * @param {string} options.to - Recipient email
 * @param {string} options.subject - Email subject
 * @param {string} options.text - Plain text content
 * @param {string} options.html - HTML content (optional)
 * @param {string} options.from - Sender email (optional)
 */
const sendMail = async(options) => {
    const resend = getEmailService()

    if (resend) {
        try {
            const emailData = {
                from: options.from || process.env.EMAIL_FROM || 'DevOps Articles <noreply@resend.dev>',
                to: options.to,
                subject: options.subject,
                text: options.text
            }

            // Add HTML content if provided
            if (options.html) {
                emailData.html = options.html
            }

            const result = await resend.emails.send(emailData)

            if (result.error) {
                throw new Error(result.error.message || 'Unknown Resend API error')
            }

            console.log('✅ Email sent successfully via Resend API:', result.data?.id)
            return result
        } catch (error) {
            console.error('❌ Resend API error:', error.message)
            throw new Error(`Email service failed: ${error.message}`)
        }
    } else {
        // Mock email service for development/testing
        console.log('📧 MOCK EMAIL (Resend not configured):')
        console.log(`To: ${options.to}`)
        console.log(`Subject: ${options.subject}`)
        console.log(`Content: ${options.text}`)
        console.log('---')

        return {
            data: { id: 'mock-email-' + Date.now() },
            error: null
        }
    }
}

module.exports = {
    sendMail
}
