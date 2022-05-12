# Build the membarrier check tool.
FROM alpine:3.12
WORKDIR /tmp
COPY membarrier_check.c .
RUN apk --no-cache add build-base linux-headers
RUN gcc -static -o membarrier_check membarrier_check.c
RUN strip membarrier_check

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.15-v3.5.8

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define working directory.
WORKDIR /tmp

# Install Chromium.
RUN \
     add-pkg chromium

# Install extra packages.
RUN \
    add-pkg \
        desktop-file-utils \
        adwaita-icon-theme \
        ttf-dejavu \
        ffmpeg-libs \
        # The following package is used to send key presses to the X process.
        xdotool

# Adjust the openbox config.
RUN \
    # Maximize only the main window.
    sed-patch 's/<application type="normal">/<application type="normal" title="Chromium">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" title="Chromium">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/chromium/chromium/main/chrome/app/theme/chromium/product_logo_64.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=0 /tmp/membarrier_check /usr/bin/

# Set environment variables.
ENV APP_NAME="Chromium"

# Metadata.
LABEL \
      org.label-schema.name="chromium" \
      org.label-schema.description="Docker container for Chromium" \
      org.label-schema.version="$DOCKER_IMAGE_VERSION" \
      org.label-schema.vcs-url="https://github.com/hxl9654/docker-chrome" \
      org.label-schema.schema-version="1.0"
