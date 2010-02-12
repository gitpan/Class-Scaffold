package Class::Scaffold::Context;
use strict;
use warnings;
our $VERSION = '0.16';
use base 'Class::Scaffold::Base';
__PACKAGE__->mk_scalar_accessors(qw(execution job));

# types of execution context: cron, apache, shell, soap
# types of job context: mail, sif, epp
# takes something like 'run/epp' and sets execution and job context
sub parse_context {
    my ($self, $spec) = @_;
    if ($spec =~ m!^(\w+)/(\w+)$!) {
        my ($job, $execution) = ($1, $2);
        $self->execution($execution);
        $self->job($job);
    } else {
        throw Error::Hierarchy::Internal::CustomMessage(
            custom_message => "Invalid context specification [$spec]",);
    }
    $self;
}

sub as_string {
    my $self = shift;
    sprintf '%s/%s',
      (defined $self->job       ? $self->job       : 'none'),
      (defined $self->execution ? $self->execution : 'none');
}
1;
__END__

=head1 NAME

Class::Scaffold::Context - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Context->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_execution>

    $obj->clear_execution;

Clears the value.

=item C<clear_job>

    $obj->clear_job;

Clears the value.

=item C<execution>

    my $value = $obj->execution;
    $obj->execution($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<execution_clear>

    $obj->execution_clear;

Clears the value.

=item C<job>

    my $value = $obj->job;
    $obj->job($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<job_clear>

    $obj->job_clear;

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

