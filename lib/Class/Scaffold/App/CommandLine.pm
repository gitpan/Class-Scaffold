package Class::Scaffold::App::CommandLine;
use strict;
use warnings;
use Class::Scaffold::Environment;
use Property::Lookup;
our $VERSION = '0.16';
use base qw(Class::Scaffold::App Getopt::Inherited);
use constant CONTEXT => 'generic/shell';
use constant GETOPT  => (qw(dryrun conf=s environment));

sub app_init {
    my $self = shift;
    $self->do_getopt;
    # Add a hash configurator layer for getopt before the superclass has a
    # chance to add the file configurator; this way, getopt definitions take
    # precedence over what's in the conf file.
    Property::Lookup->instance->add_layer(hash => scalar $self->opt);
    $self->SUPER::app_init(@_);
}

sub app_finish {
    my $self = shift;
    $self->delegate->disconnect;
}
1;
__END__

=head1 NAME

Class::Scaffold::App::CommandLine - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::App::CommandLine->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_opt>

    $obj->clear_opt;

Deletes all keys and values from the hash.

=item C<delete_opt>

    $obj->delete_opt(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<exists_opt>

    if ($obj->exists_opt($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<keys_opt>

    my @keys = $obj->keys_opt;

Returns a list of all hash keys in no particular order.

=item C<opt>

    my %hash     = $obj->opt;
    my $hash_ref = $obj->opt;
    my $value    = $obj->opt($key);
    my @values   = $obj->opt([ qw(foo bar) ]);
    $obj->opt(%other_hash);
    $obj->opt(foo => 23, bar => 42);

Get or set the hash values. If called without arguments, it returns the hash
in list context, or a reference to the hash in scalar context. If called
with a list of key/value pairs, it sets each key to its corresponding value,
then returns the hash as described before.

If called with exactly one key, it returns the corresponding value.

If called with exactly one array reference, it returns an array whose elements
are the values corresponding to the keys in the argument array, in the same
order. The resulting list is returned as an array in list context, or a
reference to the array in scalar context.

If called with exactly one hash reference, it updates the hash with the given
key/value pairs, then returns the hash in list context, or a reference to the
hash in scalar context.

=item C<opt_clear>

    $obj->opt_clear;

Deletes all keys and values from the hash.

=item C<opt_delete>

    $obj->opt_delete(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<opt_exists>

    if ($obj->opt_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<opt_keys>

    my @keys = $obj->opt_keys;

Returns a list of all hash keys in no particular order.

=item C<opt_values>

    my @values = $obj->opt_values;

Returns a list of all hash values in no particular order.

=item C<values_opt>

    my @values = $obj->values_opt;

Returns a list of all hash values in no particular order.

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

