#!/bin/sh

CURDIR=$(cd ${0%/*} && pwd)
export CURDIR=$CURDIR

export SDK_TOP=${CURDIR%/*}
cd $SDK_TOP
SDK_TOP=`pwd`

OTPDIR=$SDK_TOP/otp


install_otp()
{
    cd $SDK_TOP/otp_rel
    ./Install $OTPDIR
}


install_otp
echo "Refuge SDK Installed"
echo "Tools installed in '$SDK_TOP/tool'"
echo "Erlang installed in '$SDK_TOP/otp'"
echo 
echo "You can override the PATH environment variable with the following value:"
echo
echo "\texport PATH=$SDK_TOP/tool:$SDK_TOP/otp/bin:$PATH"
