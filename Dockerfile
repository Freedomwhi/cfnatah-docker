# ---- builder ----
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache ca-certificates
WORKDIR /src
COPY cfnat.go go.mod ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/cfnat .

# ---- runtime ----
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata \
 && adduser -D -g '' appuser \
 && mkdir -p /app && chown -R appuser:appuser /app
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /out/cfnat /app/cfnat
USER appuser
EXPOSE 1234
ENTRYPOINT ["/app/cfnat"]
CMD ["-addr", "0.0.0.0:1234"]
