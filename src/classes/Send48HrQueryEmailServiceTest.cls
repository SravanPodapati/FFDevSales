@isTest(SeeAllData=true)
private class Send48HrQueryEmailServiceTest
{
    private static c2g__codaInvoice__c s_invoice;
    private static CreditApprover__c s_manager;
    private static CreditApprover__c s_manager2;
    private static CreditApprover__c s_salesPerson;
    private static CreditApprover__c s_salesPerson2;
    private static CreditApprover__c s_approver;
    private static Contact s_contact;

    /**
     * Test the updateing of the Send48HrEmail field simulated on a Monday
     */
    static testMethod void test48HrFromMonday()
    {
        setup();

        // Nul the Invoice Document Credit Status
        s_invoice.ffps_dmg__DocumentCreditStatus__c = null;
        update s_invoice;

        // Create a new Query and set the status to Open
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            Status__c = 'Open',
            CustomerContact__c = s_contact.Id
        );

        insert qry;

        try
        {
            qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                    From Query__c
                    Where Id = :qry.Id];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertNotEquals(null, qry.DateOpened__c);
        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Test Date to Monday 30th June 1913 15:31:00
        Send48HrQueryEmailService.s_testDate = DateTime.newInstance(1913, 6, 30, 15, 31, 0);

        // Set the Date Opened to Friday 27th June 1913 15:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 6, 27, 15, 30, 0);
        update qry;

