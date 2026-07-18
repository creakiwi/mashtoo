## Host machine

### Debian

```
sudo apt install distcc gcc-i686-linux-gnu g++-i686-linux-gnu
```

`/etc/default/distcc`
```
STARTDISTCC="true"
ALLOWEDNETS="192.168.1.0/24"
LISTENER="0.0.0.0"
JOBS="8"
```

```
sudo /etc/init.d/distcc restart
i686-linux-gnu-gcc -v
```

## Target Machine

### Gentoo

```
emerge -pv sys-devel/distcc
emerge -v sys-devel/distcc
rc-update add distccd default
rc-service distccd start
```

`/etc/portage/make.conf`
```
# /8 job number see nproc
FEATURES="distcc"
DISTCC_HOSTS="localhost 192.168.1.32/8"
MAKEOPTS="-j2"
```
