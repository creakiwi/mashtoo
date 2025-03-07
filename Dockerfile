FROM alpine:latest

LABEL com.creakiwi.site="https://mashtoo.creakiwi.com"
LABEL com.creakiwi.github="https://github.com/creakiwi/mashtoo"
LABEL com.creakiwi.gitlab="https://gitlab.com/creakiwi/mashtoo"
LABEL com.creakiwi.image.title="creakiwi/mashtoo"
LABEL com.creakiwi.description="A project to easily customize Gentoo liveCD and installation"
LABEL com.creakiwi.author.name="alexception"
LABEL com.creakiwi.author.email="alexandre@creakiwi.com"
LABEL com.creakiwi.author.twitter="https://x.com/alexception_ck"

ARG ARCH=amd64
ARG MICROARCH=amd64
ARG DIST="https://ftp-osl.osuosl.org/pub/gentoo/releases/${ARCH}/autobuilds"
ARG SUFFIX="-openrc"
ARG SIGNING_KEY="0xBB572E0E2D182910"

ENV ARCH=${ARCH}
ENV MICROARCH=${MICROARCH}
ENV DIST=${DIST}
ENV SUFFIX=${SUFFIX}
ENV SIGNING_KEY=${SIGNING_KEY}
ENV USB_DEVICE=

RUN apk --no-cache add \
    partx \
    sfdisk

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

RUN mkdir -p /home/mashtoo
COPY ./mashtoo /home/mashtoo
COPY ./LICENSE /home/mashtoo
COPY ./gift.license /home/mashtoo

WORKDIR /home/mashtoo

ENTRYPOINT ["tail", "-f", "/dev/null"]
