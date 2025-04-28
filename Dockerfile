FROM alpine:latest

LABEL com.creakiwi.site="https://mashtoo.creakiwi.com"
LABEL com.creakiwi.github="https://github.com/creakiwi/mashtoo"
LABEL com.creakiwi.image.title="creakiwi/mashtoo"
LABEL com.creakiwi.description="A project to easily customize Linux liveCD installation"
LABEL com.creakiwi.author.name="alexception"
LABEL com.creakiwi.author.email="alexandre@creakiwi.com"
LABEL com.creakiwi.author.twitter="https://x.com/alexception_ck"

ARG ARCH
ARG MICROARCH
ARG DIST
ARG VERSION
ARG NETINST

ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV ARCH=${ARCH:-amd64}
ENV MICROARCH=${MICROARCH:-}
ENV DIST=${DIST:-debian}
ENV VERSION=${VERSION:-latest}
ARG NETINST=${NETINST:-0}
#ENV SUFFIX=${SUFFIX}
#ENV SIGNING_KEY=${SIGNING_KEY}
#ENV USB_DEVICE=${USB_DEVICE}
#ENV DIST="https://ftp-osl.osuosl.org/pub/gentoo/releases/${ARCH}/autobuilds"

# Common
RUN apk --no-cache add \
    fontconfig \
    musl-locales \
    musl-locales-lang

# Filesystems
RUN apk --no-cache add \
    btrfs-progs \
    dosfstools \
    e2fsprogs \
    exfatprogs \
    f2fs-tools \
    hfsprogs \
    jfsutils \
    ntfs-3g \
    xfsprogs

#RUN echo "arch: ${ARCH}, microarch: ${MICROARCH}, dist: ${DIST}, version: ${VERSION}, netinst: ${NETINST}"
RUN mkdir -p /home/mashtoo
COPY ./ /home/mashtoo/
RUN chmod +x /home/mashtoo/mashtoo.sh
WORKDIR /home/mashtoo

ENTRYPOINT ["/bin/sh", "/home/mashtoo/mashtoo.sh"]