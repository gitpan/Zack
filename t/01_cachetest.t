use lib './lib';
use Test::Simple 'no_plan';
use strict;
use Zack::File2Text::Cached;

use YAML::DBH;



my $conf = './t/mysql_credentials.conf';

if( !-f $conf ){
   ok 1, "conf file missing, $conf, skipping tests.";
   exit;
}



my $dbh = YAML::DBH::yaml_dbh('./t/mysql_credentials.conf');
ok $dbh, 'dbh connect';

my $t = Zack::File2Text::Cached->new({ dbh  => $dbh });
ok $t, 'instanced';


ok( $t->_dbsetup_reset ,"reset db");



my @files = sort split( /\n/, `find ./t/ -type f -name "bogus*"`);


#opendir(DIR,'./t/archive') or die("run test 00 first, t/archive dir not there");
#my @files = map { "./t/archive/$_" } grep { /bogus/ } readdir DIR;
#closedir DIR;
#
#opendir(DIR2,'./t/archive_larger') or die("run test 00 first, t/archive_larger dir not there");
#push @files, ( map { "./t/archive_larger/$_" } grep { /bogus/ } readdir DIR2 );
#closedir DIR2;

testone($_) for @files;

exit;

sub testone { 
   my $abs = shift;
   print STDERR "\nABS : $abs\n";

   my $txt = _slurp( $abs ) or die("could not slurp $abs");
   my $sum = _sum($abs);

   ok( ! $t->get($sum), "get() fails, no insert yet");

   ok( ! $t->exists($sum), "exists() returns false, does not exist yet");

   ok $t->set($sum, $txt), 'set()';

   my $_get;

   ok( $_get = $t->get($sum), "get()");

   unless( ok( $_get eq $txt,"original text same as stored") ){

      _dump( './t/tmp_1', $_get ); 
      _dump( './t/tmp_2', $txt ); 
      ok(1, "saved ./t/tmp_1 and t/tmp_2");
   
      ## $_get
      ## $txt

      die;
   }

   ok( $t->exists($sum), "exists() returns true");

   my $cnow = $t->records_count;
   ok(1,"count now is $cnow");
}







$dbh->disconnect;

exit;

sub _dump {
   my ($abs, $cont) = @_;

   open(F,'>',$abs) or die($!);
   print F $cont;
   close F;
   1;
}


sub _slurp {
   my $a = shift;

   local $/;
   open(F,'<',$a) or die("missing $a? $!");
   my $t = <F>;
   close F;
   return $t;
}


sub _sum {
   my $abs = shift;
   -f $abs or die("not there, $!");
   my $out = `md5sum '$abs'`;
   chomp $out;

   $out=~/(\w{32}) / or die;
   return $1;
}


