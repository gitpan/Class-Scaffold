package Class::Scaffold::Log_TEST;
use strict;
use warnings;
use Test::More;
our $VERSION = '0.16';
use base 'Class::Scaffold::Test';
use constant PLAN => 2;

sub run {
    my $self = shift;
    $self->SUPER::run(@_);

    # Use different ways of accessing the log: via the singleton object, or by
    # using the feature of turning a class method call into an instance call.
    my $log = $self->make_real_object->instance;
    isa_ok($log, $self->package);

    # manually turn off test mode so that the log won't output to STDERR; after
    # all, that's exactly what we want to test.
    $log->delegate->test_mode(0);
    $log->info('Hello');
    Class::Scaffold::Log->debug('a debug message that should not appear');
    $log->max_level(2);
    Class::Scaffold::Log->debug('a debug message that should appear');
    $log->set_pid;
    Class::Scaffold::Log->info('a message with %s and %s', qw/pid timestamp/);
    $log->clear_timestamp;
    $log->info('a message with pid but without timestamp');
    Class::Scaffold::Log->instance->clear_pid;
    Class::Scaffold::Log->instance->info('a message without pid or timestamp');
    (my $out = $log->output) =~ s/^\d{8}\.\d{6}\.\d\d/[timestamp]/mg;
    my $pid = sprintf '%08d', $$;
    is($out, <<EXPECT, 'log output');
[timestamp] Hello
[timestamp] a debug message that should appear
[timestamp] ($pid) a message with pid and timestamp
($pid) a message with pid but without timestamp
a message without pid or timestamp
EXPECT
}
1;
__END__

=head1 NAME

Class::Scaffold::Log_TEST - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Log_TEST->new;

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

