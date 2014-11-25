@isTest
private class CreateQuickOpptyController_Test {


	static User testUser = [
	select id, name, email, ProfileId, Profile.Name
	from User
	where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
	limit 1];

	static {
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}

	}
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


		CreateQuickOpptyController cqoc;


		Test.startTest();

		system.runAs(testUser) {

			cqoc = new CreateQuickOpptyController();

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
			cqoc = new CreateQuickOpptyController();
			productOptions = cqoc.getProductOptions();
		}


		Test.stopTest();

	}
}