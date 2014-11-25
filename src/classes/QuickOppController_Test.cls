@isTest(SeeAllData = true)
public with sharing class QuickOppController_Test {
	static {
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		BookingSystemCountryCodes__c bSCC = BookingSystemCountryCodes__c.getInstance('United Kingdom');
		if (bSCC == null) insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		map < String, boolean > companyMap = new map < String, boolean > ();
		companyMap.put('mail', false);
		companyMap.put('metro', false);
		for (Company__c c: [SELECT ID, Name from Company__c]) {
			if (c.name.toLowerCase().contains('mail')) {
				companyMap.put('mail', true);
			}
			if (c.name.toLowerCase().contains('merto')) {
				companyMap.put('metro', true);
			}
		}
		if (companyMap.get('mail') == false) insert TestData.buildCompany();
		if (companyMap.get('metro') == false) insert TestData.buildMetroCompany();
	}



	static User testUser = [
	select id, name, email, ProfileId, Profile.Name
	from User
	where id !=: userInfo.getUserId() 
	and isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator' 
	limit 1];


	static testMethod void CreateQuickOpptyControllerTest() {


		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;


		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c
		limit 1].id;


		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'United Kingdom';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		insert cnt;

		Pricebook2 priceBook = [
		Select p.Name, p.Id
		From Pricebook2 p
		where p.Name = : newConstH.Price_Book__c
		limit 1];


		PricebookEntry priceBookEntry = [
		select id, name, Product2Id
		from PricebookEntry
		where pricebook2Id = : priceBook.Id
		limit 1];


		QuickOppController cqoc;


		Test.startTest();

		system.runAs(testUser) {

			cqoc = new QuickOppController();

			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = acct;
			cqoc.opportunity.AccountId = acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Test Oppty';


			cqoc.pitch.First_Insertion_Date__c = date.today() + 5;
			cqoc.pitch.Description = 'Test Description';
			cqoc.pitch.UnitPrice = 1000;


			//#
			//# save with causing an exception (pricebookEntryId is missing)
			//#
			try {
				cqoc.save();
			} catch (Exception e) {
				system.debug('>>>>>>>>>>> Exception: ' + e);
			}


			cqoc.productsSelectList = priceBookEntry.Product2Id;
			cqoc.save();

			cqoc.cancel();

		}


		newConstH.Price_Book__c = 'None';
		update newConstH;


		system.runAs(testUser) {
			cqoc = new QuickOppController();
			productOptions = cqoc.getProductOptions();
		}


		Test.stopTest();

	}
	
	static testmethod void loggedINUserTest(){
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;


		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c
		limit 1].id;


		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'United Kingdom';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		insert cnt;

		Pricebook2 priceBook = [
		Select p.Name, p.Id
		From Pricebook2 p
		where p.Name = : newConstH.Price_Book__c
		limit 1];


		PricebookEntry priceBookEntry = [
		select id, name, Product2Id
		from PricebookEntry
		where pricebook2Id = : priceBook.Id
		limit 1];

		test.startTest();
			QuickOppController cqoc = new QuickOppController ();
			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = acct;
			cqoc.opportunity.AccountId = acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Test Oppty';


			cqoc.pitch.First_Insertion_Date__c = date.today() + 5;
			cqoc.pitch.Description = 'Test Description';
			cqoc.pitch.UnitPrice = 1000;
			
			cqoc.opportunity.OwnerId = testUser.Id; 

			//#
			//# save with causing an exception (pricebookEntryId is missing)
			//#
			try {
				cqoc.save();
			} catch (Exception e) {
				system.debug('>>>>>>>>>>> Exception: ' + e);
			}
		test.stopTest();
	}
	
	static testmethod void roleOptionsTest(){
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;


		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c
		limit 1].id;


		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'United Kingdom';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		insert cnt;

		Pricebook2 priceBook = [
		Select p.Name, p.Id
		From Pricebook2 p
		where p.Name = : newConstH.Price_Book__c
		limit 1];


		PricebookEntry priceBookEntry = [
		select id, name, Product2Id
		from PricebookEntry
		where pricebook2Id = : priceBook.Id
		limit 1];

		test.startTest();
			QuickOppController cqoc = new QuickOppController ();
			cqoc.roleOptions = null;
			list<SelectOption> resultOptions = cqoc.roleOptions; 
			cqoc.opportunityLineView = null;
			list<OpportunityLineItem> resultLineItems = cqoc.opportunityLineView;
			list<Selectoption> resultgetNoOfProducts = cqoc.getNoOfProducts();
			list<Selectoption> resultgetDateIncProducts = cqoc.getDateIncProducts();
		test.stopTest();
	}
	
	static testmethod void addLineTest(){
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;


		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c
		limit 1].id;


		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'United Kingdom';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		insert cnt;

		Pricebook2 priceBook = [
		Select p.Name, p.Id
		From Pricebook2 p
		where p.Name = : newConstH.Price_Book__c
		limit 1];


		PricebookEntry priceBookEntry = [
		select id, name, Product2Id
		from PricebookEntry
		where pricebook2Id = : priceBook.Id
		limit 1];

		test.startTest();
			QuickOppController cqoc = new QuickOppController ();
			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = acct;
			cqoc.opportunity.AccountId = acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Test Oppty';


			cqoc.pitch.First_Insertion_Date__c = date.today() + 5;
			cqoc.pitch.Description = 'Test Description';
			cqoc.pitch.UnitPrice = 1000;
			
			cqoc.opportunity.OwnerId = testUser.Id; 

			//#
			//# save with causing an exception (pricebookEntryId is missing)
			//#
			try {
				cqoc.addNewLine();
			} catch (Exception e) {
				system.debug('>>>>>>>>>>> Exception: ' + e);
			}
		test.stopTest();
	}
	
	static testmethod void errormessagesTest(){
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;


		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;


		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c
		limit 1].id;


		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'United Kingdom';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		insert cnt;

		Pricebook2 priceBook = [
		Select p.Name, p.Id
		From Pricebook2 p
		where p.Name = : newConstH.Price_Book__c
		limit 1];


		PricebookEntry priceBookEntry = [
		select id, name, Product2Id
		from PricebookEntry
		where pricebook2Id = : priceBook.Id
		limit 1];

		test.startTest();
			QuickOppController cqoc = new QuickOppController ();
			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = acct;
			cqoc.opportunity.AccountId = acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today()-1;
			cqoc.opportunity.Name = 'Test Oppty';


			cqoc.pitch.First_Insertion_Date__c = date.today() + 5;
			cqoc.pitch.Description = 'Test Description';
			cqoc.pitch.UnitPrice = 1000;
			
			cqoc.opportunity.OwnerId = testUser.Id; 

			//#
			//# save with causing an exception (pricebookEntryId is missing)
			//#
			try {
				cqoc.addNewLine();
			} catch (Exception e) {
				system.debug('>>>>>>>>>>> Exception: ' + e);
			}
		test.stopTest();
	}
	
}