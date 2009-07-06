package Class::Scaffold::App::Test::YAMLDriven;

use strict;
use warnings;
use File::Find;
use Class::Scaffold::App;
use Error::Hierarchy::Util 'assert_defined';
use String::FlexMatch;           # in case some tests need it
use Test::More;
use YAML::Active qw/Load Load_inactive/;
use Test::Builder;


our $VERSION = '0.08';


use base 'Class::Scaffold::App::Test';


use Error;
$Error::Debug = 1;   # to trigger a stacktrace on an exception


__PACKAGE__
    ->mk_abstract_accessors(qw(run_test plan_test))
    ->mk_hash_accessors(qw(test_def))
    ->mk_scalar_accessors(qw(
        testdir testname expect run_num runs current_test_def
    ));


use constant SHARED => '00shared.yaml';


# 'runs' is the number of stage runs per test file ensure idempotency

use constant DEFAULTS => (
    runs    => 1,
    testdir => '.',
);


sub app_code {
    my $self = shift;
    $self->SUPER::app_code(@_);

    $self->read_test_defs;
    $self->make_plan;

    for my $testname (sort $self->test_def_keys) {
        next if $testname eq SHARED;
        $self->execute_test_def($testname);
    }
}


sub read_test_defs {
    my $self = shift;

    # It's possible to pass args to the test program. If there are any
    # such args, then in order for a test file to be used its name has to
    # contain one of the args as a substring. For example, to only run
    # the policy tests whose name contains 'unnamed' or '99', you'd use:
    #
    #   perl t/10Policy.t unnamed 99

    my $name_filter = join '|' => map { "\Q$_\E" } @ARGV;
    my $testdir = $self->testdir;

    # First collect the files to process into a hash, then process that
    # hash sorted by name. This separation is necessary because some test
    # files depend on others, but find() doesn't ensure that the files are
    # returned in sorted order.

    my %file;
    find(sub {
        return unless -f && /\.yaml$/;

        (my $name = $File::Find::name) =~ s!^$testdir/!!;
        return if $name ne SHARED && $name_filter && $name !~ /$name_filter/o;
        $file{$name} = $File::Find::name;
    }, $testdir);

    for my $name (sort keys %file) {
        print "# Loading test file $name\n";

        (my $tests_yaml = do { local (@ARGV, $/) = $file{$name}; <> })
            =~ s/%%PID%%/sprintf("%06d", $$)/ge;
        $tests_yaml =~ s/%%CNT%%/sprintf("%03d", ++(our $cnt))/ge;

        # Check whether the test wants to be skipped. Quick check with a regex
        # because YAML::Load is expensive. Only then decide whether to use
        # Load() or Load_inactive(). To use Load() on a test that wants to be
        # skipped would be a bad idea as it might be work in progress; it will
        # be skipped for a reason.

        if ($tests_yaml =~ /^skip:\s*1/m) {
            print "#    Test wants to be skipped, no activation\n";
            $self->test_def($name => Load_inactive($tests_yaml));
        } else {
            # support for value classes
            local $Class::Value::SkipChecks = 1;
            $self->test_def($name => Load($tests_yaml));
        }
    }
}


sub should_skip_testname {
    my ($self, $testname) = @_;
    $self->test_def($testname)->{skip};
}


sub make_plan {
    my $self = shift;
    my $plan = 0;

    # Each YAML file produces a number of tests, except for the shared
    # file, which is expected to only contain YAML::Active objects for
    # setup.

    for my $name (sort $self->test_def_keys) {
        next if $name eq SHARED;
        for my $run (1..$self->runs) {

            # If a test def specifies that it wants to be skipped, just plan
            # one test - a pass.

            if ($self->should_skip_testname($name)) {
                $plan++;
            } else {
                $plan += $self->plan_test($self->test_def($name), $run);
            }
        }
    }

    plan tests => $plan;
}


sub execute_test_def {
    my ($self, $testname) = @_;

    assert_defined $testname, 'called without testname';

    # In case subclasses need to do special things, like multiple tickets in a
    # test definition:

    $self->current_test_def($self->test_def($testname));

    $self->expect($self->current_test_def->{expect} || {});

    for my $run (1..$self->runs) {
        $self->run_num($run);
        $self->testname(
            sprintf('%s run %d of %d', $testname, $run, $self->runs));

        # If the current test def specifies that it wants to be skipped, just
        # pass.

        if ($self->should_skip_testname($testname)) {
            $self->todo_skip_test;
        } else {
            $self->run_test;
        }
    }
}


sub named_test {
    my ($self, $suffix) = @_;
    sprintf '%s: %s', $self->testname, $suffix;
}


