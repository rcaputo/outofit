package Data::LedgerCLI::Comment;

use Moose;


has comments => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub { [] },
);


sub as_journal {
	my ($self) = @_;

	my $output = '';
	foreach (@{ $self->comments() }) {
		$output .= "; $_\n";
	}

	return $output;
}


sub headline_as_journal {
	my ($self) = @_;
	return $self->as_journal();
}


# None, but the API should be consistent.
sub sum_of_posting_amounts { return () }


__PACKAGE__->meta()->make_immutable();

1;
