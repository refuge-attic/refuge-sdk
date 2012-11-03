#!/bin/sh

# openssl
OPENSSL_VER=1.0.1c
OPENSSL_DISTNAME=openssl-1.0.1c.tar.gz

# erlang
ERLANG_VER=R15B02
ERLANG_DISTNAME=otp_src_R15B02.tar.gz

# nspr sources
NSPR_VER=4.8.8
NSPR_DISTNAME=nspr-$NSPR_VER.tar.gz

# spidermonkey js sources
JS_VER=185-1.0.0
JS_REALVER=1.8.5
JS_DISTNAME=js$JS_VER.tar.gz
JSDIR=$BUILDDIR/js-$JS_REALVER
JS_LIBDIR=$DESTDIR/js/lib
JS_INCDIR=$DESTDIR/js/include

# icu sources
ICU_VER=4.4.2
ICU_DISTNAME=icu4c-4_4_2-src.tgz
ICUDIR=$BUILDDIR/icu_src/icu
