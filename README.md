# Mashtoo
## History

Originaly set to create gentoo install easily through ssh with some core minimal configuations.

The project evolved to be a full featured set of cross-tools GNU/Linux distributions.

## Why ?

I know there is bash, I know there is python on most distributions. But not when it comes about domotics or alpine distributions.

I don't know if this is lightweight or not, because it will somehow install packages needed if needed. I just wanted a solution that works on every GNU/Linux distributions and potentially MacOS.

## Constraints and evolution

### POSIX syntax and bash

Script CAN contains bash syntax, don't hesitate to create issues if you consider it has to be created.
But I won't promise I'll do it, I've many projects to work on.

Consider this sets of scripts distributed "as is". If you have complaints, just fork it.

### bpkg dependencies installer

For the moment, I decided to use `bpkg` to install dependencies.

But I'm open to other solutions because `bpkg` is not as good as cyclic dependecies resolutions.`.

## Installation

### Install `bpkg` dependencies manager

#### System global installation
Just run:
```
curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | sudo bash
```

#### Local user installation
Just run:
```
curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash
```

### Install mashtoo

#### System global installation
Just run:
```
sudo bpkg install creakiwi/mashtoo -g
```

#### Local user installation
Just run:
```
bpkg install creakiwi/mashtoo
```

## Development and contributions

To work on mashtoo or on libraries based on mashtoo, you will need to install it first or at least have the following commands available:
- [x] make
- [x] git
- [x] curl

But if you already used mashtoo, you should have it even on busy-box based systems like alpine.

### fork and clone mashtoo project

On github, at [https://github.com/creakiwi/mashtoo](https://github.com/creakiwi/mashtoo) just fork the project

### .env.local
Fill up the .env.local file with your own values, then run:

### Develop
Just write your fucking code, bugfix.

### Coding rules
Merge won't pass if you don't respect the [coding styles and rules](documentation/coding-style.md).
