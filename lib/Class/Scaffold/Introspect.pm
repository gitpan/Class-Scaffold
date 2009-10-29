package Class::Scaffold::Introspect;

use warnings;
use strict;
use FindBin '$Bin';
use Cwd;
use File::Spec::Functions qw/curdir updir rootdir rel2abs/;
use Sys::Hostname;


our $VERSION = '0.10';


use base 'Exporter';


our %EXPORT_TAGS = (
    conf => [ qw/find_conf_file/ ],
);

our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };


sub find_file_upwards {
    my $wanted_file = shift;

    my $previous_cwd = getcwd;
    my $result;    # left undef as we'll return undef if we didn't find it
    while (rel2abs(curdir()) ne rootdir()) {
        if (-f $wanted_file) {
            $result = rel2abs(curdir());
            last;
        }
        chdir(updir());
    }
    chdir($previous_cwd);
    $result;
}


sub find_conf_file {
    my $file = 'SMOKEconf.yaml';

    # the distribution root is where Build.PL is; start the search from where
    # the bin file was (presumably within the distro). This way we can say any
    # of:
    #
    # perl t/sometest.t
    # cd t; perl sometest.t
    # perl /abs/path/to/distro/t/sometest.t

    chdir($Bin) or die "can't chdir to [$Bin]: $!\n";
    my $distro_root = find_file_upwards('Makefile.PL');

    unless (defined $distro_root && length $distro_root) {
        warn "can't find distro root from [$Bin]\n";
        warn "might not be able to find conf file using [$ENV{CF_CONF}]\n"
            if $ENV{CF_CONF} eq 'local';
        return;
    }

    my $etc = "$distro_root/etc";
    return "$etc/$file" if -e "$etc/$file";

    # warn "find_conf_file: not in [$etc/$file]";

    (my $hostname = hostname) =~ s/\W.*//;
    my $dir = "$etc/$hostname";
    return "$dir/$file" if -d $dir && -e "$dir/$file";

    # warn "find_conf_file: not in [$dir/$file]";
    undef;
}


1;


__END__



=head1 NAME

Class::Scaffold::Introspect - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Introspect->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4



=back

Class::Scaffold::Introspect inherits from L<Exporter>.

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

