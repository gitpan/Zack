use lib './lib';
use Test::Simple 'no_plan';
use strict;

my $sum;

for (qw(
4ae6c9b6a3962d0ee153385a6aebc3b7.txt 
raph-4ae6c9b6a3962d0ee153385a6aebc3b7.in
4ae6c9b6a3962d0ee153385a6aebc3b7
incredible.4ae6c9b6a3962d0ee153385a6aebc3b7
)){
   
   ok( $sum = _sum_from_string($_) );
   ok($sum, "for $sum, $_");

}

sub _sum_from_string {
   my $string = shift;
   $string=~s/^.+\///;
   $string=~/\b(\w{32})\b/ or return;
   $1;
}