sub todo_skip_test {
    my $self = shift;
    Test::Builder->new->todo_skip($self->named_test('wants to be skipped'), 1);
}


1;


__END__



=head1 NAME

Class::Scaffold::App::Test::YAMLDriven - large-scale OOP application support

=head1 SYNOPSIS

    Class::Scaffold::App::Test::YAMLDriven->new;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item C<clear_current_test_def>

    $obj->clear_current_test_def;

Clears the value.

=item C<clear_expect>

    $obj->clear_expect;

Clears the value.

=item C<clear_run_num>

    $obj->clear_run_num;

Clears the value.

=item C<clear_runs>

    $obj->clear_runs;

Clears the value.

=item C<clear_test_def>

    $obj->clear_test_def;

Deletes all keys and values from the hash.

=item C<clear_testdir>

    $obj->clear_testdir;

Clears the value.

=item C<clear_testname>

    $obj->clear_testname;

Clears the value.

=item C<current_test_def>

    my $value = $obj->current_test_def;
    $obj->current_test_def($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<current_test_def_clear>

    $obj->current_test_def_clear;

Clears the value.

=item C<delete_test_def>

    $obj->delete_test_def(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<exists_test_def>

    if ($obj->exists_test_def($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<expect>

    my $value = $obj->expect;
    $obj->expect($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<expect_clear>

    $obj->expect_clear;

Clears the value.

=item C<keys_test_def>

    my @keys = $obj->keys_test_def;

Returns a list of all hash keys in no particular order.

=item C<run_num>

    my $value = $obj->run_num;
    $obj->run_num($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<run_num_clear>

    $obj->run_num_clear;

Clears the value.

=item C<runs>

    my $value = $obj->runs;
    $obj->runs($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<runs_clear>

    $obj->runs_clear;

Clears the value.

=item C<test_def>

    my %hash     = $obj->test_def;
    my $hash_ref = $obj->test_def;
    my $value    = $obj->test_def($key);
    my @values   = $obj->test_def([ qw(foo bar) ]);
    $obj->test_def(%other_hash);
    $obj->test_def(foo => 23, bar => 42);

Get or set the hash values. If called without arguments, it returns the hash
in list context, or a reference to the hash in scalar context. If called
with a list of key/value pairs, it sets each key to its corresponding value,
then returns the hash as described before.

If called with exactly one key, it returns the corresponding value.

If called with exactly one array reference, it returns an array whose elements
are the values corresponding to the keys in the argument array, in the same
order. The resulting list is returned as an array in list context, or a
reference to the array in scalar context.

If called with exactly one hash reference, it updates the hash with the given
key/value pairs, then returns the hash in list context, or a reference to the
hash in scalar context.

=item C<test_def_clear>

    $obj->test_def_clear;

Deletes all keys and values from the hash.

=item C<test_def_delete>

    $obj->test_def_delete(@keys);

Takes a list of keys and deletes those keys from the hash.

=item C<test_def_exists>

    if ($obj->test_def_exists($key)) { ... }

Takes a key and returns a true value if the key exists in the hash, and a
false value otherwise.

=item C<test_def_keys>

    my @keys = $obj->test_def_keys;

Returns a list of all hash keys in no particular order.

=item C<test_def_values>

    my @values = $obj->test_def_values;

Returns a list of all hash values in no particular order.

=item C<testdir>

    my $value = $obj->testdir;
    $obj->testdir($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<testdir_clear>

    $obj->testdir_clear;

Clears the value.

=item C<testname>

    my $value = $obj->testname;
    $obj->testname($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item C<testname_clear>

    $obj->testname_clear;

Clears the value.

=item C<values_test_def>

    my @values = $obj->values_test_def;

Returns a list of all hash values in no particular order.

=back

Class::Scaffold::App::Test::YAMLDriven inherits from
L<Class::Scaffold::App::Test>.

The superclass L<Class::Scaffold::App::CommandLine> defines these methods
and functions:

    app_finish(), app_init(), clear_opt(), delete_opt(), exists_opt(),
    keys_opt(), opt(), opt_clear(), opt_delete(), opt_exists(), opt_keys(),
    opt_values(), usage(), values_opt()

The superclass L<Class::Scaffold::App> defines these methods and functions:

    clear_initialized(), initialized(), initialized_clear(),
    initialized_set(), run_app(), set_initialized()

The superclass L<Class::Scaffold::Storable> defines these methods and
functions:

    MUNGE_CONSTRUCTOR_ARGS(), clear_storage_info(), clear_storage_type(),
    delete_storage_info(), exists_storage_info(), id(),
    keys_storage_info(), storage(), storage_info(), storage_info_clear(),
    storage_info_delete(), storage_info_exists(), storage_info_keys(),
    storage_info_values(), storage_type(), storage_type_clear(),
    values_storage_info()

The superclass L<Class::Scaffold::Base> defines these methods and
functions:

    new(), add_autoloaded_package(), init(), log()

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

The superclass L<Data::Comparable> defines these methods and functions:

    comparable(), comparable_scalar(), dump_comparable(),
    prepare_comparable(), yaml_dump_comparable()

The superclass L<Class::Scaffold::Delegate::Mixin> defines these methods
and functions:

    delegate()

The superclass L<Class::Scaffold::Accessor> defines these methods and
functions:

    mk_framework_object_accessors(), mk_framework_object_array_accessors(),
    mk_readonly_accessors()

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    mk_abstract_accessors(), mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor()

The superclass L<Class::Accessor::Constructor> defines these methods and
functions:

    _make_constructor(), mk_constructor(), mk_constructor_with_dirty(),
    mk_singleton_constructor()

The superclass L<Class::Accessor::FactoryTyped> defines these methods and
functions:

    clear_factory_typed_accessors(), clear_factory_typed_array_accessors(),
    count_factory_typed_accessors(), count_factory_typed_array_accessors(),
    factory_typed_accessors(), factory_typed_accessors_clear(),
    factory_typed_accessors_count(), factory_typed_accessors_index(),
    factory_typed_accessors_pop(), factory_typed_accessors_push(),
    factory_typed_accessors_set(), factory_typed_accessors_shift(),
    factory_typed_accessors_splice(), factory_typed_accessors_unshift(),
    factory_typed_array_accessors(), factory_typed_array_accessors_clear(),
    factory_typed_array_accessors_count(),
    factory_typed_array_accessors_index(),
    factory_typed_array_accessors_pop(),
    factory_typed_array_accessors_push(),
    factory_typed_array_accessors_set(),
    factory_typed_array_accessors_shift(),
    factory_typed_array_accessors_splice(),
    factory_typed_array_accessors_unshift(),
    index_factory_typed_accessors(), index_factory_typed_array_accessors(),
    mk_factory_typed_accessors(), mk_factory_typed_array_accessors(),
    pop_factory_typed_accessors(), pop_factory_typed_array_accessors(),
    push_factory_typed_accessors(), push_factory_typed_array_accessors(),
    set_factory_typed_accessors(), set_factory_typed_array_accessors(),
    shift_factory_typed_accessors(), shift_factory_typed_array_accessors(),
    splice_factory_typed_accessors(),
    splice_factory_typed_array_accessors(),
    unshift_factory_typed_accessors(),
    unshift_factory_typed_array_accessors()

The superclass L<Class::Scaffold::Factory::Type> defines these methods and
functions:

    factory_log()

The superclass L<Class::Factory::Enhanced> defines these methods and
functions:

    add_factory_type(), make_object_for_type(), register_factory_type()

The superclass L<Class::Factory> defines these methods and functions:

    factory_error(), get_factory_class(), get_factory_type_for(),
    get_loaded_classes(), get_loaded_types(), get_my_factory(),
    get_my_factory_type(), get_registered_class(),
    get_registered_classes(), get_registered_types(),
    remove_factory_type(), unregister_factory_type()

The superclass L<Class::Accessor::Constructor::Base> defines these methods
and functions:

    STORE(), clear_dirty(), clear_hygienic(), clear_unhygienic(),
    contains_hygienic(), contains_unhygienic(), delete_hygienic(),
    delete_unhygienic(), dirty(), dirty_clear(), dirty_set(),
    elements_hygienic(), elements_unhygienic(), hygienic(),
    hygienic_clear(), hygienic_contains(), hygienic_delete(),
    hygienic_elements(), hygienic_insert(), hygienic_is_empty(),
    hygienic_size(), insert_hygienic(), insert_unhygienic(),
    is_empty_hygienic(), is_empty_unhygienic(), set_dirty(),
    size_hygienic(), size_unhygienic(), unhygienic(), unhygienic_clear(),
    unhygienic_contains(), unhygienic_delete(), unhygienic_elements(),
    unhygienic_insert(), unhygienic_is_empty(), unhygienic_size()

The superclass L<Tie::StdHash> defines these methods and functions:

    CLEAR(), DELETE(), EXISTS(), FETCH(), FIRSTKEY(), NEXTKEY(), SCALAR(),
    TIEHASH()

=head1 TAGS

If you talk about this module in blogs, on L<delicious.com> or anywhere else,
please use the C<classscaffold> tag.

=head1 VERSION 
                   
This document describes version 0.05 of L<Class::Scaffold::App::Test::YAMLDriven>.

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

