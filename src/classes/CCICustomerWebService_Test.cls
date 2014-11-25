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
public class CCICustomerWebService_Test {
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

		//insert custom settings for BookingSystemSettings
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

		//insert categories  
		insert TestData.createCustomerCategory();

	}
	private static testMethod void testcreateCCICustomerMailWithoutCategory() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;

		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', false);
		System.debug('Response is' + response);

		System.assertNotEquals(null, response);
		Test.stopTest();

	}

	/**/
	private static testMethod void testcreateCCICustomerMailWithCategory() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		insert acc;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', false);
		System.debug('Response is' + response);
		System.assertEquals(null, response);
		Account accUpdated = queryAccount(acc.id);
		System.assertEquals('1', accUpdated.CCIMailCustID__c);
		Test.stopTest();
	}
	/**/
	private static testMethod void testcreateCCICustomerMetroWithCategory() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		insert acc;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Metro', false);
		System.debug('Response is' + response);
		//System.assertEquals(null,response );
		Account accUpdated = queryAccount(acc.id);
		System.assertEquals('1', accUpdated.CCIMetroCustID__c);
		Test.stopTest();
	}
	/**/
	private static testMethod void testcreateCCICustomerMailWithDirectOrder() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', true);
		System.debug('Response is' + response);
		//System.assertNotEquals(null,response );
		Account accUpdated = queryAccount(acc.id);
		System.assertEquals('1', accUpdated.CCIMailCustID__c);
		Test.stopTest();
	}



	public static Account queryAccount(Id accId) {
		return ([select Id, CCIMailCustID__c, CCIMetroCustID__c from Account where Id = : accId]);
	}


	private static testMethod void testCustomerWrapperClasses() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;
		Test.startTest();
		CCICustomerWrapper.AccountInfo acInfo1 = new CCICustomerWrapper.AccountInfo(acc.id, 'Test', '76236726736', 'test', 'London', 'we2 3th', 'UK', 'UK', '04.01.01', '1', '1', false, 'Direct Advertiser', '', '');
		CCICustomerWrapper.ChatterInfo chatterInfo = new CCICustomerWrapper.ChatterInfo(acc.id, 'Test');
		CCICustomerWrapper.AccessToken accessToken = new CCICustomerWrapper.AccessToken('ato', 'tto', 'rto', 'exp', 'rd');

		Test.stopTest();
	}

	private static testMethod void testcreateInactiveCustomer() {
		setUpData();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.IsActive__c = false;
		insert acc;

		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', false);
		System.debug('Response is' + response);

		System.assertEquals(response, Label.InActiveAccountMessage);
		Test.stopTest();

	}

	private static testMethod void CCIAccountalreadyexists_Test() {
		setUpData();
		//No_Validations__c.Flag__c = true;
		Account acc = TestData.buildAccount('Agency', 'Billing Agency');
		acc.CCIMailCustID__c = 'test123456';
		insert acc;

		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', false);
		System.debug('Response is' + response);

		System.assertEquals(response, Label.CCIAccount_already_exists);
		Test.stopTest();

	}

	private static testMethod void withFinanaceAccountMail_Test() {
		setUpData();
		//No_Validations__c.Flag__c = true;
		Account acc = TestData.buildAccount('Agency', 'Billing Agency');
		insert acc;
		Company__c testCompany = new Company__c(Name = 'Mail');
		insert testCompany;
		FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(acc);
		testFinanceAccount.Company__c = testCompany.Id;
		insert testFinanceAccount;
		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Mail', false);
		System.debug('Response is' + response);
		Test.stopTest();
	}

	private static testMethod void withFinanaceAccountMetro_Test() {
		setUpData();
		//No_Validations__c.Flag__c = true;
		Account acc = TestData.buildAccount('Agency', 'Billing Agency');
		insert acc;
		Company__c testCompany = new Company__c(Name = 'Metro');
		insert testCompany;
		FinanceAccount__c testFinanceAccount = TestData.buildFinanceAccount(acc);
		testFinanceAccount.Company__c = testCompany.Id;
		insert testFinanceAccount;
		Test.startTest();
		String response = CCICustomerWebService.createCCICustomer(acc.id, 'Metro', false);
		System.debug('Response is' + response);
		Test.stopTest();
	}

	private static testMethod void testgetCCIAccount_mail() {
		setUpData();
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = 'testmail123';
		newAcc.CCIMetroCustID__c = null;
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = 'testmail123';
		oldAcc.CCIMetroCustID__c = null;
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, '', '');
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, '', '');
		oldAccInfo.add(JSON.serialize(oldai));
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		CCICustomerWebService.getCCIAccount(newAccInfo, oldAccInfo, true);
		Test.stopTest();
	}

	private static testMethod void testgetCCIAccount_metro() {
		setUpData();
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, '', '');
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, '', '');
		oldAccInfo.add(JSON.serialize(oldai));
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		CCICustomerWebService.getCCIAccount(newAccInfo, oldAccInfo, false);
		Test.stopTest();
	}

	private static testMethod void testgetCCIAccount_fullsync() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, '', '');
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, '', '');
		oldAccInfo.add(JSON.serialize(oldai));
		Test.startTest();
		CCICustomerWebService.getCCIAccount(newAccInfo, oldAccInfo, null);
		Test.stopTest();
	}

	private static testMethod void testgetCCIAccount_exceptionHandeling() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testexception123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testexception123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, '', '');
		newAccInfo.add(JSON.serialize(ai));
		system.debug('newAccountInfo : ' + newAccInfo);
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, '', '');
		oldAccInfo.add(JSON.serialize(oldai));
		Test.startTest();
		CCICustomerWebService.getCCIAccount(newAccInfo, oldAccInfo, null);
		Test.stopTest();
	}
}