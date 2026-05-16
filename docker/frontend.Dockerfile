FROM node:16-alpine AS build

WORKDIR /app

ARG VITE_BASE_PATH=http://127.0.0.1
ARG VITE_SERVER_PORT=20011

ENV VITE_BASE_PATH=${VITE_BASE_PATH}
ENV VITE_SERVER_PORT=${VITE_SERVER_PORT}

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

FROM nginx:1.27-alpine AS final

COPY docker/nginx.compose.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
