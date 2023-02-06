#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "Installing..."
cp convurltojson.sh  /bin/convurltojson
chmod +x /bin/convurltojson
echo "Done."
