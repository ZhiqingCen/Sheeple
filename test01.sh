#!/bin/dash

echo "testing echo"
echo "--------------------------\n"

# i got the correct output when I run ./sheeple.pl directly
# but something went wrong when calling it in test scripts
# it can't print "\n" as a string

echo "echo hi there" >echo.sh
echo "echo hi there >echo.sh"
echo "./sheeple.pl echo.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl echo.sh`"
echo "Expected output:"
echo "->    print \"hi there\\\n;\""
rm echo.sh

echo "\n--------------------------\n"
echo "echo \$1" >echo.sh
echo "echo \$1 >echo.sh"
echo "./sheeple.pl echo.sh"
echo "It produced the following output:"
echo "->    `./sheeple.pl echo.sh`"
echo "Expected output:"
echo "->    print \"\$ARGV[0]\\\n;\""
rm echo.sh
