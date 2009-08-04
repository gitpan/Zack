use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'Zack',
   VERSION_FROM => 'lib/Zack.pm',
   

   # gen /usr/bin/pmused by Tue May 19 10:33:44 EDT 2009 
   PREREQ_PM => {
      'Carp'                              => '1',
      'Cwd'                               => '3',
      'English'                           => '1.02',
      'Exporter'                          => '5',
      'File::Basename'                    => '2.74',
      'File::Path'                        => '1.08',
      'File::Spec::Functions'             => '3.2701',
      'File::Which'                       => '0.05',
      'Getopt::Long'                      => '2.35',
      'Getopt::Std::Strict'               => '1.01',
      'Image::OCR::Tesseract'             => '1.20',
      'LEOCHARRE::CLI'                    => '1.19',
      'LEOCHARRE::Class2'                 => '1.13',
      'LEOCHARRE::DEBUG'                  => '1.13',
      'LEOCHARRE::Dir'                    => '1.07',
      'LEOCHARRE::HTML::Text'             => '1.03',
      'LEOCHARRE::Test'                   => '1.09',
      'PDF::OCR2'                         => '1.01',
      'Pod::Usage'                        => '1.33',
      'RTF::TEXT::Converter'              => '0',
      'Readonly'                          => '1.03',
      'Smart::Comments'                   => '1',
      'Spreadsheet::ParseExcel'           => '0.33',
      'Test::Simple'                      => '0',
      'XML::Simple'                       => '2.18',
      'YAML'                              => '0.66',
      'YAML::DBH'                         => '1.06',
   },

   
   LICENSE => 'perl',
   
   
   
   EXE_FILES => [qw(bin/excel2txt bin/zack)],
);


