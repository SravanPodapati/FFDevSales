global with sharing class BatchAccountRevenueUpdateLastYear implements Database.Batchable < sObject > , Database.Stateful {

	global BatchAccountRevenueUpdateLastYear() {

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
		Where Period_End_Date__c = LAST_YEAR
		And(BrandID__c != Null Or AdvertiserID__c != Null Or Invoice_AgencyID__c != Null)]);
	}

	global void execute(Database.BatchableContext BC, List < sObject > scope) {
		List < SalesRevenue__c > srList = scope;
		Map < Id, Decimal > brandMap = new Map < Id, Decimal > ();
		Map < Id, Decimal > advertiserMap = new Map < Id, Decimal > ();
		Map < Id, Decimal > agencyMap = new Map < Id, Decimal > ();

		for (SalesRevenue__c s: srList) {
			if (s.BrandID__c != Null) {
				if (brandMap.containsKey(s.BrandID__c)) {
					brandMap.put(s.BrandID__c, (brandMap.get(s.BrandID__c) == null ? 0 : brandMap.get(s.BrandID__c)) + s.Revenue_Amount__c);
				} else {
					brandMap.put(s.BrandId__c, s.Revenue_Amount__c);
				}
			} else if (s.AdvertiserID__c != Null) {
				if (advertiserMap.containsKey(s.AdvertiserID__c)) {
					advertiserMap.put(s.AdvertiserID__c, (advertiserMap.get(s.AdvertiserID__c) == null ? 0 : advertiserMap.get(s.AdvertiserID__c)) + s.Revenue_Amount__c);
				} else {
					advertiserMap.put(s.AdvertiserID__c, s.Revenue_Amount__c);
				}
			} else {
				if (agencyMap.containsKey(s.Invoice_AgencyID__c)) {
					agencyMap.put(s.Invoice_AgencyID__c, (agencyMap.get(s.Invoice_AgencyID__c) == null ? 0 : agencyMap.get(s.Invoice_AgencyID__c)) + s.Revenue_Amount__c);
				} else {
					agencyMap.put(s.Invoice_AgencyID__c, s.Revenue_Amount__c);
				}
			}
		}

		Set < Id > allAccountMap = new Set < Id > ();

		allAccountMap.addAll(brandMap.KeySet());
		allAccountMap.addAll(advertiserMap.KeySet());
		allAccountMap.addAll(agencyMap.KeySet());

		Map < Id, Account > AccountMap = new Map < Id, Account > ([Select
		Revenue_Last_Year__c
		From Account
		Where Id IN: allAccountMap]);

		for (Id d: brandMap.KeySet()) {
			if (accountMap.containsKey(d)) {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = (accountMap.get(d).Revenue_Last_Year__c == null ? 0 : accountMap.get(d).Revenue_Last_Year__c) + brandMap.get(d)));
			} else {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = brandMap.get(d)));
			}
			// accountList.add(new Account(Id=d, Revenue_Last_Year__c=brandMap.get(d)));
		}
		for (Id d: advertiserMap.KeySet()) {
			if (accountMap.containsKey(d)) {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = (accountMap.get(d).Revenue_Last_Year__c == null ? 0 : accountMap.get(d).Revenue_Last_Year__c) + advertiserMap.get(d)));
			} else {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = advertiserMap.get(d)));
			}
			// accountList.add(new Account(Id=d, Revenue_Last_Year__c=advertiserMap.get(d)));
		}
		for (Id d: agencyMap.KeySet()) {
			if (accountMap.containsKey(d)) {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = (accountMap.get(d).Revenue_Last_Year__c == null ? 0 : accountMap.get(d).Revenue_Last_Year__c) + agencyMap.get(d)));
			} else {
				accountMap.put(d, new Account(id = d, Revenue_Last_Year__c = agencyMap.get(d)));
			}
			// accountList.add(new Account(Id=d, Revenue_Last_Year__c=agencyMap.get(d)));
		}
		// update accountList;
		update accountMap.Values();
	}

	global void finish(Database.BatchableContext ctx) {
		database.executebatch(new BatchUpdateTotalRevenue(), 1000);
	}



	// Test Method
	private static TestMethod void testBatchAccountRevenueUpdateLastYear() {
		insert TestData.createCountriesList();
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
		RecordTypeId = oppRecTypesByName.get('Agency').RecordTypeId);
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
		RecordTypeId = oppRecTypesByName.get('Advertiser').RecordTypeId);
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
		RecordTypeId = oppRecTypesByName.get('Advertiser').RecordTypeId);
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
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Metro', Department__c = 'London Classified', AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 1000));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Metro', Department__c = 'Metro', AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 3000));

		salesRevList.add(new SalesRevenue__c(Publication__c = 'You', Department__c = 'Daily Mail', BrandID__c = brand.ID, AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 1500));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Daily Mail', Department__c = 'Daily Mail', BrandID__c = brand.ID, AdvertiserID__c = acct.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 4000));

		salesRevList.add(new SalesRevenue__c(Publication__c = 'You', Department__c = 'Daily Mail', Invoice_AgencyID__c = agency.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 7000));
		salesRevList.add(new SalesRevenue__c(Publication__c = 'Daily Mail', Department__c = 'Daily Mail', Invoice_AgencyID__c = agency.ID, Period_End_Date__c = Date.today().addMonths(-12), Revenue_Amount__c = 10000));


		insert salesRevList;

		BatchAccountRevenueUpdateLastYear batchrun = new BatchAccountRevenueUpdateLastYear();
		Integer batchSize = 6;
		database.executebatch(batchrun, batchSize);
		Test.stopTest();

		Set < Id > accountSet = new Set < Id > ();
		accountSet.add(brand.Id);
		accountSet.add(acct.Id);
		accountSet.add(agency.Id);
		Map < Id, Account > accMap = new Map < Id, Account > (
		[Select
		Revenue_Last_Year__c
		From Account
		Where Id IN: accountSet]);
		System.assertEquals(4000.00, accMap.get(acct.ID).Revenue_Last_Year__c);
		System.assertEquals(5500.00, accMap.get(brand.ID).Revenue_Last_Year__c);
		System.assertEquals(17000.00, accMap.get(agency.ID).Revenue_Last_Year__c);
	}

}