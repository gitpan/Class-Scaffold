package Class::Scaffold::BusinessObject;
use strict;
use warnings;
use Error::Hierarchy::Util 'assert_defined';
our $VERSION = '0.16';
use base qw(
  Class::Scaffold::Storable
  Class::Scaffold::HierarchicalDirty
);
__PACKAGE__->mk_scalar_accessors(qw(key_name))
  ->mk_abstract_accessors(qw(key object_type));
use constant DEFAULTS => (key_name => 'key field',);

# Each business object can tell its defining key, e.g. handle for persons,
# domainname for domains etc.
# check() is given an exception container, which it fills with exceptions that
# arise from checking. Since we're dealing exclusively with value objects, we
# can check for valid characters, field lengths, some wellformedness and
# validity (in case of email value objects, for example), all from within the
# business objects themselves. By moving part of the checking code into the
# objects themselves we make the policy stage more generic. Other registries
# can simply define business objects in terms of different value objects.
sub check { }

sub used_objects {
    my $self = shift;
    ($self->object_type => $self->key);
}

sub assert_key {
    my $self = shift;
    local $Error::Depth = $Error::Depth + 1;
    assert_defined $self->key,
      sprintf('called without defined %s', $self->key_name);
}

sub store {
    my $self = shift;
    if ($self->key) {
        $self->update;
    } else {
        $self->insert;
    }
}
use constant SKIP_COMPARABLE_KEYS => ('key_name');

# do nothing; subclasses will implement it
sub apply_instruction_container { }
1;
__END__

=head1 NAME

Class::Scaffold::BusinessObject - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::BusinessObject->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_key_name>

    $obj->clear_key_name;

Clears the value.

=item C<key_name>

    my $value = $obj->key_name;
    $obj->key_name($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<key_name_clear>

    $obj->key_name_clear;

Clears the value.

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

