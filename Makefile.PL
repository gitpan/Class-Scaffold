use inc::Module::Install;
include 'Module::AutoInstall';

name 'Class-Scaffold';
all_from 'lib/Class/Scaffold.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex';
requires 'Class::Accessor::Constructor';
requires 'Class::Factory::Enhanced';
requires 'Class::Accessor::FactoryTyped' => '0.03';
requires 'Class::Value';
requires 'Data::Comparable';
requires 'Data::Inherited';
requires 'Data::Miscellany';
requires 'Data::Storage' => '0.02';
requires 'DBI';
requires 'Error::Hierarchy';
requires 'String::FlexMatch';
requires 'Term::Shell::Enhanced';
requires 'Test::Differences';
requires 'Test::More';
requires 'Text::Table';
requires 'Time::HiRes';
requires 'YAML';
requires 'YAML::Active';

build_requires 'Test::CompanionClasses' => '0.03';
build_requires 'Test::More' => '0.70';

process_templates(
    first_year    => 2004,
    rest_from     => "$ENV{HOME}/.mitlib/standard_pod",
    start_tag     => '{%',
    end_tag       => '%}',
    other_authors => [
        'Florian Helmberger C<< <fh@univie.ac.at> >>',
        'Achim Adam C<< <ac@univie.ac.at> >>',
        'Mark Hofstetter C<< <mh@univie.ac.at> >>',
        'Heinz Ekker C<< <ek@univie.ac.at> >>',
    ],
);

use_standard_tests(without => 'pod_coverage');
auto_install;
auto_include;
WriteAll;
