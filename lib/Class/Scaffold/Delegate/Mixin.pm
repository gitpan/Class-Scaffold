package Class::Scaffold::Delegate::Mixin;

# $Id: Mixin.pm 9981 2005-07-27 06:52:47Z gr $

use warnings;
use strict;



our $VERSION = '0.08';


# Class::Scaffold::Base inherits from this mixin, so we shouldn't use()
# Class::Scaffold::Environment, which inherits from
# Class::Scaffold::Base, creating redefined() warnings. So we just
# require() it here.

sub delegate {
    require Class::Scaffold::Environment;
    Class::Scaffold::Environment->getenv
}


1;


__END__



=head1 NAME

Class::Scaffold::Delegate::Mixin - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Delegate::Mixin->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4



=back

Class::Scaffold::Delegate::Mixin inherits from .

=head1 TAGS

If you talk about this module in blogs, on L<delicious.com> or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::Delegate::Mixin>.

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

