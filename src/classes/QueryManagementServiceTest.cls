@isTest(SeeAllData=true)
private class QueryManagementServiceTest
{
    private static c2g__codaInvoice__c s_invoice;
    private static CreditApprover__c s_manager;
    private static CreditApprover__c s_manager2;
    private static CreditApprover__c s_salesPerson;
    private static CreditApprover__c s_salesPerson2;
    private static CreditApprover__c s_approver;
    private static Contact s_contact;

    // Test via the Controller to maximise coverage via CreateQueryController, QueryManagementServiceTest.createQueryFromSalesInvoicId and
    //  QueryManagementServiceTest.populateQueriesFromSalesInvoices.
    // Also covers the Trigger Handler Code for changes to Sales Person.
    static testMethod void testCreateAndUpdateQuery()
    {
        setup();

        // Initialise the Controller and call the Action method
        ApexPages.StandardController stdController = new ApexPages.StandardController(s_invoice);

        CreateQueryController controller = new CreateQueryController(stdController);

        PageReference ref = controller.createQuery();

        // Retrieve the Query and assert the results
        Query__c qry;
        try
        {
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,OrderBillingNotes__c,                 
                        (Select Id, Name, QueryValue__c, LongDescription__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertEquals(s_invoice.ffps_dmg__FinanceAccount__c, qry.FinanceAccount__c);
        System.assertEquals(s_invoice.c2g__Account__c, qry.Client__c);
        System.assertEquals((String)s_invoice.get('ffps_dmgi__Order_Billing_Notes__c'), qry.OrderBillingNotes__c);
        System.assertEquals(s_salesPerson.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager.Id, qry.SalesManager__c);
        System.assertEquals(s_manager.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.BusinessUnit__c, qry.BusinessUnit__c);

        System.assertEquals(s_invoice.c2g__InvoiceLineItems__r.size(), qry.QueryLineItems__r.size());

        // Assert the Allocations
        for (Integer i = 0; i < qry.QueryLineItems__r.size(); i++)
        {
            // get the query row and invoice line by index
            QueryLineItem__c qryLine = qry.QueryLineItems__r[i];
            c2g__codaInvoiceLineItem__c invLine = s_invoice.c2g__InvoiceLineItems__r[i];

            System.assertEquals(0, qryLine.QueryValue__c);
            System.assertEquals((String)invLine.get('ffps_dmgi__LongDescription__c'), qryLine.LongDescription__c);
        }

        // Trigger Test if salesperson changes
        qry.SalesPerson__c = s_salesPerson2.Id;
        update qry;

        // Requery and assert results
        qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                    SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        (Select Id, Name, QueryValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(s_salesPerson2.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson2.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson2.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson2.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager2.Id, qry.SalesManager__c);
        System.assertEquals(s_manager2.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson2.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson2.BusinessUnit__c, qry.BusinessUnit__c);

        qry.SalesPerson__c = null;
        update qry;

        // Requery and assert results
        qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                    SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        (Select Id, Name, QueryValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals(null, qry.SalesPerson__c);
        System.assertEquals(null, qry.SalesPersonEmail__c);
        System.assertEquals(null, qry.SalesSection__c);
        System.assertEquals(null, qry.SalesSectionEmail__c);
        System.assertEquals(null, qry.SalesManager__c);
        System.assertEquals(null, qry.SalesManagerEmail__c);
        System.assertEquals(null, qry.SalesSection__c);
        System.assertEquals(null, qry.BusinessUnit__c);
    }

    /**
     * Test the Allocation applied to the query Lines upon Create
     */
    static testMethod void testQueryAllocationOnCreate()
    {
        setup();

        // Allocate the net value of the Invoice
        Decimal toAllocate = s_invoice.c2g__NetTotal__c;

        // Create a new Query and specifythe Amount to Allocate
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            TotalQueryAmount__c = toAllocate
        );

        insert qry;

        try
        {
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        (Select Id, Name, QueryValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertEquals(s_invoice.ffps_dmg__FinanceAccount__c, qry.FinanceAccount__c);
        System.assertEquals(s_invoice.c2g__Account__c, qry.Client__c);
        System.assertEquals(s_salesPerson.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager.Id, qry.SalesManager__c);
        System.assertEquals(s_manager.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.BusinessUnit__c, qry.BusinessUnit__c);

        System.assertEquals(s_invoice.c2g__InvoiceLineItems__r.size(), qry.QueryLineItems__r.size());

        // Assert the Allocations
        for (Integer i = 0; i < qry.QueryLineItems__r.size(); i++)
        {
            // get the query row and invoice line by index
            QueryLineItem__c qryLine = qry.QueryLineItems__r[i];
            c2g__codaInvoiceLineItem__c invLine = s_invoice.c2g__InvoiceLineItems__r[i];

            System.assertEquals(invLine.c2g__NetValue__c, qryLine.QueryValue__c);
        }
    }

    /**
     * Test the Allocation applied to the query Lines upon Update
     */
    static testMethod void testQueryAllocationOnUpdate()
    {
        setup();

        // Allocate the net value of the Invoice
        Decimal toAllocate = s_invoice.c2g__NetTotal__c;

        // Create a new Query and specifythe Amount to Allocate
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id
        );

        insert qry;

        try
        {
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        (Select Id, Name, QueryValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertEquals(s_invoice.ffps_dmg__FinanceAccount__c, qry.FinanceAccount__c);
        System.assertEquals(s_invoice.c2g__Account__c, qry.Client__c);
        System.assertEquals(s_salesPerson.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager.Id, qry.SalesManager__c);
        System.assertEquals(s_manager.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.BusinessUnit__c, qry.BusinessUnit__c);

        System.assertEquals(s_invoice.c2g__InvoiceLineItems__r.size(), qry.QueryLineItems__r.size());

        // Assert the Allocations
        for (Integer i = 0; i < qry.QueryLineItems__r.size(); i++)
        {
            // get the query row and invoice line by index
            QueryLineItem__c qryLine = qry.QueryLineItems__r[i];

            System.assertEquals(0, qryLine.QueryValue__c);
        }

        // Update the TotalQueryAmount
        qry.TotalQueryAmount__c = toAllocate;
        update qry;

        // Requery and assert results
        qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                    SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        (Select Id, Name, QueryValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                From Query__c
                Where Id = :qry.Id];

        // Assert the Allocations
        for (Integer i = 0; i < qry.QueryLineItems__r.size(); i++)
        {
            // get the query row and invoice line by index
            QueryLineItem__c qryLine = qry.QueryLineItems__r[i];
            c2g__codaInvoiceLineItem__c invLine = s_invoice.c2g__InvoiceLineItems__r[i];

            System.assertEquals(invLine.c2g__NetValue__c, qryLine.QueryValue__c);
        }
    }

    /**
     * Test the Updating of Invoice Document Credit Status upon Create
     */
    static testMethod void testSetDocumentQueryStatusOnCreate()
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
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertEquals(s_invoice.ffps_dmg__FinanceAccount__c, qry.FinanceAccount__c);
        System.assertEquals(s_invoice.c2g__Account__c, qry.Client__c);
        System.assertEquals(s_salesPerson.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager.Id, qry.SalesManager__c);
        System.assertEquals(s_manager.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.BusinessUnit__c, qry.BusinessUnit__c);

        System.assertEquals('Query', qry.SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c);
    }

    /**
     * Test the Updating of Invoice Document Credit Status upon Update
     */
    static testMethod void testSetDocumentQueryStatusOnUpdate()
    {
        setup();

        // Nul the Invoice Document Credit Status
        s_invoice.ffps_dmg__DocumentCreditStatus__c = null;
        update s_invoice;

        // Create a new Query and set the status to Open
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            CustomerContact__c = s_contact.Id
        );

        insert qry;

        try
        {
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                        SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        System.assertEquals(s_invoice.ffps_dmg__FinanceAccount__c, qry.FinanceAccount__c);
        System.assertEquals(s_invoice.c2g__Account__c, qry.Client__c);
        System.assertEquals(s_salesPerson.Id, qry.SalesPerson__c);
        System.assertEquals(s_salesPerson.Email__c, qry.SalesPersonEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.SalesSectionEmail__c, qry.SalesSectionEmail__c);
        System.assertEquals(s_manager.Id, qry.SalesManager__c);
        System.assertEquals(s_manager.Email__c, qry.SalesManagerEmail__c);
        System.assertEquals(s_salesPerson.SalesSection__c, qry.SalesSection__c);
        System.assertEquals(s_salesPerson.BusinessUnit__c, qry.BusinessUnit__c);

        System.assertEquals(null, qry.SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c);

        qry.Status__c = 'Query Denied';
        update qry;

        // Requery and assert results
        qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                    SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                    SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c
                From Query__c
                Where Id = :qry.Id];

        System.assertEquals('Credit Denied', qry.SalesInvoice__r.ffps_dmg__DocumentCreditStatus__c);
    }

    // Test via the Controller to maximise coverage via CreateCreditNoteController, QueryManagementServiceTest.createSalesCreditNote
    static testMethod void testCreateCreditNote()
    {
        setup();

        // Allocate the net value of the Invoice
        Decimal toAllocate = s_invoice.c2g__NetTotal__c;

        // Create a new Query and specifythe Amount to Allocate
        Query__c qry = new Query__c(
            SalesInvoice__c = s_invoice.Id,
            TotalQueryAmount__c = toAllocate
        );

        insert qry;

        // Retrieve the Query and assert the results
        try
        {
            Id invId = s_invoice.Id;
            Id spId = s_salesPerson.Id;

            qry = [Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                        SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,OrderBillingNotes__c,                 
                        (Select Id, Name, QueryValue__c, LongDescription__c, SalesInvoiceLineItem__c, NetValue__c
                         From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                    From Query__c
                    Where SalesInvoice__c = :invId and
                        SalesPerson__c = :spId];

            System.debug('>>> qry=' + qry);
        }
        catch(System.QueryException e)
        {
            System.assert(false, 'Could not find Query. Error=' + e.getMessage());
        }

        // Update the query line item amounts
        Decimal totalAmount = 0;

        for (Integer i = 0; i < qry.QueryLineItems__r.size(); i++)
        {
            // get the query row and invoice line by index
            QueryLineItem__c qryLine = qry.QueryLineItems__r[i];

            qryLine.QueryValue__c = qryLine.NetValue__c;
            totalAmount += qryLine.QueryValue__c;
        }

        update qry.QueryLineItems__r;

        // update some key fields on the Query
        qry.TotalQueryAmount__c = totalAmount;
        qry.CreditApprovalLevel__c = 1000000000;
        qry.CreditControllerApproved__c = true;
        qry.CreditControllerApprovedDate__c = System.today();
        qry.SalesApprover__c = s_approver.Id;
        qry.ApprovingCreditController__c = 'Test';
        qry.Status__c = 'Query Passed';

        update qry;

        // Initialise the Controller and call the Action methods
        ApexPages.StandardController stdController = new ApexPages.StandardController(qry);

        CreateCreditNoteController controller = new CreateCreditNoteController(stdController);

        // 1st Validate
        PageReference ref = controller.validate();

        // Assert no errors
        System.assertEquals(false, controller.HasErrors);

        // Now Create
        controller.CreditNote.c2g__CreditNoteReason__c = 'Goods Returned';
        ref = controller.createCreditNote();

        // Assert we have a valid page ref and an associated Credit note
        System.assertNotEquals(null, ref, ApexPages.getMessages());

        String crdId = ref.getURL().replaceFirst('/', '');

        c2g__codaCreditNote__c[] crdNotes = [Select Id, Name from c2g__codaCreditNote__c where Id = :crdId];
        System.assertEquals(1, crdNotes.size());
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
            CreditApprovalLevel__c = 99999999,
            SalesManager__c = s_manager.Id
        );

        approvers.add(s_salesPerson);

        s_salesPerson2 = new CreditApprover__c(
            Name = 'Sales Person2',
            Email__c = 'test_sales2@financialforce.com',
            SalesSection__c = 'test_section2-2',
            SalesSectionEmail__c = 'test_sales_section2@financialforce.com',
            BusinessUnit__c = 'test_bu2-2',
            CreditApprovalLevel__c = 99999999,
            SalesManager__c = s_manager2.Id
        );

        approvers.add(s_salesPerson2);

        s_approver = new CreditApprover__c(
            Name = 'Approver',
            Email__c = 'test_approver@financialforce.com',
            SalesSection__c = 'test_section3',
            SalesSectionEmail__c = 'test_approver_section@financialforce.com',
            BusinessUnit__c = 'test_bu3',
            CreditApprovalLevel__c = 99999999
        );

        approvers.add(s_approver);

        insert approvers;

        c2g__codaCompany__c cmp = CompanyGateway.getCurrentCompany();
        Id cmpId = cmp.Id;

        // Grab an arbitary Invoice
        String qry = 'Select Id, Name, SalesPerson__c, c2g__Account__c, ffps_dmg__FinanceAccount__c, ffps_dmgi__Order_Billing_Notes__c, ' +
                        'c2g__NetTotal__c, ' +
                        '(Select Id, Name, c2g__NetValue__c from c2g__InvoiceLineItems__r Order By c2g__LineNumber__c) ' +
                     'From c2g__codaInvoice__c Where c2g__OwnerCompany__c = :cmpId Limit 1';

        c2g__codaInvoice__c inv = (c2g__codaInvoice__c)Database.query(qry);
        Id invId = inv.Id;

        // update the Sales Person
        inv.SalesPerson__c = s_salesPerson.Id;

        update inv;

        qry = 'Select Id, Name, SalesPerson__c, c2g__Account__c, ffps_dmg__FinanceAccount__c, ffps_dmgi__Order_Billing_Notes__c, ' +
                'c2g__NetTotal__c, ' +
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