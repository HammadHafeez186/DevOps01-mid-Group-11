# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory in container
WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies (including dev dependencies for migrations)
RUN npm ci && npm cache clean --force

# Install netcat for database connection checking
RUN apk add --no-cache netcat-openbsd

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -G nodejs -u 1001

# Copy application code
COPY --chown=nodeuser:nodejs . .

# Create uploads directory with correct permissions and make scripts executable
RUN mkdir -p /app/uploads/images /app/uploads/documents && \
    chown -R nodeuser:nodejs /app/uploads && \
    chmod +x scripts/docker-start.sh 2>/dev/null || true

# Switch to non-root user
USER nodeuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Start the application with migrations
CMD ["./scripts/docker-start.sh"]
