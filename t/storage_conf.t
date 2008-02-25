#!/usr/bin/env perl

# Copyright (c) 2003-2007 University of Vienna.
#
# All rights reserved.  This software is protected by copyright.  Use,
# modification and distribution is limited according to terms of agreements.

# $Id: person_name.t 13669 2007-11-07 20:54:41Z gr $
#
# test value_person_name_full framework objects in the context of
# Registry-NICAT, which uses a specific character set for that object

use warnings;
use strict;
use Test::More tests => 5;


use base 'Class::Scaffold::App::Test';


sub app_init {
    my $self = shift;
    $self->SUPER::app_init(@_);

    our %local_conf = (
        core_storage_name => 'STG_NULL_DBI',
        core_storage_args => {
            dbname     => 'mydb',
            dbuser     => 'myuser',
            dbpass     => 'mypass',
            AutoCommit => 27,
        },
    );

    %Class::Scaffold::Environment::Configurator::Local::opt = (
        %Class::Scaffold::Environment::Configurator::Local::opt,
        %local_conf,
    );
}


sub app_code {
    my $self = shift;
    $self->SUPER::app_code(@_);

    my $storage = $self->delegate->core_storage;

    our %local_conf;
    isa_ok($storage, $self->delegate->get_storage_class_name_for(
        $local_conf{core_storage_name}
    ));
    while (my ($key, $value) = each %{ $local_conf{core_storage_args} }) {
        is($storage->$key, $value, "storage [$key] = $value");
    }
}


main->new->run_app;
