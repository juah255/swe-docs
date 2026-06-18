FROM python:3.12-slim AS builder

WORKDIR /app

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY mkdocs.yml .
COPY src ./src
RUN mkdocs build --strict --site-dir /site

FROM nginx:1.27-alpine

COPY --from=builder /site /usr/share/nginx/html

EXPOSE 80
