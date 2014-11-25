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
 */@isTest(SeeAllData = true)
private class WebServices_Test {

    private static Pricebook2 stdPricebook;
    private static List < PricebookEntry > stdPBEntries;
    static {
        //standard price book and product prices
        stdPricebook = [select id from Pricebook2 where isStandard = true];
        stdPBEntries = Mock.many('PricebookEntry', new Map < String, Object > { 'UnitPrice' => new Decimal[] {1, 2, 3},'Pricebook2Id' => stdPricebook.Id}, 3, true);
        BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
        if (bSS == null) insert TestData.createBookingSystemSettings();
        if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
            insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
        }
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();        
    }

    static testMethod void returnOrder_test() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.Created_In_CCI_By__c = '';
        insert testOrder;

        test.startTest();
        Order result = WebServices.retrieveOrder(testOrder.ID);
        system.assertEquals(testOrder.CCI_Order_Id__c, result.CCI_Order_ID__c);
        Order result2 = WebServices.retrieveOrder('000000000000000000');
        system.assertEquals(result2, null);
        test.stopTest();

    }

    static testMethod void upsertOrder_test() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        testOrder.Created_In_CCI_By__c = '';
       // insert testOrder;

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
            oI.PricebookEntryId = stdPBEntries[0].id;
        }
      //  insert testOrderItems;
        test.startTest();
        string result = WebServices.upsertOrder(testOrder, testOrderItems);
        boolean hasError = result.toLowerCase().contains('cannot identify the finance account');
        system.assertEquals(true, hasError);
        test.stopTest();
    }

    static testMethod void upsertOrder_test2() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        testOrder.Created_In_CCI_By__c = 'test.test';
        // insert testOrder;

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
           // oI.PricebookEntryId = stdPBEntries[0].id;
        }
      //  insert testOrderItems;
        test.startTest();
        string result = WebServices.upsertOrder(testOrder, testOrderItems);
        boolean hasError = result.toLowerCase().contains('created by user does not exist in glue');
        system.assertEquals(true, hasError);
        test.stopTest();
    }
    
    

    static testMethod void upsertOrder_test3() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        insert testFinanceAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.Created_In_CCI_By__c = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        testOrder.CCI_Account_ID__c = testFinanceAccount.SOP_ID__c;
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        //insert testOrder;

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
            oI.PricebookEntryId = stdPBEntries[0].id;
        }
        //insert testOrderItems;
        test.startTest();
        string result = WebServices.upsertOrder(testOrder, testOrderItems);
        boolean hasError = result.toLowerCase().contains('the customer id is blank');
        system.assertEquals(true, hasError);
        test.stopTest();
    }

    static testMethod void upsertOrder_test4() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        insert testFinanceAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.Created_In_CCI_By__c = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        testOrder.CCI_Account_ID__c = testFinanceAccount.SOP_ID__c;
        testOrder.CCI_Customer_ID__c = testAccount.CCIMailCustID__c + '123';
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        //insert testOrder;

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
            oI.PricebookEntryId = stdPBEntries[0].id;
        }
      //  insert testOrderItems;
        test.startTest();
        string result = WebServices.upsertOrder(testOrder, testOrderItems);
        boolean hasError = result.toLowerCase().contains('cannot locate the customer id');
        system.assertEquals(true, hasError);
        test.stopTest();
    }

    static testMethod void upsertOrder_test5() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        insert testFinanceAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.AccountId = testAccount.Id;
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.Created_In_CCI_By__c = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        testOrder.CCI_Account_ID__c = testFinanceAccount.SOP_ID__c;
        testOrder.CCI_Customer_ID__c = testAccount.CCIMailCustID__c;
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        //insert testOrder;

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
            oI.PricebookEntryId = stdPBEntries[0].id;
        }
      //  insert testOrderItems;
        test.startTest();
        WebServices.upsertOrder(testOrder, testOrderItems);
        test.stopTest();
    }

    static testMethod void upsertOrder_test6() {

        Mock.MOCK_DATA.addSingletonObjectType('Pricebook2');

        Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        insert testFinanceAccount;

        list < Contact > testContacts = (list < Contact > ) Mock.many('Contact', new Map < String, Object > {
            'FirstName' => 'Test', 'LastName' => 'CONTACT000#{COUNTER}',
                'Email' => 'test-person#{COUNTER}@test.com',
                'AccountId' => testAccount.ID
        },
        3, true);
        Order testOrder = (Order) Mock.one('Order');
        system.debug('testOrder' + testOrder);
        testOrder.AccountId = testAccount.Id;
        testOrder.Pricebook2Id = stdPBEntries[0].PriceBook2ID;
        testOrder.Created_In_CCI_By__c = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        testOrder.CCI_Account_ID__c = testFinanceAccount.SOP_ID__c;
        testOrder.CCI_Customer_ID__c = testAccount.CCIMailCustID__c;
        testOrder.AccountId = null;
        testOrder.CurrencyIsoCode = null;
        //insert testOrder; 

        list < OrderItem > testOrderItems = (list < OrderItem > ) Mock.many('OrderItem', 3, false);
        for (OrderItem oI: testOrderItems) {
            oI.OrderId = testOrder.Id;
            oI.PricebookEntryId = stdPBEntries[0].id;
        }
        testOrderItems[0].Quantity = 0;
        testOrderItems[0].UnitPrice = null;
        //insert testOrderItems;
        test.startTest();
        try {
            WebServices.upsertOrder(testOrder, testOrderItems);
        } catch (Exception ex) {
            system.debug('ignoring Exceptions');
        }
        test.stopTest();
    }
    
    
    static testMethod void CreateOrdernItemsFromErroredOrder_test1(){
    
      Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        testAccount.type='Direct Advertiser';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        testFinanceAccount.account__c = testAccount.id;
        insert testFinanceAccount;
        // error scenario where effective date is missing
        ErroredOrder__c eOrder = new ErroredOrder__c();
       // eOrder.Created_In_CCI_By__c = 'DM.CCI';
        eOrder.CCI_Account_Id__c = '123';
        eOrder.CCI_Customer_ID__c = 'TestCCIMailId1';
        eOrder.CCI_Order_ID__c = 'test123';
        eOrder.Created_In_CCI_By__c  = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        insert eOrder;
        ErroredOrderLine__c eOrderLine  = new ErroredOrderLine__c();
        eOrderLine.Package_Code__c = 'DM Default';
        eOrderLine.CCI_Order_Item_ID__c = '1OLI';
        eOrderLine.OrderId__c = eOrder.id;
        insert eOrderLine;
        test.startTest();
        WebServices.CreateOrdernItemsFromErroredOrder(eOrder.id);
        test.stopTest();
        
    
    }
    
    static testMethod void CreateOrdernItemsFromErroredOrder_test2(){
    
      Account testAccount = (Account) Mock.one('Account#Advertiser');
        testAccount.Name = 'TestAccount';
        testAccount.CCIMailCustID__c = 'TestCCIMailId1';
        testAccount.type='Direct Advertiser';
        insert testAccount;

        FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(testAccount);
        testFinanceAccount.name = 'TestFinAcc';
        testFinanceAccount.SOP_ID__c = '123';
        testFinanceAccount.account__c = testAccount.id;
        insert testFinanceAccount;
        
        ErroredOrder__c eOrder = new ErroredOrder__c();
       // eOrder.Created_In_CCI_By__c = 'DM.CCI';
        eOrder.CCI_Account_Id__c = '123';
        eOrder.CCI_Customer_ID__c = 'TestCCIMailId1';
        eOrder.CCI_Order_ID__c = 'test123';
        eOrder.Created_In_CCI_By__c  = [select email from user where id = : UserInfo.getUserId()].email.split('@')[0];
        eOrder.EffectiveDate__c = System.Today();
        insert eOrder;
        ErroredOrderLine__c eOrderLine  = new ErroredOrderLine__c();
        eOrderLine.Package_Code__c = 'DM Default';
        eOrderLine.CCI_Order_Item_ID__c = '1OLI';
        eOrderLine.OrderId__c = eOrder.id;
        insert eOrderLine;
        test.startTest();
        WebServices.CreateOrdernItemsFromErroredOrder(eOrder.id);
        test.stopTest();
        
    
    }
}