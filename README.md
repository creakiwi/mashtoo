# mashtoo

A project to easily customize Gentoo liveCD and installation.

## Disclaimer

> [!CAUTION]
> As you can see in `compose.yaml`, there is the following part of code:
> ```
> services:
>    mashtoo:
>        environment:
>            - USB_DEVICE=${USB_DEVICE}
> ```
>
> ⚠️ The `USB_DEVICE` (representing the future liveCD) will be erased totally **WITHOUT ANY BACKUPS**.
>
> ⚠️ All `USB_DEVICE` partitions **WILL BE DELETED** and a new one will be created.
>
> ⚠️ **NO CONFIRMATION IS ASKED**

> [!IMPORTANT]
> As you can see in `compose.yaml`, there is the following part of code:
> ```
> services:
>    mashtoo:
>        environment:
>            - ARCH=${ARCH}
>            - MICROARCH=${MICROARCH}
>            - SUFFIX=${SUFFIX}
> ```
>
> `ARCH` and `MICROARCH` must be compliant with the architecture of the machine you will use the LiveUSB device.
> `SUFFIX`

## Requirements

 - [x] /bin/sh
 - [x] Docker

## Missing options and futures developments

 - [ ] Backup `USB_DEVICE` as an iso file to restore it if needed
 - [ ] Propose an alternative to network install
 - [ ] Add checks before altering partitions of `USB_DEVICE`

As for now we need to rebuild docker image to update `/dev`, so a .sh script is needed (based on Linux and probably MacOS).
Maybe it's better to have one of :
 - A way to not rebuild docker image and have `/dev` container directory synced with `/dev` host directory while playing with partitions of `USB_DEVICE` in the container
 - A Makefile which might need adaptation between Linux/MacOS/Windows
 - A script per OS

## Bugs

Don't hesitate to open issues or ping me on networks (check Dockerfile for further personal informations).

## Contributions

Feel free to contribute in any way you want proposing features, merge or pull requests, for now it's just an alpha compliant with my needs.

## 💰 Donation

[![BITCOIN](https://img.shields.io/badge/BTC-1K6Sh6kAFb5UJwydXkAntFZPk5NLNw1nSs-yellow.svg?style=for-the-badge&logo=bitcoin)](bitcoin:1K6Sh6kAFb5UJwydXkAntFZPk5NLNw1nSs)

[![LLAMA](https://img.shields.io/badge/gimme-llama-blue.svg?style=for-the-badge&logo=ollama)](https://www.leboncoin.fr/recherche?category=28&text=lama&animal_type=farm_animals)

[![TOURTEL TWIST LEMON 0.0%](https://img.shields.io/badge/gimme-TOURTEL_TWIST_LEMON_0.0%25-gold.svg?style=for-the-badge&logo=gentoo)](https://www.carrefour.fr/p/biere-sans-alcool-aromatisee-au-jus-de-citron-0-0-tourtel-twist-3080216055336)

