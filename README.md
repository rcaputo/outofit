You need to run two reports in QuickBooks to produce the raw data for
this utility.

All these reports should have all filters disabled.

## Account Listing

The first report will be a listing of all accounts, active and
inactive.  This listing will be used to expand short account names to
their full counterparts.  In the future, the balance may be used to
check the results of an export.

Using the report Options, enable at least these three fields:

* Account
* Type
* Balance

Remember to disable all Filters, so the report includes all data.

It may be useful to memorize the report, in case you need to run it
repeatedly while cleaning up the source ledger.

Using the menus, select "Save Report as Text..."

* The account name will be "accounts.csv".
* Text Delimiters will be "Commas"

## Transaction Detail by Date

The final report will be a complete "Transaction Detail by Date".
This provides the raw data to post transactions to the new ledger.

Using the report Options, enable all the fields except "(left
margin)".

Remember to disable all Filters, so the report includes all data.

It may be useful to memorize the report, in case you need to run it
repeatedly while cleaning up the source ledger.

Using the menus, select "Save Report as Text..."

* The account name will be "all-txns.csv".
* Text Delimiters will be "Commas"

## Export the Ledger

Run outofit to export the ledger.

    ./outofit > test.ldg

Diagnostic warnings will appear on stderr if there are any known
problems.

The result should be a fully formed ledger-cli ledger.

## Known Issues

I'm pretty sure the signage on some accounts is wrong.

It should be possible to identify account types (Asset, Liability,
Revenue, Expense, etc.) and categorize them accordingly.

There is perhaps more data in the resulting ledger than required, but
I chose to preserve as much input data as possible.

Accounting conventions in my source ledger may differ from those in
yours.  It may be necessary to change some things.

The program isn't yet structured for overriding and augmenting
translation rules.

My motivation to maintain this will end when I've converted my last
ledger across.
