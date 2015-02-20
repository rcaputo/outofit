package Data::LedgerCLI::Posting;

use Moose;
use Carp qw(croak);
use Data::Money;

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


has account => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);


has amount => (
	is => 'ro',
	isa => 'Data::Money',
	required => 1,
);


has note => (
	is => 'ro',
	isa => 'Str',
);


has comments => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub { [] },
);


has places => (
	isa => 'Int',
	is => 'rw',
	default => 9,
);



# TODO: Clearer that also clears must_balance.
has virtual => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
);


# TODO: Setter that also sets virtual.
has must_balance => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
);


has posting_cost => (
	is => 'rw',
	isa => 'Num',
);

has cost_per_unit => (
	is => 'rw',
	isa => 'Num',
);

has actual_date => (
	is => 'rw',
	isa => 'Str',
);


has effective_date => (
	is => 'rw',
	isa => 'Str',
);


sub append_comment {
	my ($self, $comment) = @_;
	push @{ $self->comments() }, $comment // '';
}


sub as_journal {
	my ($self) = @_;

	my $output = '  ';

	if ($self->must_balance()) {
		$output .= '[' . $self->account() . ']';
	}
	elsif ($self->virtual()) {
		$output .= '[' . $self->account() . ']';
	}
	else {
		$output .= $self->account();
	}

	my $rendered_amount = $self->amount();
	$rendered_amount =~ s/^-\$/\$-/;

	$output .= '  ' . $rendered_amount;

	if (defined $self->cost_per_unit()) {
		$output .= ' @ ' . $self->cost_per_unit();
	}

	if (defined $self->posting_cost()) {
		$output .= ' @@ ' . $self->posting_cost();
	}

	my $date;
	if (defined $self->actual_date()) {
		$date = $self->actual_date()
	}

	if (defined $self->effective_date()) {
		$date //= '';
		$date .= '=' . $self->effective_date();
	}

	my $note;
	if (defined $date) {
		$note = "[$date]";
	}

	if (defined $self->note()) {
		$note .= ' ' if defined $note;
		$note .= $self->note();
	}

	if (defined $note) {
		$output .= "  ; $note";
	}

	# TODO - Magic in the notes.
	foreach (@{ $self->comments() }) {
		$output .= "\n  ; $_";
	}

	return $output;
}


sub new_from_journal {
	my ($class, $ledger) = @_;

	my @constructor_args;

	# Account begins with a cleared/pending flag.  Optional.
	if ($ledger =~ s/^\s*\*//) {
		push @constructor_args, ( cleared => 1 );
	}
	elsif ($ledger =~ s/^\s*!//) {
		push @constructor_args, ( pending => 1 );
	}

	# 4.1: Account is terminated by either two spaces or a tab.
	unless ($ledger =~ s/^\s*(\S.*?)(?:\s*  \s*|\s*\t\s*)//) {
		croak "Can't parse account from '$_[1]'";
	}

	push @constructor_args, ( account => $1 );

	unless ($ledger =~ s/^\s*(\$)?\s*(-?)\s*([,.\d]+)//) {
		croak "Can't parse amount from '$_[1]'";
	}

	# TODO - Currency type.
	push @constructor_args, ( amount => Data::Money->new( value => "$2$3" ) );


	if ($ledger =~ s/^\s*\@\@\s*(\d\S*)//) {
		push @constructor_args, ( posting_cost => $1 );
	}
	elsif ($ledger =~ s/^\s*\@\s*(\d\S*)//) {
		push @constructor_args, ( cost_per_unit => $1 );
	}

	if ($ledger =~ s/^\s*;\s*(\S.*?)\s*$//) {
		my $note = $1;

		if ($note =~ s/^\s*\[([-\d=\s]*)\]\s*//) {
			my $date = $1;
			if ($date =~ s/^\s*(\d\d\d\d)-(\d\d)-(\d\d)//) {
				push @constructor_args, ( actual_date => "$1-$2-$3" );
			}

			if ($date =~ s/^\s*=\s*(\d\d\d\d)-(\d\d)-(\d\d)//) {
				push @constructor_args, ( effective_date => "$1-$2-$3" );
			}

			if ($date =~ /\S/) {
				croak "Can't parse dates from note of '$_[1]'";
			}
		}

		if (length $note) {
			push @constructor_args, ( note => $note );
		}
	}

	return $class->new( @constructor_args );
}

__PACKAGE__->meta()->make_immutable();

1;
