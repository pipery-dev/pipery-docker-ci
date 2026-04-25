# Stage 1: builder
FROM alpine:3.20 AS builder
RUN apk add --no-cache bash
WORKDIR /app
COPY build.sh .
RUN chmod +x build.sh && ./build.sh

# Stage 2: runtime
FROM alpine:3.20
RUN apk add --no-cache bash
COPY --from=builder /app/output /output
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
