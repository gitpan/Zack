use Test::Simple 'no_plan';
use strict;
use lib './lib';
use LEOCHARRE::Dir 'lsfa';

ok 1, 'started';
for my $bin ( grep { /\/zack/ } lsfa('./bin') ){
   ok( system('perl', $bin, '-h') == 0 , "system $bin -h ok");

}




