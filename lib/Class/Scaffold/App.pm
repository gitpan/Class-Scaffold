package Class::Scaffold::App;

use strict;
use warnings;
use Class::Scaffold::Environment;
use Class::Scaffold::Environment::Configurator;
use Error ':try';


our $VERSION = '0.08';


use base 'Class::Scaffold::Storable';


__PACKAGE__->mk_boolean_accessors(qw(initialized));


use IO::Handle;
STDOUT->autoflush;
STDERR->autoflush;

use constant CONTEXT => 'generic/generic';

sub app_init {
    my $self = shift;

    # Normally, app_init() is called only once (namely, when the program
    # subclasses this class and does 'main->new->run_app'). However, if used
    # from within mod_perl (for example), the app is a cached object and
    # run_app() is called repeatedly from the outside. In this case,
    # app_init() should be called only once. We do this with initialized().

    return if $self->initialized;
    $self->initialized(1);

    my $configurator = Class::Scaffold::Environment::Configurator->instance;

    # If a subclass added a getopt configurator, we can ask it for the
    # location of the conf file, in case the user specified '--conf' on the
    # command line. If a filename is given, we'll use that conf file. If the
    # special string "local" is given, we try to find the conf file.
    # Otherwise use the one given in an environment variable.

    my $conf_file = $configurator->conf;
    $conf_file = '' unless defined $conf_file;
    if ($conf_file eq 'local' ||
        ($conf_file eq '' && $ENV{CF_CONF} eq 'local')) {

        # only load if needed
        require Class::Scaffold::Introspect;
        $conf_file = Class::Scaffold::Introspect::find_conf_file();
    }

    $conf_file ||= $ENV{CF_CONF};

    $configurator->add_configurator(file => $conf_file);

    $self->log->max_level(1 + ($configurator->verbose || 0));

    # Now that we have both a getopt and a file configurator, the log file
    # name can come from either the command line (preferred) or the conf file.

    $self->log->filename($configurator->logfile) if
        defined $configurator->logfile;

    # This class subclasses Class::Scaffold::Base, which returns
    # Class::Scaffold::Environment->getenv as the default delegate. So set the
    # proper environment here and then pass the newly formed delegate the
    # configurator. The environment will make use of it in its methods.

    Class::Scaffold::Environment->setenv($configurator->environment);
    $self->delegate->setup;
    $self->delegate->configurator($configurator);

    $self->delegate->context(
        Class::Scaffold::Context->new->parse_context($self->CONTEXT)
    );

    if ($configurator->dryrun) {
        $self->log->clear_timestamp;
        $self->delegate->set_rollback_mode;
    }
}


sub app_finish { 1 }
sub app_code   {}


sub run_app {
    my $self = shift;
    $self->app_init;

    $Error::Debug++;   # to get a stacktrace
    try {
        $self->app_code;
    } catch Error with {
        my $E = shift;
        $self->log->info($E->{statement}) if
            ref $E eq 'Error::Hierarchy::Internal::DBI::DBH';
        $self->log->info('Application exception: %s', $E);
        $self->log->info('%s', $E->stacktrace);
        # $self->delegate->set_rollback_mode;
    };

    $self->app_finish;
}


1;


__END__

=head1 NAME

Class::Scaffold::App - large-scale OOP application support

=head1 SYNOPSIS

    use base 'Class::Scaffold::App';

    sub app_code {
        my $self = shift;
        $self->SUPER::app_code(@_);
        # ... application-specific tasks ...
    }

    main->new->run_app;

=head1 DESCRIPTION

This is the base class for applications built with the L<Class::Scaffold>
framework, be they command-line applications or server-based applications.
Applications will subclass this class, implement their specific tasks and call
C<run_app()>.

=head1 METHODS

=over 4

=item run_app

This is the main method that application subclasses should invoke. It calls
the other methods described here. If there is an exception, it catches and
logs it.

=item app_code

Called by C<run_app()> right at the beginning. Override this method in your
application-specific subclass to do any initialization your application needs.

=item app_finish

Called by C<run_app()> within a C<try>/C<catch>-block. Override this method to
do the actual application-specific work.

=item app_init

Called by C<run_app()> right before the end. Override this method to do any
cleanup your application needs.

=item C<clear_initialized>

    $obj->clear_initialized;

Clears the boolean value by setting it to 0.

=item C<initialized>

    $obj->initialized($value);
    my $value = $obj->initialized;

If called without an argument, returns the boolean value (0 or 1). If called
with an argument, it normalizes it to the boolean value. That is, the values
0, undef and the empty string become 0; everything else becomes 1.

=item C<initialized_clear>

    $obj->initialized_clear;

Clears the boolean value by setting it to 0.

=item C<initialized_set>

    $obj->initialized_set;

Sets the boolean value to 1.

=item C<set_initialized>

    $obj->set_initialized;

Sets the boolean value to 1.

=back

Class::Scaffold::App inherits from L<Class::Scaffold::Storable>.

