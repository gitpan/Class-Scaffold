package Class::Scaffold::Environment;
use warnings;
use strict;
use Error::Hierarchy::Util 'load_class';
use Class::Scaffold::Factory::Type;
use Property::Lookup;
our $VERSION = '0.16';
use base 'Class::Scaffold::Base';
Class::Scaffold::Base->add_autoloaded_package('Class::Scaffold::');

# ptags: /(\bconst\b[ \t]+(\w+))/
__PACKAGE__->mk_scalar_accessors(qw(test_mode context))
  ->mk_boolean_accessors(qw(rollback_mode))
  ->mk_class_hash_accessors(qw(storage_cache multiplex_transaction_omit))
  ->mk_object_accessors(
    'Property::Lookup' => {
        slot => 'configurator',
        comp_mthds =>
          [ qw(core_storage_name core_storage_args memory_storage_name) ]
    },
  );
use constant DEFAULTS =>
  (test_mode => (defined $ENV{TEST_MODE} && $ENV{TEST_MODE} == 1),);
Class::Scaffold::Factory::Type->register_factory_type(
    exception_container => 'Class::Scaffold::Exception::Container',
    result              => 'Data::Storage::DBI::Result',
    storage_statement   => 'Data::Storage::Statement',
    test_util_loader    => 'Class::Scaffold::Test::UtilLoader',
);
{    # closure over $env so that it really is private
    my $env;
    sub getenv { $env }

    sub setenv {
        my ($self, $newenv, @args) = @_;
        return $env = $newenv
          if ref $newenv
              && UNIVERSAL::isa($newenv, 'Class::Scaffold::Environment');
        unless (ref $newenv) {

            # it's a string containing the class name
            load_class $newenv, 1;
            return $env = $newenv->new(@args);
        }
        throw Error::Hierarchy::Internal::CustomMessage(
            custom_message => "Invalid environment specification [$newenv]",);
    }
}    # end of closure

sub setup {
    my $self = shift;
    my $h    = $self->every_hash('CONFIGURATOR_DEFAULTS');
    $self->configurator->default_layer->hash(
        $self->every_hash('CONFIGURATOR_DEFAULTS'));
}

# ----------------------------------------------------------------------
# class name-related code
use constant STORAGE_CLASS_NAME_HASH => (

    # storage names
    STG_NULL     => 'Data::Storage::Null',
    STG_NULL_DBI => 'Data::Storage::DBI',    # for testing
);

sub make_obj {
    my $self = shift;
    Class::Scaffold::Factory::Type->make_object_for_type(@_);
}

sub get_class_name_for {
    my ($self, $object_type) = @_;
    Class::Scaffold::Factory::Type->get_factory_class($object_type);
}

sub isa_type {
    my ($self, $object, $object_type) = @_;
    return unless UNIVERSAL::can($object, 'get_my_factory_type');
    my $factory_type = $object->get_my_factory_type;
    defined $factory_type ? $factory_type eq $object_type : 0;
}

sub gen_class_hash_accessor (@) {
    for my $prefix (@_) {
        my $method = sprintf 'get_%s_class_name_for' => lc $prefix;
        my $every_hash_name = sprintf '%s_CLASS_NAME_HASH', $prefix;
        my $hash;    # will be cached here
        no strict 'refs';
        $::PTAGS && $::PTAGS->add_tag($method, __FILE__, __LINE__ + 1);
        *$method = sub {
            local $DB::sub = local *__ANON__ = sprintf "%s::%s", __PACKAGE__,
              $method
              if defined &DB::DB && !$Devel::DProf::VERSION;
            my ($self, $key) = @_;
            $hash ||= $self->every_hash($every_hash_name);
            $hash->{$key} || $hash->{_AUTO};
        };

        # so FOO_CLASS_NAME() will return the whole every_hash
        $method = sprintf '%s_CLASS_NAME' => lc $prefix;
        $::PTAGS && $::PTAGS->add_tag($method, __FILE__, __LINE__ + 1);
        *$method = sub {
            local $DB::sub = local *__ANON__ = sprintf "%s::%s", __PACKAGE__,
              $method
              if defined &DB::DB && !$Devel::DProf::VERSION;
            my $self = shift;
            $hash ||= $self->every_hash($every_hash_name);
            wantarray ? %$hash : $hash;
        };
        $method = sprintf 'release_%s_class_name_hash' => lc $prefix;
        $::PTAGS && $::PTAGS->add_tag($method, __FILE__, __LINE__ + 1);
        *$method = sub {
            local $DB::sub = local *__ANON__ = sprintf "%s::%s", __PACKAGE__,
              $method
              if defined &DB::DB && !$Devel::DProf::VERSION;
            undef $hash;
        };
    }
}
gen_class_hash_accessor('STORAGE');

