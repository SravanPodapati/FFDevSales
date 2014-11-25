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
 */
@isTest
private class CCIManager_Test {

    public static Order order1;

    public static String cciGroup
    {
        get;
        set;
    }

    public static String cciProfile
    {
        get;
        set;
    }

    /* static {
        BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
        if (bSS == null) insert TestData.createBookingSystemSettings();

        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        map < String, BookingSystemCountryCodes__c > bSCC = BookingSystemCountryCodes__c.getAll();
        if (bSCC.size() <= 0) insert TestData.createCountryCodeSettings();
    }*/

    public static void setUpData() {

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

        //insert custom settings for BookingSystemSettings
        insert TestData.createBookingSystemSettings();
        //insert categories  
        insert TestData.createCustomerCategory();
      
        insert TestData.createOrderParamSettings();
         insert TestData.createCountryCodeSettings();  

        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        insert TestData.createCountriesList();


        Product2 tmpproduct3 = new Product2();
        tmpproduct3.IsActive = true;
        tmpproduct3.Family = 'Test Family3';
        tmpproduct3.Name = 'Test product3';
        tmpproduct3.CustomerRef__c = 'CustomerRef3';
        tmpproduct3.CurrencyIsoCode = 'GBP';
        insert tmpproduct3;

        list < Account > testAccountsList = new list < Account > ();

        Account clientAccount = TestData.buildAccount('Advertiser', 'Client');
        clientAccount.Name = 'Test Account' + DateTime.now();
        clientAccount.AccountNumber = 'ABC123456';
        clientAccount.Industry = 'Finance';
        clientAccount.BillingCountry = 'United Kingdom';
        clientAccount.BillingPostalCode = 'XX11 4XX';
        testAccountsList.add(clientAccount);

        Account agencyAcount = TestData.buildAccount('Agency', 'Billing Agency');
        agencyAcount.Name = 'Test Agency' + DateTime.now();
        agencyAcount.AccountNumber = 'AGN123456';
        agencyAcount.Type = 'Billing Agency';
        agencyAcount.Industry = 'Finance';
        agencyAcount.BillingStreet = '1';
        agencyAcount.BillingPostalCode = 'XX11 4XX';
        agencyAcount.BillingCountry = 'United Kingdom';
        testAccountsList.add(agencyAcount);

        Account holdingCoAcc = TestData.buildAccount('Advertiser', 'Holding Company');
        holdingCoAcc.name = 'Holding Company';
        holdingCoAcc.CCIMailCustID__c = 'Test123';
        testAccountsList.add(holdingCoAcc);
        Account holdingAgencyAcc = TestData.buildAccount('Agency', 'Holding Agency');
        holdingAgencyAcc.Name = 'Holding Agency';
        holdingAgencyAcc.CCIMailCustID__c = '234';
        testAccountsList.add(holdingAgencyAcc);

        insert testAccountsList;

        Contact cnt = new Contact();
        cnt.AccountId = clientAccount.Id;
        cnt.LastName = 'Test Last Name';
        cnt.FirstName = 'Test First Name';
        cnt.MailingCity = 'Test Mailing City';
        cnt.MailingCountry = 'United Kingdom';
        cnt.MailingPostalCode = 'TestMPC';
        cnt.MailingState = 'Test Mailing State';
        cnt.MailingStreet = 'Test Mailing Street';
        cnt.MailingCountry = 'United Kingdom';
        insert cnt;

        Opportunity testOpp = testData.createOpportunity(clientAccount);
        testOpp.Agency__c = agencyAcount.ID;
        insert testOpp;

        order1 = new Order();
        order1.AccountID = clientAccount.id;
        order1.EffectiveDate = System.Today();
        order1.CCI_Account_ID__c = '1';
        order1.Is_Cancelled__c = false;
        order1.Has_Complaint__c = false;
        order1.IsReductionOrder = false;
        order1.Is_Accepted__c = true;
        order1.CCI_Order_ID__c = 'test123456';
        order1.Base_Price__c = 50;
        order1.First_Delivery_Date__c = System.Today();
        order1.Last_Delivery_Date__c = System.today();
        order1.Opportunity__c = testOpp.Id;
        order1.CCI_Customer_ID__c = '1';
        order1.Status = 'Draft';
        order1.Booking_Source__c = 'CCIBookingPlugin';
        insert order1;
    }


    static testMethod void createDirectAccountOrder_Test() {
        setUpData();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account clientAccount = [SELECT ID, name from Account where Type = 'Client'
        limit 1];
        Account AgencyAccount = [SELECT ID, name from Account where Type = 'Billing Agency'
        limit 1];
        Account HoldingAccount = [SELECT ID, CCIMailCustID__c, name from Account where Type = 'Holding Company'
        limit 1];
        Account HoldingAgency = [SELECT ID, CCIMailCustID__c, name from Account where Type = 'Holding Agency'
        limit 1];
        clientAccount.parentID = AgencyAccount.id;
        update clientAccount;

        test.startTest();
        string result = CCIManager.createDirectAccountOrder(clientAccount.ID, AgencyAccount.ID, 'sopId', 'cciCustomerId', 'bookingAgency', 'bookingcciId', 'parentcciId', HoldingAccount.CCIMailCustID__c, HoldingAgency.CCIMailCustID__c,'System Administrator','Systems Support');
        test.stopTest();
    }

    static testMethod void editAccountOrder_Test() {

        setUpData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Order testOrder = [SELECT ID, CCI_Order_ID__c from Order where id = : Order1.ID];
        test.startTest();
        CCIManager.editAccountOrder(testOrder.id, 'System Administrator','Systems Support');
        test.stopTest();

    }
}