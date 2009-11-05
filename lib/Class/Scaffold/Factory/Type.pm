package Class::Scaffold::Factory::Type;

use warnings;
use strict;


our $VERSION = '0.13';


use base 'Class::Factory::Enhanced';


sub import {
    my ($class, $spec) = @_;
    return unless defined $spec && $spec eq ':all';
    my $pkg = caller;
    for my $symbol (Class::Scaffold::Factory::Type->get_registered_types) {
        my $factory_class = Class::Scaffold::Factory::Type->
            get_registered_class($symbol);
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
sub factory_log {}


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

Class::Scaffold::Factory::Type inherits from L<Class::Factory::Enhanced>.

The superclass L<Class::Factory::Enhanced> defines these methods and
functions:

    add_factory_type(), make_object_for_type(), register_factory_type()

The superclass L<Class::Factory> defines these methods and functions:

    new(), factory_error(), get_factory_class(), get_factory_type_for(),
    get_loaded_classes(), get_loaded_types(), get_my_factory(),
    get_my_factory_type(), get_registered_class(),
    get_registered_classes(), get_registered_types(), init(),
    remove_factory_type(), unregister_factory_type()

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

