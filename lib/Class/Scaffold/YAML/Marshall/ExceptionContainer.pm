use 5.008;
use warnings;
use strict;

package Class::Scaffold::YAML::Marshall::ExceptionContainer;
our $VERSION = '1.100810';
# ABSTRACT: Marshalling plugin that constructs an exception container
use YAML::Marshall 'exception/container';
use parent 'Class::Scaffold::YAML::Marshall';

sub yaml_load {
    my $self = shift;
    my $node = $self->SUPER::yaml_load(@_);

 # Expect a list of hashrefs; each hash element is an exception with a
 # 'ref' key giving the exception class, and the rest being treated as args
 # to give to the exception when it is being recorded. Example:
 #
 #  exception_container: !perl/Class::Scaffold::YAML::Active::ExceptionContainer
 #    - ref: Class::Scaffold::Exception::Policy::Blah
 #      property1: value1
 #      property2: value2
    my $container = $self->delegate->make_obj('exception_container');
    for my $exception (@$node) {

        # Copy because we delete (so as to not mess up YAML references)
        my %args  = %$exception;
        my $class = delete $args{ref};
        $container->record($class, %args);
    }
    $container;
}
1;


__END__
=pod

=head1 NAME

Class::Scaffold::YAML::Marshall::ExceptionContainer - Marshalling plugin that constructs an exception container

=head1 VERSION

version 1.100810

=head1 METHODS

=head2 yaml_load

FIXME

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

The development version lives at
L<http://github.com/hanekomu/Class-Scaffold/>.
Instead of sending patches, please fork this project using the standard git
and github infrastructure.

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

