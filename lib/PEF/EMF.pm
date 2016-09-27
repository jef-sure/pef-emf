package PEF::EMF;

use strict;
use warnings;

sub not_found_error {
	+{result => 'INTERR', answer => 'No handler found'};
}

sub new {
	my ($class, %args) = @_;
	my $nfe = delete $args{not_found_error} || not_found_error;
	my $storage = delete $args{storage};
	bless {
		node_filters    => {},
		code_filters    => [],
		not_found_error => $nfe,
		storage         => $storage,
		queue           => [],
		},
		$class;
}

sub make_event {
	my @args = @_;
	my $self;
	if (@args == 1) {
		$self = {
			event   => $args[0],
			nodes   => $args[0],
			context => {}
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
				context => delete($args{context}) || {}
			};
		} else {
			$self = {
				event   => $event,
				nodes   => $event,
				context => delete($args{context}) || {}
			};
		}
	}
	$self;
}

sub _buid_predicate {
	my $filter = $_[0];
	my @nodes;
	my $predicate_str = '';
	my $predicate_sub;
	if (not ref $filter) {
		$predicate_str = <<EOS;
sub {
	my \@kn = keys %{\$_[0]{nodes}};
	\@kn == 1 && \$kn[0] eq '$filter'
}
EOS
		$filter =~ s/'/\\'/g;
		@nodes = ($filter);
	} elsif (ref $filter eq 'HASH') {
		my $nrk = @nodes = map {$_ =~ s/'/\\'/g; $_} sort keys %$filter;
		my $lrk = "('" . join("','", @nodes) . "')";
		$predicate_str = <<EOS;
sub {
	my \@kn = keys %{\$_[0]{nodes}};
	return if \@kn != $nrk || grep {not exists \$_[0]{nodes}{\$_} } $lrk;
	my \$event = \$_[0]{event};
	my \$nodes = \$_[0]{nodes};
	my \$context = \$_[0]{context};
	return 
EOS
		my @conds;
		for my $fk (keys %$filter) {
			if (defined $filter->{$fk}) {
				if (not ref $filter->{$fk}) {
					push @conds, $filter->{$fk};
				} elsif (ref $filter->{$fk} eq 'HASH') {
					my $fh = $filter->{$fk};
					push @conds, map {"\$_[0]->{\$fk}{\$_} $fh->{$_}"} keys %$fh;
				} elsif (ref $filter->{$fk} eq 'ARRAY') {
					push @conds, "(" . join(" || ", @{$filter->{$fk}}) . ")";
				}
			} else {
				push @conds, "1 == 1";
			}
		}
		$predicate_str .= join(' && ', @conds) . ";\n}";
	} elsif (ref $filter eq 'CODE') {
		$predicate_sub = $filter;
	} else {
		die "Unknown predicate format";
	}
	$@ = undef;
	$predicate_sub ||= eval $predicate_str;
	die $@ if $@;
	return ($predicate_sub, \@nodes, $predicate_str);
}

sub register {
	my ($self, $filter, @args) = @_;
	my $filter_array;
	my ($predicate_sub, $nodes, $predicate_str) = _buid_predicate($filter);
	if (@$nodes) {
		my $nk = join $;, @$nodes;
		$self->{node_filters}{$nk} ||= [];
		$filter_array = $self->{node_filters}{$nk};
	} else {
		$filter_array = $self->{code_filters};
	}
	push @{$filter_array}, [$predicate_sub, @args];
	$self;
}

sub call {
	my ($self, $revent, $cb) = @_;
	my $event = make_event($revent);
	my $nodes = $event->{nodes};
	my @kn    = sort keys %$nodes;
	my $nk    = join $;, @kn;
	my @handlers;
	if ($self->{node_filters}{$nk}) {
		@handlers = @{$self->{node_filters}{$nk}};
	}
	push @handlers, @{$self->{code_filters}};
	for my $ha (@handlers) {
		
	}
}

1;
