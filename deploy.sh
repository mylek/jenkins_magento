RELEASE=$1
cd /var/www/html

ln -sf share/var current/var

mkdir releases/$RELEASE
### komendy magento


ln -sf releases/$RELEASE current
