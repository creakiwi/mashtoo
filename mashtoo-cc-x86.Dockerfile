FROM gentoo/portage:latest as portage
FROM gentoo/stage3:i686-openrc

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN emerge --getbinpkg sys-devel/distcc

EXPOSE 3632

CMD ["distccd", "--daemon", "--no-detach", "--user", "distcc", "--port", "3632", "--allow", "192.168.1.0/24", "--log-stderr"]
