use Test::More;
use Bubblegum::Exception;
use Bubblegum::Functions;

{
    package misc::functions;
    use Bubblegum::Functions qw(
        cwd date date_epoch date_format dump file find here home merge load
        path quote raise script unquote user user_info which will
    );
    use Test::More;
    can_ok 'misc::functions', 'cwd';
    can_ok 'misc::functions', 'date';
    can_ok 'misc::functions', 'date_epoch';
    can_ok 'misc::functions', 'date_format';
    can_ok 'misc::functions', 'dump';
    can_ok 'misc::functions', 'file';
    can_ok 'misc::functions', 'find';
    can_ok 'misc::functions', 'here';
    can_ok 'misc::functions', 'home';
    can_ok 'misc::functions', 'load';
    can_ok 'misc::functions', 'merge';
    can_ok 'misc::functions', 'path';
    can_ok 'misc::functions', 'quote';
    can_ok 'misc::functions', 'raise';
    can_ok 'misc::functions', 'script';
    can_ok 'misc::functions', 'unquote';
    can_ok 'misc::functions', 'user';
    can_ok 'misc::functions', 'user_info';
    can_ok 'misc::functions', 'which';
    can_ok 'misc::functions', 'will';
    is 'Bubblegum::Exception', ref do { eval {raise 'wtf'}; $@ };
}

done_testing;
