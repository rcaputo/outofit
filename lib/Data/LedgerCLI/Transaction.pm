package Data::LedgerCLI::Transaction;

use Moose;
use Carp qw(croak);
use Data::LedgerCLI::Parsers qw( parse_date parse_effective_date );


has line_number => (
	is => 'rw',
	isa => 'Int',
);


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
	isa => 'Str',
	required => 1,
);


has effective_date => (
	is => 'rw',
	isa => 'Str',
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


sub headline_as_journal {
	my ($self) = @_;

	my $output = '';
	foreach (@{ $self->comments() }) {
		$output .= "; $_\n";
	}

	$output .= $self->date();

	if (defined $self->effective_date()) {
		$output .= '=' . $self->effective_date();
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

	return $output;
}


sub as_journal {
	my ($self) = @_;

	my $output = $self->headline_as_journal();

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

	# 4.7.1: Transaction begins with a line that begins with a digit.
	my $date = parse_date($ledger);
	croak "Can't parse transaction date from '$_[1]'" unless defined $date;
	push @constructor_args, ( date => $date );

	my $effective_date = parse_effective_date($ledger);
	if (defined $effective_date) {
		push @constructor_args, ( effective_date => $effective_date );
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


sub contains_posting_account {
	my ($self, $regexp) = @_;

	foreach (@{ $self->postings() }) {
		return 1 if $_->account() =~ $regexp;
	}

	return;
}


sub sum_of_posting_amounts {
	my ($self, @regexps) = @_;

	# Returns undef if none match.
	my @sums;
	foreach my $t (@{ $self->postings() }) {
		foreach my $ir (0..$#regexps) {
			next unless $t->account() =~ $regexps[$ir];
			$sums[$ir] //= 0;
			$sums[$ir] += $t->amount();
		}
	}

	return @sums;
}


__PACKAGE__->meta()->make_immutable();

1;
