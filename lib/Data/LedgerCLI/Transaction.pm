package Data::LedgerCLI::Transaction;

use Moose;
use DateTime;
use Carp qw(croak);

has comments => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub { [] },
);

has payee_comments => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub { [] },
);

has postings => (
	is       => 'ro',
	isa      => 'ArrayRef[Data::LedgerCLI::Posting]',
	default => sub { [] },
);

has date => (
	is => 'rw',
	isa => 'DateTime',
	required => 1,
);

has effective_date => (
	is => 'rw',
	isa => 'DateTime',
);


# TODO: Setter that clears pending.
has cleared => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
);


# TODO: Setter that clears cleared.
has pending => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
);


# TODO: Setter that treats empty string as undef.
has code => (
	is => 'rw',
	isa => 'Str',
);


has payee => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);


sub append_posting {
	my ($self, $posting) = @_;
	push @{ $self->postings() }, $posting;
}


sub append_payee_comment {
	my ($self, $comment) = @_;
	push @{ $self->payee_comments() }, $comment;
}


sub as_journal {
	my ($self) = @_;

	my $output = '';
	foreach (@{ $self->comments() }) {
		$output .= "; $_\n";
	}

	$output .= $self->date()->ymd();

	if (defined $self->effective_date()) {
		$output .= '=' . $self->effective_date()->ymd();
	}

	if ($self->cleared()) {
		$output .= ' *';
	}
	elsif ($self->pending()) {
		$output .= ' !';
	}

	my $code = $self->code();
	if (defined $code and length $code) {
		$output .= ' (' . $self->code() . ')';
	}

	$output .= ' ' . $self->payee() . "\n";

	foreach (@{ $self->payee_comments() }) {
		$output .= "  ; $_\n";
	}

	foreach (@{ $self->postings() }) {
		$output .= $_->as_journal() . "\n";
	}

	return $output;
}


sub new_from_journal {
	my ($class, $ledger) = @_;

	my @constructor_args;

	croak "Can't parse transaction date from '$_[1]'" unless(
		$ledger =~ s/^(\d\d\d\d)-(\d\d)-(\d\d)//
	);

	push @constructor_args, (
		date => DateTime->new( year => $1, month => $2, day => $3 )
	);

	if ($ledger =~ s/^=(\d\d\d\d)-(\d\d)-(\d\d)//) {
		push @constructor_args, (
			effective_date => DateTime->new( year => $1, month => $2, day => $3 )
		);
	}

	if ($ledger =~ s/^\s*\*//) {
		push @constructor_args, ( cleared => 1 );
	}
	elsif ($ledger =~ s/^\s*!//) {
		push @constructor_args, ( pending => 1 );
	}

	if ($ledger =~ s/^\s*\((.*?)\)//) {
		push @constructor_args, ( code => $1 );
	}

	$ledger =~ s/^\s*//;
	croak "Can't parse transaction from '$_[1]'" unless length $ledger;
	push @constructor_args, ( payee => $ledger );

	return $class->new( @constructor_args );
}


__PACKAGE__->meta()->make_immutable();

1;
