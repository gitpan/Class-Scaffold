package Class::Scaffold::Accessor;

use warnings;
use strict;
use Error::Hierarchy::Util 'assert_read_only';
use Class::Scaffold::Factory::Type;


our $VERSION = '0.02';


use base qw(
    Class::Accessor::Complex
    Class::Accessor::Constructor
    Class::Accessor::FactoryTyped
);


sub mk_framework_object_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_accessors(
        'Class::Scaffold::Factory::Type', @args);
}


sub mk_framework_object_array_accessors {
    my ($self, @args) = @_;
    $self->mk_factory_typed_array_accessors(
        'Class::Scaffold::Factory::Type', @args);
}


sub mk_readonly_accessors {
    my ($self, @fields) = @_;
    my $class = ref $self || $self;

    for my $field (@fields) {
        no strict 'refs';

        *{"${class}::${field}"} = sub {
            local $DB::sub = local *__ANON__ = "${class}::${field}"
                if defined &DB::DB && !$Devel::DProf::VERSION;
            my $self = shift;
            assert_read_only(@_);
            $self->{$field};
        };

        *{"${class}::set_${field}"} =
        *{"${class}::${field}_set"} = sub {
            local $DB::sub = local *__ANON__ = "${class}::${field}_set"
                if defined &DB::DB && !$Devel::DProf::VERSION;
            $_[0]->{$field} = $_[1];
        };
    }

    $self;  # for chaining
}


1;


__END__

=head1 NAME

Class::Scaffold - large-scale OOP application support

=head1 SYNOPSIS

None yet (see below).

=head1 DESCRIPTION

None yet. This is an early release; fully functional, but undocumented. The
next release will have more documentation.

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classframework> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-class-framework@rt.cpan.org>, or through the web interface at
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

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

