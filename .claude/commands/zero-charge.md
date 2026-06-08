Set the rental PaymentAmount to 0 and uncheck autopay for testing purposes.

In `/Users/ianforsyth/workspace/local/the-storage-center/app/public/wp-content/themes/the-storage-center/page-rental.php`:

1. Change the `PaymentAmount` value from `storedChargeBreakdown.total` to `0` on the line inside the `CreditcardInput` object.
2. Remove the `checked` attribute from the autopay checkbox (`id="input_autopay"`) so it is unchecked by default.

After making the changes, tell the user the charge has been zeroed out and autopay unchecked for testing. Then ask if they'd like to revert it back. If they say yes, change `PaymentAmount` back to `storedChargeBreakdown.total` and add `checked` back to the autopay checkbox.