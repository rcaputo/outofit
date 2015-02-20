package Data::LedgerCLI::Journal;

use Moose;
use Data::LedgerCLI::Transaction;
use Data::LedgerCLI::Comment;
use Data::LedgerCLI::Posting;

use constant DEBUG => 0;


has transaction_index => (
	is => 'rw',
	isa => 'Int',
);


has transactions => (
	is      => 'rw',
	isa     => 'ArrayRef[Data::LedgerCLI::Transaction]',
	default => sub { [] },
);


sub append_transaction {
	my ($self, $transaction) = @_;
	push @{ $self->transactions() }, $transaction;
}


# Potentially makes very large strings.
# A first/next iterator may be less convenient but will be more
# practical for very large journals.
sub as_journal {
	my ($self) = @_;

	my $output = '';
	foreach (@{ $self->transactions() }) {
		$output .= $_->as_journal();
	}

	return $output;
}


sub append_from_file_handle {
	my ($self, $file_handle) = @_;

	my @pending_transaction_comments;
	my $pending_transaction;

	while (<$file_handle>) {
		s/\s+$//;

		# Comment for the following transaction.
		#
		# TODO - Handle comments at the end of the file.
		# This type of comment signals the end of the preceding
		# transaction, but it doesn't guarantee a following one.

		if (s/^[;#%|*]\s*//) {

			if (
				$pending_transaction and not
				$pending_transaction->isa("Data::LedgerCLI::Comment")
			) {
				$self->append_transaction( $pending_transaction );
				$pending_transaction = undef;
			}

			$pending_transaction //= Data::LedgerCLI::Comment->new();

			push @{ $pending_transaction->comments() }, $_;

			DEBUG and print "| (TC) $_\n";
			next;
		}

		# Comment for the preceding posting.
		if (/^\s+;\s*(\S?.*?)\s*$/) {
			if (@{ $pending_transaction->postings() }) {
				my $pending_posting = $pending_transaction->postings()->[-1];
				$pending_posting->append_comment($1);
			}
			else {
				$pending_transaction->append_payee_comment($1);
			}

			DEBUG and print "| (PC) $_\n";
			next;
		}

		# Posting for the preceding transaction.
		if (/^\s+[^\s;]/) {

			my $posting = Data::LedgerCLI::Posting->new_from_journal($_);
			$pending_transaction->append_posting($posting);

			DEBUG and print "| (Po) ", $posting->as_journal(), "\n";
			next;
		}

		# The beginning of a transaction.
		if (/^\d/) {

			if ($pending_transaction) {
				push @{$self->transactions()}, $pending_transaction;
			}

			$pending_transaction = Data::LedgerCLI::Transaction->new_from_journal($_);
			$pending_transaction->line_number( $. );

			if (@pending_transaction_comments) {
				push(
					@{ $pending_transaction->comments() },
					@pending_transaction_comments
				);

				@pending_transaction_comments = ();
			}

			DEBUG and print "| (Tr) ", $pending_transaction->as_journal();
			next;
		}

		# Historical price for a commodity.
		if (/^P/) {
			DEBUG and print "- (HP) $_\n";
			next;
		}

		# Automated transaction.
		if (/^=/) {
			DEBUG and print "- (AT) $_\n";
			next;
		}

		# Periodic transaction.
		if (/^~/) {
			DEBUG and print "- (PT) $_\n";
			next;
		}

		if (/^\s*$/) {
			DEBUG and print "| (BL) $_\n";
			next;
		}

		DEBUG and print "- (??) $_\n";
	}

	if ($pending_transaction) {
		$self->append_transaction( $pending_transaction );
		$pending_transaction = undef;
	}
}



sub reset_iterator {
	my ($self) = @_;
	$self->transaction_index( 0 );
}


sub next_transaction {
	my ($self) = @_;
	return if $self->transaction_index() >= @{ $self->transactions() };
	my $i = $self->transaction_index();
	my $next_transaction = $self->transactions()->[ $i ];
	$self->transaction_index( $i + 1 );
	return $next_transaction;
}


__PACKAGE__->meta()->make_immutable();

1;
