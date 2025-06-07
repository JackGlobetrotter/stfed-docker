# ---- Builder stage ----
FROM rust:latest AS builder

RUN apt-get update && apt-get install -y git curl

# Install rustup (safe fallback)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# Clone and build
WORKDIR /app
RUN git clone https://github.com/desbma/stfed.git
WORKDIR /app/stfed
RUN cargo build --release

# ---- Final minimal image ----
FROM rust:slim-bookworm

# Runtime deps
RUN apt-get update && apt-get install -y ca-certificates 
#libssl-dev

# App location
WORKDIR /usr/local/bin

# Copy binary
COPY --from=builder /app/stfed/target/release/stfed ./stfed
RUN chmod +x ./stfed

# Set config path per XDG spec
ENV XDG_CONFIG_HOME="/config"
ENV HOME="/config"

COPY prerun.sh prerun.sh
RUN chmod +x prerun.sh

VOLUME /config/stfed /config/syncthing

CMD ["/bin/sh", "-c", "/usr/local/bin/prerun.sh && /usr/local/bin/stfed"]

