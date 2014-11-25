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
public class CCIFinanceAccountManager_Test {
	public static void setUpData() {
		insert TestData.createCountriesList();
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		Profile pMetro = [SELECT Id FROM Profile WHERE Name = 'Metro Display User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

		insert u;

		//insert custom settings for BookingSystemSettings
		insert TestData.createBookingSystemSettings();

		//insert categories  
		insert TestData.createCustomerCategory();

		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

	}


	private static testMethod void testgetCCIAccount() {
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
		newAcc.Type = 'Direct Advertiser';
		insert newAcc;


		FinanceAccount__c newfinAcc = TestData.buildFinanceAccount(newAcc);
		newfinAcc.Account__c = newAcc.id;
		newfinAcc.name = 'TestFinAcc';
		newfinAcc.SOP_ID__c = '123';
		insert newfinAcc;


		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCIAccountCreation.AccountInfo ai = new CCIAccountCreation.AccountInfo(newfinAcc.id, newfinAcc.SOP_ID__c);
		newAccInfo.add(JSON.serialize(ai));
		CCIAccountCreation.AccountInfo oldai = ai;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		CCIFinanceAccountManager.getCCIAccount(newAccInfo, oldAccInfo);
		Test.stopTest();
	}

}