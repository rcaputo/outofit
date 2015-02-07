package Data::LedgerCLI::Posting;

use Moose;
use DateTime;
use Carp qw(croak);


has account => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);


has currency => (
	is => 'ro',
	isa => 'Str',
	default => '$',
);

has amount => (
	is => 'ro',
	isa => 'Str',
	required => 1,
	trigger => sub {
		my ($self, $value) = @_;

		my ($w, $f) = split(/\./, $value, 2);

		if (defined $w) {
			$w =~ s/^0+//;
			$w = '0' unless length $w;
		}
		else {
			$w = '0';
		}

		if (defined $f) {
			$f =~ s/0+$//;
			# TODO: Decide whether to truncate $f if it's too long.
			$f .= '0' x ($self->places() - length($f));
		}
		else {
			$f = '0' x $self->places();
		};

		$_[1] = $w . '.' . $f;
	},
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
	isa => 'DateTime',
);


has effective_date => (
	is => 'rw',
	isa => 'DateTime',
);


sub append_comment {
	my ($self, $comment) = @_;
	push @{ $self->comments() }, $comment;
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

	$output .= '  ' . $self->currency() . $self->amount();

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

	# 4.1: Account is terminated by either two spaces or a tab.
	unless ($ledger =~ s/^\s*(\S.*?)(?:\s*  \s*|\t\s*)//) {
		croak "Can't parse account from '$_[1]'";
	}

	push @constructor_args, ( account => $1 );

	unless ($ledger =~ s/^\s*([\$]?)\s*(-?)\s*([,.\d]+)//) {
		croak "Can't parse amount from '$_[1]'";
	}

	push @constructor_args, ( currency => $1 ) if defined $1;
	push @constructor_args, ( amount => $2 );


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
				push @constructor_args, (
					actual_date => DateTime->new( year => $1, month => $2, day => $3 )
				);
			}

			if ($date =~ s/^\s*=\s*(\d\d\d\d)-(\d\d)-(\d\d)//) {
				push @constructor_args, (
					effective_date => DateTime->new( year => $1, month => $2, day => $3 )
				);
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
