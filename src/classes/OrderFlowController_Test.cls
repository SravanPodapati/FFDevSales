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
 @isTest(seeAllData=true)
private class OrderFlowController_Test {
    public static void setUpData() {
      //  insert TestData.createCountriesList();
        list < Account > accountList = new list < Account > ();

        ConstantsH__c ch = new ConstantsH__c();
        ch.Acc_and_Contact_owner__c = 'A&N Media';
        ch.Department__c = 'IT';
      //  insert ch;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
        EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

      //  insert u;

     //   insert TestData.createBookingSystemSettings();
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
     //   insert TestData.createCountryCodeSettings();

        //create accounts with different postcodes and account names. 
        //for Advertiser Type
        Account advertiserAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
        advertiserAccount.name = 'Advertiser Account ' + 1;
        advertiserAccount.Phone = '0208426234';
        advertiserAccount.BillingStreet = 'testStreet';
        advertiserAccount.BillingPostalCode = 'ha5 4re';
        advertiserAccount.BillingCountry = 'United Kingdom';
        accountList.add(advertiserAccount);

        insert accountList;
        
        
    }

    static testMethod void defaultValueTest() {
        setUpData();
       // Account testAcc = [SELECT ID from Account limit 1];
        Account testAcc = TestData.buildAccount('Advertiser','Direct Advertiser');
        testAcc.CCIMailCustID__c='123456';
        insert testAcc;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        test.setCurrentPage(Page.OrderProcessingFlow);
        OrderFlowController controller = new OrderFlowController(new ApexPages.StandardController(testAcc));
        Pagereference returnpage = controller.getFlowFinishLocation();
        system.assertNotEquals(returnpage, null);
        test.stopTest();

       
    }

    static testMethod void getFloFinishLocation_Test1() {
        setUpData();
        
        Account acc = TestData.buildAccount('Advertiser','Direct Advertiser');
        acc.CCIMailCustID__c='123456';
        insert acc;
        
        
       // Account acc = [SELECT ID,Name from Account limit 1];
        FinanceAccount__c finAcc= TestData.buildFinanceAccount(acc);
        finAcc.Sop_ID__c='41111';
        finAcc.Sop_Source__c = 'CCI';
        insert finAcc;
        
              
        Opportunity opp = TestData.createOpportunity(acc);
        insert opp;
         Pricebook2 priceBook = 
                [
                Select
                    p.Name
                From Pricebook2 p 
                Where p.Name =: 'Mail Display'
                 and IsActive=true Limit 1
                ];
                
        
        PricebookEntry priceBookEntry = 
                [
                Select 
                    name,
                    Product2Id 
                From PricebookEntry 
                Where pricebook2Id =: priceBook.Id 
                and IsActive=true limit 1
                ];
        

    
        OpportunityLineItem oli = TestData.createOpportunityLineItem(opp);
        oli.Account__c = acc.id;
        oli.priceBookEntryId    =priceBookEntry.Id;
        insert oli;
        
        Order order1 = TestData.createOrder(acc,opp);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        test.setCurrentPage(Page.OrderProcessingFlow);
        OrderFlowController controller = new OrderFlowController(new ApexPages.StandardController(order1));
        Pagereference returnpage = controller.getFlowEditFinishLocation();
        system.assertNotEquals(returnpage, null);
        test.stopTest();
    }

    static testMethod void getFloFinishLocation_Test2() {
        setUpData();
       // Account testAcc = [SELECT ID from Account limit 1];
        Account testAcc = TestData.buildAccount('Advertiser','Direct Advertiser');
        testAcc.CCIMailCustID__c='123457';
        insert testAcc ;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        Pagereference testPage = Page.OrderProcessingFlow;
        testPage.getParameters().put('ID', testAcc.ID);
        test.setCurrentPage(testPage);
        OrderFlowController controller = new OrderFlowController(new ApexPages.StandardController(testAcc));
       /* Map<String,Object> flowMap = new Map<String,Object>();
        //flowMap.put('AccId','12');
        controller.directOrderProcessingFlow = new Flow.Interview.DirectOrderProcessingFlow (flowMap );*/
        Pagereference returnpage = controller.getFlowFinishLocation();
        system.assertNotEquals(returnpage, null);
        test.stopTest();
    }





}