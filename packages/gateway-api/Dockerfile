# syntax=docker/dockerfile:1
FROM node:18-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/gateway-api ./packages/gateway-api
RUN npm ci --omit=dev --workspace=gateway-api --cache /tmp/empty-cache
EXPOSE 4003
CMD [ "npm", "start", "--workspace=gateway-api" ]
