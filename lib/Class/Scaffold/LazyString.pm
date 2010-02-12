package Class::Scaffold::LazyString;
use strict;
use warnings;
use Exporter qw(import);
our $VERSION = '0.16';
our @EXPORT  = qw(lazy_string);
sub lazy_string { bless { code => shift }, 'Class::Scaffold::LazyString::Code' }

package Class::Scaffold::LazyString::Code;
use overload '""' => sub { $_[0]->{code}->() };
1;
