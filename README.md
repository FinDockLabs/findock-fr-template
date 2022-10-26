# findock-fr-template

Findock component for Partner Solutions (DO NOT use on customer orgs)

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.

Evaluate https://cumulusci.readthedocs.io/en/stable/tasks.html#install-managed for Dynamic invokation


## Todo
   DESIGN REVIEW Pierre Marie
   Accepting Payment
    - Giving Page
    - Phone
    - TBD

   Processing Payment
    - Recuring Direct Debit / Via Payment schedule (SEPA)
    - Credit Card

   Reconciling Payment
   https://docs.findock.com/collecting-payments-with-findock
   

Manual Post install Step


Specs
we usually demo something like this: https://www.youtube.com/watch?v=GwiJB0Zan5o&t=32s
This roughly covers:
accepting a new SEPA DD payment through a Giving page (could also be API with custom front-end)
processing the recurring payment with a Payment Schedule. Including how to automatically generate payment schedules with a Recurring payment schedule
reconciling the SEPA DD with a pain.002 file (customers also often use CAMT files for this, but this is more direct)
following up on the failed payment with an email containing a paylink to recover the failed donation money
Let me know if you have any questions and in case you also want up to set up a Credit Card flow for demos for instance



Question:
- NPSP mapping from RD / Opp is their any additional mapping to be done?
- New RD Findock postion - use NPSP internal form? or use the std page layout?


