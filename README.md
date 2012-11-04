# Refuge SDK

The Refuge SDK provides you the API libraries and developer tools
necessary to build, test, and debug The refuge release and applications
developed for it.

Supported platforms are:

    - Linux 32, 64 bits & arm platforms
    - MacOS X 10.6,10.7,10.8
    - BSD 32 & 64 bits

## Features

The refuge SDK provides for now:

- Erlang R15B02 statically built with openssl 1.0.1c
- [Rebar](http://github.com/rebar/rebar)
- [Erica](http://github.com/benoitc/erica)

## Installation 

## Available builds (2012/01/04)

- Macosx 10.6-10.8: [Refuge SDK Installer](http://dl.refuge.io/refuge-sdk-0.1.dmg)
- Macosx 10.6-10.8: [Static archive](http://dl.refuge.io/refuge-sdk-Darwin-x86_64-0.1.tar.gz)
- Linux 64: [Static archive](http://dl.refuge.io/refuge-sdk-Linux-x86_64-0.1.tar.gz)

### Installation from archives

You can install an archive where you want on your system. For example to
install on your home folder:

    $ cd ~ && tar xvzf refuge-sdk-<platform>-<arch>-<version>.tar.gz

Then don't forget to finalize the installation

    $ cd ~/refuge-sdk && ./tools/install.sh

### Macosx Installation

You can install on macosx using the package. Just launch it and follow
instructions. This package will install the Refuge SDK in
/opt/refuge-sdk and ovveride your path to give you access to the tools
and erlang.


## Build the SDK

The build of the SDK is fully automatized. To build an archive for your
system run the following commands:

    $ git clone git://github.com/refuge/refuge-sdk.git
    $ cd refuge-sdk
    $ ./build_sdk all

Notes:

> to build the SDK you will need curl, git and libncurses installed.

## License

The Refuge SDK is available in the public domain (see UNLICENSE). gaffer
is also optionally available under the MIT License (see LICENSE), meant
especially for jurisdictions that do not recognize public domain
works.
