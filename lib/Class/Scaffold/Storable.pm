package Class::Scaffold::Storable;

# base class for all framework classes that support a storage.

use strict;
use warnings;


our $VERSION = '0.11';


use base 'Class::Scaffold::Base';


__PACKAGE__
    ->mk_scalar_accessors(qw(storage_type))
    ->mk_hash_accessors(qw(storage_info));


# Don't store the storage object itself, store the method we need to call on
# the delegate to get the storage object. This is just a little overhead, but
# saves us from a lot of headache when serializing and deserializing objects
# with Storable's freeze() and thaw(), because storage objects can't be
# deserialized properly.
#
# Impose a certain order on how the constructor args are processed. We want
# the storage to be set first, because other properties could be defined using
# mk_framework_object_accessors(). Now if the args were set in an arbitrary
# order, the framework_object-properties could be processed before the storage
# is set, which would cause an error, because the storage wouldn't be set yet,
# so it can't be asked to make an object.
#
# We can't have storage_type as a key within the storage_info hash, because we
# want to be able to set it directly if passed as an argument to the
# constructor; we also need to be able to prefer it in
# Class::Scaffold::Storable::FIRST_CONSTRUCTOR_ARGS().
#
# We use the storage's signature as the id key, i.e. to find the id of the
# object within the storage. It would not be sufficient to use the storage's
# package name as the hash key because we can think of a multiplex storage
# that multiplexes onto two file system paths. In that case each of the
# multiplexed storages would have the same package name. And we can't use the
# storage's memory address (0x012345678) because different stages can be run
# within different processes and on different machines.
#
# For example, the attributes of an object of this class might look like:

# storage_type: core_storage
# storage_info:
#   id:
#     'Registry::NICAT::Storage::DBI::Oracle::NICAT,dbname=db.test,dbuser=nic': id12345
#     'Some::File::Storage,fspath=/path/to/storage/root': id45678

# This example assumes that the core storage is multiplexing on a DBI storage
# and a file system storage.


use constant FIRST_CONSTRUCTOR_ARGS => ('storage_type');

use constant SKIP_COMPARABLE_KEYS => (qw/storage_type storage_info/);

use constant HYGIENIC => ( qw/storage storage_type/ );


sub MUNGE_CONSTRUCTOR_ARGS {
    my ($self, @args) = @_;

    # The superclass does nothing, so we'll skip this for performance reasons
    # - this method is called very often.

    # @args = $self->SUPER::MUNGE_CONSTRUCTOR_ARGS(@args);

    our %cache;
    my $extra_args;
    unless ($extra_args = $cache{ ref $self }) {
        my $object_type = $self->get_my_factory_type;
        if (defined $object_type) {
            my $storage_type =
                $self->delegate->get_storage_type_for($object_type);

            $self->delegate->$storage_type->lazy_connect;
            # storage will be disconnected in Class::Scaffold::App->app_finish

            $extra_args = $cache{ ref $self } =
                [ storage_type => $storage_type ];
        } else {
            $extra_args = $cache{ ref $self } = [];
        }
    }

    (@args, @$extra_args);
}


sub storage {
    my $self = shift;
    my $method = $self->storage_type;
    if ($method) {
        $self->delegate->$method;
    } else {
        local $Error::Depth = $Error::Depth + 1;
        throw Error::Hierarchy::Internal::CustomMessage(
            custom_message =>
                "can't find method to get storage object from delegate"
        );
    }
};


sub id {
    my $self    = shift;
    my $storage = shift;
    if (@_) {
        my $id = shift;
        $self->storage_info->{id}{ $storage->signature } = $id;
    } else {
        $self->storage_info->{id}{ $storage->signature };
    }
}


1;


__END__



=head1 NAME

Class::Scaffold::Storable - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Storable->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_storage_info>

    $obj->clear_storage_info;

Deletes all keys and values from the hash.

=item C<clear_storage_type>

    $obj->clear_storage_type;

Clears the value.

=item C<delete_storage_info>

    $obj->delete_storage_info(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<exists_storage_info>

    if ($obj->exists_storage_info($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<keys_storage_info>

    my @keys = $obj->keys_storage_info;

Returns a list of all hash keys in no particular order.

=item C<storage_info>

    my %hash     = $obj->storage_info;
    my $hash_ref = $obj->storage_info;
    my $value    = $obj->storage_info($key);
    my @values   = $obj->storage_info([ qw(foo bar) ]);
    $obj->storage_info(%other_hash);
    $obj->storage_info(foo => 23, bar => 42);

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

=item C<storage_info_clear>

    $obj->storage_info_clear;

Deletes all keys and values from the hash.

=item C<storage_info_delete>

    $obj->storage_info_delete(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<storage_info_exists>

    if ($obj->storage_info_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<storage_info_keys>

    my @keys = $obj->storage_info_keys;

Returns a list of all hash keys in no particular order.

=item C<storage_info_values>

    my @values = $obj->storage_info_values;

Returns a list of all hash values in no particular order.

=item C<storage_type>

    my $value = $obj->storage_type;
    $obj->storage_type($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<storage_type_clear>

    $obj->storage_type_clear;

Clears the value.

=item C<values_storage_info>

    my @values = $obj->values_storage_info;

Returns a list of all hash values in no particular order.

=back

Class::Scaffold::Storable inherits from L<Class::Scaffold::Base>.

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

If you talk about this module in blogs, on L<delicious.com> or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::Storable>.

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

Copyright 2004-2009 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

