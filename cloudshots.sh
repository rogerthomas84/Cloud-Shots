#!/usr/bin/env bash
#
# MIT LICENSE
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#
# Make a cache folder for upload (if it doesn't exist).
#
mkdir -p ~/.cloud-shots/cache

#
# Make a cloud shots folder (if it doesn't exist).
#
mkdir  -p ~/Pictures/CloudShots >> /dev/null

#
# Import the users rackspace settings
#
source ~/.cloud-shots/config

function completeConfig {
  zenity --info --text="Please enter the configuration details in:\n~/.cloud-shots/config" --title="Cloud Shots"
  exit
}

if [ -z "$USERNAME" ]; then
  completeConfig
fi
if [ -z "$API_KEY" ]; then
  completeConfig
fi
if [ -z "$CONTAINER" ]; then
  completeConfig
fi
if [ -z "$CONTAINER_PUBLIC_URL" ]; then
  completeConfig
fi
if [ -z "$DIRTO_USER" ]; then
  completeConfig
fi
if [ -z "$DIRTO_KEY" ]; then
  completeConfig
fi

#
# Check if the user has used this before.
#
if [ ! -f ~/.cloud-shots/cache/.seen-help ]; then
  QUESTION=`zenity --question --text="Looks like this is your first time here!\nTo take a screenshot, click \"Yes\" and drag a rectangle around the area of the screen you want to take a shot of." --title="Cloud Shots"`
  if [ $? -eq 0 ]; then
    touch ~/.cloud-shots/cache/.seen-help
  else
    exit
  fi
fi

#
# Generate some randomness for the filename
#
RANDOM=`date +%s | sha256sum | base64 | head -c 32`

#
# Give the filename the cloudshots-date-time-random format
#
FILENAME=cloudshots-$(date +%Y)-$(date +%m)-$(date +%d)_$(date +%H):$(date +%M):$(date +%S)-$RANDOM.png

#
# Save the file
#
scrot -q 100 -s ~/Pictures/CloudShots/$FILENAME ; notify-send -i 'camera' 'Cloud Shots' 'Screenshot has been saved'

#
# Define some empty variables
#
URL=""
TOKEN=""
AUTH="y"
CONNECTED="n"

PUNG=`ping identity.api.rackspacecloud.com -c1 > /dev/null 2>&1`
if [ $? -eq 0 ]; then
  CONNECTED="y"
else
  notify-send -i 'network-wired-disconnected' "Cloud Shots" "No connection to identity.api.rackspacecloud.com. Screenshot will not be uploaded."
  exit
fi

if [ -f ~/.cloud-shots/cache/.tmp-auth ]; then
  AGE=$(( `date +%s` - `stat -L --format %Y ~/.cloud-shots/cache/.tmp-auth` ))
  if [ "$AGE" -gt 1800 ]; then
    AUTH="y"
    notify-send -i 'emblem-web' "Cloud Shots" "Authenticating with Rackspace Cloud Files"
    rm ~/.cloud-shots/cache/.tmp-auth
  else
    AUTH="n"
  fi
else
  AUTH="y"
  notify-send -i 'emblem-web' "Cloud Shots" "Authenticating with Rackspace Cloud Files"
fi

if [ "$AUTH" == "y" ]; then
  #
  # Authenticate
  #
  curl -s -I -L -H "X-Auth-User: $USERNAME" -H "X-Auth-Key: $API_KEY" https://identity.api.rackspacecloud.com/v1.0 -o ~/.cloud-shots/cache/.tmp-auth
fi

#
# Extract the Storage URL and Auth Token from headers
#
while read line; do
  if [[ `echo $line | grep "X-Storage-Url: "` ]]; then
    URL="$( cut -d ':' -f 2- <<< "$line" )"
  fi
  if [[ `echo $line | grep "X-Auth-Token: "` ]]; then
    TOKEN="$( cut -d ':' -f 2- <<< "$line" )"
  fi
done < ~/.cloud-shots/cache/.tmp-auth

#
# Clean the variables
#
URL=`echo "$URL"|tr '\r' ' '`
URL="${URL#"${URL%%[![:space:]]*}"}"
URL=`echo "${URL}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`
TOKEN=`echo "$TOKEN"|tr '\r' ' '`
TOKEN="${TOKEN#"${TOKEN%%[![:space:]]*}"}"
TOKEN=`echo "${TOKEN}" | awk '{gsub(/^ +| +$/,"")} {print $0}'`

#
# Upload the file
#
curl -v -X PUT -T "$(realpath ~/Pictures/CloudShots)/$FILENAME" -H "Content-Type: image/png" -H "X-Auth-Token: $TOKEN" $URL/$CONTAINER/$FILENAME

#
# Build the Long URL
#
LONG_URL="$CONTAINER_PUBLIC_URL/$FILENAME"

SHORT_URL=$(curl -X POST --data-urlencode "url=$LONG_URL" http://dir.to/api/create -H "X-Api-User: $DIRTO_USER" -H "X-Api-Key: $DIRTO_KEY" -s)

#
# Add the URL to clipboard
#
echo $SHORT_URL | xclip -selection clipboard

#
# Send a local notification
#
notify-send -i 'emblem-default' 'Cloud Shots' 'Screenshot has been uploaded'

# Have a unicorn
#
#                                                     /
#                                                   .7
#                                        \       , //
#                                        |\.--._/|//
#                                       /\ ) ) ).'/
#                                      /(  \  // /
#                                     /(   J`((_/ \
#                                    / ) | _\     /
#                                   /|)  \  eJ    L
#                                  |  \ L \   L   L
#                                 /  \  J  `. J   L
#                                 |  )   L   \/   \
#                                /  \    J   (\   /
#              _....___         |  \      \   \```
#       ,.._.-'        '''--...-||\     -. \   \
#     .'.=.'                    `         `.\ [ Y
#    /   /                                  \]  J
#   Y / Y                                    Y   L
#   | | |          \                         |   L
#   | | |           Y                        A  J
#   |   I           |                       /I\ /
#   |    \          I             \        ( |]/|
#   J     \         /._           /        -tI/ |
#    L     )       /   /'-------'J           `'-:.
#    J   .'      ,'  ,' ,     \   `'-.__          \
#     \ T      ,'  ,'   )\    /|        ';'---7   /
#      \|    ,'L  Y...-' / _.' /         \   /   /
#       J   Y  |  J    .'-'   /         ,--.(   /
#        L  |  J   L -'     .'         /  |    /\
#        |  J.  L  J     .-;.-/       |    \ .' /
#        J   L`-J   L____,.-'`        |  _.-'   |
#         L  J   L  J                  ``  J    |
#         J   L  |   L                     J    |
#          L  J  L    \                    L    \
#          |   L  ) _.'\                    ) _.'\
#          L    \('`    \                  ('`    \
#           ) _.'\`-....'                   `-....'
#          ('`    \
#           `-.___/   sk
#
# Source: http://ascii.co.uk/art/unicorn
#
