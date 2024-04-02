# Common stage
FROM node:18-alpine AS base

WORKDIR /app

COPY --chown=node:node package.json package-lock.json ./

RUN npm ci --only=production && npm cache clean --force

USER node

## Build stage
## Covers dev dependencies that's not gonna be a part of the common stage
FROM node:18-alpine AS build

WORKDIR /app

COPY --chown=node:node . .

RUN npm ci

RUN npm run build

USER node

# Production image stage
FROM node:18-alpine

COPY --chown=node:node --from=base /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist

USER node

CMD ["node", "dist/main.js"]