use lib './lib';
#use LEOCHARRE::Test 'no_plan';
use Test::Simple 'no_plan';

use strict;
use Zack::File2Text 'file2text';
use Zack::File2Text::Cached;
use Cwd;

sub ok_part { print STDERR "\n==\n@_\n\n"; 1 }

#ok_mysqld() or die;

my $t = Zack::File2Text::Cached->new({ abs_conf  => './t/mysql_credentials.conf' });
ok $t, 'instanced';

ok( $t->dbh, "can get dbh connection") or die("cant connect to db, is there a testing database?\n\n\n");

ok_part("RESET DB from SCRACTCH");
ok( $t->_dbsetup_reset ,"reset db");

ok_part("GET LIST OF SOURCE FILES..");

# we do hdreceipt later.. it's a problem file.
my @files = grep { !/CVS\// and !/hdreceipt/ } sort split( /\n/, `find ./t/testdocs -type f`);

ok_part("TEST THEM");

testone($_) for @files;
use Cwd;


=poc
# I DONT GET IT
what is happening is that testing a pdf, it messes up in PDF::GetImages
but if i use zack command line to a file, it works fine!
and PDF::OCR2 works adn tests fine too.. this is bonkers strange



ok_part("THIS ONE IS CAUSING PROBLEMS");
#$PDF::OCR2::NO_TRASH_CLEANUP = 1;
$PDF::OCR2::DEBUG = 1;
$Image::OCR::Tesseract::DEBUG = 1;
$PDF::OCR2::Page::DEBUG = 1;
$PDF::GetImages::DEBUG = 1;

$Zack::File2Text::DEBUG = 1;

my $text = file2text( cwd() .'/t/testdocs/hdreceipt.pdf');
ok( $text , "have text via procedural");
my $le = length $text;
ok( $le, "have length $le");


#ok_part("VIA NON PROC");
#testone(cwd().'/t/testdocs/hdreceipt.pdf');

=cut

exit;




sub testone { 
   my $abs = shift;
   
   require Zack::File2Text::Base;

   my $cwd = cwd();
   print STDERR "\n--------------------------------\nABS : $abs\n";
   printf STDERR "      ( cwd: %s ) \n", cwd();
   my $sum = Zack::File2Text::Base::sumcli($abs);


   ok( ! $t->get($sum), "get($sum) fails, no insert yet");
   #ok( ! $t->get($abs), "get() fails, no insert yet");
   #printf STDERR "      ( cwd: %s ) \n", cwd();

   ok( ! $t->exists($sum), "exists($sum) returns false, does not exist yet");

   #ok( ! $t->exists($abs), "exists() returns false, does not exist yet");
   #printf STDERR "      ( cwd: %s ) \n", cwd();

   ok $t->file2text($abs);
   #printf STDERR "      ( cwd: %s ) \n", cwd();

   ok( $t->exists($sum), "exists($sum) returns true");
   #ok( $t->exists($abs), "exists() returns true");
   #printf STDERR "      ( cwd: %s ) \n", cwd();


   my $cnow = $t->records_count;
   ok(1,"count now is $cnow");

}







$t->dbh->disconnect;

exit;


