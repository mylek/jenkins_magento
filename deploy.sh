RELEASE=$1
cd /var/www/html

mkdir releases/$RELEASE
tar -xzf tmp/$RELEASE.tar.gz -C releases/$RELEASE --strip-components=1

ln -sf share/var releases/$RELEASE/var
ln -sf share/var releases/$RELEASE/app/etc/env.php
ln -sf share/pub/media releases/$RELEASE/pub/media
### komendy magento


ln -sf releases/$RELEASE current

rm -rf tmp/$RELEASE.tar.gz

### Remove dir not 3 last
cd releases
find . -maxdepth 1 -mindepth 1 -type d -printf "%T+ %f\0" | sort -z | head -z -n -3 | cut -z -d' ' -f 2- | xargs -0 rm -rf
cd ..

exit
