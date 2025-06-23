# ---------- Build stage ----------
FROM dart:stable AS builder               
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version                       

WORKDIR /app
COPY frontend/pubspec.* ./
RUN flutter pub get
COPY frontend .
RUN flutter build web --release

# ---------- Runtime stage ----------
FROM nginx:1.25-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
