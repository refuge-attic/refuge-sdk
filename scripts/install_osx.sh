#!/bin/sh

PATH="/opt/refuge-sdk/tools:/opt/refuge-sdk/libs/otp_rel/bin:$PATH"
export PATH

/opt/refuge-sdk/tools/install.sh

echo ""
echo "# Added by the Refuge SDK" >> ~/.bash_profile
echo "export PATH=$PATH" >> ~/.bash_profile

exit 0
