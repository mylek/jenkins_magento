RELEASE=$1
cd /var/www/html
mkdir releases/$RELEASE
### komendy magento


ln -sf releases/$RELEASE current
