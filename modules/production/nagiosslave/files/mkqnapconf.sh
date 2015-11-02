echo "naam $1 #zalen $2"
cp default/nas-default$2.conf ./$1.conf
sed -i "s/default/$1/g" $1.conf
