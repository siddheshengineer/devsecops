# Build stage
FROM node:20-alpine AS Build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# App stage
FROM nginx:alpine
COPY --from=Build /app/dist /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
