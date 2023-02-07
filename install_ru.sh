#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Пожалуйста, запустите от root"
  exit
fi
echo "Установка..."
cp convurltojson.sh  /bin/convurltojson
chmod +x /bin/convurltojson
echo "Готово."
