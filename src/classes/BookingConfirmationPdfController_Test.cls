/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */@isTest(seeAllData = true)
private class BookingConfirmationPdfController_Test {
    static{
        BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
        if (bSS == null) insert TestData.createBookingSystemSettings();
        if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
            insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
        }
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
    }
    public static void setupData() {
        Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
        acc.CCIMailCustID__c = '12345';
        insert acc;

        Opportunity newOp = TestData.createOpportunity(acc);
        insert newOp;

        PricebookEntry pbe = [select id, PriceBook2ID from PricebookEntry where CurrencyIsoCode = 'GBP'
        limit 1];
        Order order1 = new Order(AccountID = acc.id, EffectiveDate = System.Today(), CCI_Account_ID__c = '1', CurrencyIsoCode = 'GBP',
        Is_Cancelled__c = false, Has_Complaint__c = false, IsReductionOrder = false,
        Is_Accepted__c = true, CCI_Order_ID__c = 'Test123456', Base_Price__c = 50, First_Delivery_Date__c = System.Today(),
        Last_Delivery_Date__c = System.today(), Opportunity__c = newOp.Id, CCI_Customer_ID__c = '1',
        Status = 'Draft', Booking_Source__c = 'CCIBookingPlugin', PriceBook2ID = pbe.PriceBook2ID);
        order1.CCIBookingAgencyId__c = '12345';
        insert order1;


        OrderItem oT1 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item1', PricebookEntryID = pbe.ID);
        OrderItem oT2 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item2', PricebookEntryID = pbe.ID);
        insert oT1;
        insert oT2;
    }

    static testMethod void controllerTest() {
        setupData();
        order testOrder = [select id from order where Is_Accepted__c = true and CCI_Order_ID__c = 'test123456'
        limit 1];
        test.startTest();
        Pagereference testPage = Page.BookingConfirmationPdf;
        testPage.getParameters().put('id', testOrder.ID);
        //set the current page to BookingConfirmationPdf VF 
        test.setCurrentPage(testPage);
        BookingConfirmationPdfController controller = new BookingConfirmationPdfController(new ApexPages.StandardController(TestOrder));

        test.stopTest();


    }

    static testMethod void getBrand_Test() {
        setupData();
        order testOrder = [select id, CCIBookingAgencyId__c from order where Is_Accepted__c = true and CCI_Order_ID__c = 'test123456'
        limit 1];
        test.startTest();
        Pagereference testPage = Page.BookingConfirmationPdf;
        testPage.getParameters().put('id', testOrder.ID);
        //set the current page to BookingConfirmationPdf VF 
        test.setCurrentPage(testPage);
        BookingConfirmationPdfController controller = new BookingConfirmationPdfController(new ApexPages.StandardController(TestOrder));
        BookingConfirmationPdfController.getBrand();
        test.stopTest();
    }

    static testMethod void getBrand_Test2() {
        setupData();
        order testOrder = [select id, CCIBookingAgencyId__c from order where Is_Accepted__c = true and CCI_Order_ID__c = 'test123456'
        limit 1];
        orderItem oT = [SELECT id from OrderItem where OrderId = : testOrder.ID limit 1];
        oT.Publication_Name__c = 'Test Brand 2';
        update oT;
        test.startTest();
        Pagereference testPage = Page.BookingConfirmationPdf;
        testPage.getParameters().put('id', testOrder.ID);
        //set the current page to BookingConfirmationPdf VF 
        test.setCurrentPage(testPage);
        BookingConfirmationPdfController controller = new BookingConfirmationPdfController(new ApexPages.StandardController(TestOrder));
        BookingConfirmationPdfController.getBrand();
        test.stopTest();
    }

    static testMethod void getAgency_Test() {
        setupData();
        order testOrder = [select id from order where Is_Accepted__c = true and CCI_Order_ID__c = 'test123456'
        limit 1];
        test.startTest();
        Pagereference testPage = Page.BookingConfirmationPdf;
        testPage.getParameters().put('id', testOrder.ID);
        //set the current page to BookingConfirmationPdf VF 
        test.setCurrentPage(testPage);
        BookingConfirmationPdfController controller = new BookingConfirmationPdfController(new ApexPages.StandardController(TestOrder));
        BookingConfirmationPdfController.getagency();
        test.stopTest();
    }

    static testMethod void getAgency_Test2() {
        setupData();
        order testOrder = [select id from order where Is_Accepted__c = true and CCI_Order_ID__c = 'test123456'
        limit 1];
        test.startTest();
        Pagereference testPage = Page.BookingConfirmationPdf;
        testPage.getParameters().put('id', testOrder.ID);
        //set the current page to BookingConfirmationPdf VF 
        test.setCurrentPage(testPage);
        BookingConfirmationPdfController controller = new BookingConfirmationPdfController(new ApexPages.StandardController(TestOrder));
        BookingConfirmationPdfController.getagency();
        test.stopTest();
    }
}