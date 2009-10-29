package Class::Scaffold::LazyString;

use strict;
use warnings;

use base 'Exporter';

our $VERSION = '0.10';

our @EXPORT = qw(lazy_string);

sub lazy_string { bless { code => shift }, 'Class::Scaffold::LazyString::Code' }

package Class::Scaffold::LazyString::Code;
use overload '""' => sub { $_[0]->{code}->() };

1;

