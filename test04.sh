#!/bin/dash

echo "testing read"
echo "--------------------------\n"

echo "read line" >read.sh
echo "echo read line >read.sh"
echo "./sheeple.pl read.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl read.sh`"
echo "Expected output:"
echo "->    \$line = <STDIN>;\nchomp \$line;"
rm read.sh
