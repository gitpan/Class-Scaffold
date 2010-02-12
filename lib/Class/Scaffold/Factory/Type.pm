package Class::Scaffold::Factory::Type;
use warnings;
use strict;
our $VERSION = '0.16';
use base 'Class::Factory::Enhanced';

sub import {
    my ($class, $spec) = @_;
    return unless defined $spec && $spec eq ':all';
    my $pkg = caller;
    for my $symbol (Class::Scaffold::Factory::Type->get_registered_types) {
        my $factory_class =
          Class::Scaffold::Factory::Type->get_registered_class($symbol);
        no strict 'refs';
        my $target = "${pkg}::obj_${symbol}";
        *$target = sub () { $factory_class };
    }
}

# override this method with a caching version; it's called very often
sub make_object_for_type {
    my ($self, $object_type, @args) = @_;
    our %cache;
    my $class = $cache{$object_type} ||= $self->get_factory_class($object_type);
    $class->new(@args);
}

# no warnings
sub factory_log { }

sub register_factory_type {
    my ($item, @args) = @_;
    $item->SUPER::register_factory_type(@args);
    return unless $::PTAGS;
    while (my ($factory_type, $package) = splice @args, 0, 2) {
        $::PTAGS->add_tag("csft--$factory_type", "filename_for:$package", 1);
    }
}
1;
__END__

=head1 NAME

Class::Scaffold::Factory::Type - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Factory::Type->new;

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

