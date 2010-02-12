package Class::Scaffold::App::Test::Class;
use warnings;
use strict;
our $VERSION = '0.16';
use base qw(Class::Scaffold::App::CommandLine Test::Class::GetoptControl);
use constant GETOPT => qw(
  runs|r=s
);
use constant GETOPT_DEFAULTS => (runs => 2,);

sub app_code {
    my $self = shift;
    $self->SUPER::app_code(@_);
    { no warnings 'once'; $::app = $self; }
    $self->runtests;
}
1;
