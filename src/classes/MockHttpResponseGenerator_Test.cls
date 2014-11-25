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
private class MockHttpResponseGenerator_Test {
	public static void setUpData() {
		list < Account > accountList = new list < Account > ();

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

		//insert test accounts 
		Account agencyAccount = TestData.buildAccount('agency', 'Direct Advertiser');
		agencyAccount.name = 'Agency Account ' + 1;
		agencyAccount.BillingPostalCode = 'yy' + 1 + ' ' + 1 + 'yy';

		accountList.add(agencyAccount);

		insert accountList;
	}

	static testMethod void customerResponse_Test() {

		test.startTest();
		string endpointURL = 'https://test.cci-webaccess-dmgmedia.co.uk/api/customers';
		MockHttpResponseGenerator moc = new MockHttpResponseGenerator();
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpointUrl);
		HTTPResponse res = moc.respond(req);
		test.stopTest();
	}

	static testMethod void profileResponse_Test() {

		test.startTest();
		string endpointURL = 'https://test.cci-webaccess-dmgmedia.co.uk/api/setup/user/profiles';
		MockHttpResponseGenerator moc = new MockHttpResponseGenerator();
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpointUrl);
		HTTPResponse res = moc.respond(req);
		test.stopTest();
	}

	static testMethod void accountsResponse_Test() {

		test.startTest();
		string endpointURL = 'https://test.cci-webaccess-dmgmedia.co.uk/api/accounts';
		MockHttpResponseGenerator moc = new MockHttpResponseGenerator();
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpointUrl);
		HTTPResponse res = moc.respond(req);
		test.stopTest();
	}

	static testMethod void groupsResponse_Test() {

		test.startTest();
		string endpointURL = 'https://test.cci-webaccess-dmgmedia.co.uk/api/setup/user/groups';
		MockHttpResponseGenerator moc = new MockHttpResponseGenerator();
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpointUrl);
		HTTPResponse res = moc.respond(req);
		test.stopTest();
	}

	static testMethod void tokenResponse_Test() {

		test.startTest();
		string endpointURL = 'https://test.cci-webaccess-dmgmedia.co.uk/api/authentication/oauth/token';
		MockHttpResponseGenerator moc = new MockHttpResponseGenerator();
		HTTPRequest req = new HTTPRequest();
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpointUrl);
		HTTPResponse res = moc.respond(req);
		test.stopTest();
	}

	static testmethod void queryAccount_Test() {
		Id accID = '000000000000000000';
		try {
			MockHttpResponseGenerator.queryAccount(accId);
		} catch (Exception ex) {

		}
	}

}