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
requires 'Vim::Tag';
requires 'YAML';
requires 'YAML::Active';

recommends 'Test::Pod';
recommends 'Test::Pod::Coverage';

test_requires 'Test::CompanionClasses' => '0.03';
test_requires 'Test::More' => '0.70';
test_requires 'Test::Compile';

auto_install;
auto_include;
WriteAll;
