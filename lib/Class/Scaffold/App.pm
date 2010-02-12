package Class::Scaffold::App;
use strict;
use warnings;
use Class::Scaffold::Environment;
use Property::Lookup;
use Error ':try';
our $VERSION = '0.16';
use base 'Class::Scaffold::Storable';
__PACKAGE__->mk_boolean_accessors(qw(initialized));
use IO::Handle;
STDOUT->autoflush;
STDERR->autoflush;
use constant CONTEXT => 'generic/generic';

sub app_init {
    my $self = shift;

    # Normally, app_init() is called only once (namely, when the program
    # subclasses this class and does 'main->new->run_app'). However, if used
    # from within mod_perl (for example), the app is a cached object and
    # run_app() is called repeatedly from the outside. In this case,
    # app_init() should be called only once. We do this with initialized().
    return if $self->initialized;
    $self->initialized(1);
    my $configurator = Property::Lookup->instance;

    # If a subclass added a getopt configurator, we can ask it for the
    # location of the conf file, in case the user specified '--conf' on the
    # command line. If a filename is given, we'll use that conf file. If the
    # special string "local" is given, we try to find the conf file.
    # Otherwise use the one given in an environment variable.
    my $conf_file_spec = $configurator->conf || $ENV{CF_CONF} || '';
    for my $conf_file (split ';', $conf_file_spec) {
        if ($conf_file eq 'local') {

            # only load if needed
            require Class::Scaffold::Introspect;
            $conf_file = Class::Scaffold::Introspect::find_conf_file();
        }
        $configurator->add_layer(file => $conf_file);
    }
    $self->log->max_level(1 + ($configurator->verbose || 0));

    # Now that we have both a getopt and a file configurator, the log file
    # name can come from either the command line (preferred) or the conf file.
    $self->log->filename($configurator->logfile)
      if defined $configurator->logfile;

    # This class subclasses Class::Scaffold::Base, which returns
    # Class::Scaffold::Environment->getenv as the default delegate. So set the
    # proper environment here and then pass the newly formed delegate the
    # configurator. The environment will make use of it in its methods.
    Class::Scaffold::Environment->setenv($configurator->environment);
    $self->delegate->setup;
    $self->delegate->configurator($configurator);
    $self->delegate->context(
        Class::Scaffold::Context->new->parse_context($self->CONTEXT));
    if ($configurator->dryrun) {
        $self->log->clear_timestamp;
        $self->delegate->set_rollback_mode;
    }
}
sub app_finish { 1 }
sub app_code   { }

sub run_app {
    my $self = shift;
    $self->app_init;
    $Error::Debug++;    # to get a stacktrace
    try {
        $self->app_code;
    }
    catch Error with {
        my $E = shift;
        $self->log->info($E->{statement})
          if ref $E eq 'Error::Hierarchy::Internal::DBI::DBH';
        $self->log->info('Application exception: %s', $E);
        $self->log->info('%s',                        $E->stacktrace);

        # $self->delegate->set_rollback_mode;
    };
    $self->app_finish;
}
1;
__END__

=head1 NAME

Class::Scaffold::App - large-scale OOP application support

=head1 SYNOPSIS

    use base 'Class::Scaffold::App';

    sub app_code {
        my $self = shift;
        $self->SUPER::app_code(@_);
        # ... application-specific tasks ...
    }

    main->new->run_app;

=head1 DESCRIPTION

This is the base class for applications built with the L<Class::Scaffold>
framework, be they command-line applications or server-based applications.
Applications will subclass this class, implement their specific tasks and call
C<run_app()>.

=head1 METHODS

=over 4

=item run_app

This is the main method that application subclasses should invoke. It calls
the other methods described here. If there is an exception, it catches and
logs it.

=item app_code

Called by C<run_app()> right at the beginning. Override this method in your
application-specific subclass to do any initialization your application needs.

=item app_finish

Called by C<run_app()> within a C<try>/C<catch>-block. Override this method to
do the actual application-specific work.

=item app_init

Called by C<run_app()> right before the end. Override this method to do any
cleanup your application needs.

=item C<clear_initialized>

    $obj->clear_initialized;

Clears the boolean value by setting it to 0.

=item C<initialized>

    $obj->initialized($value);
    my $value = $obj->initialized;

If called without an argument, returns the boolean value (0 or 1). If called
with an argument, it normalizes it to the boolean value. That is, the values
0, undef and the empty string become 0; everything else becomes 1.

=item C<initialized_clear>

    $obj->initialized_clear;

Clears the boolean value by setting it to 0.

=item C<initialized_set>

    $obj->initialized_set;

Sets the boolean value to 1.

=item C<set_initialized>

    $obj->set_initialized;

Sets the boolean value to 1.

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

