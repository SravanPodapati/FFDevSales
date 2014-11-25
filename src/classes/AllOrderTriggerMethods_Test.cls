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
private class AllOrderTriggerMethods_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static Account acc;
	static list < Account_Mapping__c > mappingList;
	static PricebookEntry pbe;
	static Opportunity newOpp;
	static list < OpportunityLineItem > oLIList;
	static Order order1;
	static list<OrderItem> insertOrderItems;
	static {
		acc = TestData.buildAccount('Agency', 'Billing Agency');
		acc.CCIMailCustID__c = 'test1234';
		insert acc;

		system.debug('Record Type of Account is : ' + [SELECT ID, RecordType.Name from Account where ID = : acc.ID].RecordType.Name);

		mappingList = TestData.buildAccountMaping(acc.ID, acc.CCIMailCustID__c, acc.CCIMetroCustID__c);
		insert mappingList;

		pbe = [select id, Product2Id, PriceBook2ID from PricebookEntry where CurrencyIsoCode = 'GBP'
		and IsActive = true limit 1];

		newOpp = TestData.createOpportunity(acc);
		insert newOpp;

		oLIList = new list < OpportunityLineItem > ();
		oLIList.add(new OpportunityLineItem(PricebookEntryId = pbe.id, Description = 'Test Description', UnitPrice = 1000,
		Quantity = 1, Brand__c = 'Special Brand', Color_Specification__c = 'Color', Region__c = 'National',
		Size__c = '24x4', Position__c = 'Front Page', OpportunityID = newOpp.Id, Last_Insertion_Date__c = Date.today()));

		oLIList.add(new OpportunityLineItem(PricebookEntryId = pbe.id, Description = 'Test Description', UnitPrice = 1000,
		Quantity = 1, Brand__c = 'Special Brand', Color_Specification__c = 'Color', Region__c = 'National',
		Size__c = '24x4', Position__c = 'Front Page', OpportunityID = newOpp.Id, Last_Insertion_Date__c = Date.today()));
		insert oLIList;

	}

	static testMethod void onBeforeInsert_Test() {
		test.startTest();

		order1 = new Order(AccountID = acc.id, EffectiveDate = System.Today(), CCI_Account_ID__c = acc.CCIMailCustID__c, CurrencyIsoCode = 'GBP',
		Is_Cancelled__c = false, Has_Complaint__c = false, IsReductionOrder = false,
		Is_Accepted__c = true, CCI_Order_ID__c = 'Test123456', Base_Price__c = 50, First_Delivery_Date__c = System.Today(),
		Last_Delivery_Date__c = System.today(), CCI_Customer_ID__c = acc.CCIMailCustID__c,
		Status = 'Draft', Booking_Source__c = 'CCIBookingPlugin',
		Opportunity__c = newOpp.Id, PriceBook2ID = pbe.PriceBook2ID);
		insert order1;

		insertOrderItems = new list<OrderItem>();
		OrderItem oT1 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item1', PricebookEntryID = pbe.ID);
		insertOrderItems.add(oT1);
		OrderItem oT2 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item2', PricebookEntryID = pbe.ID);
		insertOrderItems.add(oT2);
		insert insertOrderItems;


		Order testOrder = [SELECT ID, CCI_Account_ID__c, Agency__c from Order where CCI_Account_ID__c = 'test1234'
		limit 1];
		system.assertNOTEquals(testOrder.Agency__c, null);
		test.stopTest();

	}

	static testMethod void onAfterUpdate_Test() {
		test.startTest();

		order1 = new Order(AccountID = acc.id, EffectiveDate = System.Today(), CCI_Account_ID__c = acc.CCIMailCustID__c, CurrencyIsoCode = 'GBP',
		Is_Cancelled__c = false, Has_Complaint__c = false, IsReductionOrder = false,
		Is_Accepted__c = true, CCI_Order_ID__c = 'Test123456', Base_Price__c = 50, First_Delivery_Date__c = System.Today(),
		Last_Delivery_Date__c = System.today(), CCI_Customer_ID__c = acc.CCIMailCustID__c,
		Status = 'Draft', Booking_Source__c = 'CCIBookingPlugin',
		Opportunity__c = newOpp.Id, PriceBook2ID = pbe.PriceBook2ID);
		insert order1;

		insertOrderItems = new list<OrderItem>();
		OrderItem oT1 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item1', PricebookEntryID = pbe.ID);
		insertOrderItems.add(oT1);
		OrderItem oT2 = new OrderItem(Publication_Name__c = 'test brand', OrderID = order1.Id, UnitPrice = 100, Quantity = 1, CCI_Order_Item_ID__c = 'Item2', PricebookEntryID = pbe.ID);
		insertOrderItems.add(oT2);
		insert insertOrderItems;


		Order testOrder = [SELECT ID, Status, CCI_Account_ID__c, Agency__c from Order where CCI_Account_ID__c = 'test1234'
		limit 1];
		system.assertNOTEquals(testOrder.Agency__c, null);
		testOrder.Status = 'Activated';
		update testOrder;
		test.stopTest();

	}
}