FROM python:3.9-alpine3.13

# enables proper stdout flushing
ENV PYTHONUNBUFFERED yes
# no .pyc files
ENV PYTHONDONTWRITEBYTECODE yes

# pip optimizations
ENV PIP_NO_CACHE_DIR yes
ENV PIP_DISABLE_PIP_VERSION_CHECK yes

WORKDIR /code

COPY requirements.txt .

RUN apk add --no-cache \
    git \
    # Pillow
    # refer to: https://pillow.readthedocs.io/en/stable/installation.html#external-libraries
    # and: https://github.com/python-pillow/docker-images/blob/master/alpine/Dockerfile
    zlib-dev \
    jpeg-dev \
    openjpeg-dev \
    freetype-dev \
    # gif optimizer
    gifsicle \
    # webp support
    libwebp-dev \
    # Font for trocr
    ttf-dejavu \
    && apk add --no-cache --virtual .build-deps \
    # Required for almost everything
    gcc \
    musl-dev \
    && pip install -U pip \
    && pip install -U -r requirements.txt \
    && apk del --purge .build-deps

ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID -S pink \
    && adduser -u $UID -S pink -G pink \
    && chown -R pink:pink /code

USER pink

# at this point .dockerignore might be more appropriate
COPY --chown=pink:pink pink pink
COPY --chown=pink:pink dbschema dbschema
COPY --chown=pink:pink templates templates

ENTRYPOINT ["python", "-m", "pink"]
