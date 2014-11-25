global with sharing class BatchAccountResetRevenue implements Database.Batchable < sObject > , Database.Stateful {

	global BatchAccountResetRevenue() {

	}

	global static void StartBatch() {
		ID batchprocessid = database.executebatch(new BatchAccountResetRevenue(), 50);
	}

	global Database.querylocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(
		[
		Select
		Revenue_Last_Month__c,
		Revenue_Last_Quarter__c,
		Revenue_Last_Year__c,
		Hierarchy_Revenue_Last_Month__c,
		Hierarchy_Revenue_Last_Quarter__c,
		Hierarchy_Revenue_Last_Year__c
		From Account
		Where isActive__c = True]);
	}

	global void execute(Database.BatchableContext BC, List < sObject > scope) {
		List < Account > accountList = scope;

		for (Account a: accountList) {
			a.Revenue_Last_Month__c = 0;
			a.Revenue_Last_Quarter__c = 0;
			a.Revenue_Last_Year__c = 0;
			a.Hierarchy_Revenue_Last_Month__c = 0;
			a.Hierarchy_Revenue_Last_Quarter__c = 0;
			a.Hierarchy_Revenue_Last_Year__c = 0;
		}

		update accountList;
	}

	global void finish(Database.BatchableContext ctx) {
		database.executebatch(new BatchAccountRevenueUpdateLastMonth(), 200);
	}



	// Test Method
	private static TestMethod void testBatchAccountResetRevenue() {
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
		Test.startTest();
		User testUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true
		and Profile.Name = 'System Administrator'
		limit 1];

		String testProfileId = [select id
		from Profile
		limit 1].id;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'Test Department 1',
		IsManager__c = false,
		//Price_Book__c             = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		Map < String, RecordTypeInfo > oppRecTypesByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
		System.debug('oppRecTypesByName:' + oppRecTypesByName);

		Account agency = new Account(
		Name = 'TestAgency',
		AccountNumber = 'ABC123456',
		Type = 'Agency',
		BillingStreet = 'Test Billing Street',
		BillingState = 'Test Billing State',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'London',
		Industry = 'Finance',
		IndClassLvl1__c = 'Finance',
		IndClassLvl2__c = 'Finance',
		Classified_Minor_Category__c = 'Finance',
		CustomerRef1__c = '12345',
		CustomerRef2__c = '23456',
		CustomerRef3__c = '34567',
		CustomerRef4__c = 'TestA',
		RecordTypeId = oppRecTypesByName.get('Agency').RecordTypeId,
		Revenue_Last_Month__c = 100,
		Revenue_Last_Quarter__c = 200,
		Revenue_Last_Year__c = 300);
		insert agency;

		Account acct = new Account(
		Name = 'TestAccount',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		BillingStreet = 'Test Billing Street',
		BillingState = 'Test Billing State',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'London',
		Industry = 'Finance',
		IndClassLvl1__c = 'Finance',
		IndClassLvl2__c = 'Finance',
		Classified_Minor_Category__c = 'Finance',
		CustomerRef1__c = '12345',
		CustomerRef2__c = '23456',
		CustomerRef3__c = '34567',
		CustomerRef4__c = 'TestA',
		RecordTypeId = oppRecTypesByName.get('Advertiser').RecordTypeId,
		Revenue_Last_Month__c = 100,
		Revenue_Last_Quarter__c = 200,
		Revenue_Last_Year__c = 300);
		insert acct;

		Account brand = new Account(
		Name = 'TestBrand',
		ParentId = acct.Id,
		AccountNumber = 'ABC123456',
		Type = 'Brand',
		BillingStreet = 'Test Billing Street',
		BillingState = 'Test Billing State',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'London',
		Industry = 'Finance',
		IndClassLvl1__c = 'Finance',
		IndClassLvl2__c = 'Finance',
		Classified_Minor_Category__c = 'Finance',
		CustomerRef1__c = '12345',
		CustomerRef2__c = '23456',
		CustomerRef3__c = '34567',
		CustomerRef4__c = 'TestA',
		RecordTypeId = oppRecTypesByName.get('Advertiser').RecordTypeId,
		Revenue_Last_Month__c = 100,
		Revenue_Last_Quarter__c = 200,
		Revenue_Last_Year__c = 300);
		insert brand;


		List < Account_Mapping__c > accMapList = new List < Account_Mapping__c > ();
		accMapList.add(new Account_Mapping__c(
		Account__c = acct.Id,
		Source_System__c = 'CCI Metro',
		Source_Key__c = '23747',
		Active__c = True));
		accMapList.add(new Account_Mapping__c(
		Account__c = acct.Id,
		Source_System__c = 'CCI Mail',
		Source_Key__c = '28462',
		Active__c = True));
		accMapList.add(new Account_Mapping__c(
		Account__c = acct.Id,
		Source_System__c = 'Advance',
		Source_Key__c = '2347239',
		Active__c = True));

		insert accMapList;


		BatchAccountResetRevenue batchrun = new BatchAccountResetRevenue();
		Integer batchSize = 6;
		database.executebatch(batchrun, batchSize);
		Test.stopTest();

		Set < Id > accountSet = new Set < Id > ();
		accountSet.add(brand.Id);
		accountSet.add(acct.Id);
		accountSet.add(agency.Id);
		Map < Id, Account > accMap = new Map < Id, Account > (
		[Select
		Revenue_Last_Month__c,
		Revenue_Last_Quarter__c,
		Revenue_Last_Year__c
		From Account
		Where Id IN: accountSet]);
		System.assertEquals(0, accMap.get(acct.ID).Revenue_Last_Month__c);
		System.assertEquals(0, accMap.get(brand.ID).Revenue_Last_Month__c);
		System.assertEquals(0, accMap.get(agency.ID).Revenue_Last_Month__c);
	}

}