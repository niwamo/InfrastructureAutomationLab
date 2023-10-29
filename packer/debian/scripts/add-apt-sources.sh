# add apt sources, if not already present
if [ ! -d /etc/apt/sources.list.d ]; then mkdir -p /etc/apt/sources.list.d; fi
if [ ! -f /etc/apt/sources.list.d/debian.sources ]; 
then
cat << EOF > /etc/apt/sources.list.d/debian.sources
Types: deb
# http://snapshot.debian.org/archive/debian/20231009T000000Z
URIs: http://deb.debian.org/debian
Suites: bookworm bookworm-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
# http://snapshot.debian.org/archive/debian-security/20231009T000000Z
URIs: http://deb.debian.org/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
fi