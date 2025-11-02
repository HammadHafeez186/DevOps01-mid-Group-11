'use strict'

const path = require('path')
const fs = require('fs')
const os = require('os')
const multer = require('multer')

const ensureDirSync = (dirPath) => {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true })
    }
}

const resolveUploadBaseDir = () => {
    const candidates = []

    if (process.env.UPLOAD_BASE_DIR) {
        candidates.push({
            label: 'UPLOAD_BASE_DIR',
            dir: path.resolve(process.env.UPLOAD_BASE_DIR)
        })
    }

    if (process.env.NODE_ENV !== 'production') {
        candidates.push({
            label: 'project uploads directory',
            dir: path.join(process.cwd(), 'uploads')
        })
    }

    candidates.push({
        label: 'system temp directory',
        dir: path.join(os.tmpdir(), 'app-uploads')
    })

    for (const candidate of candidates) {
        try {
            ensureDirSync(candidate.dir)
            fs.accessSync(candidate.dir, fs.constants.W_OK)
            return candidate.dir
        } catch (error) {
            console.warn(
                `Upload directory ${candidate.label} at ${candidate.dir} is not writable: ${error.code || error.message}`
            )
        }
    }

    throw new Error('Unable to locate a writable upload directory for uploads')
}

const baseUploadDir = resolveUploadBaseDir()

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const subDir = file.mimetype.startsWith('image/') ? 'images' : 'documents'
        const absolutePath = path.join(baseUploadDir, subDir)
        ensureDirSync(absolutePath)
        cb(null, absolutePath)
    },
    filename: (req, file, cb) => {
        const timestamp = Date.now()
        const sanitizedOriginal = file.originalname.replace(/\s+/g, '-')
        cb(null, `${timestamp}-${sanitizedOriginal}`)
    }
})

const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true)
        return
    }

    const allowedDocuments = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ]

    if (allowedDocuments.includes(file.mimetype)) {
        cb(null, true)
        return
    }

    cb(new Error('Unsupported file type. Images, PDFs, and Word documents only.'))
}

const upload = multer({
    storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10 MB
    },
    fileFilter
})

module.exports = {
    upload,
    baseUploadDir
}
