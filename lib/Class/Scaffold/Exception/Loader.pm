use 5.008;
use warnings;
use strict;

package Class::Scaffold::Exception::Loader;
our $VERSION = '1.100810';
# ABSTRACT: Exception raised when a class cannot be loaded
use parent qw(Error::Hierarchy::Internal Class::Scaffold::Accessor);
__PACKAGE__->mk_scalar_accessors(qw(class origin message));
use constant default_message => "Can't load [%s], (%s) %s";
sub properties { $_[0]->SUPER::properties, qw/class origin message/ }
1;


__END__
=pod

=head1 NAME

Class::Scaffold::Exception::Loader - Exception raised when a class cannot be loaded

=head1 VERSION

version 1.100810

=head1 METHODS

=head2 properties

FIXME

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Class-Scaffold>.

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

  Marcel Gruenauer <marcel@cpan.org>
  Florian Helmberger <fh@univie.ac.at>
  Achim Adam <ac@univie.ac.at>
  Mark Hofstetter <mh@univie.ac.at>
  Heinz Ekker <ek@univie.ac.at>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

