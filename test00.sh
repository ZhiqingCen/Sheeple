#!/bin/dash

echo "testing variables"
echo "--------------------------\n"

echo "number=1" >number.sh
echo "echo \"number=1\" >number.sh"
echo "./sheeple.pl number.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl number.sh`"
echo "Expected output:"
echo "->    \$number = 1;"
rm number.sh

echo "\n--------------------------\n"
echo "word=abc" >word.sh
echo "echo \"word=abc\" >word.sh"
echo "./sheeple.pl word.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl word.sh`"
echo "Expected output:"
echo "->    \$word = 'abc';"
rm word.sh

# echo "testing error messages"
# echo "./sheeple.pl sheeple.pl"
# echo "It produced the following output:"
# echo "->    `./sheeple.pl sheeple.pl`"
# echo "Expected output:"
# echo "->    usage: ./sheeple.pl <filename of shell script only>"
