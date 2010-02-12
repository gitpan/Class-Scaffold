package Class::Scaffold::Accessor;
use warnings;
use strict;
use Error::Hierarchy::Util 'assert_read_only';
use Class::Scaffold::Factory::Type;
our $VERSION = '0.16';
use base qw(
  Class::Accessor::Complex
  Class::Accessor::Constructor
  Class::Accessor::FactoryTyped
);

sub mk_framework_object_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_accessors('Class::Scaffold::Factory::Type', @args);
}

sub mk_framework_object_array_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_array_accessors('Class::Scaffold::Factory::Type',
        @args);
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
        *{"${class}::set_${field}"} = *{"${class}::${field}_set"} = sub {
            local $DB::sub = local *__ANON__ = "${class}::${field}_set"
              if defined &DB::DB && !$Devel::DProf::VERSION;
            $_[0]->{$field} = $_[1];
        };
    }
    $self;    # for chaining
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

=item mk_framework_object_accessors

Makes factory-typed accessors - see L<Class::Accessor::FactoryTyped> - and
uses L<Class::Scaffold::Factory::Type> as the factory class.

=item mk_framework_object_array_accessors

Makes factory-typed array accessors - see L<Class::Accessor::FactoryTyped> -
and uses L<Class::Scaffold::Factory::Type> as the factory class.

=item mk_readonly_accessors

Takes an array of strings as its argument. For each string it creates methods
as described below, where C<*> denotes the slot name.

=over 4

=item C<*>

This method can retrieve a value from its slot. If it receives an argument, it
throws an exception. If called without a value, the method retrieves the value
from the slot. There is a method to set the value - see below -, but
separating the setter and getter methods ensures that it can't be set, for
example, using the class' constructor.

=item C<*_set>, C<set_*>

Sets the slot to the given value and returns it.

=back

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

