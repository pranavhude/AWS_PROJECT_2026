FROM node:22-alpine

ENV NODE_ENV=production
ENV PORT=80

WORKDIR /app

COPY package.json ./
COPY app.js ./

EXPOSE 80

USER node

CMD ["npm", "start"]
