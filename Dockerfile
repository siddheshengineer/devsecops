# buildtime variables
ARG NODE_VERSION=20-alpine
ARG NGINX_VERSION=alpine

# Build stage
FROM node:${NODE_VERSION} AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# App stage
FROM nginx:${NGINX_VERSION}

# runtime variables
ENV USER_NAME=secUser
ENV GROUP_NAME=secGroup
ENV USER_ID=8754
ENV GROUP_ID=4876
ENV APP_PORT=8080

# Custom user
RUN addgroup -g ${GROUP_ID} -S ${GROUP_NAME} && adduser -u ${USER_ID} -S ${USER_NAME} -G ${GROUP_NAME}

# Copy build files from build stages
COPY --from=build /app/dist /usr/share/nginx/html

# Change ownership
RUN chown -R ${USER_NAME}:${GROUP_NAME} /usr/share/nginx/html

# Fix permissions for Nginx cache directories
RUN mkdir -p /var/cache/nginx /var/run/ var/log/nginx && \
    chown -R ${USER_NAME}:${GROUP_NAME} /var/cache/nginx /var/run/ var/log/nginx

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Switch to non-root user
USER ${USER_NAME}

EXPOSE ${APP_PORT}
ENTRYPOINT ["nginx", "-g", "daemon off;"]
