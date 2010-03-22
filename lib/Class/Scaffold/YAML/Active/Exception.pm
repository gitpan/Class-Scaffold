use 5.008;
use warnings;
use strict;

package Class::Scaffold::YAML::Active::Exception;
our $VERSION = '1.100810';
# ABSTRACT: Plugin for recording an exception for a test
use YAML::Active qw/assert_hashref hash_activate/;
use parent 'Class::Scaffold::YAML::Active';

sub yaml_activate {
    my ($self, $phase) = @_;
    assert_hashref($self);
    my $hash = hash_activate($self, $phase);
    {
        ref       => $hash->{type},
          message => $hash->{type}->record(%{ $hash->{attr} }),
    };
}
1;


__END__
=pod

=head1 NAME

Class::Scaffold::YAML::Active::Exception - Plugin for recording an exception for a test

=head1 VERSION

version 1.100810

=head1 METHODS

=head2 yaml_activate

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

