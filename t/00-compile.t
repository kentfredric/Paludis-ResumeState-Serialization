use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.037

use Test::More  tests => 3;



my @module_files = (
    'Paludis/ResumeState/Serialization.pm',
    'Paludis/ResumeState/Serialization/Basic.pm',
    'Paludis/ResumeState/Serialization/Grammar.pm'
);



# no fake home requested

my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



# no warning checks;


