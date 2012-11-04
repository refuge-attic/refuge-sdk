#!/bin/sh

PATH="/opt/refuge-sdk/tools:/opt/refuge-sdk/otp/bin:$PATH"
export PATH

/opt/refuge-sdk/tools/install.sh

echo "# Added by the Refuge SDK" > ~/.bash_profile
echo "export PATH=$PATH" > ~/.bash_profile
