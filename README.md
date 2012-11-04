# Refuge SDK

The Refuge SDK provides you the API libraries and developer tools
necessary to build, test, and debug The refuge release and applications
developed for it.

Supported platforms are:

    - Linux 32, 64 bits & arm platforms
    - MacOS X 10.6,10.7,10.8
    - BSD 32 & 64 bits

## Features

The refuge SDK provides

- Erlang R15B02 statically built with openssl 1.0.1c
- Spidermonky 1.8.5
- entop
- Erica

## Installation 

You can use one of the built release available on the Downloads
repository:

    https://github.com/refuge/refuge-sdk/downloads

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

## License

The Refuge SDK is available in the public domain (see UNLICENSE). gaffer
is also optionally available under the MIT License (see LICENSE), meant
especially for jurisdictions that do not recognize public domain
works.
