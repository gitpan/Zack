use strict;
use vars qw(@CHARS $CHARLAST $MAXLENGTH $DEBUG);
@CHARS = ( 'a' .. 'z', 0 .. 9);
#$CHARLAST = ((scalar @CHARS) - 1) or die;
$CHARLAST = scalar @CHARS;
$MAXLENGTH = 1000000;



sub make_bogus_file {
   my ($path, $size) = @_;
   $path or die("missing path argument");
   
   warn("$path already on disk") and return if -e $path;

   
   # size should be in k?
   
   open(F,'>',$path) or die("cant open for writing '$path', $!");
   print F randstring($size);
   close F;

   # cant return size here so simply..
   unless ( $size ){ # it may not have been defined..
      $size = filesize($path);
   }
   return $size;

   
}

sub filesize {
   my $abs = shift;

   my $size = (stat($abs))[7];  # in bytes

   return $size;
}


sub randstring {
   my $length = shift;   
   $length ||= int( rand($MAXLENGTH) + 1 );
   print STDERR "randstring() length: $length\n" if $DEBUG;
   my $string;
   for( 0 .. ($length - 1)){
      $string.=$CHARS[int(rand($CHARLAST))];
   }
   return $string;


}





sub make_bogus_files {
   my ($dirpath, $filecount, $totalbytes) = @_; 
   $filecount or die'missing filecount';
   $filecount > 2 or die 'filecount low'; # hmmm


   # resolve ammount

   $totalbytes ||= 1000;
   print STDERR "\n\ninitial bytes arg at $totalbytes\n" if $DEBUG;
   $totalbytes=~/^\d/ or die("invalid sie ammount spec $totalbytes");

   my %unit = (
      B => 1,                          # in bytes
      K => 1024,                       # kilobytes
      M => ( 1024 * 1024 ),            # megabytes
      G => ( 1024 * 1024 * 1024 ),     # gigabytes - too big.. ??
   );
   if($totalbytes=~s/([BKMG]{1}).*$//i){
      my $unit = $unit{uc($1)};
      print STDERR " [$totalbytes] ";
      $totalbytes = int ($totalbytes * $unit);

      printf STDERR "totalbytes [unit %s] resolved to total bytes: $totalbytes\n", 
         $unit{uc($1)};
   }
   
   $totalbytes and $totalbytes=~/^\d+$/ or die("invalid size resolved: $totalbytes");

   my $wantarray = wantarray;
   my @abs_files;


   -d $dirpath or die("!-d $dirpath");

   # what would the average size be?
   my $average_size = int ($totalbytes / $filecount) + 1;
   $average_size or die("cant resolve average_size");
   print STDERR "average size: $average_size\n";
   
   # we want random sizes.. so we should set the $::MAXLENGTH so it gets us something close
   # toward the end
   
   # I would guess it's the average size x 2 for length, yes.. to get close but random sizes
   local $::MAXLENGTH = ($average_size * 2); 
  
   # decent filenames..
   my $length_of_filename = int( ($filecount * 0.01 ) + 2); 

   my $_totalbytes; # keep track 

   my $_last_size = undef; # if defined, will mean this is the last file to be made

   for ( 0 .. $filecount ){           
           
      my $filename = 'bogus.'.$_.'.'.randstring( $length_of_filename );
      my $abs = "$dirpath/$filename";
      print STDERR "$abs\n" if $DEBUG;
      (push @abs_files, $abs ) if $wantarray;

      my $size = make_bogus_file($abs, $_last_size);
      $_totalbytes+=$size;


      # was this the last file?
      if ($_last_size){
         print STDERR "last size flag is on.. 
         total is $_totalbytes bytes in $filecount files
         total bytes asked for were $_totalbytes\n";
         last;
      }   

          
      # test ourselves
      if( $_totalbytes > $totalbytes){
         die("went over");
      }   
          
      # should the next one be the last file???
      # if the diff between 'total size of files made' and 'target total',
      # is less than the MAXLENGTH, then yes
      my $togo = ($totalbytes - $_totalbytes);
      print STDERR "Togo: $togo\n" if $DEBUG;
      if ($togo <= $::MAXLENGTH){
         print STDERR "Togo is less than maxlength $::MAXLENGTH, we stop after next..\n";
         $_last_size = $togo;
      }   
   } 
   return @abs_files if $wantarray;
   1;
}




1;




__END__

make bogus data of size x
