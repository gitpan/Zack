package Zack::File2Text::Base;
use strict;
use Exporter;
use Carp;
use Cwd;
use vars qw(@ISA @EXPORT);
@ISA = qw/Exporter/;
@EXPORT = qw(_sumordie sumcli escape_filename _arg2sum _slurp _dump _sumokordie _arg2sumordie);


sub _sumokordie { $_[0] and $_[0]=~/^[0-9a-f]{32}$/ or confess("invalid sum arg '@_'"); $_[0] }

sub _arg2sumordie { my $sum = _arg2sum($_[0]) or confess("invalid sum arg '@_'"); $sum }

sub sumcli {
   my $abs = escape_filename($_[0]);
   my $r = `md5sum $abs`;
   chomp $r; 
   $r=~s/\s.*//;

   $r=~s/^\W//;
   $r=~/^([0-9a-f]{32})/;
   return $1; 
}

sub escape_filename {
   my $arg = $_[0];
   $arg=~s/([^a-zA-Z0-9\/])/\\$1/g;
   # TODO: check that this escaping works better
   return $arg;
}


# arg is sum, string with sum, or filepath
sub _arg2sum {
   my $arg = shift;
   if( $arg=~/\b([0-9a-f]{32})\b/  ){
      return $1;
   }
   my $f = Cwd::abs_path($arg) or return;
   -f $f or return;
   return sumcli($f);
}

sub _slurp {
   my $a = shift;

   local $/;
   open(F,'<',$a) or die("not on disk '$a'? error: $!");
   my $t = <F>;
   close F;
   return $t;
}


sub _dump {
   my ($abs, $cont) = @_;

   open(F,'>',$abs) or die($!);
   print F $cont;
   close F;
   1;
}






1;

__END__

=pod

=head1 NAME

Zack::File2Text::Base

=head1 DESCRIPTION

Private.

=head1 SUBS

=head2 sumcli()

Arg is filepath, returns gnu/md5sum digest.

=head2 excape_filename()

Arg is filename, escapes for shell using, returns string.

=head2 _slurp()

Arg is path to file.

=head2 _dump()

Arg is path and text content.

=head1 SEE ALSO

L<Zack>

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


