# What Is This?

"outofit" is a personal project to migrate my Intuit's QuickBooks data
to another, transparent format.  Currently the ledger-cli format,
because:

* ledger-cli is free, open source.  I have the power and option to
  extend or maintain it as necessary.  It probably won't be since
  there's an active community developing it.
* ledger-cli won't turn off features I rely on because I haven't paid
  them money recently.  Yes, I'm kind of bitter about that.
* My data isn't held hostage.  While the ledger-cli format is nuanced,
  it's still just plain text.  It's also documented.  I can migrate to
  something else whenever I want.
* Extensibility.  I can write whatever programs I need to update my
  ledger.  The TODO outline includes tasks to replace various
  QuickBooks input forms with prompted input on the command line.

It has some drawbacks, of course:

* No pointy-clicky ease of use.  But if I start to miss this, I know
  enough Gtk+ programming to make something workable.
* No TurboTax integration.  Fortunately for me, Intuit never gave me
  this feature to begin with.  QuickBooks Pro for Mac was never able
  to export tax information to TurboTax Business.

# Operation

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

* Signs on some of the accounts may be wrong.  I need to verify that
  the amounts being used represent the proper directions of credits
  and debits.
* It should be possible to identify account types (Asset, Liability,
  Revenue, Expense, etc.) and categorize them accordingly.  This will
  help with the signage on accounts.
* Add command line flags to omit unneeded fields.  I chose to preserve
  as much of the input data as possible.  The resulting ledger
  probably includes more information than most people need.
* Accounting conventions in my source ledger may differ from those in
  yours.  It may be necessary to change some things to use more
  generally accepted accounting practices.  I'm learning as I'm going.
* The program isn't yet structured for overriding and augmenting
  translation rules.  This limits reusability, but it can be fixed.
* My motivation to maintain this will end when I've converted my last
  ledger across.  Continued development will rely partly on users, who
  I hope will contribute to the project while they need it.
