use Test::Simple 'no_plan';
require './t/bogusdata.pl';
use strict;

system('rm -rf ./t/archive');
ok mkdir './t/archive';


my @f;
ok @f = make_bogus_files('./t/archive',10, '80');
ok -f $_, "file $_" for @f;





# make larger file also
system('rm -rf ./t/archive_larger');
ok mkdir './t/archive_larger';

my @f2;
ok @f2 = make_bogus_files('./t/archive_larger',5, '1M');
ok -f $_, "file $_" for @f2;


# make larger file also
system('rm -rf ./t/archive_largerest');
ok mkdir './t/archive_largerest';

#my @f2;
#ok @f2 = make_bogus_files('./t/archive_largerest',3, '3M');
#ok -f $_, "file $_" for @f2;



