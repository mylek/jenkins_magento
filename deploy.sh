RELEASE=$1
SERVER_DIR=$2
cd $SERVER_DIR

### create release dir and unzip
mkdir $SERVER_DIR/releases/$RELEASE
tar -xzf $SERVER_DIR/tmp/$RELEASE.tar.gz -C releases/$RELEASE --strip-components=1

### create assets symlinks
#ln -sf $SERVER_DIR/share/var/ $SERVER_DIR/releases/$RELEASE/
#ln -sf $SERVER_DIR/share/env.php $SERVER_DIR/releases/$RELEASE/app/etc/env.php
#ln -sf $SERVER_DIR/share/pub/media $SERVER_DIR/releases/$RELEASE/pub/

### komendy magento
#cd $SERVER_DIR/releases/$RELEASE
#echo "bin/magento setup:upgrade --keep-generated"
#cd $SERVER_DIR
#sudo chown -R www-data:www-data *

### create core symlink
#sudo rm -fr $SERVER_DIR/current
#ln -sf $SERVER_DIR/releases/$RELEASE $SERVER_DIR/current
ln -sf /var/www/spamgwozd.chickenkiller.com/releases/1742464086 /var/www/spamgwozd.chickenkiller.com/current
echo "ln -sf $SERVER_DIR/releases/$RELEASE $SERVER_DIR/current"

### restart services
#echo "sudo /etc/init.d/php8.1-fpm restart"

### remove archived files
rm -rf $SERVER_DIR/tmp/$RELEASE.tar.gz

### Deletes old releases folders leaving the last 3
cd $SERVER_DIR/releases
find . -maxdepth 1 -mindepth 1 -type d -printf "%T+ %f\0" | sort -z | head -z -n -3 | cut -z -d' ' -f 2- | xargs -0 rm -rf
cd $SERVER_DIR

exit
