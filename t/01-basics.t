#!perl

use 5.010;
use strict;
use warnings;

use Test::More 0.98;
use WWW::GudangAPI qw(get_ga_ssuri);

plan skip_all => 'Only for RELEASE_TESTING' unless $ENV{RELEASE_TESTING};

test_call_ga_func(
    name     => 'http',
    module   => 'tax/id/npwp',
    sub      => 'parse_npwp',
    args     => {npwp=>'00.000.001.8-000'},
    status   => 200,
);

test_call_ga_func(
    name     => 'unknown module -> fail',
    module   => 'foo/bar',
    sub      => 'sub',
    args     => {},
    status   => 500,
);

# XXX: https

done_testing();

sub test_call_ga_func {
    my (%args) = @_;

    subtest $args{name} => sub {
        my $uri = get_ga_ssuri(module=>$args{module}, sub=>$args{sub});
        my $res = $uri->call(%{ $args{args} });
        if ($args{status}) {
            is($res->[0], $args{status}, "status")
                or diag explain $res;
        }
        if (exists $args{result}) {
            is_deeply($res->[2], $args{result}, "result")
                or diag explain $res->[2];
        }
        if ($args{posttest}) {
            $args{posttest}->($res);
        }
    };
}
