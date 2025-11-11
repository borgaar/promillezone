FROM rust:1-alpine AS base

FROM base AS builder

WORKDIR /build

RUN apk add --no-cache \
    openssl-libs-static \
    postgresql-dev

COPY . .

ARG CARGO_BUILD_JOBS="default"

RUN cargo build ${CARGO_BUILD_JOBS:+--jobs $CARGO_BUILD_JOBS} --release

FROM base AS runner

RUN adduser -D -u 1000 nonroot

USER nonroot:nonroot

COPY --from=builder --chown=nonroot:nonroot /build/target/release/promillezone /usr/local/bin/promillezone

CMD ["promillezone"]