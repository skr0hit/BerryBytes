# ---- Base Stage ----
# Use a specific Node.js version for reproducibility
FROM node:18-alpine AS base
WORKDIR /app

# Copy package files
COPY package*.json ./

# ---- Dependencies Stage ----
# Install production dependencies
FROM base AS dependencies
RUN npm ci --omit=dev

# ---- Production Stage ----
# Use a minimal, hardened base image
FROM node:18-alpine AS production
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy installed dependencies and source code
COPY --from=dependencies /app/node_modules ./node_modules
COPY index.js .

# Expose the application port
EXPOSE 3000

# Healthcheck to ensure the application is responsive
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O - http://localhost:3000/healthz || exit 1

# Command to run the application
CMD [ "node", "index.js" ]