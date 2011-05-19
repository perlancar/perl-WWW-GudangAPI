package WWW::GudangAPI;
# ABSTRACT: Client library for GudangAPI.com

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use Sub::Spec::HTTP::Client qw(call_sub_http);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(call_ga_api);

our %SPEC;

$SPEC{call_ga_api} = {
    summary => 'Call API function from GudangAPI.com',
    description => <<'_',

This function is actually a thin wrapper for
Sub::Spec::HTTP::Client::call_sub_http.

_
    args => {
        module => ['str*' => {
            summary => 'Name of module to call',
            match   => qr!^\w+((?:::|/)\w+)*$!,
        }],
        sub => ['str*' => {
            summary => 'Name of function to call',
            match   => qr/^\w+$/,
        }],
        args => ['hash' => {
            summary => 'Function arguments',
            arg_pos => 3,
        }],
        https => ['bool' => {
            summary => 'Whether to use HTTPS instead of HTTP',
            description => <<'_',

You might want to use HTTPS if you send sensitive data such as password or
financial data. Note that HTTPS access has higher latency.

_
            default => 0,
        }],
        log_level => ['str' => {
            summary => 'Request logging output from server',
            in      => [qw/fatal error warn info debug trace/],
        }],
        log_callback => ['code' => {
            summary => 'Pass log messages to callback subroutine',
            description => <<'_',

If log_callback is not provided, log messages will be "rethrown" into Log::Any
logging methods (e.g. $log->warn(), $log->debug(), etc).

_
        }],
    },
};
sub call_ga_api {
    my %args = @_;

    # XXX schema
    my $module = $args{module}
        or return [400, "Please specify module"];
    $module =~ m!\A\w+((?:::|/+)\w+)*\z!
        or return [400, "Invalid module `$module`: use 'foo/bar' syntax"];
    my $modulep = $module; $modulep =~ s!::!/!g;
    $module =~ s!/!::!g;

    my $sub    = $args{sub}
        or return [400, "Please specify sub"];
    $sub =~ /\A\w+\z/
        or return [400, "Invalid sub: use alphanums only"];
    my $args   = $args{args} // {};
    ref($args) eq 'HASH'
        or return [400, "Invalid args: must be hash"];
    my $log_level = $args{log_level};
    my $https = $args{https};

    call_sub_http(
        url => ($https ? "https" : "http") . "://api.gudangapi.com".
            "/v1/$modulep/$sub;j",
        module => $module, sub => $sub, args => $args,
        log_level => $log_level);
}

1;
__END__

=head1 SYNOPSIS

 use WWW::GudangAPI qw(call_ga_api);
 my $res = call_ga_api(
     module => 'tax/id/npwp',
     sub    => 'parse_npwp',
     args   => {npwp=>'00.000.001.8-000'},
     #https => 1, # use https, default is 0
 );
 say "valid!" if $res->[0] == 200; # prints 'valid!'


=head1 DESCRIPTION

This module is the Perl client library for GudangAPI,
L<http://www.gudangapi.com/>.

This module uses L<Log::Any>.

This module's functions has L<Sub::Spec> specs.


=head1 FUNCTIONS

None are exported, but they can be.


=head1 SEE ALSO

L<Sub::Spec::HTTP::Client>

=cut