sub load_cached_class_for_type {
    my ($self, $object_type_const) = @_;

    # Cache for efficiency reasons; the environment is the core of the whole
    # framework.
    our %cache;
    my $class = $self->get_class_name_for($object_type_const);
    unless (defined($class) && length($class)) {
        throw Error::Hierarchy::Internal::CustomMessage(custom_message =>
              "Can't find class for object type [$object_type_const]",);
    }
    load_class $class, $self->test_mode;
    $class;
}

sub storage_for_type {
    my ($self, $object_type) = @_;
    my $storage_type = $self->get_storage_type_for($object_type);
    $self->$storage_type;
}

# When running class tests in non-final distributions, which storage should we
# use? Ideally, every distribution (but especially the non-final ones like
# Registry-Core and Registry-Enum) should have a mock storage against which to
# test. Until then, the following mechanism can be used:
#
# Every storage notes whether it is abstract or an implementation. Class tests
# that need a storage will skip() the tests if the storage is abstract.
# Problem: we need to ask all the object types' storages used in a test code
# block, as different objects types could use different storages. For example:
#    skip(...) unless
#        $self->delegate->all_storages_are_implemented(qw/person command .../);
sub all_storages_are_implemented {
    my ($self, @object_types) = @_;
    for my $object_type (@object_types) {
        return 0 if $self->storage_for_type($object_type)->is_abstract;
    }
    1;
}

# Have a special method for making delegate objects, because delegates will be
# cached (i.e., pseudo-singletons) and don't need storages and extra args and
# such.
sub make_delegate {
    my ($self, $object_type_const, @args) = @_;
    our %cache;
    $cache{delegate}{$object_type_const} ||=
      $self->make_obj($object_type_const, @args);
}

# ----------------------------------------------------------------------
# storage-related code
use constant STORAGE_TYPE_HASH => (_AUTO => 'core_storage',);

sub get_storage_type_for {
    my ($self, $key) = @_;
    our %cache;
    return $cache{get_storage_type_for}{$key}
      if exists $cache{get_storage_type_for}{$key};
    my $storage_type_for = $self->every_hash('STORAGE_TYPE_HASH');
    $cache{get_storage_type_for}{$key} = $storage_type_for->{$key}
      || $storage_type_for->{_AUTO};
}

sub make_storage_object {
    my $self         = shift;
    my $storage_name = shift;
    my %args =
        @_ == 1
      ? defined $_[0]
          ? ref $_[0] eq 'HASH'
              ? %{ $_[0] }
              : @_
          : ()
      : @_;
    if (my $class = $self->get_storage_class_name_for($storage_name)) {
        load_class $class, $self->test_mode;
        return $class->new(%args);
    }
    throw Error::Hierarchy::Internal::CustomMessage(
        custom_message => "Invalid storage name [$storage_name]",);
}

sub core_storage {
    my $self = shift;
    $self->storage_cache->{core_storage} ||=
      $self->make_storage_object($self->core_storage_name,
        $self->core_storage_args);
}

sub memory_storage {
    my $self = shift;
    $self->storage_cache->{memory_storage} ||=
      $self->make_storage_object($self->memory_storage_name);
}

# Forward some special methods onto all cached storages. Some storages could
# be a bit special - we don't want to rollback or disconnect from them when
# calling the multiplexing rollback() and disconnect() methods below, so we
# ignore them when multiplexing. For example, mutex storages (see
# Data-Conveyor for the concept).
sub rollback {
    my $self = shift;
    while (my ($storage_type, $storage) = each %{ $self->storage_cache }) {
        next if $self->multiplex_transaction_omit($storage_type);
        $storage->rollback;
    }
}

