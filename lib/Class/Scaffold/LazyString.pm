package Class::Scaffold::LazyString;

# Copyright (c) 2003-2007 University of Vienna.
#
# All rights reserved.  This software is protected by copyright.  Use,
# modification and distribution is limited according to terms of agreements.

use strict;
use warnings;

use base 'Exporter';

our $VERSION = '0.09';

our @EXPORT = qw(lazy_string);

sub lazy_string { bless { code => shift }, 'Class::Scaffold::LazyString::Code' }

package Class::Scaffold::LazyString::Code;
use overload '""' => sub { $_[0]->{code}->() };

1;

