
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Class::Scaffold',
                       'DISTNAME' => 'Class-Scaffold',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'Marcel Gruenauer <marcel@cpan.org>, Florian Helmberger <fh@univie.ac.at>, Achim Adam <ac@univie.ac.at>, Mark Hofstetter <mh@univie.ac.at>, Heinz Ekker <ek@univie.ac.at>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'Large-scale OOP application support',
                       'EXE_FILES' => [
                                        'bin/cf_dumpenv'
                                      ],
                       'VERSION' => '1.100760',
                       'PREREQ_PM' => {
                                        'Data::Miscellany' => '0',
                                        'YAML' => '0',
                                        'Property::Lookup' => '0',
                                        'Test::Class::GetoptControl' => '0',
                                        'String::FlexMatch' => '0',
                                        'Encode' => '0',
                                        'List::Util' => '0',
                                        'Class::Accessor::Constructor' => '0',
                                        'Test::Builder' => '0',
                                        'Error::Hierarchy' => '0',
                                        'Data::Inherited' => '0',
                                        'YAML::Active' => '0',
                                        'Error::Hierarchy::Test' => '0',
                                        'YAML::Active::Plugin::Hash' => '0',
                                        'Devel::Caller' => '0',
                                        'Getopt::Long' => '0',
                                        'Error::Hierarchy::Container' => '0',
                                        'parent' => '0',
                                        'English' => '0',
                                        'IO::File' => '0',
                                        'overload' => '0',
                                        'Error::Hierarchy::Mixin' => '0',
                                        'Test::More' => '0.88',
                                        'File::Temp' => '0',
                                        'YAML::Active::Plugin::Array' => '0',
                                        'Class::Accessor::FactoryTyped' => '0',
                                        'Scalar::Util' => '0',
                                        'FindBin' => '0',
                                        'Error::Hierarchy::Util' => '0',
                                        'IO::Handle' => '0',
                                        'Class::Value' => '0',
                                        'Test::CompanionClasses::Base' => '0',
                                        'Class::Factory::Enhanced' => '0',
                                        'Error' => '0',
                                        'File::Find' => '0',
                                        'Test::CompanionClasses::Engine' => '0',
                                        'File::Spec::Functions' => '0',
                                        'Class::Accessor::Complex' => '0',
                                        'Time::HiRes' => '0',
                                        'constant' => '0',
                                        'Getopt::Inherited' => '0',
                                        'YAML::Marshall' => '0',
                                        'Exporter' => '0',
                                        'Carp' => '0',
                                        'Error::Hierarchy::Internal' => '0',
                                        'Data::Comparable' => '0',
                                        'UNIVERSAL::require' => '0',
                                        'Cwd' => '0',
                                        'Sys::Hostname' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



