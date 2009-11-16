package Class::Scaffold::Log;

use warnings;
use strict;
use Carp;
use IO::File;
use Time::HiRes 'gettimeofday';

our $VERSION = '0.14';

use base 'Class::Scaffold::Base';

__PACKAGE__
    ->mk_singleton(qw(instance))
    ->mk_scalar_accessors(qw(filename max_level))
    ->mk_boolean_accessors(qw(pid timestamp))
    ->mk_concat_accessors(qw(output));

use constant DEFAULTS => (
    max_level => 1,
);

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
          $_[5]+1900,$_[4]+1,@_[3,2,1,0]
    }->(localtime($hires[0]))
     . (@_ ? sprintf(".%06d",$hires[1]) : "");
}


sub logdate { substr(precdate(1), 0, 18) }


# like get_set_std, but also generate handle from filename unless defined
sub handle {
    my $self = shift;
    $self = Class::Scaffold::Log->instance unless ref $self;

    # in test mode, ignore what we're given - always log to STDOUT.

    if ($self->delegate->test_mode) {
        return $self->{handle} ||= IO::File->new(">&STDOUT") or
            die "can't open STDOUT: $!\n";
    }

    if (@_) {
        $self->{handle} = shift;
    } else {
        if ($self->filename) {
            $self->{handle} ||=
                IO::File->new(sprintf(">>%s", $self->filename)) or
                die sprintf("can't append to %s: %s\n", $self->filename, $!);
        } else {
            $self->{handle} ||= IO::File->new(">&STDERR") or
                die "can't open STDERR: $!\n";
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
    } elsif (defined($self->filename) && length ($self->filename)) {

        open $fh, '>>', $self->filename or
            die sprintf "can't open %s for appending: %s", $self->filename, $!;
        print $fh $msg or
            die sprintf "can't print to %s: %s", $self->filename, $!;
        close $fh or
            die sprintf "can't close %s: %s", $self->filename, $!;

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

Class::Scaffold::Log inherits from L<Class::Scaffold::Base>.

The superclass L<Class::Scaffold::Base> defines these methods and
functions:

    new(), FIRST_CONSTRUCTOR_ARGS(), MUNGE_CONSTRUCTOR_ARGS(),
    add_autoloaded_package(), log()

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

The superclass L<Data::Comparable> defines these methods and functions:

    comparable(), comparable_scalar(), dump_comparable(),
    prepare_comparable(), yaml_dump_comparable()

The superclass L<Class::Scaffold::Delegate::Mixin> defines these methods
and functions:

    delegate()

The superclass L<Class::Scaffold::Accessor> defines these methods and
functions:

    mk_framework_object_accessors(), mk_framework_object_array_accessors(),
    mk_readonly_accessors()

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    mk_abstract_accessors(), mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor()

The superclass L<Class::Accessor::Constructor> defines these methods and
functions:

    _make_constructor(), mk_constructor(), mk_constructor_with_dirty(),
    mk_singleton_constructor()

The superclass L<Class::Accessor::FactoryTyped> defines these methods and
functions:

    clear_factory_typed_accessors(), clear_factory_typed_array_accessors(),
    count_factory_typed_accessors(), count_factory_typed_array_accessors(),
    factory_typed_accessors(), factory_typed_accessors_clear(),
    factory_typed_accessors_count(), factory_typed_accessors_index(),
    factory_typed_accessors_pop(), factory_typed_accessors_push(),
    factory_typed_accessors_set(), factory_typed_accessors_shift(),
    factory_typed_accessors_splice(), factory_typed_accessors_unshift(),
    factory_typed_array_accessors(), factory_typed_array_accessors_clear(),
    factory_typed_array_accessors_count(),
    factory_typed_array_accessors_index(),
    factory_typed_array_accessors_pop(),
    factory_typed_array_accessors_push(),
    factory_typed_array_accessors_set(),
    factory_typed_array_accessors_shift(),
    factory_typed_array_accessors_splice(),
    factory_typed_array_accessors_unshift(),
    index_factory_typed_accessors(), index_factory_typed_array_accessors(),
    mk_factory_typed_accessors(), mk_factory_typed_array_accessors(),
    pop_factory_typed_accessors(), pop_factory_typed_array_accessors(),
    push_factory_typed_accessors(), push_factory_typed_array_accessors(),
    set_factory_typed_accessors(), set_factory_typed_array_accessors(),
    shift_factory_typed_accessors(), shift_factory_typed_array_accessors(),
    splice_factory_typed_accessors(),
    splice_factory_typed_array_accessors(),
    unshift_factory_typed_accessors(),
    unshift_factory_typed_array_accessors()

The superclass L<Class::Scaffold::Factory::Type> defines these methods and
functions:

    factory_log()

The superclass L<Class::Factory::Enhanced> defines these methods and
functions:

    add_factory_type(), make_object_for_type(), register_factory_type()

The superclass L<Class::Factory> defines these methods and functions:

    factory_error(), get_factory_class(), get_factory_type_for(),
    get_loaded_classes(), get_loaded_types(), get_my_factory(),
    get_my_factory_type(), get_registered_class(),
    get_registered_classes(), get_registered_types(),
    remove_factory_type(), unregister_factory_type()

The superclass L<Class::Accessor::Constructor::Base> defines these methods
and functions:

    STORE(), clear_dirty(), clear_hygienic(), clear_unhygienic(),
    contains_hygienic(), contains_unhygienic(), delete_hygienic(),
    delete_unhygienic(), dirty(), dirty_clear(), dirty_set(),
    elements_hygienic(), elements_unhygienic(), hygienic(),
    hygienic_clear(), hygienic_contains(), hygienic_delete(),
    hygienic_elements(), hygienic_insert(), hygienic_is_empty(),
    hygienic_size(), insert_hygienic(), insert_unhygienic(),
    is_empty_hygienic(), is_empty_unhygienic(), set_dirty(),
    size_hygienic(), size_unhygienic(), unhygienic(), unhygienic_clear(),
    unhygienic_contains(), unhygienic_delete(), unhygienic_elements(),
    unhygienic_insert(), unhygienic_is_empty(), unhygienic_size()

The superclass L<Tie::StdHash> defines these methods and functions:

    CLEAR(), DELETE(), EXISTS(), FETCH(), FIRSTKEY(), NEXTKEY(), SCALAR(),
    TIEHASH()

=head1 TAGS

If you talk about this module in blogs, on L<delicious.com> or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::Log>.

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

