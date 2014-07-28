test-1.ldg: accounts.csv all-txns.csv
	./outofit > test-1.ldg

test-2.ldg: outofit DumpJournal.pm accounts.csv all-txns.csv
	./outofit > test-2.ldg

test.one: test-1.ldg
	ledger -f test-1.ldg balance > test.one

test.two: test-2.ldg
	ledger -f test-2.ldg balance > test.two

diff: test.two
	diff test.one test.two
