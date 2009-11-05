package Class::Scaffold::Test::UtilLoader;

use warnings;
use strict;
use Class::Scaffold::YAML::Marshall::Constant;
use Class::Scaffold::YAML::Marshall::ExceptionContainer;
use Class::Scaffold::YAML::Marshall::Concat;
use Class::Scaffold::YAML::Marshall::PID;

# So that we can ->make_obj('test_util_loader')
use base 'Class::Scaffold::Storable';

our $VERSION = '0.13';

# This module doesn't do anything except load other classes necessary for
# tests. It is being loaded in Class::Scaffold::App::Test. It is mapped to the
# 'test_util_loader' object type in Class::Scaffold::Environment. So
# distributions based on Class::Scaffold can define their own test util loader
# class and tell the environment about it.

1;


__END__



=head1 NAME

Class::Scaffold::Test::UtilLoader - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Test::UtilLoader->new;

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

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2004-2009 by the author.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

