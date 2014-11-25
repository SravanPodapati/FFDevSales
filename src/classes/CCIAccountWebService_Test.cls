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
public class CCIAccountWebService_Test {
	public static FinanceAccount__c finAcc;
	public static FinanceAccount__c finAcc2;

	public static void setUpData() {
		insert TestData.createCountriesList();
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com', EmailEncodingKey = 'UTF-8', FirstName = 'A&N',
		LastName = 'Media', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		//insert custom settings for BookingSystemSettings


		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		acc.CCIMailCustID__c = '1';
		insert acc;
		Account acc2 = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc2.Name = 'Account2';
		insert acc2;

		finAcc = TestData.buildFinanceAccount(acc);
		finAcc2 = TestData.buildMetroFinanceAccount(acc2);
		finAcc2.SOP_Source__c = 'CCI';
		finAcc2.SOP_ID__c = '123';
		insert finAcc;
		insert finAcc2;

	}
	public static void setUpBookingSettings() {


		insert TestData.createBookingSystemSettings();

	}
	public static void setUpBookingSettings1() {


		insert TestData.createIncompleteBookingSystemSettings1();

	}
	public static void setUpBookingSettings2() {


		insert TestData.createIncompleteBookingSystemSettings2();

	}

	// Not a direct order 
	static testmethod void testCreateCCIAccount_Test() {
		setUpData();
		setUpBookingSettings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String errorResponse = CCIAccountWebService.createCCIAccount(finAcc.id, false);
		System.assertEquals(null, errorResponse);
		Test.stopTest();
	}


	static testmethod void testCreateCCIAccount_TestWoBookingSettings() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String errorResponse = CCIAccountWebService.createCCIAccount(finAcc.id, false);
		//System.assertNotEquals(null,errorResponse);
		Test.stopTest();
	}

	static testmethod void testCreateCCIAccount_TestWithIncompleteBookingSettings1() {
		setUpData();
		setUpBookingSettings1();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String errorResponse = CCIAccountWebService.createCCIAccount(finAcc.id, false);
		//System.assertNotEquals(null,errorResponse);
		Test.stopTest();
	}
	static testmethod void testCreateCCIAccount_TestWithIncompleteBookingSettings2() {
		setUpData();
		setUpBookingSettings2();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String errorResponse = CCIAccountWebService.createCCIAccount(finAcc.id, false);
		//System.assertNotEquals(null,errorResponse);
		Test.stopTest();
	}



	static testmethod void testCreateCCIAccountFromOrder() {
		setUpData();
		setUpBookingSettings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		CCIAccountWebService.createCCIAccountFromOrder(finAcc.id);
		Test.stopTest();
	}

	// Not a direct order 
	static testmethod void testCreateCCIAccountValidations() {
		setUpData();
		setUpBookingSettings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String errorResponse = CCIAccountWebService.createCCIAccount(finAcc2.id, false);
		System.assertNotEquals(null, errorResponse);
		Test.stopTest();
	}

	static testmethod void testCreateFutureCCIAccount() {
		setUpData();
		setUpBookingSettings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		CCIAccountWebService.createFutureCCIAccount(finAcc.id, true);
		Test.stopTest();
	}


	public static FinanceAccount__c queryFinAccount(Id accId) {
		return ([select Id, SOP_ID__c, SOP_Source__c from FinanceAccount__c where Id = : accId]);
	}
}