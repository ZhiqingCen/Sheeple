#!/bin/dash

echo "testing if function"
echo "--------------------------\n"

# i got the correct output when I run ./sheeple.pl directly
# but something went wrong when calling it in test scripts
# it can't print "\n" as a string

echo "if [ 0 -le 1 ]\nthen\n    echo function succeed\nfi\n" >if.sh
echo "cat if.sh\n"
cat if.sh
# echo "echo hi there >echo.sh"
echo "./sheeple.pl if.sh"
echo "It produced the following output:"
echo "`./sheeple.pl if.sh`\n"
echo "Expected output:"
echo "if (0 <= 1) {\n    print \"function succeed\\\n\";\n}"
rm if.sh
