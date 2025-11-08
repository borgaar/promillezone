FROM rust:slim-trixie AS base

FROM base AS builder

WORKDIR /build

COPY . .

RUN apt update && apt-get install -y libpq-dev

RUN cargo build --release

FROM base AS runner

RUN useradd -m -u 1000 nonroot

USER nonroot:nonroot

COPY --from=builder --chown=nonroot:nonroot /build/target/release/promillezone /usr/local/bin/promillezone

CMD ["promillezone"]