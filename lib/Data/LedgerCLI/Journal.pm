package Data::LedgerCLI::Journal;

use Moose;
use Data::LedgerCLI::Transaction;
use Data::LedgerCLI::Posting;

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

			if ($pending_transaction) {
				$self->append_transaction( $pending_transaction );
				$pending_transaction = undef;
			}

			push @{ $pending_transaction->comments() }, $_;

			print "| (TC) $_\n";
			next;
		}

		# Comment for the preceding posting.
		if (/^\s+;\s*(\S.*?)\s*$/) {
			if (@{ $pending_transaction->postings() }) {
				my $pending_posting = $pending_transaction->postings()->[-1];
				$pending_posting->append_comment($1);
			}
			else {
				$pending_transaction->append_payee_comment($1);
			}

			print "| (PC) $_\n";
			next;
		}

		# Posting for the preceding transaction.
		if (/^\s+[^\s;]/) {

			my $posting = Data::LedgerCLI::Posting->new_from_journal($_);
			$pending_transaction->append_posting($posting);

			print "| (Po) ", $posting->as_journal(), "\n";
			next;
		}

		# The beginning of a transaction.
		if (/^\d/) {

			if ($pending_transaction) {
				push @{$self->transactions()}, $pending_transaction;
			}

			$pending_transaction = Data::LedgerCLI::Transaction->new_from_journal($_);

			if (@pending_transaction_comments) {
				push(
					@{ $pending_transaction->comments() },
					@pending_transaction_comments
				);

				@pending_transaction_comments = ();
			}

			print "| (Tr) ", $pending_transaction->as_journal(), "\n";
			next;
		}

		# Historical price for a commodity.
		if (/^P/) {
			print "- (HP) $_\n";
			next;
		}

		# Automated transaction.
		if (/^=/) {
			print "- (AT) $_\n";
			next;
		}

		# Periodic transaction.
		if (/^~/) {
			print "- (PT) $_\n";
			next;
		}

		if (/^\s*$/) {
			print "| (BL) $_\n";
			next;
		}

		print "- (??) $_\n";
	}
}


__PACKAGE__->meta()->make_immutable();

1;
