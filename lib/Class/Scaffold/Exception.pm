package Class::Scaffold::Exception;
use warnings;
use strict;
our $VERSION = '0.16';

# It's ok to inherit from Class::Scaffold::Storable as well; new() will be
# found in Error::Hierarchy first. For the exception class itself, to inherit
# from Class::Scaffold::Base would be enough, but there might be subclasses
# that need the 'storage' accessor - Class::Scaffold::Exception::Container, for
# example.
use base qw(
  Error::Hierarchy
  Class::Scaffold::Storable
);
1;
__END__

=head1 NAME

Class::Scaffold::Exception - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Exception->new;

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

