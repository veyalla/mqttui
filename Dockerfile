# First Stage: Build the Rust binary
FROM rust:alpine as builder

RUN apk update && \
    apk upgrade && \
    apk add --no-cache musl-dev

# Create a new Rust project
WORKDIR /src
COPY . .

# Build the Rust binary
RUN cargo build --release

# Second Stage: Create a minimal runtime image
FROM alpine:latest

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates

# Create a new user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the binary from the builder stage
COPY --from=builder /src/target/release/mqttui /usr/local/bin/mqttui

# Change the ownership of the binary to the new user
RUN chown appuser:appgroup /usr/local/bin/mqttui

# Switch to the new user
USER appuser

# Set the binary as the entry point of the container
ENTRYPOINT ["/usr/local/bin/mqttui"]