sub commit {
    my $self = shift;
    while (my ($storage_type, $storage) = each %{ $self->storage_cache }) {
        next if $self->multiplex_transaction_omit($storage_type);
        $storage->commit;
    }
}

sub disconnect {
    my $self = shift;
    while (my ($storage_type, $storage) = each %{ $self->storage_cache }) {
        next if $self->multiplex_transaction_omit($storage_type);
        $storage->disconnect;

        # remove it from the cache so we'll reconnect next time
        $self->storage_cache_delete($storage_type);
        require Class::Scaffold::Storable;
        %Class::Scaffold::Storable::cache = ();
    }
    our %cache;
    $cache{get_storage_type_for} = {};
}

# Check configuration values for consistency. Empty, but it exists so
# subclasses can call SUPER::check()
sub check { }
1;
__END__

=head1 NAME

Class::Scaffold::Environment - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Environment->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_configurator>

    $obj->clear_configurator;

Deletes the object.

=item C<clear_context>

    $obj->clear_context;

Clears the value.

=item C<clear_multiplex_transaction_omit>

    $obj->clear_multiplex_transaction_omit;

Deletes all keys and values from the hash. Since this is a class variable, the
value will be changed for all instances of this class.

=item C<clear_rollback_mode>

    $obj->clear_rollback_mode;

Clears the boolean value by setting it to 0.

=item C<clear_storage_cache>

    $obj->clear_storage_cache;

Deletes all keys and values from the hash. Since this is a class variable, the
value will be changed for all instances of this class.

=item C<clear_test_mode>

    $obj->clear_test_mode;

Clears the value.

=item C<configurator>

    my $object = $obj->configurator;
    $obj->configurator($object);
    $obj->configurator(@args);

If called with an argument object of type Class::Scaffold::Environment::Configurator it sets the object; further
arguments are discarded. If called with arguments but the first argument is
not an object of type Class::Scaffold::Environment::Configurator, a new object of type Class::Scaffold::Environment::Configurator is constructed and the
arguments are passed to the constructor.

If called without arguments, it returns the Class::Scaffold::Environment::Configurator object stored in this slot;
if there is no such object, a new Class::Scaffold::Environment::Configurator object is constructed - no arguments
are passed to the constructor in this case - and stored in the configurator slot
before returning it.

=item C<configurator_clear>

    $obj->configurator_clear;

Deletes the object.

