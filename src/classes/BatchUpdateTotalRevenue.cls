global with sharing class BatchUpdateTotalRevenue implements Database.Batchable < sObject > , Database.Stateful {

	global BatchUpdateTotalRevenue() {

	}

	global Database.querylocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(
		[
		Select
		BrandID__c,
		AdvertiserID__c,
		Invoice_AgencyID__c,
		Revenue_Amount__c
		From SalesRevenue__c
		// Where   (BrandID__c != Null Or AdvertiserID__c != Null Or Invoice_AgencyID__c != Null)
		Where(BrandID__r.ParentID != Null Or AdvertiserID__r.ParentID != Null Or Invoice_AgencyID__r.ParentId != Null)]);
	}

	global void execute(Database.BatchableContext BC, List < sObject > scope) {
		List < SalesRevenue__c > srList = scope;

		Set < Id > accSet = new Set < Id > ();
		for (SalesRevenue__c s: srList) {
			if (s.BrandID__c != null) {
				accSet.add(s.BrandID__c);
			}
			if (s.AdvertiserID__c != null) {
				accSet.add(s.AdvertiserID__c);
			}
			if (s.Invoice_AgencyID__c != null) {
				accSet.add(s.Invoice_AgencyID__c);
			}
		}

		List < AggregateResult > accountList = [
		Select ParentId, Sum(Revenue_Last_Month__c), Sum(Revenue_Last_Quarter__c), Sum(Revenue_Last_Year__c)
		From Account
		Where Id IN: accSet
		And ParentId != null
		Group By ParentId];

		List < Account > accountsToUpdateList = new List < Account > ();
		for (AggregateResult ag: accountList) {
			accountsToUpdateList.add(new Account(Id = (Id) ag.get('ParentId'),
			Hierarchy_Revenue_Last_Month__c = (Decimal) ag.get('expr0'),
			Hierarchy_Revenue_Last_Quarter__c = (Decimal) ag.get('expr1'),
			Hierarchy_Revenue_Last_Year__c = (Decimal) ag.get('expr2')));
		}
		System.debug('accountsToUpdateList:' + accountsToUpdateList);
		update accountsToUpdateList;

	}

	global void finish(Database.BatchableContext ctx) {

	}



	// Test Method
	private static TestMethod void testBatchAccountRevenueUpdate() {
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

		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		insert TestData.createCountriesList();

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
		Review_Status__c = 'Reviewed');
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
		Review_Status__c = 'Reviewed');
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
		Review_Status__c = 'Reviewed');
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

		List < SalesRevenue__c > salesRevList = new List < SalesRevenue__c > ();
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Metro', Department__c = 'London Classified', AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 1000));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Metro', Department__c = 'Metro', AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 3000));

		salesRevList.add(new SalesRevenue__c(Publication__c = 'You', Department__c = 'Daily Mail', BrandID__c = brand.ID, AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 1500));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Daily Mail', Department__c = 'Daily Mail', BrandID__c = brand.ID, AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 4000));

		salesRevList.add(new SalesRevenue__c(Publication__c = 'You', Department__c = 'Daily Mail', Invoice_AgencyID__c = agency.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 7000));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Daily Mail', Department__c = 'Daily Mail', Invoice_AgencyID__c = agency.ID, Period_End_Date__c = Date.today().addMonths(-1), Revenue_Amount__c = 10000));


		insert salesRevList;

		List < Account > simAccount = new List < Account > ();

		simAccount.add(new Account(Id = brand.Id, Revenue_Last_Month__c = 5500, Revenue_Last_Quarter__c = 5500, Revenue_Last_Year__c = 5500));
		simAccount.add(new Account(Id = acct.Id, Revenue_Last_Month__c = 4000, Revenue_Last_Quarter__c = 4000, Revenue_Last_Year__c = 4000));
		simAccount.add(new Account(Id = agency.Id, Revenue_Last_Month__c = 17000, Revenue_Last_Quarter__c = 17000, Revenue_Last_Year__c = 17000));
		update simAccount;

		BatchUpdateTotalRevenue batchrun = new BatchUpdateTotalRevenue();
		Integer batchSize = 6;
		database.executebatch(batchrun, batchSize);
		Test.stopTest();

		Set < Id > accountSet = new Set < Id > ();
		accountSet.add(brand.Id);
		accountSet.add(acct.Id);
		accountSet.add(agency.Id);

		Map < Id, Account > accMap = new Map < Id, Account > (
		[Select
		Hierarchy_Revenue_Last_Month__c,
		Hierarchy_Revenue_Last_Quarter__c,
		Hierarchy_Revenue_Last_Year__c,
		Total_Revenue_Last_Month__c,
		Total_Revenue_Last_Quarter__c,
		Total_Revenue_Last_Year__c
		From Account
		Where Id IN: accountSet]);

		System.assertEquals(5500.00, accMap.get(acct.ID).Hierarchy_Revenue_Last_Month__c);
		System.assertEquals(9500.00, accMap.get(acct.ID).Total_Revenue_Last_Month__c);

	}

}