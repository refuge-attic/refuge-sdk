#!/bin/sh

[ "$MACHINE" ] || MACHINE=`(uname -m) 2>/dev/null` || MACHINE="unknown"
[ "$RELEASE" ] || RELEASE=`(uname -r) 2>/dev/null` || RELEASE="unknown"
[ "$SYSTEM" ] || SYSTEM=`(uname -s) 2>/dev/null`  || SYSTEM="unknown"
[ "$BUILD" ] || VERSION=`(uname -v) 2>/dev/null` || VERSION="unknown"


CFLAGS="-g -O2 -Wall"
LDFLAGS="-lstdc++"
ARCH=
ISA64=
GNUMAKE=make
CC=gcc
CXX=g++
case "$SYSTEM" in
    Linux)
        ARCH=`arch 2>/dev/null`
        ;;
    FreeBSD|OpenBSD|NetBSD)
        ARCH=`(uname -p) 2>/dev/null`
        GNUMAKE=gmake
        ;;
    Darwin)
        ARCH=`(uname -p) 2>/dev/null`
        ISA64=`(sysctl -n hw.optional.x86_64) 2>/dev/null`
        ;;
    *)
        ARCH="unknown"
        ;;
esac


# NSPR env
NSPR_CONFIGURE_ENV=""
NSPR_CFLAG=$CFLAGS
case $SYSTEM in
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            NSPR_CONFIGURE_ENV="--enable-64bit"
        fi
        NSPR_CFLAGS="$CFLAGS -lpthread"
        ;;
    FreeBSD|OpenBSD|NetBSD)
        if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
            NSPR_CONFIGURE_ENV+=--enable-64bit
        fi
        ;;
    Darwin)
        if [ "$ISA64" = "1" ]; then
            NSPR_CONFIGURE_ENV+=--enable-64bit
        fi
        ;;
esac


OPENSSL_PLATFORM=$OPENSSL_PLATFORM
if ! test -n "$OPENSSL_PLATFORM"; then
    case $SYSTEM in
        Linux)
            case "$ARCH" in
                x86_64)
                    OPENSSL_PLATFORM="linux-generic64"
                    ;;
                *)
                    case "$MACHINE" in
                        arm*) 
                            OPENSSL_PLATFORM="linux-armv4"
                            ;;
                        *)
                            OPENSSL_PLATFORM="linux-generic32"
                            ;;
                    esac
                    ;;
            esac
            ;;
        FreeBSD|OpenBSD|NetBSD)
            OPENSSL_PLATFORM="BSD-generic32"

            if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
                OPENSSL_PLATFORM="BSD-generic64"
            fi
            ;;
        Darwin)
            OPENSSL_PLATFORM="darwin-i386-cc"
            if [ "$ISA64" = "1" ]; then
                OPENSSL_PLATFORM="darwin64-x86_64-cc"
            fi
            ;;
    esac
fi


case $SYSTEM in
    Darwin)
        OTP_ENV+="--enable-darwin-64bit"
        ;;
    *)
        OTP_ENV+=""
        ;;
esac