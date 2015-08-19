#!/bin/sh

# This script allows OpenAperture to dynamically send environment variables to a container at runtime:
#   * writes /etc/container_environment files for Passenger Phusion Docker containers (baseimage)
#     * Docs here: https://github.com/phusion/baseimage-docker#envvar_central_definition
#   * uses the envver utility by Jordan Day, to retrieve environment variables for a Product Environment
#   * bypasses the 2K command-line limitation for fleetd "docker run ..."


# Requirements -
#   * A Passenger Phusion BaseImage-compatible Docker Container:
#     * https://github.com/phusion/baseimage-docker
#   * This script should be installed in the BaseImage container here:
#     * /etc/my_init.d/00_OA_vars.sh
#     * chmod 755 /etc/my_init.d/00_OA_vars.sh
#   * Needs the OpenAperture envver Go Program
#     * https://github.com/OpenAperture/envver
#     * https://s3.amazonaws.com/lexmark-devops-artifacts/binaries/envver-linux-amd64
#     * (envver binary should be installed at /opt/bin/envver-linux-amd64)
#     * (chmod -R +rx /opt/bin)
#   * Needs /bin/sh and awk
#     * NOTE: for more information on special features of /bin/sh and awk as used in this script:
#       * http://unix.stackexchange.com/questions/146942/how-can-i-test-if-a-variable-is-empty-or-contains-only-spaces
#       * http://stackoverflow.com/questions/19154996/awk-split-only-by-first-occurrence
#       * http://www.unix.com/shell-programming-and-scripting/55172-awk-print-redirection-variable-file-name.html


echo -n "Dynamic OpenAperture Environment Variables -- "


# Check to see if all OA_* variables are defined
if [[ -z "${OA_CLIENT_ID// }" || -z "${OA_CLIENT_SECRET// }" || -z "${OA_AUTH_TOKEN_URL// }" || -z "${OA_URL// }" || -z "${OA_PRODUCT_NAME// }" || -z "${OA_PRODUCT_ENVIRONMENT_NAME// }" ]];
then
  echo "Skipping (not enough parameters)..."
  exit 0
fi


# Verify installation of envver
if [[ ! -x /opt/bin/envver-linux-amd64 ]];
then
  echo "/opt/bin/envver-linux-amd64 cannot be located or is not executable"
  exit 1
fi


# We should now be able to retrieve variables, saving them into /etc/container_environment
echo "Attempting retrieval for"
echo "  Product '${OA_PRODUCT_NAME}'"
echo "  Environment '${OA_PRODUCT_ENVIRONMENT_NAME}'"
/opt/bin/envver-linux-amd64 | awk -F= '{ st = index($0,"=");print substr($0,st+1) > "/etc/container_environment/"$1 }'
ret_val=$?


# Check to see if envver returned a success or failure
if [[ "$ret_val" -ne "0" ]];
then
  echo "Failed envver retrieval -- Exit Code: '${ret_val}'"
  exit $ret_val
fi


# All Done.  If you got here, then enjoy!
echo "OpenAperture Runtime Variables Created in /etc/container_environment"
exit 0

