package WWW::GudangAPI;

use 5.010;
use strict;
use warnings;
use Exporter::Lite;
use Log::Any '$log';
use Perinci::Access;

our @EXPORT_OK = qw(get_ga_ssuri);
our %SPEC;
# VERSION

$SPEC{call_ga} = {
    v => 1.1,
    summary =>
        'Call GudangAPI.com API functions',
    description => <<'_',

Note that GudangAPI.com is a Riap server, so you can use any Riap client to
access it.

_
    args => {
        module => {
            req => 1,
            pos => 0,
            schema => ['str*' => {
                match   => qr!^\w+(?:::\w+)*$!,
            }],
            summary => 'Name of module to call',
        },
        func => {
            req => 1,
            pos => 1,
            schema => ['str*' => {
                match   => qr/^\w+$/,
            }],
            summary => 'Name of function to call',
        },
        user => {
            schema => ['str' => {
                default => 'ga',
            }],
            summary => 'GudangAPI username',
        },
        args => {
            schema => ['hash*' => {
                default => {},
            }],
            summary => 'Function arguments',
        },
        https => {
            schema => ['bool' => {
                default => 0,
            }],
            summary => 'Whether to use HTTPS instead of HTTP',
            description => <<'_',

You might want to use HTTPS if you send sensitive data such as password or
financial data. Note that HTTPS access has higher latency.

_
        },
    },
};
sub call_ga {
    my %args = @_;

    state $pa = Perinci::Access->new;

    # XXX schema

    my $user = $args{user};
    if (defined $user) {
        $user =~ /\A\w+\z/
            or return [400, "Invalid user `$user`: use alphanums only"];
    }
    $user //= "ga";

    my $module = $args{module}
        or return [400, "Please specify module"];
    $module =~ m!\A\w+(?:::\w+)*\z!
        or return [400, "Invalid module `$module`: use 'foo::bar' syntax"];

    my $func = $args{func};
    if (defined $func) {
        $func =~ /\A\w+\z/
            or return [400, "Invalid sub: use alphanums only"];
    }
    my $https = $args{https};

    my $url = join("",
                   ($https ? "https" : "http"), "://",
                   "gudangapi.com/",
                   $user,
                   "/$module",
                   (defined($func) ? "::$func" : "")
               );
    $log->tracef("url=%s", $url);
    $pa->request(call => $url, {args=>});
}

1;
__END__
# ABSTRACT: Client library for GudangAPI.com

=head1 SYNOPSIS

 use WWW::GudangAPI qw(call_ga);
 my $uri = call_ga(
     module => 'tax/id/npwp',
     func   => 'parse_npwp',
     #https => 1, # use https, default is 0
     args => {npwp=>'00.000.001.8-000'}
 );
 my $res = $uri->call(npwp=>'00.000.001.8-000');
 say "valid!" if $res->[0] == 200; # prints 'valid!'


=head1 DESCRIPTION

This module is the Perl client library for GudangAPI,
L<http://www.gudangapi.com/>. It is currently a very thin (and probably pretty
useless) wrapper for L<Perinci::Access>, since GudangAPI is L<Riap>-compliant.
As a matter of fact, you can just do:

 my $pa = Perinci::Access->new;
 my $res = $pa->request(call => "http://gudangapi.com/ga/MODULE::FUNC",
                        {args=>{ARG=>...}});

and skip this module altogether. But in the future some convenience features
will be added to this module.

This module uses L<Log::Any>.

This module has L<Rinci> metadata.


=head1 SEE ALSO

L<Riap>

L<Perinci::Access>

http://www.gudangapi.com/

=cut
