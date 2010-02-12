package Class::Scaffold::Storable;

# base class for all framework classes that support a storage.
use strict;
use warnings;
our $VERSION = '0.16';
use base 'Class::Scaffold::Base';
__PACKAGE__->mk_scalar_accessors(qw(storage_type))
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
use constant SKIP_COMPARABLE_KEYS   => (qw/storage_type storage_info/);
use constant HYGIENIC               => (qw/storage storage_type/);

sub MUNGE_CONSTRUCTOR_ARGS {
    my ($self, @args) = @_;

    # needed in order to mix object creation of a given class with and without
    # explicitly setting the storage object for it (Erik P. Ostlyngen, NORID):
    if (@args % 2 == 0) {
        my %args = @args;
        return %args if $args{storage_type};
    }

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
    my $self   = shift;
    my $method = $self->storage_type;
    if ($method) {
        $self->delegate->$method;
    } else {
        local $Error::Depth = $Error::Depth + 1;
        throw Error::Hierarchy::Internal::CustomMessage(custom_message =>
              "can't find method to get storage object from delegate");
    }
}

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

