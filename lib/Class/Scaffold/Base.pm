package Class::Scaffold::Base;

# base class for all classes of the class framework.
# Everything should subclass this.
use strict;
use warnings;
use Data::Miscellany 'set_push';
use Error::Hierarchy::Util 'load_class';
our $VERSION = '0.16';
use base qw/
  Data::Inherited
  Data::Comparable
  Error::Hierarchy::Mixin
  Class::Scaffold::Delegate::Mixin
  Class::Scaffold::Accessor
  Class::Scaffold::Factory::Type
  /;

# We subclass Class::Scaffold::Factory::Type so objects can introspect to see
# which object type they are.
__PACKAGE__->mk_constructor;

# so every_hash has something to fall back to:
sub FIRST_CONSTRUCTOR_ARGS { () }

# so everyone can call SUPER:: without worries, just pass through the args:
sub MUNGE_CONSTRUCTOR_ARGS {
    my $self = shift;
    @_;
}
sub init { 1 }

# Convenience method so subclasses don't need to say
#
#   use Class::Scaffold::Log;
#   my $log = Class::Scaffold::Log;
#   $log->info(...);
#
# or
#
#   Class::Scaffold::Log->debug(...);
#
# but can say
#
#   $self->log->info(...);
#
# Eliminating fixed package names is also a way of decoupling; later on we
# might choose to get the log from the delegate or anywhere else, in which
# case we can make the change in one location - here.
#
# Class::Scaffold::Log inherits from this class, so we don't use() it but
# require() it, to avoid 'redefined' warnings.
sub log {
    my $self = shift;
    require Class::Scaffold::Log;
    Class::Scaffold::Log->instance;
}

# Try to load currently not loaded packages of the Class-Scaffold and other
# registered distributions and call the wanted method.
#
# Throw an exception if the package in which we have to look for the wanted
# method is already loaded (= the method doesn't exist).
sub UNIVERSAL::DESTROY { }

sub UNIVERSAL::AUTOLOAD {
    my ($pkg, $method) = ($UNIVERSAL::AUTOLOAD =~ /(.*)::(.*)/);
    local $" = '|';
    our @autoload_packages;
    unless ($pkg =~ /^(@autoload_packages)/) {

        # we don't deal with crappy external libs and
        # their problems. get lost with your symbol.
        require Carp;
        local $Carp::CarpLevel = 1;
        Carp::confess sprintf "Undefined subroutine &%s called",
          $UNIVERSAL::AUTOLOAD;
    }
    (my $key = "$pkg.pm") =~ s!::!/!g;
    local $Error::Depth = $Error::Depth + 1;
    if (exists $INC{$key}) {

        # package has been loaded already, so the method wanted
        # doesn't seem to exist.
        require Carp;
        local $Carp::CarpLevel = 1;
        Carp::confess sprintf "Undefined subroutine &%s called",
          $UNIVERSAL::AUTOLOAD;
    } else {
        load_class $pkg, 1;
        no warnings;
        if (my $coderef = UNIVERSAL::can($pkg, $method)) {
            goto &$coderef;
        } else {
            require Carp;
            local $Carp::CarpLevel = 1;
            Carp::confess sprintf "Undefined subroutine &%s called",
              $UNIVERSAL::AUTOLOAD;
        }
    }
}

sub add_autoloaded_package {
    shift if $_[0] eq __PACKAGE__;
    my $prefix = shift;
    our @autoload_packages;
    set_push @autoload_packages, $prefix;
}
1;
__END__

=head1 NAME

Class::Scaffold::Base - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::Base->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<new>

    my $obj = Class::Scaffold::Base->new;
    my $obj = Class::Scaffold::Base->new(%args);

Creates and returns a new object. The constructor will accept as arguments a
list of pairs, from component name to initial value. For each pair, the named
component is initialized by calling the method of the same name with the given
value. If called with a single hash reference, it is dereferenced and its
key/value pairs are set as described before.

=item FIRST_CONSTRUCTOR_ARGS

This method is used by the constructor to order key-value pairs that are
passed to the newly created object's accessors - see
L<Class::Accessor::Constructor>. This class just defines it as an empty list;
subclasses should override it as necessary. The method exists in this class so
even if subclasses don't override it, there's something for the constructor
mechanism to work with.

=item C<MUNGE_CONSTRUCTOR_ARGS>

This method is used by the constructor to munge the constructor arguments -
see L<Class::Accessor::Constructor>. This class' method just returns the
arguments as is; subclasses should override it as necessary. The method exists
in this class so even if subclasses don't override it, there's something for
the constructor mechanism to work with.

=item C<add_autoloaded_package>

This class method takes a single prefix and adds it to the list - set, really
- of packages whose methods should be autoloaded. The L<Class::Scaffold>
framework will typically be used by an application whose classes are stored in
and underneath a package namespace. To avoid having to load all classes
explicitly, you can pass the namespace to this method. This class defines a
L<UNIVERSAL::AUTOLOAD> that respects the set of classes it should autoload
methods for.

=item C<init>

This method is called at the end of the constructor - see
L<Class::Accessor::Constructor>. This class' method does nothing; subclasses
should override it and wrap it with C<SUPER::> as necessary. The method exists
in this class so even if subclasses don't override it, there's something for
the constructor mechanism to work with.

=item C<log>

This method acts as a shortcut to L<Class::Scaffold::Log>. Instead of writing

    use Class::Scaffold::Log;
    Class::Scaffold::Log->instance->debug('foo');

you can simply write

    $self->log->debug('foo');

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

