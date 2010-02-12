package Class::Scaffold::Util;

# Package holding various useful functions.
use warnings;
use strict;
use Error::Hierarchy::Util 'assert_hashref';
our $VERSION = '0.16';
use Exporter qw(import);
our %EXPORT_TAGS = (util => [qw/hash_delta const/],);
our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };

# generates the delta for two given hashrefs.
# returns three hashrefs containing the elements of the given hashrefs
# which should be
#   1. inserted
#   2. updated
#   3. deleted
sub hash_delta {
    my ($this, $that) = @_;
    my ($insert, $delete, $update);
    $this = {} unless defined $this;
    $that = {} unless defined $that;
    assert_hashref $this,
      sprintf "hash_delta: \$this isn't a hashref, it's a %s", ref $this;
    assert_hashref $that,
      sprintf "hash_delta: \$that isn't a hashref, it's a %s", ref $that;

    # get extinct keys.
    for (keys %$this) {
        $delete->{$_} = $this->{$_} unless exists $that->{$_};
    }

    # get new keys.
    for (keys %$that) {

        # and catch updated keys also.
        if (exists $this->{$_}) {
            $update->{$_} = $that->{$_};
        } else {
            $insert->{$_} = $that->{$_};
        }
    }
    return ($insert, $update, $delete);
}

sub const ($@) {
    my $name = shift;
    my %args = @_;
    my ($pkg, $filename, $line) = (caller)[ 0 .. 2 ];
    no strict 'refs';
    my $every_hash_name = "${name}_HASH";
    $::PTAGS && $::PTAGS->add_tag($every_hash_name, $filename, $line);
    *{"${pkg}::${every_hash_name}"} = sub { %args };
    $::PTAGS && $::PTAGS->add_tag($name, $filename, $line);
    *{"${pkg}::${name}"} = sub {
        my $self = shift;
        my $hash = $self->every_hash($every_hash_name);
        if (@_) {
            my $key = shift;
            $hash->{$key}
              || $hash->{_AUTO}
              || throw Error::Hierarchy::Internal::CustomMessage(
                custom_message =>
                  "neither key [$key] nor [_AUTO] in $every_hash_name");
        } else {
            my @val = values %$hash;
            return wantarray ? @val : \@val;
        }
    };

    # have a sub that returns how many of those items there are
    my $count_name = "${name}_COUNT";
    $::PTAGS && $::PTAGS->add_tag($count_name, $filename, $line);
    *{"${pkg}::${count_name}"} = sub {
        my $self = shift;
        scalar(@{ $self->$name });
    };
    while (my ($key, $value) = each %args) {
        $::PTAGS && $::PTAGS->add_tag($key, $filename, $line);
        *{"${pkg}::${key}"} = sub { $value };
    }
}
1;
__END__

=head1 NAME

Class::Scaffold::Util - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Util->new;

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

