use Test::Simple 'no_plan';
use strict;
use lib './lib';
use Zack::File2Text 'file2text';





my $output = file2text('./t/testdocs/emplyeelist.xls');
ok $output;

print STDERR "OUTPUT\n\n$output\n\n";

