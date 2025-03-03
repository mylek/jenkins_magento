RELEASE=$1
cd /var/www/html

mkdir releases/$RELEASE
ln -sf share/var releases/$RELEASE/var
### komendy magento


ln -sf releases/$RELEASE current
