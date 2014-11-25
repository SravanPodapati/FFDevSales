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
public class AccountSearchController_Test {

	public static void setUpData() {
		insert TestData.createCountriesList();
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
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		//create accounts with different postcodes and account names. 
		//for Advertiser Type
		for (integer i = 1; i <= 9; i++) {
			Account advertiserAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
			advertiserAccount.name = 'Advertiser Account ' + i;
			advertiserAccount.BillingPostalCode = 'xx' + i + ' ' + i + 'xx';

			accountList.add(advertiserAccount);
		}

		//for Agency Type
		for (integer i = 1; i <= 9; i++) {
			Account agencyAccount = TestData.buildAccount('agency', 'Direct Advertiser');
			agencyAccount.name = 'Agency Account ' + i;
			agencyAccount.BillingPostalCode = 'yy' + i + ' ' + i + 'yy';

			accountList.add(agencyAccount);
		}

		insert accountList;
	}

	static testMethod void defaultValuesTest() {
		setUpData();
		test.startTest();

		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//validate the default valus 
		system.assertEquals('Name', controller.sortOption);
		system.assertEquals('ASC', controller.sortDirection);
		system.assertEquals('', controller.recordTypeID);
		system.assertNotEquals(null, controller.recordTypeID);
		system.assertEquals(null, controller.postCode);
		system.assertEquals(null, controller.accountName);

		//conform the search results are zero when the page loaded for the first time.
		list < Account > resultList = controller.getSearchAccounts();

		system.assertEquals(0, resultList.size());

		test.stopTest();
	}

	//Customer or Account Name search with record type
	//verify the search results are returned properelly
	static testmethod void searchResultTest1() {
		setUpData();
		test.startTest();
		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//set the Customer name 
		controller.accountName = 'Advertiser';
		controller.recordTypeID = [SELECT ID from RecordType where SobjectType = 'Account'
		and DeveloperName = 'Advertiser'].ID;
		list < Account > resultList = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(9, resultList.size());
		//asert the resuls containging the string passed to accountName
		for (Account acc: resultList) {
			system.assertEquals(true, acc.Name.toUpperCase().contains(controller.accountName.toUpperCase()));
		}
		test.stopTest();
	}

	//verify no results are returned 
	static testMethod void searchResultsTest2() {
		setUpData();
		test.startTest();
		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//set the Customer name 
		controller.accountName = 'Advertiser';
		controller.recordTypeID = [SELECT ID from RecordType where SobjectType = 'Account'
		and DeveloperName = 'Agency'].ID;
		list < Account > resultList = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(0, resultList.size());

		test.stopTest();
	}

	//Search with record type and postcode 
	//verify the search results are returned properelly
	static testmethod void searchResultTest3() {
		setUpData();
		test.startTest();
		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//set the Post Code  
		controller.postCode = 'xx1 1xx';
		controller.recordTypeID = [SELECT ID from RecordType where SobjectType = 'Account'
		and DeveloperName = 'Advertiser'].ID;
		list < Account > resultList = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(1, resultList.size());
		//asert the resuls containging the string passed to accountName
		for (Account acc: resultList) {
			system.assertEquals(true, acc.Name.toUpperCase().contains(controller.accountName.toUpperCase()));
		}
		test.stopTest();
	}

	//Search with record type, Post code and Account Name 
	//verify the search results are returned properelly
	static testmethod void searchResultTest4() {
		setUpData();
		test.startTest();
		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//set the Customer name 
		controller.accountName = 'Advertiser Account 1';
		controller.postCode = 'xx1 1xx';
		controller.recordTypeID = [SELECT ID from RecordType where SobjectType = 'Account'
		and DeveloperName = 'Advertiser'].ID;
		list < Account > resultList = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(1, resultList.size());
		//asert the resuls containging the string passed to accountName
		for (Account acc: resultList) {
			system.assertEquals(true, acc.Name.toUpperCase().contains(controller.accountName.toUpperCase()));
		}
		test.stopTest();
	}


	//test methods for VF remote Action 
	static testmethod void getDataTest1() {
		setUpData();
		test.startTest();
		//test with out passing record type
		list < Sobject > resultList1 = AccountSearchController.getData('Account', '');
		integer resultSize = [select count() from Account where name like 'Account%'];

		system.assertEquals(resultSize, resultList1.size());

		//test with record type and parm
		id recordTpeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Advertiser').RecordTypeId;
		list < Sobject > resultList3 = AccountSearchController.getData('Advertiser', recordTpeId);
		resultSize = [select count() from Account where name like 'Advertiser%'
		and RecordTypeId = : recordTpeId];

		system.assertEquals(resultSize, resultList3.size());

		test.stopTest();
	}

	//test method for alias records
	static testmethod void aliasTest() {
		setUpData();
		Account testAccount = [select id from account limit 1];
		list < Account_Alias__c > insertAlias = new list < Account_Alias__c > ();
		insertAlias.add(new Account_Alias__c(name = 'alias 1', Is_Active__c = true, Account__c = testAccount.id));
		insertAlias.add(new Account_Alias__c(name = 'alias 2', Is_Active__c = true, Account__c = testAccount.id));
		insertAlias.add(new Account_Alias__c(name = 'alias 3', Is_Active__c = true, Account__c = testAccount.id));
		insertAlias.add(new Account_Alias__c(name = 'alias 4', Is_Active__c = false, Account__c = testAccount.id));

		insert insertAlias;
		test.startTest();
		//set the current page to AccountSearchScreen VF 
		test.setCurrentPage(Page.AccountSearchScreen);
		AccountSearchController controller = new AccountSearchController(new ApexPages.StandardController(new Account()));

		//set the Customer name 
		controller.accountName = 'alias';
		list < Account > resultList = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(1, resultList.size());

		//set the Customer name 
		controller.accountName = 'alias 4';
		list < Account > resultList2 = controller.getSearchAccounts();

		//assert the syze of the results 
		system.assertEquals(0, resultList2.size());
		controller.doSearch();
		controller.clear();
		test.stopTest();
	}

}