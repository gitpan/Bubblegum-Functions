# ABSTRACT: Experimental Function Library for Bubblegum
package Bubblegum::Functions;

use 5.10.0;

use strict;
use utf8::all;
use warnings;

use Bubblegum;
use Bubblegum::Exception;
use Try::Tiny;

use Class::Load ();
use Cwd ();
use Data::Dumper ();
use DateTime::Tiny ();
use File::Find::Rule ();
use File::HomeDir ();
use File::Spec ();
use File::Which ();
use Path::Tiny ();
use Time::Format ();
use Time::ParseDate ();
use Type::Params ();
use Types::Standard ();

use Hash::Merge::Simple 'merge';

use base 'Exporter::Tiny';

our $VERSION = '0.02'; # VERSION


our @EXPORT_OK = qw(
    cwd
    date
    date_epoch
    date_format
    dump
    file
    find
    here
    home
    load
    merge
    path
    quote
    raise
    script
    unquote
    user
    user_info
    which
    will
);


sub cwd {
    return Path::Tiny->cwd;
}


sub date {
    my $input = shift || 'now';
    my $epoch = date_epoch($input, @_);
    my $date  = date_format($epoch) or return;
    DateTime::Tiny->from_string($date);
}


sub date_epoch {
    my $input = shift || 'now';
    my $epoch = [Time::ParseDate::parsedate $input, @_];
    return $epoch->[0] or undef;
}


sub date_format {
    my $epoch  = shift or return;
    my $format = shift || 'yyyy-mm-ddThh:mm:ss';
    # my $format = shift || 'yyyy-mm{on}-dd hh:mm{in}:ss tz'; # not atm
    return Time::Format::time_format $format, $epoch;
}


sub dump {
    return Data::Dumper->new([shift])
        ->Indent(1)->Sortkeys(1)->Terse(1)->Dump
}


sub file {
    goto &path;
}


sub find {
    my $spec = !$#_ ? '*.*' : pop;
    my $path = path(@_);
    return [ map { path($_) }
        File::Find::Rule->file()->name($spec)->in($path) ];
}


sub here {
    return path(
        File::Spec->rel2abs(
            join '', (File::Spec->splitpath((caller 1)[1]))[0,1]
        )
    );
}


sub home {
    my $user = $ENV{USER} // user();
    my $func = $user ? 'users_home' : 'my_home';
    return eval { path(File::HomeDir->can($func)->($user)) };
}


sub load {
    return Class::Load::load_class(@_);
}



sub path {
    return Path::Tiny::path(@_);
}


