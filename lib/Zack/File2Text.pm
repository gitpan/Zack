package Zack::File2Text;
use strict;
use Zack::File2Text::Base;
use LEOCHARRE::Debug;
use LEOCHARRE::HTML::Text;
use Exporter;
use vars qw(%EXTRACT %_EXTRACT @EXPORT_OK @ISA $VERSION $DEBUG $errstr);
$VERSION = sprintf "%d.%02d", q$Revision: 1.14 $ =~ /(\d+)/g;
@ISA = qw/Exporter/;
@EXPORT_OK = qw(file2text known_exts have_extractor);

#TODO , do this with mime instead of extensions! :-)
%EXTRACT = (
      # subname => [ exts ]
      text_from_pdf => [qw(pdf)],
      text_from_img => [qw(jpg jpeg tif tiff pbm ppm)],
      text_from_htm => [qw(htm html shtml asp php)],
      text_from_doc => ['doc'],
      text_from_rtf => ['rtf'],
      text_from_excel => ['xls'],
      text_from_txt => ['txt','msg'],
      text_from_pod => ['pod'], # add pm??
      
);


*text_from_htm = \&LEOCHARRE::HTML::Text::html2txt;

sub known_exts { sort keys %_EXTRACT }

#use Smart::Comments '###';
sub errstr { $errstr = $_[0] if $_[0]; $errstr }

sub have_extractor { _extractor_ref($_[0]) ? 1 : 0 }

sub file2text {
   my $abs_file = shift;
   
   my $extractor = _extractor_ref($abs_file)
      or return;

   no strict 'refs';
   &$extractor($abs_file);

   
}

# arg is ext or filename .. _extractor_ref(pdf) or _extractor_ref(filename.pdf)
sub _extractor_ref {
   my $arg = shift;
   my $ext;

   if ($arg=~/^([a-z0-5]{1,5})/){
      $ext = lc $1;
   }
   elsif ( $arg=~/\.(\w{1,5})$/){
      $ext = lc $1;
   }
   else {
      warn errstr("Can't match file extension in arg '$arg'");
      return;
   }

   my $subname = $_EXTRACT{$ext} 
      or warn errstr("No extractor for ext '$ext'")
      and return;

   debug("Extractor chosen for arg '$arg', $subname");
   $subname;
}

sub known_ext {
   $_[0]=~/\.(\w{1,5})$/ or return;
   $_EXTRACT{lc($1)} or return;
   $1;
}


sub text_from_pdf {
   my $abs_file = shift;
   debug("PDF::OCR2 called");

   require PDF::OCR2;


   my $o = PDF::OCR2->new($abs_file)
      or return;
   
   $o->text;
}

sub text_from_img {
   my $abs_file = shift;
   debug("Image::OCR::Tesseract called");
   require Image::OCR::Tesseract;
   return Image::OCR::Tesseract::get_ocr($abs_file);
}

sub text_from_doc {
   my $abs_file = shift;
   debug("antiword called");
   require File::Which;
   my $_abs_file = Zack::File2Text::Base::escape_filename($abs_file);
   debug("escaped filename '$abs_file'");
   my $bin = File::Which::which('antiword') 
      or warn("Path to antiword not found!")
      and return;
   debug("path to antiword: '$bin'");
   my $out = `$bin $_abs_file`;
   return $out;
}
   

sub text_from_excel {
   my $abs_file = shift;
   debug("excel2txt called");
   require File::Which;
   my $bin = File::Which::which('excel2txt') or warn("Path to excel2txt not found!");
   debug("path to excel2txt '$bin'");

   $abs_file=~/\/([^\/]+)$/ or die("Cant regex in to argument '$abs_file'");
   my $filename = $1;

   my $dir_out = '/tmp/temp_dir_'.time().( int rand 9000 );
   mkdir $dir_out;
   -d $dir_out or die("Missing dir $dir_out, not on disk. Check permissions?");
   debug("$dir_out");
   system('cp', $abs_file, "$dir_out/$filename")==0 or die($!);
   system($bin, '-o', $dir_out, "$dir_out/$filename") ==0 or die($!);

   my $text_out='';

   opendir(DIR,$dir_out) or die($!);
   my @files = grep { /\.txt$/ } readdir DIR;
   

   for my $file (@files){
      my $out = Zack::File2Text::Base::_slurp("$dir_out/$file") or next;
      $text_out.=$out."\n"; # probably should have pagebreak char
   }
   
   unlink @files if (@files and scalar @files);


   return $text_out;
}

sub text_from_pod {

}

sub text_from_rtf {
   my $abs_file = shift;

   require RTF::TEXT::Converter; # this has a RETARDED interface

   open(FILE,'<',$abs_file) or die();
   #my $input = Zack::File2Text::Base::_slurp($abs_file);


   my $output;

   my $o = RTF::TEXT::Converter->new( output => \$output );

   $output = $o->parse_stream( \*FILE );
   close FILE;
   return $output;
}

sub text_from_txt {
   my $abs_file = shift;
   my $t = Zack::File2Text::Base::_slurp($abs_file);
   defined $t or warn("No text inside file '$abs_file'\n");
   return $t;
}




INIT {
   # remap..
   no strict 'refs';
   for my $sub ( keys %EXTRACT ){
      for my $ext (@{$EXTRACT{$sub}}){
         $_EXTRACT{$ext} = \&{"$sub"};
         debug("EXTRACTOR $ext: $sub");
      }
   }

   ### %_EXTRACT
}


1;
