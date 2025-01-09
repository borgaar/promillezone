FROM node:current-alpine AS build

RUN apk add openssl

WORKDIR /build

COPY . .

RUN npm install -g pnpm

RUN pnpm i --frozen-lockfile

ENV SKIP_ENV_VALIDATION=1

RUN pnpm build

FROM node:current-alpine AS runner

WORKDIR /app

RUN apk add openssl
# Prisma is used in prod deployment
RUN npm install -g prisma

COPY --from=build /build/.next/standalone ./
RUN rm -f .env
COPY --from=build /build/.next/static ./.next/static/
COPY --from=build /build/prisma ./prisma/
COPY --from=build /build/public ./public/

EXPOSE 3000
ENV PORT=3000

ENV NEXT_TELEMETRY_DISABLED=1

CMD [ "node", "server.js" ]
