# ---------- Build stage ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY backend/package*.json ./     
RUN npm ci --omit=dev
COPY backend ./                   
RUN npm run build                  

# ---------- Runtime stage ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app /app
EXPOSE 3000
CMD ["node","dist/main.js"]