The superclass L<Class::Scaffold::Storable> defines these methods and
functions:

    MUNGE_CONSTRUCTOR_ARGS(), clear_storage_info(), clear_storage_type(),
    delete_storage_info(), exists_storage_info(), id(),
    keys_storage_info(), storage(), storage_info(), storage_info_clear(),
    storage_info_delete(), storage_info_exists(), storage_info_keys(),
    storage_info_values(), storage_type(), storage_type_clear(),
    values_storage_info()

The superclass L<Class::Scaffold::Base> defines these methods and
functions:

    new(), FIRST_CONSTRUCTOR_ARGS(), add_autoloaded_package(), init(),
    log()

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

The superclass L<Data::Comparable> defines these methods and functions:

    comparable(), comparable_scalar(), dump_comparable(),
    prepare_comparable(), yaml_dump_comparable()

The superclass L<Class::Scaffold::Delegate::Mixin> defines these methods
and functions:

    delegate()

The superclass L<Class::Scaffold::Accessor> defines these methods and
functions:

    mk_framework_object_accessors(), mk_framework_object_array_accessors(),
    mk_readonly_accessors()

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    mk_abstract_accessors(), mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor()

The superclass L<Class::Accessor::Constructor> defines these methods and
functions:

    _make_constructor(), mk_constructor(), mk_constructor_with_dirty(),
    mk_singleton_constructor()

The superclass L<Class::Accessor::FactoryTyped> defines these methods and
functions:

    clear_factory_typed_accessors(), clear_factory_typed_array_accessors(),
    count_factory_typed_accessors(), count_factory_typed_array_accessors(),
    factory_typed_accessors(), factory_typed_accessors_clear(),
    factory_typed_accessors_count(), factory_typed_accessors_index(),
    factory_typed_accessors_pop(), factory_typed_accessors_push(),
    factory_typed_accessors_set(), factory_typed_accessors_shift(),
    factory_typed_accessors_splice(), factory_typed_accessors_unshift(),
    factory_typed_array_accessors(), factory_typed_array_accessors_clear(),
    factory_typed_array_accessors_count(),
    factory_typed_array_accessors_index(),
    factory_typed_array_accessors_pop(),
    factory_typed_array_accessors_push(),
    factory_typed_array_accessors_set(),
    factory_typed_array_accessors_shift(),
    factory_typed_array_accessors_splice(),
    factory_typed_array_accessors_unshift(),
    index_factory_typed_accessors(), index_factory_typed_array_accessors(),
    mk_factory_typed_accessors(), mk_factory_typed_array_accessors(),
    pop_factory_typed_accessors(), pop_factory_typed_array_accessors(),
    push_factory_typed_accessors(), push_factory_typed_array_accessors(),
    set_factory_typed_accessors(), set_factory_typed_array_accessors(),
    shift_factory_typed_accessors(), shift_factory_typed_array_accessors(),
    splice_factory_typed_accessors(),
    splice_factory_typed_array_accessors(),
    unshift_factory_typed_accessors(),
    unshift_factory_typed_array_accessors()

The superclass L<Class::Scaffold::Factory::Type> defines these methods and
functions:

    factory_log()

The superclass L<Class::Factory::Enhanced> defines these methods and
functions:

    add_factory_type(), make_object_for_type(), register_factory_type()

The superclass L<Class::Factory> defines these methods and functions:

    factory_error(), get_factory_class(), get_factory_type_for(),
    get_loaded_classes(), get_loaded_types(), get_my_factory(),
    get_my_factory_type(), get_registered_class(),
    get_registered_classes(), get_registered_types(),
    remove_factory_type(), unregister_factory_type()

The superclass L<Class::Accessor::Constructor::Base> defines these methods
and functions:

    STORE(), clear_dirty(), clear_hygienic(), clear_unhygienic(),
    contains_hygienic(), contains_unhygienic(), delete_hygienic(),
    delete_unhygienic(), dirty(), dirty_clear(), dirty_set(),
    elements_hygienic(), elements_unhygienic(), hygienic(),
    hygienic_clear(), hygienic_contains(), hygienic_delete(),
    hygienic_elements(), hygienic_insert(), hygienic_is_empty(),
    hygienic_size(), insert_hygienic(), insert_unhygienic(),
    is_empty_hygienic(), is_empty_unhygienic(), set_dirty(),
    size_hygienic(), size_unhygienic(), unhygienic(), unhygienic_clear(),
    unhygienic_contains(), unhygienic_delete(), unhygienic_elements(),
    unhygienic_insert(), unhygienic_is_empty(), unhygienic_size()

The superclass L<Tie::StdHash> defines these methods and functions:

    CLEAR(), DELETE(), EXISTS(), FETCH(), FIRSTKEY(), NEXTKEY(), SCALAR(),
    TIEHASH()

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Florian Helmberger C<< <fh@univie.ac.at> >>

Achim Adam C<< <ac@univie.ac.at> >>

Mark Hofstetter C<< <mh@univie.ac.at> >>

Heinz Ekker C<< <ek@univie.ac.at> >>

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2008 by the authors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

