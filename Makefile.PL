use inc::Module::Install;
include 'Module::AutoInstall';

name 'Class-Scaffold';
all_from 'lib/Class/Scaffold.pm';

auto_set_homepage;
auto_set_bugtracker;
auto_set_repository;

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
requires 'YAML' => '0.70';
requires 'YAML::Active';

test_requires 'Test::CompanionClasses' => '0.03';
test_requires 'Test::More' => '0.70';
extra_tests;

author_requires 'ShipIt';
author_requires 'ShipIt::Step::DistClean';
author_requires 'ShipIt::Step::DistTestExtra';
author_requires 'ShipIt::Step::Manifest';
author_requires 'ShipIt::Step::Twitter';
author_requires 'Test::Compile';
author_requires 'Test::Perl::Critic';
author_requires 'Test::Pod';
author_requires 'Test::Spelling';
author_requires 'Pod::Wordlist::hanekomu';
author_requires 'Test::Pod::Coverage';
# author_requires 'Test::Kwalitee';   # Attempt to free unreferenced scalar
author_requires 'Test::YAML::Meta';
author_requires 'Test::Portability::Files';
author_requires 'Test::Synopsis';

auto_install;
auto_include;
WriteAll;
