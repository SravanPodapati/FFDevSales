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
private class AccountFullSyncController_Test {
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
		//for Advertiser Type

		Account advertiserAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		advertiserAccount.name = 'Advertiser Account ' + 1;
		advertiserAccount.BillingPostalCode = 'xx' + 1 + ' ' + 1 + 'xx';

		insert advertiserAccount;

	}
	static testMethod void defaultValus_test() {
		setUpData();
		test.startTest();
		Account acc = [SELECT ID from Account limit 1];
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(acc));
		test.stopTest();
	}

	static testMethod void cciFullSync_test1() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account testAccount = [SELECT ID, DoCCIInt__c from Account limit 1];
		testAccount.CCIMetroCustID__c = '001234';
		update testAccount;
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(testAccount));
		test.starttest();
		PageReference resultPage = controller.cciFullSync();
		test.stopTest();

	}

	static testMethod void cciFullSync_test2() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account testAccount = [SELECT ID, DoCCIInt__c from Account limit 1];
		testAccount.CCIMetroCustID__c = '001234';
		update testAccount;
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(testAccount));
		User u = [select id from User where Alias = 'anmedia'
		limit 1];
		test.starttest();
		system.runAs(u) {
			PageReference resultPage = controller.cciFullSync();
		}
		test.stopTest();
	}
	static testMethod void cciFullSync_test3() {
		setUpData();

		Account testAccount = [SELECT ID, DoCCIInt__c from Account limit 1];
		testAccount.CCIMetroCustID__c = '001234';
		update testAccount;
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(testAccount));
		User u = [select id from User where Alias = 'anmedia'
		limit 1];
		test.starttest();
		try {
			PageReference resultPage = controller.cciFullSync();
		} catch (exception e) {

		}
		test.stopTest();
	}
	
	static testMethod void flagisalreadyTicked(){
		setUpData();

		Account testAccount = [SELECT ID, DoCCIInt__c from Account limit 1];
		testAccount.DoCCIInt__c = true;
		update testAccount;
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(testAccount));
		User u = [select id from User where Alias = 'anmedia'
		limit 1];
		test.starttest();
		try {
			PageReference resultPage = controller.cciFullSync();
		} catch (exception e) {

		}
		test.stopTest();
		
	}
	
	static testMethod void exceptiontest(){
		setUpData();


		Account testAccount = [SELECT ID, DoCCIInt__c from Account limit 1];
		testAccount.CCIMetroCustID__c = '001234';
		update testAccount;
		AccountFullSyncController controller = new AccountFullSyncController(new Apexpages.Standardcontroller(testAccount));
		controller.currentRecord.BillingPostalCode = '';
		User u = [select id from User where Alias = 'anmedia'
		limit 1];
		test.starttest();
		try {
			PageReference resultPage = controller.cciFullSync();
		} catch (exception e) {

		}
		test.stopTest();
	}

}