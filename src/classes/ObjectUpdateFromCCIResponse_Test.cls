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
private class ObjectUpdateFromCCIResponse_Test {
	public static void setupData() {
		insert TestData.createCountriesList();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Name = 'Advertiser';
		Account cus = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		cus.Name = 'Customer';

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
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

		insert acc;
		insert cus;
	}
	static testMethod void mailTest() {
		setUpData();

		string dbType = 'Mail';
		ID accID = [select id from Account where Name = 'Advertiser'
		limit 1].id;

		String jsonString = '{"customerId": "374207","externalCustomerId": "001M000000XqqqsIAB","customerFinanceId": null,"presentationName": "Weddirectad101","streetAddress": null,"zipCode": null,"countryName": null,"areaCode": null,"extension": null,"number": null,"pobox": null}';
		test.startTest();
		ObjectUpdateFromCCIResponse.createAccounMapping(jsonString, dbType, accId);
		test.stopTest();
	}

	static testMethod void metroTest() {
		setUpData();

		string dbType = 'Metro';
		ID accID = [select id from Account where Name = 'Advertiser'
		limit 1].id;

		String jsonString = '{"customerId": "374207","externalCustomerId": "001M000000XqqqsIAB","customerFinanceId": null,"presentationName": "Weddirectad101","streetAddress": null,"zipCode": null,"countryName": null,"areaCode": null,"extension": null,"number": null,"pobox": null}';
		test.startTest();
		ObjectUpdateFromCCIResponse.createAccounMapping(jsonString, dbType, accId);
		test.stopTest();
	}

	static testMethod void updateFinanceMapping_Test() {
		setUpData();

		string dbType = 'Metro';
		ID accID = [select id from Account where Name = 'Advertiser'
		limit 1].id;

		String jsonString = '{"accountId": "374207","externalCustomerId": "001M000000XqqqsIAB","customerFinanceId": null,"presentationName": "Weddirectad101","streetAddress": null,"zipCode": null,"countryName": null,"areaCode": null,"extension": null,"number": null,"pobox": null}';
		test.startTest();
		string result = ObjectUpdateFromCCIResponse.updateFinanceMapping(jsonString);
		system.assertEquals(result, '374207');
		test.stopTest();
	}
}