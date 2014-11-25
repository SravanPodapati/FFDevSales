@isTest(SeeAllData = true)
private class PitchHubController_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testMethod void testPitchHub() {
		User testUser = [
		Select name, email, ProfileId, Profile.Name
		From User
		Where isActive = true /*and managerId != null*/
		And Profile.Name = 'System Administrator'
		Limit 1];

		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;
		List < SelectOption > roleOptions;
		List < OpportunityLineItem > oppLine;
		List < SelectOption > noOfProducts;
		List < SelectOption > dateIncrement;

		OpportunityContactRole cr = new OpportunityContactRole();

		Pricebook2 testPB = [Select
		name
		From Pricebook2
		Where isActive = true
		Limit 1];

		String testProfileId = [Select id
		From Profile
		Limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 

		ConstantsH__c constH = [
		select Name, Price_Book__c, Acc_and_Contact_owner__c
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
		Select id
		From RecordType
		Where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c].id;

		String agencyRecTypeId = [
		Select id
		From RecordType
		Where DeveloperName = : Constants__c.getInstance('All').Agency_Record_Type__c
		Limit 1].id;

		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId,
		BillingCountry = 'United Kingdom');
		insert acct;

		Account agency = new Account(
		Name = 'Test Agency',
		AccountNumber = 'AGN123456',
		Type = 'Billing Agency',
		Industry = 'Finance',
		RecordTypeId = agencyRecTypeId,
		BillingStreet = '1',
		BillingPostalCode = 'a111aa',
		Phone = '01236547896',
		BillingCountry = 'United Kingdom');
		insert agency;

		Contact cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'Test Mailing Country';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		cnt.MailingCountry = 'United Kingdom';
		insert cnt;

		Pricebook2 priceBook = [
		Select
		p.Name
		From Pricebook2 p
		Where p.Name = : newConstH.Price_Book__c
		Limit 1];


		PricebookEntry priceBookEntry = [
		Select
		name,
		Product2Id
		From PricebookEntry
		Where pricebook2Id = : priceBook.Id
		limit 1];


		PitchHubController cPHC;


		Test.startTest();

		system.runAs(testUser) {

			Business_Team_Activity__c bta = [Select id From Business_Team_Activity__c Where Account__c = : acct.Id Limit 1];
			Event event = new Event(whatid = bta.id, DurationInMinutes = 30, ActivityDateTime = Date.today());
			insert event;
			Task tsk = new Task(whatid = bta.id);
			insert tsk;

			PageReference pageRef = Page.PitchHub;
			pageRef.getParameters().put('Contactid', cnt.Id);
			pageRef.getParameters().put('Eventid', event.Id);
			pageRef.getParameters().put('Activityid', tsk.Id);
			Test.setCurrentPageReference(pageRef);

			Date d1PastFirstInsertionDates = Date.today().addDays(-1);
			Date d2FirstInsertionDates = Date.today().addDays(5);
			Date d3FirstInsertionDates = Date.today().addDays(10);

			String sArrFirstInsertionDatesWithPastDates;
			sArrFirstInsertionDatesWithPastDates = d1PastFirstInsertionDates.format() + ',' + d2FirstInsertionDates.format() + ',' + d3FirstInsertionDates.format();

			String sArrFirstInsertionDatesWithoutPastDates;
			sArrFirstInsertionDatesWithoutPastDates = d2FirstInsertionDates.format() + ',' + d3FirstInsertionDates.format();


			for (Integer i = 0; i < 2; i++) {

				cPHC = new PitchHubController();
				OpportunityLineItem sOppLineItem = new OpportunityLineItem();

				productOptions = cPHC.getProductOptions();
				stageOptions = cPHC.getStageOptions();
				roleOptions = cPHC.roleOptions;

				cPHC.stageSelectList = 'Preparation';

				cPHC.account = acct;
				cPHC.opportunity.AccountId = acct.Id;
				cPHC.opportunity.Type = 'Proactive';
				cPHC.opportunity.CloseDate = date.today();
				cPHC.opportunity.Name = 'Test Oppty';
				cPHC.opportunity.Agency__c = agency.Id;

				cPHC.contactRole = new OpportunityContactRole();
				//cPHC.contactRole.ContactId  = cnt.id;

				cPHC.productsSelectList = priceBookEntry.Product2Id;

				if (i == 0) cPHC.SelectedInsertionDates = (String) sArrFirstInsertionDatesWithPastDates;
				else if (i == 1) cPHC.SelectedInsertionDates = (String) sArrFirstInsertionDatesWithoutPastDates;

				sOppLineItem.PricebookEntryId = priceBookEntry.Product2Id;
				sOppLineItem.Description = 'Test Description';
				sOppLineItem.UnitPrice = 1000;
				//sOppLineItem.ServiceDate                = date.today().addDays(5);    
				sOppLineItem.Quantity = 1;
				sOppLineItem.Brand__c = 'Special Brand';
				sOppLineItem.Color_Specification__c = 'Color';
				sOppLineItem.Region__c = 'National';
				sOppLineItem.Size__c = '24x4';
				sOppLineItem.Position__c = 'Front Page';


				cPHC.save();


				List < Opportunity > opList = [
				Select
				Id
				From Opportunity
				Where AccountId = : acct.Id];


				List < OpportunityLineItem > oplList = [
				Select
				Id
				From OpportunityLineItem
				Where Opportunity.AccountId = : acct.Id];

				/*
                if(i == 0){                
                    System.assertEquals(0, opList.size());
                    System.assertEquals(0, oplList.size());               
                }
                else if(i == 1){
                    System.assertEquals(1, opList.size());
                    System.assertEquals(2, oplList.size());
                }
                */

			}

			cPHC.cancel();

		}


		newConstH.Price_Book__c = 'None';
		update newConstH;


		system.runAs(testUser) {
			cPHC = new PitchHubController();
			productOptions = cPHC.getProductOptions();
		}


		Test.stopTest();

	}
}