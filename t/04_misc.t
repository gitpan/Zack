use lib './lib';
use Test::Simple 'no_plan';
use strict;
use Zack::File2Text 'known_exts';
use Smart::Comments '###';

my @exts = known_exts();

ok @exts;
ok scalar @exts;

### @exts
