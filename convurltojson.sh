#!/bin/bash
if [ -z $2 ]; then
echo "Usage:"
echo ""
echo "convurltojson url_begining_with_ss:// file_to_export.json local_port(optional)"
echo ""
exit
fi

# Shadowsocks URL
url=$(echo $1)
add_char="#"

# Check if the add char is not found in the input string
if ! echo "${url}" | grep -q "${add_char}"; then
  # Add the add char to the end of the input string
  url="${url}${add_char}"
fi

start_sample="//"
end_sample="@"

# Get the start index of the start sample
start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)

start_index=$((${start_index} + 3 ))
# Get the end index of the end sample
end_index=$(( $(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1) + ${#end_sample} - 1 ))

# Calculate the length of the desired substring
length=$(( ${end_index} - ${start_index} + 1 ))

# Extract the desired substring
encoded=$(echo "${url}" | cut -c ${start_index}-${end_index})


chiperinfo=$(echo $encoded | base64 --decode)

# Start and end samples
start_sample="@"
if ! echo "${url}" | grep -q "?"; then
  # Add the add char to the end of the input string
  end_sample="#"
else
  end_sample="?"
fi

# Get the start index of the start sample
start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)
start_index=$((${start_index} + 2 ))
# Get the end index of the end sample
end_index=$(( $(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1) + ${#end_sample} - 1 ))

# Calculate the length of the desired substring
length=$(( ${end_index} - ${start_index} + 1 ))

# Extract the desired substring
ipport=$(echo "${url}" | cut -c ${start_index}-${end_index})

# Character before which the string should be extracted
char=":"

# Get the index of the before char
char_index=$(echo "${ipport}" | grep -b -o "${char}" | cut -d':' -f1 | head -n 1)

# Extract the desired substring
ip=$(echo "${ipport}" | cut -c -${char_index})
char_index=$((${char_index} +2 ))
port=$(echo "${ipport}" | cut -c ${char_index}-)

char_index=$(echo "${chiperinfo}" | grep -b -o "${char}" | cut -d':' -f1 | head -n 1)

# Extract the desired substring
chiper=$(echo "${chiperinfo}" | cut -c -${char_index})
char_index=$((${char_index} +2 ))
password=$(echo "${chiperinfo}" | cut -c ${char_index}-)

echo "{" > $2
echo '"server":"'$ip'",' >> $2
echo '"server_port:"'$port',' >> $2
if [ $3 ]; then
echo '"local_port":'$3',' >>$2
fi

echo '"password":"'$password'",' >> $2

if [ $(echo $end_sample) = '?' ]; then
        echo '"method":"'$chiper'",'  >> $2
        echo '"plugin":"obfs-local",' >> $2
	start_sample="obfs-host%3D"
        end_sample="#"
        if  echo "${url}" | grep -q "http"; then
        obfsopt="http"
        fi
        if  echo "${url}" | grep -q "tls"; then
        obfsopt="tls"
        fi
        
        # Get the start index of the start sample
        start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)
        start_index=$((${start_index} + 13 ))
        #echo $start_index
        # Get the end index of the end sample
        end_index=$(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1)

        # Extract the desired substring
        substring=$(echo "${url}" | cut -c ${start_index}-${end_index})

        echo '"plugin_opts":"obfs='$obfsopt';failover='"${substring}"'"' >> $2
else
echo '"method":"'$chiper'"' >> $2
fi
echo "}" >> $2
cat $2
