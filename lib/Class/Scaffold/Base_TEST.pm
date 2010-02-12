package Class::Scaffold::Base_TEST;
use strict;
use warnings;
use Error::Hierarchy::Test 'throws2_ok';
use Test::More;
our $VERSION = '0.16';
use base 'Class::Scaffold::Test';
use constant PLAN => 4;

sub run {
    my $self = shift;
    $self->SUPER::run(@_);
    my $obj = $self->make_real_object;
    isa_ok($obj->delegate, 'Class::Scaffold::Environment');
    isa_ok($obj->log,      'Class::Scaffold::Log');
    throws2_ok { $obj->foo }
    'Error::Simple',
      qr/^Undefined subroutine &Class::Scaffold::Base::foo called at/,
      'call to undefined subroutine caught by UNIVERSAL::AUTOLOAD';

    # Undef the existing error. Strangely necessary, otherwise the next
    # ->make_real_object dies with the error message still in $@, although the
    # require() in ->make_real_object should have cleared it on success...
    undef $@;
    throws2_ok { Class::Scaffold::Does::Not::Exist->new }
    'Error::Hierarchy::Internal::CustomMessage',
      qr/Couldn't load package \[Class::Scaffold::Does::Not::Exist\]:/,
      'call to undefined package caught by UNIVERSAL::AUTOLOAD';
}
1;
__END__

=head1 NAME

Class::Scaffold::Base_TEST - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Base_TEST->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<run>

Runs the actual tests specific to this class.

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

