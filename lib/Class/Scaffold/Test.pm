package Class::Scaffold::Test;
use strict;
use warnings;
use Test::More;
use Class::Value;    # see run() below
our $VERSION = '0.16';

# Also inherit from Class::Scaffold::Base so we get a delegate; put it first
# so its new() is found, not the very basic new() from Project::Build::Test
use base qw(
  Class::Scaffold::Base
  Test::CompanionClasses::Base
);
use constant PLAN => 1;

sub obj_ok {
    my ($self, $object, $object_type_const) = @_;
    isa_ok($object, $self->delegate->get_class_name_for($object_type_const));
}

# Override planned_test_count() with a version that uses every_list().
# Project::Build::Test->planned_test_count() couldn't use that because
# every_list() is implemented in Data::Inherited, which in turn uses
# Project::Build.
sub planned_test_count {
    my $self = shift;
    my $plan;

    # so that PLANs can use the delegate:
    $::delegate = $self->delegate;
    $plan += $_ for $self->every_list('PLAN');
    $plan;
}

sub run {
    my $self = shift;
    $self->SUPER::run(@_);

    # check that test prerequisites are ok
    is($Class::Value::SkipChecks, 1, '$Class::Value::SkipChecks is on');
}
1;
__END__

=head1 NAME

Class::Scaffold::Test - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Test->new;

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

