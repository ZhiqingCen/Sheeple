#!/bin/dash

echo "testing \$(())"
echo "--------------------------\n"

echo "addition=$((1+2))" >addition.sh
echo "echo \"addition=\$((1+2))\" >addition.sh"
echo "./sheeple.pl addition.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl addition.sh`"
echo "Expected output:"
echo "->    \$addition = 3;"
rm addition.sh
