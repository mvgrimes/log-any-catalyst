package Log::Any::Adapter::Catalyst;
use Log::Any::Adapter::Util qw(make_method);
use strict;
use warnings;
use Carp;
use base qw(Log::Any::Adapter::Base);

our $VERSION = '0.10';

sub init {
    my ($self) = @_;

    croak "Log::Any::Adapter->set must be called with the 'logger' parameter\n"
      . "Typically, in you Catalyst Application Class:\n"
      . "Log::Any::Adapter->set('Catalyst', logger => __PACKAGE__->log);\n"
      unless $self->{logger};
}

# Connect the Log::Any methods to the appropriate Catalyst::Log method
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    my $cat_log_method = $method;

    # Map log levels down to Catalyst::Log levels where necessary
    for ($cat_log_method) {
        s/trace/debug/;
        s/notice/info/;
        s/warning/warn/;
        s/critical|alert|emergency/fatal/;
    }

    __PACKAGE__->delegate_method_to_slot( 'logger', $method, $cat_log_method );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Catalyst - Enable error and status logging in Catalyst Models via Log::Any

=head1 SYNOPSIS

In a Catalyst Model, View, etc (anywhere you don't have C<$c>):

    use Log::Any qw($log);

    $log->debug( "Sent to $c->log() if called from a Catalyst model" );

In a your main Catalyst module (MyApp.pm):

    use Log::Any::Adapter;

    Log::Any::Adapter->set('Catalyst', logger => __PACKAGE__->log);

=head1 DESCRIPTION

This Log::Any adapter uses L<Catalyst::Log> for logging. L<Catalyst::Log> must
be initialized before calling I<set>, but Catalyst takes care of that for you.
There are no parameters.

=head1 LOG LEVEL TRANSLATION

Log levels are translated from L<Log::Any> to L<Catalyst::Log> as follows:

    trace -> debug
    debug -> debug
    info (inform) -> info
    notice -> info
    warning (warn) -> warn
    error (err) -> error
    critical (crit, fatal) -> fatal
    alert -> fatal
    emergency -> fatal

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Any::Adapter|Log::Any::Adapter>,
L<Catalyst|Catalyst>, L<Catalyst::Log|Catalyst::Log>

=head1 AUTHOR

Mark Grimes

=head1 COPYRIGHT & LICENSE

Copyright (C) 2011 Mark Grimes, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
