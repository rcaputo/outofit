package DumpJournal;

use warnings;
use strict;

our @EXPORT_OK = qw( delete_used_fields delete_unused_fields dump_journal );
use Exporter;
use base 'Exporter';

# All transactions include all fields, whether or not they're needed.
# During debugging, it's useful to dump the raw input data.  But we
# don't need to dump things that don't matter.

my @globally_irrelevant_fields = (
	'',
	'Action',
	'Balance',
	'Billed Date',
	'Class',
	'Credit',
	'Debit',
	'Deliv Date',
	'Entered/Last Modified',
	'Estimate Active',
	'FOB',
	'Last modified by',
	'Open Balance',
	'P. O. #',
	'Print',
	'Rep',
	'Split',  # TODO - Is this really not necessary?
	'State',
	'Terms',
	'Via',
);

my @not_an_invoice = (
	'Aging',
	'Item Description',
	'Item',
	'Qty',
	'Sales Price',
	'Ship Date',
);

my @not_billable = (
	'Billing Status',
);

my @not_payable = (
	'Payment',
);

my @not_a_payment = (
	'Pay Meth',
);

my @not_due = (
	'Due Date',
);

my %irrelevant_fields = (
	'Credit Card Charge' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_due,
		@not_payable,
	],
	'Bill' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_payable,
	],
	'Bill Pmt -Check' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_billable,
		@not_due,
		@not_payable,
	],
	'Bill Pmt -CCard' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_billable,
		@not_due,
		@not_payable,
	],
	'Invoice' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_billable,
		@not_payable,
	],
	'Deposit' => [
		@globally_irrelevant_fields,
		@not_an_invoice,
		@not_due,
	],
	'Payment' => [
		@globally_irrelevant_fields,
		@not_an_invoice,
		@not_billable,
		@not_due,
	],
	'Check' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_due,
		@not_payable,
	],
	'Credit Card Credit' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_due,
		@not_payable,
	],
	'Credit' => [
		@globally_irrelevant_fields,
		@not_a_payment,
		@not_an_invoice,
		@not_billable,
		@not_due,
		@not_payable,
	],
);

sub delete_unused_fields {
	my ($journal) = @_;
	foreach (@$journal) {
		delete @{$_}{ @{ $irrelevant_fields{$_->{'Type'}} } };
	}
}

sub delete_used_fields {
	my ($journal) = shift();
	delete @{$_}{ @_ } foreach @$journal;
}

# Debugging function to dump abbreviated items in a journal entry.
# Irrelevant fields are removed to keep the output brief.

sub dump_journal {
	my (
		$posting_type, $posting_number, $journal_date, $any_posting, $journal
	) = @_;

	#use YAML::Syck; print YAML::Syck::Dump($journal);
	use JSON::XS; print( encode_json($_), "\n") foreach @$journal;
}

1;
