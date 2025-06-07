if [ -f /config/syncthing/config.xml ]; then
API_KEY=$(grep -oEm1 "<apikey>[^<]+" /config/syncthing/config.xml | sed -n "s/^.*apikey>\s*\(\S*\).*$/\1/p")
cat > /config/stfed/config.toml <<EOF
url = "http://syncthing:8384/"
api_key = "${API_KEY}"
EOF
fi