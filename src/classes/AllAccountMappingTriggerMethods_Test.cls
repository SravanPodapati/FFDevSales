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
public class AllAccountMappingTriggerMethods_Test {
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

		//insert categories  
		insert TestData.createCustomerCategory();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

	}

	private static testMethod void testUpdateAccountMapping() {
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
		System.debug('AccUpdated is..' + accUpdated);
		Account_Mapping__c mapping = queryAccountMapping(accUpdated.CCIMailCustID__c);
		System.debug('Mapping is' + mapping);
		mapping.Active__c = false;
		update mapping;
		Account accUpdated2 = queryAccount(acc.id);
		System.debug('AccUpdated2 is' + accUpdated2);
		System.assertEquals(null, accUpdated2.CCIMailCustID__c);


		Test.stopTest();
	}

	public static Account queryAccount(Id accId) {
		return ([select Id, CCIMailCustID__c, CCIMetroCustID__c from Account where Id = : accId]);
	}
	public static Account_Mapping__c queryAccountMapping(String sourceKey) {
		System.debug('SourceKey is' + sourceKey);
		return ([select Id, Active__c from Account_Mapping__c where Source_Key__c = : sourceKey and Active__c = true]);
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


		Account_Mapping__c mapping = new Account_Mapping__c();
		mapping.Account__c = newAcc.id;
		mapping.Source_Key__c = '1';
		mapping.Source_System__c = 'CCI Mail';
		insert mapping;


		List < String > newAccInfo = new List < String > ();

		AccountMappingInfo ai = new AccountMappingInfo(mapping.Id, mapping.Account__c, mapping.Source_Key__c, mapping.Source_System__c, mapping.active__c);
		newAccInfo.add(JSON.serialize(ai));

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		AllAccountMappingTriggerMethods.getCCIAccount(newAccInfo);
		Test.stopTest();
	}
	
	// Test delete Account Mapping
	
	private static testMethod void testDeleteAccountMapping() 
	{
		setUpData();

		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		insert acc;

		List<Account_Mapping__c> mapping = TestData.buildAccountMaping(acc.Id, '2', '3');
		insert mapping;
	
	    
	    Account qAcc = [Select CCIMailCustID__c From Account Where Id = :acc.Id];
	   // System.assertEquals('2', qAcc.CCIMailCustID__c);
	   
	    Test.startTest();
	    delete mapping;
	    

	    Account qAccDel = [Select CCIMailCustID__c From Account Where Id = :acc.Id];
	    
	    System.debug('qAccDel:'+qAccDel);
	    System.assertEquals(null, qAccDel.CCIMailCustID__c);
	    
	    Test.stopTest();
	    
    }	


}