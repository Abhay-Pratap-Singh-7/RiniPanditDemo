# Build Stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency specifications
COPY backend/package*.json ./
RUN npm ci

# Copy backend source code and build TypeScript
COPY backend/ ./
RUN npm run build

# Production Stage
FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5001

# Install only production dependencies
COPY backend/package*.json ./
RUN npm ci --only=production

# Copy compiled JavaScript output
COPY --from=builder /app/dist ./dist

EXPOSE 5001

CMD ["node", "dist/server.js"]