sub quote {
    my $string = shift;
    return unless defined $string;
    $string =~ s/(["\\])/\\$1/g;
    return qq{"$string"};
}


sub raise {
    my $class = 'Bubblegum::Exception';
    @_ = ($class, message => shift // $@, data => shift);
    goto $class->can('throw');
}


sub script {
    return file($0);
}


sub unquote {
    my $string = shift;
    return unless defined $string;
    return $string unless $string =~ s/^"(.*)"$/$1/g;
    $string =~ s/\\\\/\\/g;
    $string =~ s/\\"/"/g;
    return $string;
}


sub user {
    return user_info()->[0];
}


sub user_info {
    return [eval '(getpwuid $>)'];
}


sub which {
    return path(File::Which::which(@_));
}


sub will {
    return eval
        sprintf 'sub {%s}', join ';',
            map { /^\s*\$\w+$/ ? "my$_=shift" : "$_" }
            map { /^\s*\@\w+$/ ? "my$_=\@_"   : "$_" }
            map { /^\s*\%\w+$/ ? "my$_=\@_"   : "$_" }
        split /;/, join ';', @_;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bubblegum::Functions - Experimental Function Library for Bubblegum

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    package Server;

    use Bubblegum::Class;
    use Bubblegum::Constraints -minimal;

    has _hashref, 'config';

    package main;

    use Bubblegum;
    use Bubblegum::Functions 'file';

    my $config = file('/tmp/config')->slurp->yaml->decode;
    my $server = Server->new(config => $config);

=head1 DESCRIPTION

Bubblegum::Functions is the standard function library for L<Bubblegum> with a
focus on minimalism and data integrity. B<Note: This is an early release
available for testing and feedback and as such is subject to change.>

By default, no functions are exported when using this package, all functionality
desired will need to be explicitly requested. The following are a list of
functions available:

=head1 FUNCTIONS

=head2 cwd

The cwd function returns a L<Path::Tiny> instance for operating on the current
working directory.

    my $dir = cwd;
    my @more = $dir->children;

=head2 date

The date function returns a L<DateTime::Tiny> instance from an epoch or common
date phrase, e.g. yesterday. The first argument should be a date string parsable
by L<Time::ParseDate>, it defaults to C<now>.

    my $date = date 'this friday';

=head2 date_epoch

The date_epoch function returns an epoch string from a common date phrase, e.g.
yesterday. The first argument should be a date string parsable by
L<Time::ParseDate>, it defaults to C<now>.

    my $date = date_epoch 'next friday';

=head2 date_format

The date_format function returns a formatted date string from an epoch string
and a L<Time::Format> template. The first argument should be an epoch date
string; the second argument should be a date format string recognized by
L<Time::Format>, it defaults to C<yyyy-mm-ddThh:mm:ss>.

    my $date = date_format time;

=head2 dump

The dump function returns a representation of a Perl data structure.

    my $class = bless {}, 'main';
    say dump $class;

=head2 file

The file function returns a L<Path::Tiny> instance for operating on files.

    my $file  = file './customers.json';
    my $lines = $file->slurp;

=head2 find

The find function traverses a directory and returns an arrayref of L<Path::Tiny>
objects matching the specified criteria.

    my $texts = find './documents', '*.txt';

=head2 here

The here function returns a L<Path::Tiny> instance for operating on the directory
of the file the function is called from.

    my $dir = here;
    my @more = $dir->children;

=head2 home

The home function returns a L<Path::Tiny> instance for operating on the current
user's home directory.

    my $dir = home;
    my @more = $dir->children;

=head2 load

The load function uses L<Class::Load> to require modules at runtime.

    my $class = load 'Test::Automata';

=head2 merge

The merge function uses L<Hash::Merge::Simple> to merge multi hash references
into a single hash reference. Please view the L<Hash::Merge::Simple>
documentation for example usages.

    my $hash = merge $hash_a, $hash_b, $hash_c;

=head2 path

The path function returns a L<Path::Tiny> instance for operating on the
directory specified.

    my $dir = path '/';
    my @more = $dir->children;

=head2 quote

The quote function escapes double-quoted strings within the string.

    my $string = quote '"Ins\'t it a wonderful day"';

=head2 raise

The raise function uses L<Bubblegum::Exception> to throw a catchable exception.
The raise function can also store arbitrary data that can be accessed by the
trap.

    raise 'business object not saved' => { obj => $business }
        if ! $business->id;

=head2 script

The script function returns a L<Path::Tiny> instance for operating on the script
being executed.

=head2 unquote

The unquote function unescapes double-quoted strings within the string.

    my $string = unquote '\"Ins\'t it a wonderful day\"';

=head2 user

The user function returns the current user's username.

    my $nick = user;

=head2 user_info

The user_info function returns an array reference of user information. This
function is not currently portable and only works on *nix systems.

    my $info = user_info;

=head2 which

The which function use L<File::Which> to return a L<Path::Tiny> instance for
operating on the located executable program.

    my $mailer = which 'sendmail';

=head2 will

The will function will construct and return a code reference from a string or
set of strings belonging to a single unit of execution. This function exists to
make creating tiny routines from strings easier. This function is especially
useful when used with methods that require code-references as arguments; e.g.
callbacks and chained method calls. Note, if the string begins with a semi-colon
separated list of variables, e.g. scalar, array or hash, then those variables
will automatically be expanded and assigned data from the default array.

    my $print = will '$output; say $output' or raise;
    $print->('hello world');

    # generates a coderef
    will '$output; say $output';

    # is equivalent to
    sub { my $output = shift; say $output; };

    # just as ...
    will '$a;$b; return $b - $a';

    # is equivalent to
    sub { my $a = shift; my $b = shift; return $b - $a; };

    # as well as ...
    will '%a; return keys %a';

    # is equivalent to
    sub { my %a = @_; return keys %a; };

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
