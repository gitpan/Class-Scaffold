package Class::Scaffold::Log;
use warnings;
use strict;
use Carp;
use IO::File;
use Time::HiRes 'gettimeofday';
our $VERSION = '0.16';
use base 'Class::Scaffold::Base';
__PACKAGE__->mk_singleton(qw(instance))
  ->mk_scalar_accessors(qw(filename max_level))
  ->mk_boolean_accessors(qw(pid timestamp))->mk_concat_accessors(qw(output));
use constant DEFAULTS => (max_level => 1,);

sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    $self->clear_pid;
    $self->set_timestamp;
}

sub precdate {
    my @hires = gettimeofday;
    return sub {
        sprintf "%04d%02d%02d.%02d%02d%02d",
          $_[5] + 1900, $_[4] + 1, @_[ 3, 2, 1, 0 ];
      }
      ->(localtime($hires[0])) . (@_ ? sprintf(".%06d", $hires[1]) : "");
}
sub logdate { substr(precdate(1), 0, 18) }

# like get_set_std, but also generate handle from filename unless defined
sub handle {
    my $self = shift;
    $self = Class::Scaffold::Log->instance unless ref $self;

    # in test mode, ignore what we're given - always log to STDOUT.
    if ($self->delegate->test_mode) {
        return $self->{handle} ||= IO::File->new(">&STDOUT")
          or die "can't open STDOUT: $!\n";
    }
    if (@_) {
        $self->{handle} = shift;
    } else {
        if ($self->filename) {
            $self->{handle} ||= IO::File->new(sprintf(">>%s", $self->filename))
              or die sprintf("can't append to %s: %s\n", $self->filename, $!);
        } else {
            $self->{handle} ||= IO::File->new(">&STDERR")
              or die "can't open STDERR: $!\n";
        }
        $self->{handle}->autoflush(1);
        return $self->{handle};
    }
}

# called like printf
sub __log {
    my ($self, $level, $format, @args) = @_;
    $self = Class::Scaffold::Log->instance unless ref $self;

    # Check for max_level before stringifying $format so we don't
    # unnecessarily trigger a potentially lazy string.
    return if $level > $self->max_level;

    # in case someone passes us an object that needs to be stringified so we
    # can compare it with 'ne' further down (e.g., an exception object):
    $format = "$format";
    return unless defined $format and $format ne '';

    # make sure there's exactly one newline at the end
    1 while chomp $format;
    $format .= "\n";
    $format = sprintf "(%08d) %s", $$, $format if $self->pid;
    $format = sprintf "%s %s", $self->logdate, $format if $self->timestamp;
    my $msg = sprintf $format => @args;

    # Open and close the file for each line that is logged. That doesn't cost
    # much and makes it possible to move the file away for backup, rotation
    # or whatver.
    my $fh;
    if ($self->delegate->test_mode) {
        print $msg;
    } elsif (defined($self->filename) && length($self->filename)) {
        open $fh, '>>', $self->filename
          or die sprintf "can't open %s for appending: %s", $self->filename, $!;
        print $fh $msg
          or die sprintf "can't print to %s: %s", $self->filename, $!;
        close $fh
          or die sprintf "can't close %s: %s", $self->filename, $!;
    } else {
        warn $msg;
    }
    $self->output($msg);
}

sub info {
    my $self = shift;
    $self->__log(1, @_);
}

sub debug {
    my $self = shift;
    $self->__log(2, @_);
}

sub deep_debug {
    my $self = shift;
    $self->__log(3, @_);
}

# log a final message, close the log and croak.
sub fatal {
    my ($self, $format, @args) = @_;
    my $message = sprintf($format, @args);
    $self->info($message);
    croak($message);
}
1;
__END__

=head1 NAME

Class::Scaffold::Log - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Log->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<instance>

    my $obj = Class::Scaffold::Log->instance;
    my $obj = Class::Scaffold::Log->instance(%args);

Creates and returns a new object. The object will be a singleton, so repeated
calls to the constructor will always return the same object. The constructor
will accept as arguments a list of pairs, from component name to initial
value. For each pair, the named component is initialized by calling the
method of the same name with the given value. If called with a single hash
reference, it is dereferenced and its key/value pairs are set as described
before.

=item C<clear_filename>

    $obj->clear_filename;

Clears the value.

=item C<clear_max_level>

    $obj->clear_max_level;

Clears the value.

=item C<clear_output>

    $obj->clear_output;

Clears the value.

=item C<clear_pid>

    $obj->clear_pid;

Clears the boolean value by setting it to 0.

=item C<clear_timestamp>

    $obj->clear_timestamp;

Clears the boolean value by setting it to 0.

=item C<filename>

    my $value = $obj->filename;
    $obj->filename($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<filename_clear>

    $obj->filename_clear;

Clears the value.

=item C<max_level>

    my $value = $obj->max_level;
    $obj->max_level($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<max_level_clear>

    $obj->max_level_clear;

Clears the value.

=item C<output>

    my $value = $obj->output;
    $obj->output($value);

A getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it appends to the current value.

=item C<output_clear>

    $obj->output_clear;

Clears the value.

=item C<pid>

    $obj->pid($value);
    my $value = $obj->pid;

If called without an argument, returns the boolean value (0 or 1). If called
with an argument, it normalizes it to the boolean value. That is, the values
0, undef and the empty string become 0; everything else becomes 1.

=item C<pid_clear>

    $obj->pid_clear;

Clears the boolean value by setting it to 0.

=item C<pid_set>

    $obj->pid_set;

Sets the boolean value to 1.

=item C<set_pid>

    $obj->set_pid;

Sets the boolean value to 1.

=item C<set_timestamp>

    $obj->set_timestamp;

Sets the boolean value to 1.

=item C<timestamp>

    $obj->timestamp($value);
    my $value = $obj->timestamp;

If called without an argument, returns the boolean value (0 or 1). If called
with an argument, it normalizes it to the boolean value. That is, the values
0, undef and the empty string become 0; everything else becomes 1.

=item C<timestamp_clear>

    $obj->timestamp_clear;

Clears the boolean value by setting it to 0.

=item C<timestamp_set>

    $obj->timestamp_set;

Sets the boolean value to 1.

=back

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

Copyright 2004-2009 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

