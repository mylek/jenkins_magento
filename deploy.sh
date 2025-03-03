RELEASE=$1
cd /var/www/html

mkdir releases/$RELEASE
ln -sf share/var releases/$RELEASE/var
ln -sf share/var releases/$RELEASE/app/etc/env.php
ln -sf share/pub/media releases/$RELEASE/pub/media
### komendy magento


ln -sf releases/$RELEASE current
