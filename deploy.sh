RELEASE=$1
cd /var/www/spamgwozd.chickenkiller.com

### create release dir and unzip
mkdir releases/$RELEASE
tar -xzf tmp/$RELEASE.tar.gz -C releases/$RELEASE --strip-components=1

### create assets symlinks
ln -sf share/var releases/$RELEASE/var
ln -sf share/env.php releases/$RELEASE/app/etc/env.php
ln -sf share/pub/media releases/$RELEASE/pub/media

### komendy magento
cd releases/$RELEASE
echo "bin/magento setup:upgrade --keep-generated"
cd /var/www/spamgwozd.chickenkiller.com

### create core symlink
rm current
ln -sf releases/$RELEASE current

### restart services
echo "sudo /etc/init.d/php8.1-fpm restart"

### remove archived files
rm -rf tmp/$RELEASE.tar.gz

### Deletes old releases folders leaving the last 3
cd releases
find . -maxdepth 1 -mindepth 1 -type d -printf "%T+ %f\0" | sort -z | head -z -n -3 | cut -z -d' ' -f 2- | xargs -0 rm -rf
cd /var/www/spamgwozd.chickenkiller.com

exit
