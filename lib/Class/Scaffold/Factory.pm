package Class::Scaffold::Factory;
use warnings;
use strict;
use Error;    # to get $Error::Depth;
use Error::Hierarchy::Util qw/assert_defined load_class/;
our $VERSION = '0.16';
use base 'Class::Scaffold::Storable';

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

=head1 NAME

Class::Scaffold::Factory - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Factory->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

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

