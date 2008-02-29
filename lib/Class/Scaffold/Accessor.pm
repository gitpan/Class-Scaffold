package Class::Scaffold::Accessor;

use warnings;
use strict;
use Error::Hierarchy::Util 'assert_read_only';
use Class::Scaffold::Factory::Type;


our $VERSION = '0.05';


use base qw(
    Class::Accessor::Complex
    Class::Accessor::Constructor
    Class::Accessor::FactoryTyped
);


sub mk_framework_object_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_accessors(
        'Class::Scaffold::Factory::Type', @args);
}


sub mk_framework_object_array_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_array_accessors(
        'Class::Scaffold::Factory::Type', @args);
}


sub mk_readonly_accessors {
    my ($self, @fields) = @_;
    my $class = ref $self || $self;

    for my $field (@fields) {
        no strict 'refs';

        *{"${class}::${field}"} = sub {
            local $DB::sub = local *__ANON__ = "${class}::${field}"
                if defined &DB::DB && !$Devel::DProf::VERSION;
            my $self = shift;
            assert_read_only(@_);
            $self->{$field};
        };

        *{"${class}::set_${field}"} =
        *{"${class}::${field}_set"} = sub {
            local $DB::sub = local *__ANON__ = "${class}::${field}_set"
                if defined &DB::DB && !$Devel::DProf::VERSION;
            $_[0]->{$field} = $_[1];
        };
    }

    $self;  # for chaining
}


1;


__END__



=head1 NAME

Class::Scaffold::Accessor - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Accessor->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4



=back

Class::Scaffold::Accessor inherits from L<Class::Accessor::Complex>,
L<Class::Accessor::Constructor>, and L<Class::Accessor::FactoryTyped>.

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    mk_abstract_accessors(), mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    new(), _carp(), _croak(), _mk_accessors(), accessor_name_for(),
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

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::Accessor>.

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

