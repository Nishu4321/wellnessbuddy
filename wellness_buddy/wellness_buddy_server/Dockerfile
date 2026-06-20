FROM dart:stable AS build

WORKDIR /app

# Copy the server package
COPY packages/wellnessbuddy_server/ .

# Get dependencies
RUN dart pub get

# Compile to native executable
RUN dart compile exe bin/main.dart -o bin/server

# Minimal runtime image
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=build /app/bin/server ./bin/server
COPY --from=build /app/config/ ./config/

EXPOSE 8080
CMD ["./bin/server"]