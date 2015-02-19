#!perl

use warnings;
use strict;

use Data::LedgerCLI::Journal;
use Data::LedgerCLI::Transaction;
use Data::LedgerCLI::Posting;

{
	my $j = Data::LedgerCLI::Journal->new();

	$j->append_from_file_handle(\*DATA);

	print $j->as_journal();
}

exit;

__DATA__

2000-11-22 * Payee
	; Payee comment.
	* Account:From  $-100.00
	Account:To       $100.00
