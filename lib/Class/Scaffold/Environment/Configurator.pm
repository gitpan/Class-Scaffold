package Class::Scaffold::Environment::Configurator;

# $Id: Configurator.pm 13653 2007-10-22 09:11:20Z gr $
#
# Base class for environment configurators

use warnings;
use strict;
use Error::Hierarchy::Util qw/assert_defined load_class/;
use Class::Scaffold::Environment::Configurator::Local;

# Don't rely on UNIVERSAL::throw if we defined an AUTOLOAD...
use Error::Hierarchy::Internal::CustomMessage;


our $VERSION = '0.05';


use base 'Class::Scaffold::Accessor';


__PACKAGE__
    ->mk_singleton_constructor(qw(new instance))
    ->mk_array_accessors(qw(configurators))
    ->mk_scalar_accessors(qw(local_configurator));


sub init {
    my $self = shift;
    $self->local_configurator(
        Class::Scaffold::Environment::Configurator::Local->new,
    );
}


sub add_configurator {
    my $self = shift;
    my $type = shift;

    assert_defined $type, 'missing configuration type';

    if ($type eq 'file') {
        my $spec = shift;
        assert_defined $spec, 'missing file configuration spec';

        my ($class, $conf_filename);
        if (index($spec, ';') != -1) {
            ($class, $conf_filename) = split /;/ => $spec;

            assert_defined $_, sprintf(
                "can't determine file configuration class from spec [%s]", $spec)
                for $class, $conf_filename;
        } else {

            # assume a default class, and the spec _is_ the conf file name
            $class = 'Class::Scaffold::Environment::Configurator::File';
            $conf_filename = $spec;
        }

        load_class $class, 0;
        $self->configurators_push($class->new(filename => $conf_filename));

    } elsif ($type eq 'getopt') {
        my $options = shift;
        assert_defined $options, 'missing getopt configuration spec';

        require Class::Scaffold::Environment::Configurator::Getopt;
        $self->configurators_push(
            Class::Scaffold::Environment::Configurator::Getopt->
                new(opt => $options)
        );

    } else {
        throw Error::Hierarchy::Internal::CustomMessage(custom_message =>
            sprintf 'unknown configuration type [%s]', $type);
    }
}


# Define functions and class methods lest they be handled by AUTOLOAD.

sub DEFAULTS { () }
sub FIRST_CONSTRUCTOR_ARGS { () }
sub DESTROY {}


# Ask every configurator in turn; return the first defined answer we're given.

sub AUTOLOAD {
    my $self = shift;
    (my $method = our $AUTOLOAD) =~ s/.*://;

    if (@_) {
        throw Error::Hierarchy::Internal::CustomMessage(custom_message =>
            sprintf 'configuration key [%s] is read-only', $method);
    }

    # The local configurator is special -- it always comes first, no matter
    # which configurators have been specified.

    for my $configurator ($self->local_configurator, $self->configurators) {
        my $answer = $configurator->$method;
        return $answer if defined $answer;
    }
    undef;
}


1;


__END__



=head1 NAME

Class::Scaffold::Environment::Configurator - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Environment::Configurator->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item instance

    my $obj = Class::Scaffold::Environment::Configurator->instance;
    my $obj = Class::Scaffold::Environment::Configurator->instance(%args);

Creates and returns a new object. The object will be a singleton, so repeated
calls to the constructor will always return the same object. The constructor
will accept as arguments a list of pairs, from component name to initial
value. For each pair, the named component is initialized by calling the
method of the same name with the given value. If called with a single hash
reference, it is dereferenced and its key/value pairs are set as described
before.

=item new

    my $obj = Class::Scaffold::Environment::Configurator->new;
    my $obj = Class::Scaffold::Environment::Configurator->new(%args);

Creates and returns a new object. The object will be a singleton, so repeated
calls to the constructor will always return the same object. The constructor
will accept as arguments a list of pairs, from component name to initial
value. For each pair, the named component is initialized by calling the
method of the same name with the given value. If called with a single hash
reference, it is dereferenced and its key/value pairs are set as described
before.

=item clear_configurators

    $obj->clear_configurators;

Deletes all elements from the array.

=item clear_local_configurator

    $obj->clear_local_configurator;

Clears the value.

=item configurators

    my @values    = $obj->configurators;
    my $array_ref = $obj->configurators;
    $obj->configurators(@values);
    $obj->configurators($array_ref);

Get or set the array values. If called without an arguments, it returns the
array in list context, or a reference to the array in scalar context. If
called with arguments, it expands array references found therein and sets the
values.

=item configurators_clear

    $obj->configurators_clear;

Deletes all elements from the array.

=item configurators_count

    my $count = $obj->configurators_count;

Returns the number of elements in the array.

=item configurators_index

    my $element   = $obj->configurators_index(3);
    my @elements  = $obj->configurators_index(@indices);
    my $array_ref = $obj->configurators_index(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item configurators_pop

    my $value = $obj->configurators_pop;

Pops the last element off the array, returning it.

=item configurators_push

    $obj->configurators_push(@values);

Pushes elements onto the end of the array.

=item configurators_set

    $obj->configurators_set(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item configurators_shift

    my $value = $obj->configurators_shift;

Shifts the first element off the array, returning it.

=item configurators_splice

    $obj->configurators_splice(2, 1, $x, $y);
    $obj->configurators_splice(-1);
    $obj->configurators_splice(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item configurators_unshift

    $obj->configurators_unshift(@values);

Unshifts elements onto the beginning of the array.

=item count_configurators

    my $count = $obj->count_configurators;

Returns the number of elements in the array.

=item index_configurators

    my $element   = $obj->index_configurators(3);
    my @elements  = $obj->index_configurators(@indices);
    my $array_ref = $obj->index_configurators(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item instance_instance

    my $obj = Class::Scaffold::Environment::Configurator->instance_instance;
    my $obj = Class::Scaffold::Environment::Configurator->instance_instance(%args);

Creates and returns a new object. The constructor will accept as arguments a
list of pairs, from component name to initial value. For each pair, the named
component is initialized by calling the method of the same name with the given
value. If called with a single hash reference, it is dereferenced and its
key/value pairs are set as described before.

=item local_configurator

    my $value = $obj->local_configurator;
    $obj->local_configurator($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item local_configurator_clear

    $obj->local_configurator_clear;

Clears the value.

=item new_instance

    my $obj = Class::Scaffold::Environment::Configurator->new_instance;
    my $obj = Class::Scaffold::Environment::Configurator->new_instance(%args);

Creates and returns a new object. The constructor will accept as arguments a
list of pairs, from component name to initial value. For each pair, the named
component is initialized by calling the method of the same name with the given
value. If called with a single hash reference, it is dereferenced and its
key/value pairs are set as described before.

=item pop_configurators

    my $value = $obj->pop_configurators;

Pops the last element off the array, returning it.

=item push_configurators

    $obj->push_configurators(@values);

Pushes elements onto the end of the array.

=item set_configurators

    $obj->set_configurators(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item shift_configurators

    my $value = $obj->shift_configurators;

Shifts the first element off the array, returning it.

=item splice_configurators

    $obj->splice_configurators(2, 1, $x, $y);
    $obj->splice_configurators(-1);
    $obj->splice_configurators(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item unshift_configurators

    $obj->unshift_configurators(@values);

Unshifts elements onto the beginning of the array.

=back

Class::Scaffold::Environment::Configurator inherits from
L<Class::Scaffold::Accessor> and L<Class::Accessor::Constructor::Base>.

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

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

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
                   
This document describes version 0.05 of L<Class::Scaffold::Environment::Configurator>.

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

