package Zack::File2Text::Cached;
use strict;
use Zack::File2Text::Base;
use Zack::File2Text;
use Exporter;
use vars qw(@ISA @EXPORT_OK $VERSION $TABLE_NAME $ABS_CACHE);
@ISA = qw/Exporter/;
@EXPORT_OK = qw(_fs_set);
use Carp;
use LEOCHARRE::Class2;
use LEOCHARRE::Debug;


__PACKAGE__->make_constructor_init;
__PACKAGE__->make_accessor_setget({
   'dbh'  => undef, #sub { die("missing dbh argument to constructor") }, 
   errstr => undef,
   storage_type => 'dbh', #or fs
   abs_conf => '/etc/zack.conf',
   cache_override => 0,
   });

$VERSION = sprintf "%d.%02d", q$Revision: 1.6 $ =~ /(\d+)/g;
$ABS_CACHE = '/tmp/zack_cache';
$TABLE_NAME = 'digestsum2textcontent';

sub init {
   my $self = shift;
   if (! $self->dbh ){
      ### no dbh
      require YAML::DBH;
      $self->dbh( YAML::DBH::yaml_dbh($self->abs_conf) ) or die; 
   }
}
sub exists {
   my ($self, $sum) = ($_[0], _arg2sumordie($_[1]));

   $self->{sthe} ||= $self->dbh->prepare(
      "SELECT count(*) FROM $TABLE_NAME WHERE sum = ? LIMIT 1"
   );
   $self->{sthe}->execute($sum);
   my $e = $self->{sthe}->fetch->[0];
   $self->{sthe}->finish;
   $e || 0;

}

sub records_count {
   my($self) = @_;
   $self->{sthn} ||= $self->dbh->prepare(
      "SELECT count(*) FROM $TABLE_NAME"
   );
   $self->{sthn}->execute;
   my $e = $self->{sthn}->fetch->[0];
   $self->{sthn}->finish;
   $e || 0;
}

sub get {
   my ($self, $sum) = ($_[0], _arg2sumordie($_[1]));

   $self->{sth} ||= 
      $self->dbh->prepare("SELECT txt FROM $TABLE_NAME WHERE sum = ? LIMIT 1");   
   $self->{sth}->execute($sum);
   my $row = $self->{sth}->fetch;
   $self->{sth}->finish;
   $row->[0];
}


sub set {
   my ($self, $sum) = ($_[0], _arg2sumordie($_[1]));
   my $txt = $_[2];
   
   # TODO test $txt?
   # TODO convert ext to unicode or something??

   # we user REPLACE INTO so if we are updating text, it's ok
   $self->{sthin} ||= 
      $self->dbh->prepare("REPLACE INTO $TABLE_NAME (sum,txt) values (?,?)");
   unless( $self->{sthin}->execute($sum,$txt)  ){
      $self->errstr("Could not insert $sum txt, ".$self->dbh->errstr);
      $self->{sthin}->finish;
      return;
   }
   1;

}

sub delete {
   my ($self, $sum) = ($_[0], _arg2sumordie($_[1]));

   $self->{sthd} ||= 
      $self->dbh->prepare("DELETE FROM $TABLE_NAME WHERE sum = ? LIMIT 1");
   $self->{sthd}->execute($sum);
   $self->{sthd}->finish;   
   1;
}





sub _dbsetup_reset {
   my $self = shift;
   $self->dbh->do("DROP TABLE IF EXISTS $TABLE_NAME");
   $self->_dbsetup_install;
   1;
}

sub _dbsetup_install {
   my $self = shift;
   $self->dbh->do(
      "CREATE TABLE $TABLE_NAME ("
      .'sum VARCHAR(32) PRIMARY KEY NOT NULL,'
      .'txt LONGTEXT NOT NULL )'
   );
   1;
}





#START FS VERSION
sub _fs_delete {   
   unlink _sum2path(@_);
}

sub _fs_exists {
   -f _sum2path(@_);
}

sub _fs_get {
   local $/;
   open(FI,'<', _sum2path(@_)) or warn($!) and return;
   my $t = <FI>;
   close FI;
   return $t;
}



sub _fs_set {
   my($sum,$text)=@_;
   open(FI,'>',_sum2path($sum)) or die($!);
   print FI $text;
   close FI;
   1;
}



