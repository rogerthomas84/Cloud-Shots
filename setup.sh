#!/bin/bash

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

if [[ $EUID -eq 0 ]]; then
  echo ""
  echo "Do not run this setup file as ROOT!" 2>&1
  echo ""
  exit 1
fi

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_PATH="/usr/share/applications/cloudshots.desktop"

sudo apt-get install scrot xclip realpath -y

sudo cp $SCRIPTPATH/cloudshots.desktop $TARGET_PATH
sudo chmod 644 $TARGET_PATH
sudo chown root:root $TARGET_PATH
sudo cp $SCRIPTPATH/cloudshots.sh /usr/bin/cloudshots
sudo chmod +x /usr/bin/cloudshots
if [ -d ~/.cloud-shots/cache ]; then
  rm -rf ~/.cloud-shots/cache
fi

mkdir -p ~/.cloud-shots/cache

if [ ! -f ~/.cloud-shots/config ]; then
    cp $SCRIPTPATH/config.template ~/.cloud-shots/config
fi

echo ""
echo "- Setup complete"
echo ""
echo "Whats next?"
echo ""
echo "Edit the file located at: ~/.cloud-shots/config"
echo "Enter in your Rackspace credentials."
echo ""
echo "After you've done that, simply drag the launcher from your applications menu to your launcher bar."
echo "Then, just right click, select 'Take Screenshot' and drag the region of the page to copy."
echo "It'll get saved in ~/Pictures/CloudShots and uploaded."
echo "The uploaded URL will be available for you in your clipboard"
echo ""
echo ""
