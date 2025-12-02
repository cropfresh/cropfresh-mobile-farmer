FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build apk --release
FROM scratch
COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /
