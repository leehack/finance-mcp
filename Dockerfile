# Use Google's official Dart image.
# https://hub.docker.com/_/dart
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Build a minimal release image.
FROM debian:stable-slim

# Copy the compiled binary.
COPY --from=build /app/bin/server /app/bin/server

# Expose the default port for HTTP transport.
EXPOSE 3000

# Set the entrypoint to the server binary.
ENTRYPOINT ["/app/bin/server"]

# Default to running the HTTP transport.
CMD ["--transport", "http", "--host", "0.0.0.0", "--port", "3000"]
