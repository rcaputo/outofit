#!perl

use warnings;
use strict;

use Data::LedgerCLI::Transaction;
use Data::LedgerCLI::Posting;

{
	my $t = Data::LedgerCLI::Transaction->new(
		date => DateTime->new( year => 2000, month => 1, day => 1 ),
		payee => 'Payee',
		postings => [
			Data::LedgerCLI::Posting->new(
				account => 'Store',
				amount => 1.2,
			)
		],
	);

	$t->pending(1);
	$t->cleared(1);

	print $t->as_journal();
}

exit;
