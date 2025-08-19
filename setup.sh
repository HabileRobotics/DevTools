#!/usr/bin/bash

################################################################################
## Built Tools envornment Setup Script
##
## Author:  Jose Pagan
##   Date:  12/02/2024
## Update:  01/20/2025
################################################################################
if [[ "$SHELL" == "/bin/bash" ]]
then
    ## if using BASH
    [ -v DEBUG  ] && [ "$DEBUG" -ne "0" ] echo "Running with BASH Shell"
    SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
    SCRIPT_PATH=$( cd $(dirname $(readlink `[[ $OSTYPE == linux* ]] && echo "-f"` ${BASH_SOURCE[0]})) ; pwd -P)
else
    ## with non-BASH
    [ -v DEBUG  ] && [ "$DEBUG" -ne "0" ] echo "Running with non-BASH Shell: [$SHELL]"
    SCRIPT_NAME=$(basename $0)
    SCRIPT_PATH=$( cd $(dirname $(readlink `[[ $OSTYPE == linux* ]] && echo "-f"` $0)) ; pwd -P)
fi

## Source the common definitions:
source ${SCRIPT_PATH}/common

DOCKERHUB_NAMESPACE=DevTools

################################################################################
echo "Build Tools setup script:"

echo "Prepending PATH with: ${SCRIPT_PATH}"
export PATH=${SCRIPT_PATH}:$PATH

echo "Build Tools setup complete"
