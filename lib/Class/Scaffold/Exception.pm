use 5.008;
use warnings;
use strict;

package Class::Scaffold::Exception;
BEGIN {
  $Class::Scaffold::Exception::VERSION = '1.102280';
}
# ABSTRACT: Base class for framework exceptions

# It's ok to inherit from Class::Scaffold::Storable as well; new() will be
# found in Error::Hierarchy first. For the exception class itself, to inherit
# from Class::Scaffold::Base would be enough, but there might be subclasses
# that need the 'storage' accessor - Class::Scaffold::Exception::Container, for
# example.
use parent qw(
  Error::Hierarchy
  Class::Scaffold::Storable
);
1;

__END__
=pod

=head1 NAME

Class::Scaffold::Exception - Base class for framework exceptions

=head1 VERSION

version 1.102280

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

