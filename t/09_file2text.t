use Test::Simple 'no_plan';
use strict;
use lib './lib';
use LEOCHARRE::Dir 'lsfa';
use Zack::File2Text 'file2text';

#use Smart::Comments '###';


$Zack::File2Text::DEBUG =  1;

my @f = lsfa('./t/testdocs');


for my $f ( @f){
   printf STDERR "\n%s\n", '-'x70;
   ok(1, "file $f");
   my $t;

   ok( $t = file2text($f),'file2text()')
      or warn("Cannot get text output for '$f'\n");
      

  ## $t
  #
  print STDERR "\n\n===========================================\n\n\n";

}




