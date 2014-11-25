trigger SetAccountDefaults on Account (before insert, before update)
{
    // check if the defaulting is active and bail if not
    Accounting_Defaults__c defaults = Accounting_Defaults__c.getInstance();
    if( defaults == null )
    {
        return;
    }
    
    // get our various lookups
    Id accPayable = null;
    Id accRec = null;
    Id inputVat = null;
    Id outputVat = null;
    Id FinanceContact = null;
    Id LastContact = null;
    String LastcontactEmail = null;
    
    
// firstly look up our GLAs
    Set<String> glas = new Set<String>();
    if( defaults.Accounts_Payable_Control__c != null )
    {
        glas.add( defaults.Accounts_Payable_Control__c );
    }
    if( defaults.Accounts_Receivable_Control__c != null )
    {
        glas.add( defaults.Accounts_Receivable_Control__c );
    }
    
    if( glas.size() > 0 )
    {
        for( c2g__codaGeneralLedgerAccount__c gla : [Select Id,Name from c2g__codaGeneralLedgerAccount__c where Name in :glas] )
        {
            if( defaults.Accounts_Payable_Control__c != null )
            {
                if( gla.Name == defaults.Accounts_Payable_Control__c )
                {
                    accPayable = gla.Id;
                }
            }
            if( defaults.Accounts_Receivable_Control__c != null )
            {
                if( gla.Name == defaults.Accounts_Receivable_Control__c )
                {
                    accRec = gla.Id;
                }
            }
        }
    }
    
// secondly look up the tax codes
    Set<String> taxCodes = new Set<String>();
    if( defaults.Input_VAT_Code__c != null )
    {
        taxCodes.add( defaults.Input_VAT_Code__c );
    }
    if( defaults.Output_VAT_Code__c != null )
    {
        taxCodes.add( defaults.Output_VAT_Code__c );
    }
    
    if( taxCodes.size() > 0 )
    {
        for( c2g__codaTaxCode__c code : [Select Id,Name from c2g__codaTaxCode__c where Name in :taxCodes] )
        {
            if( defaults.Input_VAT_Code__c != null )
            {
                if( code.Name == defaults.Input_VAT_Code__c )
                {
                    inputVat = code.Id;
                }
                if( code.Name == defaults.Output_VAT_Code__c )
                {
                    outputVat = code.Id;
                }
            }
            if( defaults.Output_VAT_Code__c != null )
            {
                taxCodes.add( defaults.Output_VAT_Code__c );
            }
        }
    }
    
    // Third look up the Finance Contact Name
    Set<String> FinanceContacts = new Set<String>();
    if( defaults.Finance_Contact__c != null )
    {
        FinanceContacts.add( defaults.Finance_Contact__c );
    }
        
    if( FinanceContacts.size() > 0 )
    {
        for( contact contactlist : [Select Id,Name from Contact where Name in :FinanceContacts] )
        {
            if( defaults.Finance_Contact__c != null )
            {
                if( contactlist.Name == defaults.Finance_Contact__c )
                {
                    FinanceContact = contactlist.Id;
                }

            }
        }
    }

// Fourth look up Find Last Contact
    Set<Id> accountIds = new Set<Id>();
    for (Account a : trigger.new) 
    {
        accountIds.add(a.Id);
    }
    if( defaults.Use_Last_Contact__c == True )
    {
        List<Contact> contacts = [Select Id, Email from Contact where Account.Id in :accountIds ORDER BY LastModifiedDate DESC LIMIT 1];
        if( contacts.size() > 0 )
        {
            LastContact = contacts[0].Id;
            LastContactEmail = contacts[0].Email;
        }
    }


// now update each account with the resolved defaults
    for( Account acc : trigger.new )
    {
        if( acc.c2g__CODAAccountsPayableControl__c == null )
            acc.c2g__CODAAccountsPayableControl__c = accPayable;
        
        if( acc.c2g__CODAAccountsReceivableControl__c == null )
            acc.c2g__CODAAccountsReceivableControl__c = accRec;
            
        if( acc.c2g__CODABaseDate1__c == null )
            acc.c2g__CODABaseDate1__c = defaults.Base_Date_1__c;
            
        if( acc.c2g__CODABillingMethod__c == null )
            acc.c2g__CODABillingMethod__c = defaults.Billing_Method__c;
            
        if( acc.c2g__CODAInputVATCode__c == null )
            acc.c2g__CODAInputVATCode__c = inputVat;
            
        if( acc.c2g__CODAOutputVATCode__c == null )
            acc.c2g__CODAOutputVATCode__c = outputVat;
            
        if( acc.c2g__CODAPaymentMethod__c == null )
            acc.c2g__CODAPaymentMethod__c = defaults.Payment_Method__c;
            
        if( acc.c2g__CODATaxCalculationMethod__c == null )
            acc.c2g__CODATaxCalculationMethod__c = defaults.Tax_Calculation_Method__c;
            
        if( acc.c2g__CODAVATStatus__c == null )
            acc.c2g__CODAVATStatus__c = defaults.Tax_Status__c;

        if( acc.c2g__CODAECCountryCode__c == null )
            acc.c2g__CODAECCountryCode__c = defaults.EC_Country__c;
    
        if( acc.c2g__CODAFinanceContact__c == null )
            acc.c2g__CODAFinanceContact__c = FinanceContact;

        if( acc.c2g__CODAInvoiceEmail__c == null )
            acc.c2g__CODAInvoiceEmail__c = defaults.Invoice_Email__c;

        if( defaults.Use_Last_Contact__c == True )
            acc.c2g__CODAFinanceContact__c = LastContact;
        
        if( defaults.Use_Last_Contact__c == True )
            acc.c2g__CODAInvoiceEmail__c = LastContactEmail;


    }

}