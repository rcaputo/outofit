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


__PACKAGE__->meta()->make_immutable();

1;
