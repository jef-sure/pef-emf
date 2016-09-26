package PEF::EMF;

sub not_found_error {
	+{ result => 'INTERR', answer => 'No handler found' };
}

sub new {
	my ( $class, %args ) = @_;
	my $nfe = delete $args{not_found_error} || not_found_error;
	my $storage = delete $args{storage};
	bless {
		node_filters    => {},
		code_filters    => [],
		not_found_error => $nfe,
		storage         => $storage
	  },
	  $class;
}

sub _buid_predicate {
	my $filter = $_[0];
	my @nodes;
	my $predicate_str = '';
	if ( not ref $filter ) {
		$predicate_str = <<EOS;
sub {
	my \@kn = keys %{\$_[0]{nodes}};
	\@kn == 1 && \$kn[0] eq '$filter'
}
EOS
		@nodes = ($filter);
	}
	elsif ( ref $filter eq 'HASH' ) {
		my $nrk = keys %$filter;
		my $lrk = "('" . join( "','", keys %$filter ) . "')";
		$predicate_str = <<EOS;
sub {
	my \@kn = keys %{\$_[0]{nodes}};
	return if \@kn != $nrk || grep {not exists \$_[0]{\$_} } $lrk;
	my \$event = \$_[0]{event};
	my \$nodes = \$_[0]{nodes};
EOS
		my @conds;
		for my $fk ( keys %$filter ) {
			if ( defined $filter->{$fk} ) {
				if ( not ref $filter->{$fk} ) {
					push @conds, $filter->{$fk};
				}
				elsif ( ref $filter->{$fk} eq 'HASH' ) {
					my $fh = $filter->{$fk};
					push @conds,
					  map { "\$_[0]->{\$fk}{\$_} " . $fh->{$_} }
					  keys %$fh;
				}
			}
		}
		$predicate_str .= join( ' && ', @conds ) . ";\n}";
	}
	else {
	}
}

sub add_filter {
	my ( $self, $filter, @args ) = @_;
	my $sub_filter;
	my $filter_array;
	if ( not ref $filter ) {
		$sub_filter = sub { $_[0]->node_is($filter); };
	}
	elsif ( ref $filter ne 'CODE' ) {
		$sub_filter = sub { $_[0]->predicate_is($filter); };
	}
	else {
		$sub_filter   = $filter;
		$filter_array = $self->{code_filters};
	}
	push @{$filter_array}, $sub_filter;
	$self;
}

sub process_event {
	my ( $self, $event ) = @_;
}

1;