        // Initialise and execute the Service
        Send48HrQueryEmailService svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Date Opened to Thursday 26th June 1913 15:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 6, 26, 15, 30, 0);
        update qry;

        // Initialise and execute the Service
        svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(true, qry.Send48HrEmail__c);
    }

    /**
     * Test the updateing of the Send48HrEmail field simulated on a Tuesday
     */
    static testMethod void test48HrFromTuesday()
    {
        setup();

        // Nul the Invoice Document Credit Status
        s_invoice.ffps_dmg__DocumentCreditStatus__c = null;
        update s_invoice;

        // Create a new Query and set the status to Open
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            Status__c = 'Open',
            CustomerContact__c = s_contact.Id
        );

        insert qry;

        try
        {
            qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                    From Query__c
                    Where Id = :qry.Id];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertNotEquals(null, qry.DateOpened__c);
        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Test Date to Tuesday 1st July 1913 15:31:00
        Send48HrQueryEmailService.s_testDate = DateTime.newInstance(1913, 7, 1, 15, 31, 0);

        // Set the Date Opened to Friday 27th June 1913 16:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 6, 27, 16, 30, 0);
        update qry;

        // Initialise and execute the Service
        Send48HrQueryEmailService svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Date Opened to Friday 27th June 1913 15:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 6, 27, 15, 30, 0);
        update qry;

        // Initialise and execute the Service
        svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(true, qry.Send48HrEmail__c);
    }

    /**
     * Test the updateing of the Send48HrEmail field simulated on a Monday
     */
    static testMethod void test48HrFromWednesday()
    {
        setup();

        // Nul the Invoice Document Credit Status
        s_invoice.ffps_dmg__DocumentCreditStatus__c = null;
        update s_invoice;

        // Create a new Query and set the status to Open
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            Status__c = 'Open',
            CustomerContact__c = s_contact.Id
        );

        insert qry;

        try
        {
            qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                    From Query__c
                    Where Id = :qry.Id];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertNotEquals(null, qry.DateOpened__c);
        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Test Date to Wednesday 2nd July 1913 15:31:00
        Send48HrQueryEmailService.s_testDate = DateTime.newInstance(1913, 7, 2, 15, 31, 0);

        // Set the Date Opened to Tuesday 1st July 1913 15:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 7, 1, 15, 30, 0);
        update qry;

        // Initialise and execute the Service
        Send48HrQueryEmailService svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(false, qry.Send48HrEmail__c);

        // Set the Date Opened to Monday 30th June 1913 15:30:00
        qry.DateOpened__c = DateTime.newInstance(1913, 6, 30, 15, 30, 0);
        update qry;

        // Initialise and execute the Service
        svc = new Send48HrQueryEmailService();
        svc.execute(null);

        // Requery and assert the Send48HrEmail Flag
        qry = [Select Id, Name, DateOpened__c, Send48HrEmail__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(true, qry.Send48HrEmail__c);
    }

    private static void setup()
    {
        // Create the Credit Approvers
        List<CreditApprover__c> managers = new List<CreditApprover__c>();

        s_manager = new CreditApprover__c(
            Name = 'Manager',
            Email__c = 'test_manager@financialforce.com',
            SalesSection__c = 'test_section1',
            SalesSectionEmail__c = 'test_manager_section@financialforce.com',
            BusinessUnit__c = 'test_bu1',
            CreditApprovalLevel__c = 99999
        );

        managers.add(s_manager);

        s_manager2 = new CreditApprover__c(
            Name = 'Manager2',
            Email__c = 'test_manager2@financialforce.com',
            SalesSection__c = 'test_section1-2',
            SalesSectionEmail__c = 'test_manager_section2@financialforce.com',
            BusinessUnit__c = 'test_bu1-2',
            CreditApprovalLevel__c = 99999
        );

        managers.add(s_manager2);

        insert managers;

        List<CreditApprover__c> approvers = new List<CreditApprover__c>();

        s_salesPerson = new CreditApprover__c(
            Name = 'Sales Person',
            Email__c = 'test_sales@financialforce.com',
            SalesSection__c = 'test_section2',
            SalesSectionEmail__c = 'test_sales_section@financialforce.com',
            BusinessUnit__c = 'test_bu2',
            CreditApprovalLevel__c = 99999,
            SalesManager__c = s_manager.Id
        );

        approvers.add(s_salesPerson);

        s_salesPerson2 = new CreditApprover__c(
            Name = 'Sales Person2',
            Email__c = 'test_sales2@financialforce.com',
            SalesSection__c = 'test_section2-2',
            SalesSectionEmail__c = 'test_sales_section2@financialforce.com',
            BusinessUnit__c = 'test_bu2-2',
            CreditApprovalLevel__c = 99999,
            SalesManager__c = s_manager2.Id
        );

        approvers.add(s_salesPerson2);

        s_approver = new CreditApprover__c(
            Name = 'Approver',
            Email__c = 'test_approver@financialforce.com',
            SalesSection__c = 'test_section3',
            SalesSectionEmail__c = 'test_approver_section@financialforce.com',
            BusinessUnit__c = 'test_bu3',
            CreditApprovalLevel__c = 99999
        );

        approvers.add(s_approver);

        insert approvers;

        // Grab an arbitary Invoice
        String qry = 'Select Id, Name, SalesPerson__c, c2g__Account__c, ffps_dmg__FinanceAccount__c, ffps_dmgi__Order_Billing_Notes__c, ' +
                        '(Select Id, Name, c2g__NetValue__c from c2g__InvoiceLineItems__r Order By c2g__LineNumber__c) ' +
                     'From c2g__codaInvoice__c Limit 1';

        c2g__codaInvoice__c inv = (c2g__codaInvoice__c)Database.query(qry);
        Id invId = inv.Id;

        // update the Sales Person
        inv.SalesPerson__c = s_salesPerson.Id;

        update inv;

        qry = 'Select Id, Name, SalesPerson__c, c2g__Account__c, ffps_dmg__FinanceAccount__c, ffps_dmgi__Order_Billing_Notes__c, ' +
                '(Select Id, Name, c2g__NetValue__c, ffps_dmgi__LongDescription__c ' +
                    'from c2g__InvoiceLineItems__r Order By c2g__LineNumber__c) ' +
              'From c2g__codaInvoice__c ' +
              'Where Id = :invId';
        
        inv = (c2g__codaInvoice__c)Database.query(qry);

        System.assertNotEquals(null, inv.SalesPerson__c);
        System.assertEquals(s_salesPerson.Id, inv.SalesPerson__c);

        s_invoice = inv;

        // Grab an arbitary Contact
        //s_contact = [Select Id, Name From Contact Limit 1];
        Contact c = new Contact(
            FirstName = 'My Test Contact', 
            LastName = 'My Test Contact', 
            Email = 'test_contact@financialforce.com', 
            AccountId = inv.c2g__Account__c
        );

        insert c;

        s_contact = [Select Id, Name From Contact Where Id = :c.Id];

        // Apply contact to finance account (if not set)
        ffps_dmg__FinanceAccount__c fa = [Select Id, ffps_dmg__DocumentDestinationContact__c From ffps_dmg__FinanceAccount__c Where Id = :inv.ffps_dmg__FinanceAccount__c];

        if (fa.ffps_dmg__DocumentDestinationContact__c == null)
        {
            fa.ffps_dmg__DocumentDestinationContact__c = s_contact.Id;
            update fa;
        }
    }
}