package Class::Scaffold::App::CommandLine;

use strict;
use warnings;
use Class::Scaffold::Environment;
use Class::Scaffold::Environment::Configurator;

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');


our $VERSION = '0.04';


use base 'Class::Scaffold::App';


__PACKAGE__->mk_hash_accessors(qw(opt));


use constant CONTEXT => 'generic/shell';

# alias logfile to log so that when can use '--log', but it gets stored in
# '{logfile}', which is what Class::Scaffold::App expects

use constant GETOPT => (qw/
    help man logfile|log=s verbose|v+ dryrun conf=s version|V environment
/);


sub usage {
    my $self = shift;
    require Pod::Usage;
    Pod::Usage::pod2usage(@_);
}


sub app_init {
    my $self = shift;
    my %opt;

    GetOptions(\%opt, $self->every_list('GETOPT')) or usage(2);

    usage(1) if $opt{help};
    usage(-exitstatus => 0, -verbose => 2) if $opt{man};

    # Add the getopt configurator before the superclass has a chance to add
    # the file configurator; this way, getopt definitions take precedence over
    # what's in the conf file.

    Class::Scaffold::Environment::Configurator->instance->
        add_configurator(getopt => \%opt);
    $self->opt(%opt);

    $self->SUPER::app_init(@_);
}


sub app_finish {
    my $self = shift;
    $self->delegate->disconnect;
}


1;


__END__



=head1 NAME

Class::Scaffold::App::CommandLine - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::App::CommandLine->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item clear_opt

    $obj->clear_opt;

Deletes all keys and values from the hash.

=item delete_opt

    $obj->delete_opt(@keys);

Takes a list of keys and deletes those keys from the hash.

=item exists_opt

    if ($obj->exists_opt($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item keys_opt

    my @keys = $obj->keys_opt;

Returns a list of all hash keys in no particular order.

=item opt

    my %hash     = $obj->opt;
    my $hash_ref = $obj->opt;
    my $value    = $obj->opt($key);
    my @values   = $obj->opt([ qw(foo bar) ]);
    $obj->opt(%other_hash);
    $obj->opt(foo => 23, bar => 42);

Get or set the hash values. If called without arguments, it returns the hash
in list context, or a reference to the hash in scalar context. If called
with a list of key/value pairs, it sets each key to its corresponding value,
then returns the hash as described before.

If called with exactly one key, it returns the corresponding value.

If called with exactly one array reference, it returns an array whose elements
are the values corresponding to the keys in the argument array, in the same
order. The resulting list is returned as an array in list context, or a
reference to the array in scalar context.

If called with exactly one hash reference, it updates the hash with the given
key/value pairs, then returns the hash in list context, or a reference to the
hash in scalar context.

=item opt_clear

    $obj->opt_clear;

Deletes all keys and values from the hash.

=item opt_delete

    $obj->opt_delete(@keys);

Takes a list of keys and deletes those keys from the hash.

=item opt_exists

    if ($obj->opt_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item opt_keys

    my @keys = $obj->opt_keys;

Returns a list of all hash keys in no particular order.

=item opt_values

    my @values = $obj->opt_values;

Returns a list of all hash values in no particular order.

=item values_opt

    my @values = $obj->values_opt;

Returns a list of all hash values in no particular order.

=back

Class::Scaffold::App::CommandLine inherits from L<Class::Scaffold::App>.

The superclass L<Class::Scaffold::App> defines these methods and functions:

    app_code(), clear_initialized(), initialized(), initialized_clear(),
    initialized_set(), run_app(), set_initialized()

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

    new(), add_autoloaded_package(), init(), log()

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

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.04 of L<Class::Scaffold::App::CommandLine>.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<<bug-class-scaffold@rt.cpan.org>>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHORS

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

Florian Helmberger C<< <fh@univie.ac.at> >>

Achim Adam C<< <ac@univie.ac.at> >>

Mark Hofstetter C<< <mh@univie.ac.at> >>

Heinz Ekker C<< <ek@univie.ac.at> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2008 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

