package Class::Scaffold::Exception::Util;

use strict;
use warnings;
use Error::Hierarchy::Util 'assert_class';


our $VERSION = '0.12';


use base 'Exporter';


our %EXPORT_TAGS = (
    misc => [ qw{assert_object_type} ],
);

our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };


# pass an OBJ_* constant to this method

sub assert_object_type ($$) {
    my ($obj, $object_type_const) = @_;
    local $Error::Depth = $Error::Depth + 1;
    assert_class($obj, Class::Scaffold::Environment->getenv->
        get_class_name_for($object_type_const)
    );
}


1;


__END__



=head1 NAME

Class::Scaffold::Exception::Util - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Exception::Util->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4



=back

Class::Scaffold::Exception::Util inherits from L<Exporter>.

The superclass L<Exporter> defines these methods and functions:

    as_heavy(), export(), export_fail(), export_ok_tags(), export_tags(),
    export_to_level(), import(), require_version()

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

