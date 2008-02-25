package Class::Scaffold::Base;

# $Id: Base.pm 13653 2007-10-22 09:11:20Z gr $

# base class for all classes of the class framework.
# Everything should subclass this.

use strict;
use warnings;
use Data::Miscellany 'set_push';
use Error::Hierarchy::Util 'load_class';


our $VERSION = '0.03';


use base qw/
    Data::Inherited
    Data::Comparable
    Error::Hierarchy::Mixin
    Class::Scaffold::Delegate::Mixin
    Class::Scaffold::Accessor
    Class::Scaffold::Factory::Type
/;

# We subclass Class::Scaffold::Factory::Type so objects can introspect to see
# which object type they are.


__PACKAGE__->mk_constructor;


# so every_hash has something to fall back to:

sub FIRST_CONSTRUCTOR_ARGS { () }


# so everyone can call SUPER:: without worries, just pass through the args:

sub MUNGE_CONSTRUCTOR_ARGS {
    my $self = shift;
    @_
}


sub init { 1 }


# Convenience method so subclasses don't need to say
#
#   use Class::Scaffold::Log;
#   my $log = Class::Scaffold::Log;
#   $log->info(...);
#
# or
#
#   Class::Scaffold::Log->debug(...);
#
# but can say
#
#   $self->log->info(...);
#
# Eliminating fixed package names is also a way of decoupling; later on we
# might choose to get the log from the delegate or anywhere else, in which
# case we can make the change in one location - here.
#
# Class::Scaffold::Log inherits from this class, so we don't use() it but
# require() it, to avoid 'redefined' warnings.

sub log {
    my $self = shift;
    require Class::Scaffold::Log;
    Class::Scaffold::Log->instance;
}


# Try to load currently not loaded packages of the Class-Scaffold and other
# registered distributions and call the wanted method.
#
# Throw an exception if the package in which we have to look for the wanted
# method is already loaded (= the method doesn't exist).

sub UNIVERSAL::DESTROY {}

sub UNIVERSAL::AUTOLOAD {
    my ($pkg, $method) = ($UNIVERSAL::AUTOLOAD =~ /(.*)::(.*)/);

    local $" = '|';
    our @autoload_packages;
    unless ($pkg =~ /^(@autoload_packages)/) {
        # we don't deal with crappy external libs and
        # their problems. get lost with your symbol.
        require Carp;
        local $Carp::CarpLevel = 1;
        Carp::confess sprintf
            "Undefined subroutine &%s called", $UNIVERSAL::AUTOLOAD;
    }
    (my $key = "$pkg.pm") =~ s!::!/!g;
    local $Error::Depth = $Error::Depth + 1;
    if (exists $INC{$key}) {
        # package has been loaded already, so the method wanted
        # doesn't seem to exist.
        require Carp;
        local $Carp::CarpLevel = 1;
        Carp::confess sprintf
            "Undefined subroutine &%s called", $UNIVERSAL::AUTOLOAD;
    } else {
        load_class $pkg, 1;
        no warnings;
        if (my $coderef = UNIVERSAL::can($pkg, $method)) {
            goto &$coderef;
        } else {
            require Carp;
            local $Carp::CarpLevel = 1;
            Carp::confess sprintf
                "Undefined subroutine &%s called", $UNIVERSAL::AUTOLOAD;
        }
    }
}



sub add_autoloaded_package {
    shift if $_[0] eq __PACKAGE__;
    my $prefix = shift;
    our @autoload_packages;
    set_push @autoload_packages, $prefix;
}


1;


__END__



=head1 NAME

Class::Scaffold::Base - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Base->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

    my $obj = Class::Scaffold::Base->new;
    my $obj = Class::Scaffold::Base->new(%args);

Creates and returns a new object. The constructor will accept as arguments a
list of pairs, from component name to initial value. For each pair, the named
component is initialized by calling the method of the same name with the given
value. If called with a single hash reference, it is dereferenced and its
key/value pairs are set as described before.

=back

Class::Scaffold::Base inherits from L<Data::Inherited>,
L<Data::Comparable>, L<Error::Hierarchy::Mixin>,
L<Class::Scaffold::Delegate::Mixin>, L<Class::Scaffold::Accessor>,
L<Class::Scaffold::Factory::Type>, and
L<Class::Accessor::Constructor::Base>.

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
                   
This document describes version 0.03 of L<Class::Scaffold::Base>.

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

