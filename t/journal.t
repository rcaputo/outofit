#!perl

use warnings;
use strict;

use Data::LedgerCLI::Journal;
use Data::LedgerCLI::Transaction;
use Data::LedgerCLI::Posting;

{
	my $j = Data::LedgerCLI::Journal->new();

	my $t = Data::LedgerCLI::Transaction->new(
		comments => [ 'This is a comment.' ],
		date => DateTime->new( year => 2000, month => 1, day => 1 ),
		payee => 'Payee',
		postings => [
			Data::LedgerCLI::Posting->new(
				account => 'Store',
				amount => 1.2,
			)
		],
	);

	# TODO - Dangerous to append the same transaction more than once.
	$j->append_transaction( $t );
	$j->append_transaction( $t );

	print $j->as_journal();
}

exit;