=item C<context>

    my $value = $obj->context;
    $obj->context($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<context_clear>

    $obj->context_clear;

Clears the value.

=item C<core_storage_args>

    $obj->core_storage_args(@args);
    $obj->core_storage_args;

Calls core_storage_args() with the given arguments on the object stored in the configurator slot.
If there is no such object, a new Class::Scaffold::Environment::Configurator object is constructed - no arguments
are passed to the constructor - and stored in the configurator slot before forwarding
core_storage_args() onto it.

=item C<core_storage_name>

    $obj->core_storage_name(@args);
    $obj->core_storage_name;

Calls core_storage_name() with the given arguments on the object stored in the configurator slot.
If there is no such object, a new Class::Scaffold::Environment::Configurator object is constructed - no arguments
are passed to the constructor - and stored in the configurator slot before forwarding
core_storage_name() onto it.

=item C<delete_multiplex_transaction_omit>

    $obj->delete_multiplex_transaction_omit(@keys);

Takes a list of keys and deletes those keys from the hash. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<delete_storage_cache>

    $obj->delete_storage_cache(@keys);

Takes a list of keys and deletes those keys from the hash. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<exists_multiplex_transaction_omit>

    if ($obj->exists_multiplex_transaction_omit($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise. Since this is a class variable, the value will be
changed for all instances of this class.

=item C<exists_storage_cache>

    if ($obj->exists_storage_cache($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise. Since this is a class variable, the value will be
changed for all instances of this class.

=item C<keys_multiplex_transaction_omit>

    my @keys = $obj->keys_multiplex_transaction_omit;

Returns a list of all hash keys in no particular order. Since this is a class
variable, the value will be changed for all instances of this class.

=item C<keys_storage_cache>

    my @keys = $obj->keys_storage_cache;

Returns a list of all hash keys in no particular order. Since this is a class
variable, the value will be changed for all instances of this class.

=item C<memory_storage_name>

    $obj->memory_storage_name(@args);
    $obj->memory_storage_name;

Calls memory_storage_name() with the given arguments on the object stored in the configurator slot.
If there is no such object, a new Class::Scaffold::Environment::Configurator object is constructed - no arguments
are passed to the constructor - and stored in the configurator slot before forwarding
memory_storage_name() onto it.

=item C<multiplex_transaction_omit>

    my %hash     = $obj->multiplex_transaction_omit;
    my $hash_ref = $obj->multiplex_transaction_omit;
    my $value    = $obj->multiplex_transaction_omit($key);
    my @values   = $obj->multiplex_transaction_omit([ qw(foo bar) ]);
    $obj->multiplex_transaction_omit(%other_hash);
    $obj->multiplex_transaction_omit(foo => 23, bar => 42);

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

This is a class variable, so it is shared between all instances of this class.
Changing it in one object will change it for all other objects as well.

=item C<multiplex_transaction_omit_clear>

    $obj->multiplex_transaction_omit_clear;

Deletes all keys and values from the hash. Since this is a class variable, the
value will be changed for all instances of this class.

=item C<multiplex_transaction_omit_delete>

    $obj->multiplex_transaction_omit_delete(@keys);

Takes a list of keys and deletes those keys from the hash. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<multiplex_transaction_omit_exists>

    if ($obj->multiplex_transaction_omit_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise. Since this is a class variable, the value will be
changed for all instances of this class.

=item C<multiplex_transaction_omit_keys>

    my @keys = $obj->multiplex_transaction_omit_keys;

Returns a list of all hash keys in no particular order. Since this is a class
variable, the value will be changed for all instances of this class.

=item C<multiplex_transaction_omit_values>

    my @values = $obj->multiplex_transaction_omit_values;

Returns a list of all hash values in no particular order. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<rollback_mode>

    $obj->rollback_mode($value);
    my $value = $obj->rollback_mode;

If called without an argument, returns the boolean value (0 or 1). If called
with an argument, it normalizes it to the boolean value. That is, the values
0, undef and the empty string become 0; everything else becomes 1.

=item C<rollback_mode_clear>

    $obj->rollback_mode_clear;

Clears the boolean value by setting it to 0.

=item C<rollback_mode_set>

    $obj->rollback_mode_set;

Sets the boolean value to 1.

=item C<set_rollback_mode>

    $obj->set_rollback_mode;

Sets the boolean value to 1.

=item C<storage_cache>

    my %hash     = $obj->storage_cache;
    my $hash_ref = $obj->storage_cache;
    my $value    = $obj->storage_cache($key);
    my @values   = $obj->storage_cache([ qw(foo bar) ]);
    $obj->storage_cache(%other_hash);
    $obj->storage_cache(foo => 23, bar => 42);

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

This is a class variable, so it is shared between all instances of this class.
Changing it in one object will change it for all other objects as well.

=item C<storage_cache_clear>

    $obj->storage_cache_clear;

Deletes all keys and values from the hash. Since this is a class variable, the
value will be changed for all instances of this class.

=item C<storage_cache_delete>

    $obj->storage_cache_delete(@keys);

Takes a list of keys and deletes those keys from the hash. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<storage_cache_exists>

    if ($obj->storage_cache_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise. Since this is a class variable, the value will be
changed for all instances of this class.

=item C<storage_cache_keys>

    my @keys = $obj->storage_cache_keys;

Returns a list of all hash keys in no particular order. Since this is a class
variable, the value will be changed for all instances of this class.

=item C<storage_cache_values>

    my @values = $obj->storage_cache_values;

Returns a list of all hash values in no particular order. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<test_mode>

    my $value = $obj->test_mode;
    $obj->test_mode($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<test_mode_clear>

    $obj->test_mode_clear;

Clears the value.

=item C<values_multiplex_transaction_omit>

    my @values = $obj->values_multiplex_transaction_omit;

Returns a list of all hash values in no particular order. Since this is a
class variable, the value will be changed for all instances of this class.

=item C<values_storage_cache>

    my @values = $obj->values_storage_cache;

Returns a list of all hash values in no particular order. Since this is a
class variable, the value will be changed for all instances of this class.

=back

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

Copyright 2004-2009 by the authors.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

