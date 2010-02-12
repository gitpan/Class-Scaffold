package Class::Scaffold::ConstantImporter;
use warnings;
use strict;
use Devel::Caller qw(caller_args);
our $VERSION = '0.16';

sub import {
    my $pkg     = shift;
    my $callpkg = caller(0);
    no strict 'refs';

    # For each requested symbol, install a proxy sub into the caller's
    # namespace. When invoked, it will get the caller's $self and retrieve the
    # symbol's value from the caller's delegate. It will then replace itself
    # with a sub that just returns that value.
    #
    # The value is cached so that if the same constant is imported in
    # different packages we still only make one call to the delegate.
    #
    # That way the symbol can be used without the $self->delegate->... part.
    # You have to make sure that when the symbol is first used, you do it from
    # within a method whose $self has access to the delegate.
    #
    # The delegate is cached so that later this mechanism can be used even
    # from within subs that don't have access to the delegate.
    our %cache;
    for my $symbol (@_) {
        *{"${callpkg}::${symbol}"} = sub {
            unless (exists $cache{$symbol}) {
                my $caller_self = (caller_args(1))[0];
                our $delegate ||= $caller_self->delegate;
                $cache{$symbol} = $delegate->$symbol;
            }
            no warnings 'redefine';
            *{"${callpkg}::${symbol}"} = sub { $cache{$symbol} };
            $cache{$symbol};
        };
    }
}
1;
