package Class::Scaffold::HierarchicalDirty;

use strict;
use warnings;

# $Id: HierarchicalDirty.pm 13653 2007-10-22 09:11:20Z gr $
#
# Mixin that multiplexes the dirty flag among its subobjects using
# Class::Accessor::FactoryTyped's introspection support


our $VERSION = '0.05';


sub dirty {
    my $self = shift;

    for my $attr (Class::Scaffold::Accessor->factory_typed_accessors) {
        return 1 if $self->$attr->dirty;
    }

    for my $attr (Class::Scaffold::Accessor->factory_typed_array_accessors) {
        for my $element ($self->$attr) {
            return 1 if $element->dirty;
        }
    }

    return 0;
}


sub set_dirty {
    my $self = shift;

    $self->$_->set_dirty for
        Class::Scaffold::Accessor->factory_typed_accessors;

    for my $attr (Class::Scaffold::Accessor->factory_typed_array_accessors) {
        for my $element ($self->$attr) {
            $element->set_dirty;
        }
    }
}


sub clear_dirty {
    my $self = shift;

    $self->$_->clear_dirty for
        Class::Scaffold::Accessor->factory_typed_accessors;

    for my $attr (Class::Scaffold::Accessor->factory_typed_array_accessors) {
        for my $element ($self->$attr) {
            $element->clear_dirty;
        }
    }
}


1;


__END__



=head1 NAME

Class::Scaffold::HierarchicalDirty - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::HierarchicalDirty->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4



=back

Class::Scaffold::HierarchicalDirty inherits from .

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::HierarchicalDirty>.

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

Copyright 2004-2008 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

