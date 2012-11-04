#!/bin/sh

CURDIR=$(cd ${0%/*} && pwd)
export CURDIR=$CURDIR

CURLBIN=`which curl`
if ! test -n "$CURLBIN"; then
    echo "Error: curl is required. Add it to 'PATH'"
    exit 1
fi

GITBIN=`which git`
if ! test -n "$GITBIN"; then
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


DESTDIR=$CURDIR/dest/refuge-sdk
LIBSDIR=$DESTDIR/libs

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
    rm -rf $LIBSDIR/openssl
    rm -rf $BUILDDIR/openssl-$OPENSSL_VER
}

build_openssl()
{
    fetch $OPENSSL_DISTNAME $DOWNLOAD_URL

    echo "==> Build openssl $OPENSSL_VER"
    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$OPENSSL_DISTNAME | $TAR xf -

    
    cd $BUILDDIR/openssl-$OPENSSL_VER
    patch -p1 -i $PATCHES/openssl/pic.patch

    if [ "$SYSTEM" = "Linux" ]; then
        echo "here"
        ./config shared no-idea no-mdc2 no-rc5 zlib enable-tlsext no-ssl2
    else
        ./Configure no-shared $OPENSSL_PLATFORM
    fi
    make depend
    make

    mkdir -p $LIBSDIR/openssl/lib
    mv libcrypto.a $LIBSDIR/openssl/lib/
	mv libssl.a $LIBSDIR/openssl/lib/

    mkdir -p $LIBSDIR/openssl/include/openssl
    cp -RH include/openssl/*.h $LIBSDIR/openssl/include/openssl/
}

clean_otp()
{
    rm -rf $BUILDDIR/otp_src_$ERLANG_VER
    rm -rf $LIBSDIR/otp_rel
}

build_otp()
{
    fetch $ERLANG_DISTNAME $DOWNLOAD_URL

    echo "==> Build Erlang $ERLANG_VER"
    cd $BUILDDIR
    $GUNZIP -c $DISTDIR/$ERLANG_DISTNAME | $TAR xf -

    cd $BUILDDIR/otp_src_$ERLANG_VER
    ./otp_build configure \
        --disable-dynamic-ssl-lib \
        --with-ssl=$LIBSDIR/openssl $OTP_ENV
    ./otp_build boot -a
    ./otp_build release -a $LIBSDIR/otp_rel
}

clean_rebar()
{
    rm -rf $BUILDDIR/rebar
    rm -rf $DESTDIR/tools/rebar
}


build_rebar()
{
    export PATH="$BUILDDIR/otp_src_$ERLANG_VER/bin:$PATH"
    mkdir -p $BUILDDIR/rebar
    echo "==> Fetch rebar"
    $GITBIN clone $REBAR_MASTER $BUILDDIR/rebar
    echo "==> build rebar"
    cd $BUILDDIR/rebar
    ./bootstrap
    mkdir -p $DESTDIR/tools
    cp $BUILDDIR/rebar/rebar $DESTDIR/tools/
    chmod +x $DESTDIR/tools/rebar
}

clean_erica()
{
    rm -rf $BUILDDIR/erica
    rm -rf $DESTDIR/tools/erica
}


build_erica()
{
    export PATH="$BUILDDIR/otp_src_$ERLANG_VER/bin:$PATH"
    mkdir -p $BUILDDIR/erica
    echo "==> Fetch erica"
    $GITBIN clone $ERICA_MASTER $BUILDDIR/erica
    echo "==> build erica"
    cd $BUILDDIR/erica
    make 
    mkdir -p $DESTDIR/tools
    cp $BUILDDIR/erica/erica $DESTDIR/tools/
    chmod +x $DESTDIR/tools/erica
}


build_all()
{
    build_openssl
    build_otp
    build_rebar
    build_erica
}

finalize()
{
    # miscellaneous
    cp LICENSE UNLICENSE NOTICE README.md $DESTDIR/
    cp scripts/* $DESTDIR/tools/
}

clean_all()
{
    echo $DESTDIR
    rm -rf $DESTDIR
    rm -rv $BUILDDIR
    rm -rf pkg

}

make_archive()
{
    cd $DESTDIR/..
    tar cvzf ../refuge-sdk-$SYSTEM-$MACHINE-$PKG_VERSION.tar.gz $DESTDIR
}


make_dmg()
{
    echo "==> Build DMG"
    mkdir -p pkg

    cp -f support/README.txt pkg/
	cp -f LICENSE pkg/LICENSE.txt
	cp -f support/dmg-background.png pkg/ 
	cp -f support/setviewoptions.applescript pkg/
	cp -f support/makedmg.sh pkg/
	cp -f support/rcouch.icns pkg/
	cd pkg
	./makedmg.sh refuge-sdk-$PKG_VERSION.dmg \
        "Refuge SDK Installer.pkg" "Refuge SDK Installer" \
        dmg-background.png rcouch.icns	
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
    finalize 
    make_archive
    exit 0
fi

case "$1" in
    all)
        shift 1
        clean_all
        setup
        build_all
        finalize
        make_archive 
        ;;
    clean)
        shift 1
        clean_all
        ;;
    archive)
        shift 1
        finalize
        make_archive
        ;;
    dmg)
        shift 1
        make_dmg
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
    rebar)
        shift 1
        setup
        clean_rebar
        build_rebar
        ;;
    erica)
        shift 1
        setup
        clean_erica
        build_erica
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
