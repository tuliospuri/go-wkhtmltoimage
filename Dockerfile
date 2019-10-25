FROM golang:1.11.4-alpine3.8

RUN apk add git
RUN apk --no-cache add tzdata zlib-dev ttf-ubuntu-font-family ttf-linux-libertine freetype freetype-dev fontconfig libx11-dev libxext-dev libxrender-dev ttf-freefont dbus xvfb curl qt5-qtbase

# wkhtmltoimage
RUN apk update && apk upgrade && apk add --update --no-cache \
    libgcc libstdc++ libx11 glib libxrender libxext libintl \
    libcrypto1.0 libssl1.0 \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family \
    nodejs imagemagick pdftk
COPY wkhtmltoimage /bin
RUN chmod +x /bin/wkhtmltoimage

# Wrapper for xvfb
RUN echo $'#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 640x480x8 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltoimage $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltoimage-headless && \
    chmod +x /usr/bin/wkhtmltoimage-headless

# Fix fonts
RUN ln -s /usr/share/fonts /usr/lib/fonts
RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f