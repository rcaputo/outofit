#!perl

use warnings;
use strict;

use Data::LedgerCLI::Posting;

{
	my $p = Data::LedgerCLI::Posting->new(
		account => 'Store',
		amount => 1.2,
	);

	print $p->as_journal(), "\n";
}

{
	my $p = Data::LedgerCLI::Posting->new(
		account => 'Store',
		amount => 3,
	);

	print $p->as_journal(), "\n";
}

{
	my $p = Data::LedgerCLI::Posting->new(
		account => 'Store',
		amount => '.0044',
	);

	print $p->as_journal(), "\n";
}

exit;
