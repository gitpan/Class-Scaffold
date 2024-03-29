use 5.008;
use warnings;
use strict;

package Class::Scaffold::Factory;
BEGIN {
  $Class::Scaffold::Factory::VERSION = '1.102280';
}
# ABSTRACT: Base class for framework factories
use Error;    # to get $Error::Depth;
use Error::Hierarchy::Util qw/assert_defined load_class/;
use parent 'Class::Scaffold::Storable';

sub notify_lookup_failure {
    my ($self, $handler_type, $spec) = @_;
    local $Error::Depth = $Error::Depth + 1;
    throw Class::Scaffold::Exception::NoSuchFactoryHandler(
        handler_type => $handler_type,
        spec         => join(', ', @$spec),
    );
}

sub get_class_name_for_handler {
    my ($self, $handler_type, $spec) = @_;
    assert_defined $handler_type, 'called without handler_type.';
    my $class = $self->every_hash($handler_type);
    for my $spec_el (@$spec) {

        # Stringify potential value object as using it as a hash key doesn't
        # trigger stringification automatically
        if (exists $class->{"$spec_el"}) {
            $class = $class->{"$spec_el"};
        } elsif (exists $class->{_AUTO}) {
            $class = $class->{_AUTO};

            # ignore the rest of the spec
            last;
        } else {
            $self->notify_lookup_failure($handler_type, $spec);
            return;    # undef to signal failure
        }
    }
    $class;
}

sub gen_handler {
    my ($self, $handler_type, $spec, %args) = @_;
    my $class = $self->get_class_name_for_handler($handler_type, $spec);
    load_class $class, $self->delegate->test_mode;
    $class->new(
        storage_type => $self->storage_type,
        %args
    );
}
1;


__END__
=pod

=head1 NAME

Class::Scaffold::Factory - Base class for framework factories

=head1 VERSION

version 1.102280

=head1 METHODS

=head2 gen_handler

FIXME

=head2 get_class_name_for_handler

FIXME

=head2 notify_lookup_failure

FIXME

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see
L<http://search.cpan.org/dist/Class-Scaffold/>.

The development version lives at
L<http://github.com/hanekomu/Class-Scaffold/>.
Instead of sending patches, please fork this project using the standard git
and github infrastructure.

=head1 AUTHORS

=over 4

=item *

Marcel Gruenauer <marcel@cpan.org>

=item *

Florian Helmberger <fh@univie.ac.at>

=item *

Achim Adam <ac@univie.ac.at>

=item *

Mark Hofstetter <mh@univie.ac.at>

=item *

Heinz Ekker <ek@univie.ac.at>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

