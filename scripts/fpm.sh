#!/bin/bash
##################################
# Zabbix monitoring script
#
# php-fpm:
#  - anything available via FPM status page
#
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922	VV	initial creation
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# Nginx defaults
NGINX_STATUS_DEFAULT_URL="http://localhost/fpm/status"
WGET_BIN="/usr/bin/wget"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.91"
ERROR_NO_ACCESS="-0.92"
ERROR_WRONG_PARAM="-0.93"
ERROR_DATA="-0.94" # either can not connect /	bad host / bad port

# Handle host and port if non-default
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$NGINX_STATUS_DEFAULT_URL"
fi

# save the nginx stats in a variable for future parsing
NGINX_STATS=$($WGET_BIN -q $URL -O - 2>/dev/null)

# error during retrieve
if [ $? -ne 0 -o -z "$NGINX_STATS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from nginx stats
#
#RESULT=$(echo "$NGINX_STATS" | awk 'print $0;match($0, "^'"$ZBX_REQ_DATA"':[[:space:]]+(.*)", a) { print a[1] }')
#RESULT=$(echo "$NGINX_STATS" | grep "$ZBX_REQ_DATA" | awk -F : '{print $2}')
RESULT=$(echo "$NGINX_STATS" | awk -F : "{if(\$1==\"$ZBX_REQ_DATA\") print \$2}")
if [ $? -ne 0 -o -z "$RESULT" ]; then
    echo $ERROR_WRONG_PARAM
    exit 1
fi

echo $RESULT

exit 0
