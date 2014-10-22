use 5.008;
use warnings;
use strict;

package Class::Scaffold::Exception::NoSuchFactoryHandler;
BEGIN {
  $Class::Scaffold::Exception::NoSuchFactoryHandler::VERSION = '1.100980';
}
# ABSTRACT: Exception raised on a factory look-up failure
use parent 'Class::Scaffold::Exception';
__PACKAGE__->mk_accessors(qw(handler_type spec));
use constant default_message =>
  'Factory lookup failure for handler type [%s], spec [%s]';
use constant PROPERTIES => (qw/handler_type spec/);

sub init {
    my $self = shift;

    # because we call SUPER::init(), which uses caller() to set
    # package, filename and line of the exception, *plus* we don't want
    # to report the abstract method that threw this exception itself,
    # rather we want to report its caller, i.e. the one that called the
    # abstract method. So we use +2.
    local $Error::Depth = $Error::Depth + 2;
    $self->SUPER::init(@_);
}
1;

__END__
=pod

=head1 NAME

Class::Scaffold::Exception::NoSuchFactoryHandler - Exception raised on a factory look-up failure

=head1 VERSION

version 1.100980

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Class-Scaffold>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see
L<http://search.cpan.org/dist/Class-Scaffold/>.

=head1 AUTHORS

  Marcel Gruenauer <marcel@cpan.org>
  Florian Helmberger <fh@univie.ac.at>
  Achim Adam <ac@univie.ac.at>
  Mark Hofstetter <mh@univie.ac.at>
  Heinz Ekker <ek@univie.ac.at>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

