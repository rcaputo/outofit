package Data::LedgerCLI::Parsers;

use warnings;
use strict;

require Exporter;
use base 'Exporter';
our @EXPORT_OK = qw(parse_date parse_effective_date);

# parse_date($string, $required);

sub parse_date {
	if ($_[0] =~ s/^(\d\d\d\d)-(\d\d)-(\d\d)\s*//) {
		return "$1-$2-$3";
	}

	return;
}


sub parse_effective_date {
	if ($_[0] =~ s/^=\s*(\d\d\d\d)-(\d\d)-(\d\d)\s*//) {
		return "$1-$2-$3";
	}

	return;
}


1;
