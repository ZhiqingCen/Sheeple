#!/usr/bin/perl -w

# translate only shell script
if ($ARGV[0]) {
    $name = $ARGV[0];
    @file = split('/', $name);
    if (! ($file[@file - 1] =~ /.sh$/)) {
        print("usage: ./sheeple.pl <filename of shell script only>\n");
        exit 1;
    }
}


$indent = 0;

while ($line = <>) {
    chomp $line;

    # subset 0
    if ($line =~ "#!/bin/*") {
        # eg. #!/bin/sh or #!/bin/bash or  #!/bin/dash
        print("#!/usr/bin/perl -w\n");

    } elsif ($line =~ "# .*") {
        # leave comments unchanged
        $line =~ s/^ {4}//;
        if ($indent == 1) {
            print("    ");
        }
        print("$line\n");

    } elsif ($line =~ "echo .*") {
        # eg. echo 'hello world'
        $line =~ s/echo //;
        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            # $arg =~ s/$@/\@ARGV/;
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation
        if ($indent == 1) {             # add indentation
            print("    ");
        }

        print("print \"$line\\n\";\n"); # print "hello world\n";

    } elsif (($line =~ "ls .*") || ($line =~ /ls$/) || ($line =~ /pwd$/) || ($line =~ /id$/) || ($line =~ /date$/)) {
        # eg. ls / ls -l /dev/null / pwd / id / date
        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(\(.*\)\)/) {
            $line =~ s/\$\(\(/\$/;      # $((line+1)) change to $line + 1
            $line =~ s/\)\)//;
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        if ($indent == 1) {             # add indentation
            print("    ");
        }
        print("system \"$line\";\n");   # system "ls /dev/null";

    } elsif (($line =~ ".*=.*") && (!($line =~ /if (test|\[)/)) && (!($line =~ /elif (test|\[)/)) && (!($line =~ /while (test|\[)/))) {
        # eg. a=1
        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;

        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(\(.*\)\)/) {
            $line =~ s/\$\(\(/\$/;      # $((line+1)) change to $line + 1
            $line =~ s/\)\)//;
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        if ($indent == 1) {             # add indentation
            print("    ");
        }

        @array = split('=', $line);     # assign variable
        print("\$");
        if ($array[1] =~ /\$/) {
            print join(' = ', @array);
            print(";\n");
        } else {
            if ($array[1] =~ /\d/) {
                print join(' = ', @array);
                print(";\n");
            } else {
                print join(' = \'', @array);
                print("\';\n");
            }
        }

    } elsif ($line =~ "cd .*") {
        # eg. cd examples
        $line =~ s/cd //;

        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        if ($indent == 1) {             # add indentation
            print("    ");
        }
        print("chdir \'$line\';\n");    # cd /tmp

    } elsif ($line =~ /^\s*$/) {
        # empty line
        print("\n");

    } elsif ($line =~ "exit .*") {
        # eg. exit 0
        $line =~ s/^ {4}//;
        if ($indent == 1) {
            print("    ");
        }
        print("$line;\n");              # exit 0;

    } elsif ($line =~ "read .*") {
        # eg. read line
        $line =~ s/read //;

        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        if ($indent == 1) {             # add indentation
            print("    \$$line = <STDIN>;\n");
            print("    chomp \$$line;\n");
        } else {
            print("\$$line = <STDIN>;\n");
            print("chomp \$$line;\n");
        }


    } elsif ($line =~ "for .* in .*") {
        # eg. for word in Houston 1202 alarm
        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        @array = split(' ', $line);
        print("foreach \$$array[1] (");
        foreach (@array) {
            if (($_ eq $array[3]) && ($_ =~ /\.\D/)) { # for c_file in *.c
                print("glob(\"$array[3]\")");
                last;                   # break
            } elsif (($_ ne $array[0]) && ($_ ne $array[1]) && ($_ ne $array[2]) && ($_ ne $array[@array - 1]) && ($_ =~ /\d/)) {
                print("$_, "); # print int
            } elsif (($_ ne $array[0]) && ($_ ne $array[1]) && ($_ ne $array[2]) && ($_ ne $array[@array - 1])) {
                print("\'$_\', "); # print string
            } elsif (($_ eq $array[@array - 1])) {   # last one without comma
                if (($_ =~ /\d/)) {
                    print("$_");        # print int
                } else {
                    print("\'$_\'");    # print string
                }
            }
        }
        print(") {\n");
        $next_line = <>;

        if ($next_line eq "do") {       # skip
            $next_line = <>;
        } elsif ($next_line eq "done") {
            print("}");                 # }
            $indent = 0;
        } else {
            $indent = 1;                # add indentation
        }

    } elsif ($line =~ /while (test|\[)/) {
        # eg. while test $number -le $finish
        $line =~ s/test//;
        $line =~ s/\[//g;
        $line =~ s/\]//g;
        $line =~ s/while //;

        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        @array = split(' ', $line);
        print("while (");
        foreach (@array) {
            if (($_ eq "$array[1]") && ($_ eq "-le") && ($_ =~ /\D/)) {
                $_ = "<=";
                print(" $_");
            } elsif (($_ eq "$array[1]") && ($_ eq "-ge") && ($_ =~ /\D/)) {
                $_ = "=>";
                print(" $_");
            } elsif (($_ eq "$array[1]") && ($_ eq "-lt") && ($_ =~ /\D/)) {
                $_ = "<";
                print(" $_");
            } elsif (($_ eq "$array[1]") && ($_ eq "-gt") && ($_ =~ /\D/)) {
                $_ = ">";
                print(" $_");
            } elsif (($_ eq "$array[1]") && ($_ eq"-eq") && ($_ =~ /\D/)) {
                $_ = "==";
                print(" $_");
            } elsif (($_ eq "$array[1]") && ($_ eq "-ne") && ($_ =~ /\D/)) {
                $_ = "!=";
                print(" $_");
            } elsif ($_ eq "$array[0]") {
                print("$_");
            } else {
                print(" $_");
            }
        }

        $next_line = <>;
        if ($next_line eq "do") {       # skip
            $next_line = <>;
        } else {
            $indent = 1;                # add indentation
        }
        print(") {\n");

    } elsif (($line =~ /if (test|\[)/) || ($line =~ /elif (test|\[)/)) {
        # eg. if test Andrew = great
        $line =~ s/test//;
        $line =~ s/\[//g;
        $line =~ s/\]//g;

        $arg = $line;                   # $1 change to $ARGV[1]
        if ($arg =~ /\$\d/) {
            $arg =~ ($line =~ /(\d+) /g);
            $arg =~ s/\D//g;
            $arg = $arg - 1;
            $line =~ s/\$(\d+)/\$ARGV[$arg]/;
        } elsif ($arg =~ "$@") {
            $arg =~ ($line =~ /$@ /g);
            $arg =~ s/\$\@//g;
            $arg = "\@ARGV";
            $line =~ s/\$\@/$arg/;
        }

        $line =~ s/^ {4}//;             # remove indentation

        if ($line =~ "\'.*\"") {        # if " and ' appear together
            $line =~ s/'//g;
            $line =~ s/"/\\"/g;
        } else {                        # if only " or ' appear
            $line =~ s/'//g;
            $line =~ s/"//g;
        }

        if ($line =~ /`expr/) {         # `expr $line` remove `expr `
            $line =~ s/expr //;
            $line =~ s/`//g;
        } elsif ($line =~ /`.*`/) {     # `$line` remain unchange
        } elsif ($line =~ /\$\(.*\)/) { # $(line) change to `$line`
            $line =~ s/\$\(/`/;
            $line =~ s/\)/`/;
        }

        if ($line =~ "elif .*") {
            print("} elsif (");
        } else {
            print("if (");
        }
        @array = split(' ', $line);
        $stop=0;
        if ($array[2] =~ /!=/) {
            if ($array[1] =~ /\d/) {
                print("$array[1]");
            } else {
                print("\'$array[1]\'");
            }
            print(" ne ");
            if ($array[3] =~ /\d/) {
                print("$array[3]");
            } else {
                print("\'$array[3]\'");
            }
            $stop=1;
        } elsif ($array[2] =~ /=/) {
            if ($array[1] =~ /\d/) {
                print("$array[1]");
            } else {
                print("\'$array[1]\'");
            }
            print(" eq ");
            if ($array[3] =~ /\d/) {
                print("$array[3]");
            } else {
                print("\'$array[3]\'");
            }
            $stop=1;
        }

        if ($stop != 1) {
            $line =~ s/elif//;
            $line =~ s/if//;
            @array = split(' ', $line);
            for (@array) {
                if (($_ eq "$array[1]") && ($_ eq "-le") && ($_ =~ /\D/)) {
                    $_ = "<=";
                    print(" $_");
                } elsif (($_ eq "$array[1]") && ($_ eq "-ge") && ($_ =~ /\D/)) {
                    $_ = "=>";
                    print(" $_");
                } elsif (($_ eq "$array[1]") && ($_ eq "-lt") && ($_ =~ /\D/)) {
                    $_ = "<";
                    print(" $_");
                } elsif (($_ eq "$array[1]") && ($_ eq "-gt") && ($_ =~ /\D/)) {
                    $_ = ">";
                    print(" $_");
                } elsif (($_ eq "$array[1]") && ($_ eq "-eq") && ($_ =~ /\D/)) {
                    $_ = "==";
                    print(" $_");
                } elsif (($_ eq "$array[1]") && ($_ eq "-ne") && ($_ =~ /\D/)) {
                    $_ = "!=";
                    print(" $_");
                } elsif (($_ eq "$array[0]") && ("$_" =~ /-*/) && ($_ =~ /\D/)) {
                    print("$array[0] \'$array[1]\'");
                    last;
                } elsif ($_ eq "$array[0]") {
                    if ($_ =~ /\d/) {
                        print("$_");
                    } else {
                        print("\'$_\'");
                    }
                } else {
                    if ($_ =~ /\d/) {
                        print(" $_");
                    } else {
                        print(" \'$_\'");
                    }
                }
            }
        }
        $next_line = <>;

        if ($next_line eq "then") {     # skip
            $next_line = <>;
        } else {
            $indent = 1;                # add indentation
        }
        print(") {\n");

    } elsif ($line =~ /else$/) {
        # eg. else
        print ("} else {\n");
        $indent = 1;                    # add indentation

    } elsif (($line =~ /done$/) || ($line =~ /fi$/)) {
        # eg. done / fi
        print("}\n");                   # close curly braces of for or if function
        $indent = 0;                    # remove indentation

    } elsif (($line =~ /do$/) || ($line =~ /then$/)) {
        # eg. do / then
    } else {
        # untranslated shell construct
        print("# untranslated shell construct: $line\n");
    }
}
