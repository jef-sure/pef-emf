package PEF::EMF::Event;

use strict;
use warnings;

sub new {
	my ($class, @args) = @_;
	my $self;
	if (@args == 1) {
		$self = {
			event => $args[0],
			nodes => $args[0]
		};
	} else {
		my %args = @args;
		my $event = $args{event} or return;
		return if ref $event ne 'HASH';
		if ($args{nodes}) {
			my @nodes = ref($args{nodes}) ? @{$args{nodes}} : ($args{nodes});
			$self = {
				event => $event,
				nodes => {map {$_ => $event->{$_}} @nodes},
			};
		} else {
			$self = {
				event => $event,
				nodes => $event,
			};
		}
	}
	bless $self, $class;
}

1;
