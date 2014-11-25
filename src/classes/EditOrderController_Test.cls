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
private class EditOrderController_Test {
	public static void setupData() {
		insert TestData.createCountriesList();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com', EmailEncodingKey = 'UTF-8',
		FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
		ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		//insert custom settings for BookingSystemSettings
		insert TestData.createBookingSystemSettings();
		insert TestData.createOrderParamSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		insert acc;

		Opportunity newOp = TestData.createOpportunity(acc);
		insert newOp;
		Order order1 = new Order(AccountID = acc.id, EffectiveDate = System.Today(), CCI_Account_ID__c = '1',
		Is_Cancelled__c = false, Has_Complaint__c = false, IsReductionOrder = false,
		Is_Accepted__c = true, CCI_Order_ID__c = '123456', Base_Price__c = 50, First_Delivery_Date__c = System.Today(),
		Last_Delivery_Date__c = System.today(), Opportunity__c = newOp.Id, CCI_Customer_ID__c = '1',
		Status = 'Draft', Booking_Source__c = 'CCIBookingPlugin');
		insert order1;
	}

	static testmethod void defaultValue_Test() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Order testOrder = [select ID from Order limit 1];
		test.startTest();
		Pagereference testPage = Page.EditOrderPage;
		testPage.getParameters().put('id', testOrder.Id);
		EditOrderController controller = new EditOrderController(new Apexpages.Standardcontroller(testOrder));
		Test.setCurrentPage(testPage);
		system.assertNotEquals(controller.Order, null);
		test.stopTest();
	}

	static testMethod void editOrderException_test() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Order testOrder = [select ID from Order limit 1];
		test.startTest();
		Pagereference testPage = Page.EditOrderPage;
		testPage.getParameters().put('id', testOrder.Id);
		EditOrderController controller = new EditOrderController(new Apexpages.Standardcontroller(testOrder));
		Test.setCurrentPage(testPage);
		try {
			controller.editOrder();
		} catch (Exception e) {

			boolean expectedException = e.getMessage().contains('Label.CCI_Exception') ? true : false;
			system.assertEquals(expectedException, true);
			system.assertEquals(controller.renderPlugin, false);
			system.assertEquals(controller.renderError, true);
		}

		test.stopTest();
	}

	static testMethod void editOrderSuccess_test() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Order testOrder = [select ID from Order limit 1];
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Pagereference testPage = Page.EditOrderPage;
		testPage.getParameters().put('id', testOrder.Id);
		EditOrderController controller = new EditOrderController(new Apexpages.Standardcontroller(testOrder));
		Test.setCurrentPage(testPage);
		controller.editOrder();
		test.stopTest();
	}

}