sub _fs_reset {

   # slightly dangerous :
   # -d $a ? system('rm','-rf',$a) == 0 ? 1 ;
   
   if ( -d $ABS_CACHE ){
      opendir(DIR,$ABS_CACHE) or die($!);
      while ( my $f = <DIR> ){
         unlink $f;
      }
      closedir DIR;
      return 1;
   }
   mkdir $ABS_CACHE;
   #$self->_fs_install;
}

sub _fs_install {
   mkdir $ABS_CACHE;
}

sub _sum2path {
   _sumokordie($_[0]);  
   "$ABS_CACHE/$_[0]";   
}

sub _fs_records_count {
   opendir(DIR,$ABS_CACHE) or die($!);
   my $c;
   while( <DIR> ) { $c++; }
   closedir DIR;
   return $c;
}

# END FS VERSION








# START WRAPPER

sub file2text {
   my $self = shift;
   my $abs_file = Cwd::abs_path($_[0]);
   debug(__PACKAGE__."::file2text() '$abs_file'");
   my $sum = sumcli($abs_file);
   my $text;


   if( $text = $self->get($sum) ){
      
      ### was cached
      if( $self->cache_override ){
         debug('was cached');
         $self->delete($sum);
         undef $text;
      }
      else {
         return $text;
      }
   }

   ### was not cached


   $text = Zack::File2Text::file2text($abs_file) or return;

   $self->set($sum,$text);
   $text;   
}

# END WRAPPER




1;

__END__

=pod

=head1 NAME

Zack::File2Text::Cached

=head1 DESCRIPTION

The digest is not of the text stored. The digest is of what we got the text *from*.
This is meant to be used via Zack module/namespace. Private.

=head1 METHODS

=head2 new()

   new({ dbh => $dbh });

=head2 file2text()

Argument is abs path to file on disk.
If not cached, will regenerate using Zack::File2Text.

   $self->file2text('/path/to/file.pdf');

If it returns nothing, there might not be an extractor for the filetype.
Check $Zack::File2Text::errstr

Returns text cached.

=head2 get()

Argument is sum. 
Returns text cached.

   my $text = $self->get('87c1e9938cd60077f3cdfbda765d8695');
   my $text = $self->get('./file.txt');


=head2 set()

Argument is sum and text.

   $self->set('87c1e9938cd60077f3cdfbda765d8695','text content');
   $self->set('./file.txt','text content');


=head2 delete()

Argument is sum.

   $self->delete('87c1e9938cd60077f3cdfbda765d8695');   
   $self->delete('./file.txt');

=head2 exists()

Argument is sum.
Returns boolean. 

   $self->exists('87c1e9938cd60077f3cdfbda765d8695');   
   $self->exists('./file.txt');


=head2 records_count()

Returns count of records.

=head1 DEBUG ETC

Debug on:

   $Zack::File2Text::Cached::DEBUG = 1;

Table name:

   $Zack::File2Text::Cached::TABLE_NAME;

=head1 WHAT IS SUM AND WHAT IS TEXT

Sum is a md5 sum hex digest, 32 chars long, as output by cli gnu md5sum utility.

Text is text content extracted from a source image or html page, etc.

=head1 CAVEATS

For the methods that take a sum as argument, you can optionally provide a file path as argument,
and we try to use md5sum to get the sum. 
This is for covenience.


If your output is larger then 1 meg for a file, you will need to change the 
max_allowed_packet_size in your mysqld server.

   # locate my.cnf

Add a line that says
   
   max_allowed_packet=5M

Restart the daemon

   # /etc/init.d/mysqld restart

The default is 1

=head1 SEE ALSO

L<Zack>
L<zack.conf>



=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=head1 COPYRIGHT

Copyright (c) Leo Charre. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms and conditions as Perl itself.

This means that you can, at your option, redistribute it and/or modify it under either the terms the GNU Public License (GPL) version 1 or later, or under the Perl Artistic License.

See http://dev.perl.org/licenses/

=head1 DISCLAIMER

THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

Use of this software in any way or in any form, source or binary, is not allowed in any country which prohibits disclaimers of any implied warranties of merchantability or fitness for a particular purpose or any disclaimers of a similar nature.

IN NO EVENT SHALL I BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION (INCLUDING, BUT NOT LIMITED TO, LOST PROFITS) EVEN IF I HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE

=cut


