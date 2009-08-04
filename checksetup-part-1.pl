#!/usr/bin/perl
use strict;
use Test::Simple 'no_plan';
use File::Which 'which';
use base 'LEOCHARRE::CLI';
sub bad;
sub say;


-e '/etc/zack.conf' or die(23);


ok( $^O=~/linux/, 'using Linux') or bad;


ok_app('antiword');

ok_app('excel2txt');



HACK: { # previous conf name ... . this is a hack
   my $abs_conf_old = '/etc/file2text.conf';
   my $abs_conf = '/etc/zack.conf';
   if ( ! -e $abs_conf and -f $abs_conf_old ){
      system("mv $abs_conf_old $abs_conf")== 0 or die($?);
   }
}



ok( -e '/etc/zack.conf','have /etc/zack.conf') or bad;

ok( which('mysql'),'found mysql cli') or bad;

#ok( -e '/etc/init.d/mysqld


my $mysqld  = '/etc/init.d/mysqld';
if ( -e $mysqld ){
   my $status = `$mysqld status`;
   ok( $status=~/is running/,"$mysqld status, is running") or bad;
}


ok_perldeps();



good();
exit;





# MODULE CHECKS
sub ok_perldeps {
   sub _havemod { eval { "use $_[0];"}  ? 1 : 0 }


   my @mods = _makefile_deps();
   my @missing;
   MODULE: for my $mod ( @mods ){

      if (_havemod($mod)){
         ok(1,"Have module '$mod'") and next MODULE;
      }



      else {
         push @missing, $mod;
      }

   }

   if (@missing and scalar @missing){
      say("Missing modules:\n");
      say("\t$_\n") for @missing;
      yn("Want me to call cpan to install these?") or bad;

      system("cpan @missing");

      for my $mod (@missing){
         ok( _havemod($mod),"Found module: $mod.") or bad;
      }

   }
         
} # END MODULE CHECKS



sub ok_app {
   my $what = shift;
   ok( _require_app($what), "Found '$what' installed.") or bad;
}

sub _require_app {
   my $app = shift;

   which($app) and return 1;
   
   print "Sorry, you're missing the application '$app'.\n";

   if ( which('yum') ){
   
      yn("It seems that you have 'yum'. Would you like me try to install '$app' via yum?") 
         or say "In that case you should find '$app' and install it.\n"
         and bad;

      whoami() eq 'root' or say "Oops, can't install. Not root.\n"
         and bad;

      system('yum','-y','install',$app);

      which($app) or say "Still can't find path to '$app'. Error.\n"
         and bad;

      return 1;
   }
   bad;

}

sub say { print STDERR "@_" }

sub bad { say("\nCHECK FAILED.\n"); exit 1 }
sub good { say("\nCHECK PASSED.\n"); exit }


#use Smart::Comments '###';
sub _makefile_deps {
   local $/;
   open(FILE,'<','./Makefile.PL') or die($!);
   my $txt = <FILE>;
   close FILE;
   
   $txt=~/PREREQ_PM\s*=>\s*({[^\}]+})/s or return;

   ### $txt
   my $href = eval "$1";

   ### $href
   my @m = keys %$href;
   return @m;

}




