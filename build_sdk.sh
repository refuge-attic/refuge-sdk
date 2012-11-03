#!/bin/sh

CURDIR=$(cd ${0%/*} && pwd)
export CURDIR=$CURDIR

CURLBIN=`which curl`
if ! test -n "$CURLBIN"; then
    echo "Error: curl is required. Add it to 'PATH'"
    exit 1
fi

GIT=`which git`
if ! test -n "$GIT"; then
    echo "Error: git is required. Add it to 'PATH'"
    exit 1
fi

# set default patches
GUNZIP=`which gunzip`
UNZIP=`which unzip`
TAR=`which tar`
GNUMAKE=`which gmake`


PATCHES=$CURDIR/patches
BUILDDIR=$CURDIR/build
DISTDIR=$CURDIR/dists


DOWNLOAD_URL=http://dl.refuge.io
REPO=refuge-sdk
SDK_TAG=$(sh -c 'git describe --tags --always 2>/dev/null || echo dev')
REVISION=$(echo $SDK_TAG | sed -e 's/^$(REPO)-//')
PKG_VERSION=$(echo $REVISION | tr - .)
DESTDIR=$CURDIR/dest/refuge-sdk-$PKG_VERSION

. support/env.sh
. support/versions.sh

fetch()
{
    UPLOAD_TARGET=$DISTDIR/$1
    if ! test -f $UPLOAD_TARGET; then
        echo "==> Fetch $1 to $UPLOAD_TARGET"
        $CURLBIN --progress-bar -L $2/$1 -o $UPLOAD_TARGET
    fi
}

setup()
{
    echo "==> build Refuge SDK ..."
    mkdir -p $DISTDIR
    mkdir -p $BUILDDIR
    mkdir -p $DESTDIR
}

clean_openssl()
{
    rm -rf $DESTDIR/openssl
    rm -rf $BUILDDIR/openssl-$OPENSSL_VER
}

build_openssl()
{
    fetch $OPENSSL_DISTNAME $DOWNLOAD_URL

    echo "==> Build openssl $OPENSSL_VER"
    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$OPENSSL_DISTNAME | $TAR xf -

    
    cd $BUILDDIR/openssl-$OPENSSL_VER
    ./Configure no-shared $OPENSSL_PLATFORM
    make

    mkdir -p $DESTDIR/openssl/lib
    mv libcrypto.a $DESTDIR/openssl/lib/
	mv libssl.a $DESTDIR/openssl/lib/

    mkdir -p $DESTDIR/openssl/include/openssl
    cp -RH include/openssl/*.h $DESTDIR/openssl/include/openssl/
}

clean_otp()
{
    rm -rf $BUILDDIR/otp_src_$ERLANG_VER
    rm -rf $DESTDIR/otp_rel
}

build_otp()
{
    fetch $ERLANG_DISTNAME $DOWNLOAD_URL

    echo "==> Build Erlang $ERLANG_VER"
    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$ERLANG_DISTNAME | $TAR xf -


    mkdir $DESTDIR/otp_rel
    cd $BUILDDIR/otp_src_$ERLANG_VER
    ./otp_build autoconf
    ./otp_build configure \
        --disable-dynamic-ssl-lib \
        --with-ssl=$DESTDIR/openssl $OTP_ENV
    ./otp_build boot -a
    ./otp_build release -a $DESTDIR/otp_rel
}

clean_nspr()
{
    rm -rf $BUILDDIR/nspr*
    rm -rf $DESTDIR/nspr*
}


build_nspr()
{
    fetch $NSPR_DISTNAME $DOWNLOAD_URL

    echo "==> build nspr"
    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$NSPR_DISTNAME | $TAR xf -

    cd $BUILDDIR/nspr-$NSPR_VER/mozilla/nsprpub
    ./configure --disable-debug --enable-optimize \
        --prefix=$DESTDIR/nsprpub $NSPR_CONFIGURE_ENV

    $GNUMAKE all
    $GNUMAKE install
}

clean_js()
{
    rm -rf $JSDIR
    rm -rf $DESTDIR/js
}

build_js()
{

    fetch $JS_DISTNAME $DOWNLOAD_URL

    mkdir -p $JS_LIBDIR
    mkdir -p $JS_INCDIR

    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$JS_DISTNAME | $TAR -xf -

    echo "==> build js"
    cd $JSDIR/js/src
    patch -p0 -i $PATCHES/js/patch-jsprf_cpp
	patch -p0 -i $PATCHES/js/patch-configure

    env CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
        CPPFLAGS="-DXP_UNIX -DJS_C_STRINGS_ARE_UTF8" \
        ./configure --prefix=$DESTDIR/js \
				    --disable-debug \
					--enable-optimize \
					--enable-static \
					--disable-shared-js \
					--disable-tests \
					--with-system-nspr \
					--with-nspr-prefix=$DESTDIR/nsprpub && \
        $GNUMAKE all

    mkdir -p $JS_INCDIR/js
    cp $JSDIR/js/src/*.h $JS_INCDIR
    cp $JSDIR/js/src/*.tbl $JS_INCDIR
    cp $JSDIR/js/src/libjs_static.a $JS_LIBDIR
}

clean_icu()
{
    rm -rf $BUILDDIR/icu*
    rm -rf $DESTDIR/icu*
}

build_icu()
{
    fetch $ICU_DISTNAME $DOWNLOAD_URL

    mkdir -p $ICUDIR

    echo "==> build icu4c"

    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$ICU_DISTNAME | $TAR xf - -C $BUILDDIR/icu_src

    # apply patches
    cd $BUILDDIR/icu_src
    for P in $PATCHES/icu/*.patch; do \
        (patch -p0 -i $P || echo "skipping patch"); \
    done

    cd $ICUDIR/source

    CFLAGS="-g -Wall -fPIC -Os"

    env CC="gcc" CXX="g++" CPPFLAGS="" LDFLAGS="-fPIC" \
	CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS" \
        ./configure --disable-debug \
		    --enable-static \
		    --disable-shared \
		    --disable-icuio \
		    --disable-layout \
		    --disable-extras \
		    --disable-tests \
		    --disable-samples \
		    --prefix=$DESTDIR/icu && \
        $GNUMAKE && $GNUMAKE install
}

build_all()
{
    build_openssl
    build_otp
    build_nspr
    build_js
    build_icu
}


clean_all()
{
    rm -rf $DESTDIR
    rm -rf $BUILDDIR

}


usage()
{
    cat << EOF
Usage: $basename [command] [OPTIONS]

The $basename command compile the Refuge SDK.

Commands:

    all:        build 
    clean:      clean
    -?:         display usage

Report bugs at <https://github.com/refuge/refuge-sdk>.
EOF
}




if [ "x$1" = "x" ]; then
    clean_all
    setup
    build_all 

    exit 0
fi

case "$1" in
    all)
        shift 1
        clean_all
        setup
        build_all 
        ;;
    clean)
        shift 1
        clean_all
        ;;
    openssl)
        shift 1
        setup
        clean_openssl
        build_openssl
        ;;
    otp)
        shift 1
        setup
        clean_otp
        build_otp
        ;;
    nspr)
        shift 1
        setup
        clean_nspr
        build_nspr
        ;;
    js)
        shift 1
        setup
        clean_js
        build_js
        ;;
    icu)
        shift 1
        setup
        clean_icu
        build_icu
        ;;
    help|--help|-h|-?)
        usage
        exit 0
        ;;
    *)
        echo $basename: ERROR Unknown command $arg 1>&2
        echo 1>&2
        usage 1>&2
        echo "### $basename: Exiting." 1>&2
        exit 1;
        ;;
esac

exit 0
