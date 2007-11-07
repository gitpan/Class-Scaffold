package Class::Scaffold::App::Test::Classes;

use warnings;
use strict;
use FindBin '$Bin';
use Test::More;
use Test::CompanionClasses::Engine;


our $VERSION = '0.01';


use base 'Class::Scaffold::App::Test';


__PACKAGE__
    ->mk_array_accessors(qw(inherited))
    ->mk_scalar_accessors(qw(lib));


use constant DEFAULTS => (
    lib => "$Bin/../lib",   # two levels, we live in t/embedded/
);

use constant GETOPT => ('exact');


sub app_code {
    my $self = shift;
    $self->SUPER::app_code(@_);
    Test::CompanionClasses::Engine->new->run_tests(
        exact     => $self->opt->{exact},
        lib       => $self->lib,
        filter    => [ @ARGV ],
        inherited => [ $self->inherited ],
    );
}


1;


__END__

=head1 NAME

Class::Scaffold - large-scale OOP application support

=head1 SYNOPSIS

None yet (see below).

=head1 DESCRIPTION

None yet. This is an early release; fully functional, but undocumented. The
next release will have more documentation.

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classframework> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-class-framework@rt.cpan.org>, or through the web interface at
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

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

