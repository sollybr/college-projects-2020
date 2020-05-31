package Client;
use strict;
use warnings;

sub name {
	my $self =  shift;
	return $self;
}

sub address {
	my $self = shift;
	return $self;
}

sub new {
	my $class = shift;
	my $self = { @_ };
	bless $self;
	return $self;
}

1;