package Class::Scaffold::Factory::Type;

use warnings;
use strict;


our $VERSION = '0.05';


use base 'Class::Factory::Enhanced';


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

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::Factory::Type>.

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

