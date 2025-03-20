SERVER_DIR=$1

### Deletes old releases folders leaving the last 3
cd $SERVER_DIR/releases
find . -maxdepth 1 -mindepth 1 -type d -printf "%T+ %f\0" | sort -z | head -z -n -3 | cut -z -d' ' -f 2- | xargs -0 rm -rf
cd $SERVER_DIR

exit
