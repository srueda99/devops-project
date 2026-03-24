# --- BUILDER STAGE ---
FROM node:24-alpine AS builder
# Set environment variables
ARG API_URL
ENV VITE_API_URL=$API_URL
# Set working directory
WORKDIR /app
# Install dependencies with ci for production installs
COPY package.json package-lock.json ./
RUN npm ci
# Copy the source code
COPY . .
# Compile the static assets
RUN npm run build


# --- RUNTIME STAGE ---
FROM nginx:alpine
# Create the PID file and set permissions to the nginx user
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d
# Copy the compiled assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Switch to a non-root user
USER nginx
# Expose the port
EXPOSE 8080
# Run the nginx application
CMD ["nginx", "-g", "daemon off;"]