#!/usr/bin/perl
use Test::Simple 'no_plan';
use lib './lib';
use strict;
#use Smart::Comments '###';
use warnings;
use Getopt::Std::Strict 'c:hXP';
use Zack::File2Text::Cached;
sub bad;
sub good;


print usage() and exit if $opt_h;
$opt_c ||= '/etc/zack.conf';

ok( -f $opt_c, "have on disk: '$opt_c'.");

ok_mysqld() or bad;


my $t = Zack::File2Text::Cached->new({ abs_conf => $opt_c });
ok( $t, 'instanced') or bad;
my $table_name = $Zack::File2Text::Cached::TABLE_NAME;
ok($table_name, "table name $table_name") or bad;

ok( $t->dbh,'can get dbh handle') or bad;

unless( have_table( $table_name ) ){
   ok( $t->_dbsetup_install, "making sure it exists." ) or bad;
}


if($opt_P){
   
    $t->_dbsetup_reset;
   
}


ok( have_table($table_name),"have table $table_name" ) or bad;
ok( ! have_table('bogust9blename2342'),"dont have table with bogus name") or bad;

$t->dbh->disconnect;

good;
exit;









sub have_table {
   my $table_name = shift;

   my $sth = $t->dbh->table_info( undef,undef,$table_name,undef) or return;
   my $r = $sth->fetchall_arrayref or return;

   #say("described table '$table_name', $r");
   ### $r
   $r and scalar @$r or return 0;
   
   1;

}



sub usage {

   qq{$0 - install or reset cache setup

DESCRIPTION

Install database table setup, will not override existing.

PARAMETERS

   -c path to conf file with mysql credentials
      default is /etc/zack.conf

OPTION FLAGS

   -h help
   -P drops entire database and rebuilds. CAUTION.

};
}

sub say { print STDERR "@_\n"; 1 }
sub bad { say("\nCHECK FAILED.\n"); exit 1 }
sub good { say("\nCHECK PASSED.\n"); exit }

sub ok_mysqld {

   my $mysqld  = '/etc/init.d/mysqld';
   if ( -e $mysqld ){
      my $status = `$mysqld status`;
      ok( $status=~/is running/,"$mysqld status, is running") or bad;
   }
}






