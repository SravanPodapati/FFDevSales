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
 */@isTest
private class EmailController_Test {

    public static ID orderNumber;

    public static void setUpData() {
        insert TestData.createCountriesList();
        ConstantsH__c ch = new ConstantsH__c();
        ch.Acc_and_Contact_owner__c = 'A&N Media';
        ch.Department__c = 'IT';
        insert ch;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
        EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

        insert u;
        insert TestData.createBookingSystemSettings();
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        insert TestData.createCountryCodeSettings();
        //create accounts with different postcodes and account names. 
        Account testAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
        testAccount.name = 'Advertiser Account ' + 1;
        testAccount.BillingPostalCode = 'xx1 1xx';
        insert testAccount;
        Contact contact  = new Contact(Firstname='Test',lastName='contact',Phone='004412345678',Email='test.contact@email.com');
        insert contact;

        Opportunity testOpp = TestData.createOpportunity(testAccount);
        insert testOpp;

        Order testOrder = TestData.createOrder(testAccount, testOpp);
        insert testOrder;

        orderNumber = testOrder.OrderNumber;

        Order testOrder2 = [select id, OrderNumber from Order limit 1];
    }

    static testMethod void defaultValues_Test() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));

        system.assertEquals(controller.address, null);
        system.assertEquals(controller.cc, null);
        system.assertEquals(controller.bcc, null);
        system.assertNotEquals(controller.body, null);
        system.assertEquals(controller.parentId, testOrder.Id);
        system.assertNOTEquals(controller.orderAttachment, null);
        system.assertEquals(controller.order.id, testOrder.Id);
        system.assertEquals(controller.attachmentExists, true);
        system.assertEquals(controller.attachmentUrl, '/apex/BookingConfirmationPdf?id={!parentID}');

        test.stopTest();
    }

    static testMethod void remove_Test() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));

        controller.remove();
        system.assertEquals(controller.attachmentExists, false);
        system.assertEquals(controller.orderAttachment, null);
        test.stopTest();

    }

    static testMethod void view_Test() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));

        Pagereference resultPage = controller.view();

        system.assert(resultPage.getUrl().contains('orderId'));
        system.assertEquals(resultPage.getRedirect(), true);
        test.stopTest();
    }

    static testMethod void cancel_Test() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));

        Pagereference resultPage = controller.cancel();

        system.assert(resultPage.getUrl().contains(controller.parentID));
        system.assertEquals(resultPage.getRedirect(), true);
        test.stopTest();
    }

    static testmethod void send_ExceptionTest() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));
        try {
            controller.send();
        } catch (Exception e) {
            boolean toFieldExceptionThrown = e.getMessage().contains(system.Label.To_Field_exception) ? true : false;
            boolean subjectFieldExceptionThrown = e.getMessage().contains(system.Label.Subject_Field_exception) ? true : false;

            system.assertEquals(toFieldExceptionThrown, true);
            system.assertEquals(subjectFieldExceptionThrown, true);
        }
        test.stopTest();
    }

    static testmethod void send_SuccessTest() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));
        try {
            controller.address = 'test.test@test.com';
            controller.subject = 'test email';
            controller.send();
            system.assertEquals(Limits.getEmailInvocations(), 1);
        } catch (Exception e) {

        }
        test.stopTest();
    }

    static testmethod void send_Success_BCC_CCTest() {
        setUpData();
        test.startTest();
        Order testOrder = [select id, OrderNumber from Order limit 1];
        //set the current page to AccountSearchScreen VF 
        Pagereference testPage = Page.CustomEmail;
        testPage.getParameters().put('orderNo', testOrder.OrderNumber);
        test.setCurrentPage(testPage);
        EmailController controller = new EmailController(new ApexPages.StandardController(testOrder));
        try {
            controller.address = 'test.test@test.com';
            controller.cc = 'test.test@test.com';
            controller.bcc = 'test.test@test.com';
            controller.subject = 'test email';
            controller.send();
            system.assertEquals(Limits.getEmailInvocations(), 1);
        } catch (Exception e) {

        }
        test.stopTest();
    }
}