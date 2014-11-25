@isTest
private class ActivateDeactivatePitchIdeaContr_Test {

	static User testUser = [select id, name, email, ProfileId, Profile.Name
							from User
							where isActive = true and managerId != null /*and Profile.Name = 'System Administrator'*/
							limit 1];

	static OpportunityLineItem CreateTestOpportunity() {
		if (BookingSystemSettings__c.getAll().get('CCI') == null) {
			insert TestData.createBookingSystemSettings();
		}
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();

		Map < String, RecordTypeInfo > opportunityRecTypeByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();

		System.debug(opportunityRecTypeByName);
		System.debug('Regular_Opp_Record_Type__c:' + Constants__c.getInstance('All').Regular_Opp_Record_Type__c);

		String opportunityRecTypeId = opportunityRecTypeByName.get('Pitch').RecordTypeId;
		Map < String, RecordTypeInfo > accountRecTypeByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();

		String advertiserRecTypeId = accountRecTypeByName.get(Constants__c.getInstance('All').Advertiser_Record_Type__c).RecordTypeId;
		String agencyRecTypeId = accountRecTypeByName.get(Constants__c.getInstance('All').Agency_Record_Type__c).RecordTypeId;

		Pricebook2 testPB = [select id, name from Pricebook2 where isActive = true limit 1];
		String testProfileId = [select id from Profile limit 1].id;
		User manager = [select id, name from User where isActive = true and id != : testUser.Id limit 1];

		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 
		ConstantsH__c constH = [select id, Name, Price_Book__c, Acc_and_Contact_owner__c
								from ConstantsH__c
								where SetupOwnerId = : testUser.ProfileId
								limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(Acc_and_Contact_owner__c = testUser.Name,
													Department__c = 'None',
													IsManager__c = false,
													Price_Book__c = testPB.Name,
													SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		list < Account > accountsList = new list < Account > ();
		Account acct = new Account(Name = 'Test Account',
									AccountNumber = 'ABC123456',
									Industry = 'Finance',
									Type = 'Booking Agency',
									BillingStreet = 'Agency Street',
									BillingState = 'Agency TestState',
									BillingPostalCode = 'A111AA',
									BillingCountry = 'United Kingdom',
									BillingCity = 'Agency City',
									RecordTypeId = advertiserRecTypeId,
									Phone = '012364788996');
									accountsList.add(acct);

		Account acct2 = new Account(Name = 'Test Adv',
									AccountNumber = 'ABC1234562',
									Industry = 'Finance',
									Type = 'Direct Advertiser',
									BillingStreet = 'Street',
									BillingState = 'TestState',
									BillingPostalCode = 'A111AA',
									BillingCountry = 'United Kingdom',
									BillingCity = 'City',
									RecordTypeId = advertiserRecTypeId,
									Phone = '01236547891');
		accountsList.add(acct2);

		Account acct3 = new Account(Name = 'Test Agency',
									AccountNumber = 'ABC1234563',
									Industry = 'Finance',
									Type = 'Billing Agency',
									BillingStreet = 'Street',
									BillingState = 'TestState',
									BillingPostalCode = 'A111AA',
									BillingCountry = 'United Kingdom',
									BillingCity = 'City',
									RecordTypeId = agencyRecTypeId,
									Phone = '01236547896');
		accountsList.add(acct3);
		insert accountsList;
		Opportunity oppty = new Opportunity(Name = 'Test Oppty',
											recordTypeId = opportunityRecTypeId,
											AccountId = acct.id,
											Agency__c = acct3.id,
											StageName = 'Final Negotiations',
											CloseDate = Date.today(),
											LeadSource = 'Organic - Google',
											Type = 'Proactive',
											OwnerId = testUser.id);
		try {
			insert oppty;
		} catch (exception e) {
			system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
		}
		//#
		//# Create and insert all test products
		//#

		List < Product2 > newProducts = new List < Product2 > ();

		Product2 tmpproduct1 = new Product2();
		tmpproduct1.IsActive = true;
		tmpproduct1.Family = 'Test Family1';
		tmpproduct1.Name = 'Test product1';
		tmpproduct1.CustomerRef__c = 'CustomerRef1';
		newProducts.add(tmpProduct1);

		Product2 tmpproduct2 = new Product2();
		tmpproduct2.IsActive = true;
		tmpproduct2.Family = 'Test Family2';
		tmpproduct2.Name = 'Test product2';
		tmpproduct2.CustomerRef__c = 'CustomerRef2';
		newProducts.add(tmpProduct2);

		Product2 tmpproduct3 = new Product2();
		tmpproduct3.IsActive = true;
		tmpproduct3.Family = 'Test Family3';
		tmpproduct3.Name = 'Test product3';
		tmpproduct3.CustomerRef__c = 'CustomerRef3';
		newProducts.add(tmpProduct3);

		Product2 tmpproduct4 = new Product2();
		tmpproduct4.IsActive = true;
		tmpproduct4.Family = 'Test Family4';
		tmpproduct4.Name = 'Test product4';
		tmpproduct4.CustomerRef__c = 'CustomerRef4';
		newProducts.add(tmpProduct4);

		Product2 tmpproduct5 = new Product2();
		tmpproduct5.IsActive = true;
		tmpproduct5.Family = 'Test Family5';
		tmpproduct5.Name = 'Test product5';
		tmpproduct5.CustomerRef__c = 'CustomerRef5';
		newProducts.add(tmpProduct5);


		insert newProducts;

		Pricebook2 standardPB = [select id from Pricebook2 where isStandard = true];

		//#
		//# Create and insert all test pricebook entries
		//# 

		List < PricebookEntry > newPricebookEntries = new List < PricebookEntry > ();

		PricebookEntry newPBE1 = new PricebookEntry(
		Product2Id = tmpproduct1.id,
		isActive = true,
		//  PriceBook2Id                = priceBook.id,
		PriceBook2Id = standardPB.id,
		UnitPrice = 100.0,
		UseStandardPrice = false);
		newPricebookEntries.add(newPBE1);

		PricebookEntry newPBE2 = new PricebookEntry(
		Product2Id = tmpproduct2.id,
		isActive = true,
		//PriceBook2Id              = priceBook.id,
		PriceBook2Id = standardPB.id,
		UnitPrice = 200.0,
		UseStandardPrice = false);
		newPricebookEntries.add(newPBE2);

		PricebookEntry newPBE3 = new PricebookEntry(
		Product2Id = tmpproduct3.id,
		isActive = true,
		//PriceBook2Id              = priceBook.id,
		PriceBook2Id = standardPB.id,
		UnitPrice = 300.0,
		UseStandardPrice = false);
		newPricebookEntries.add(newPBE3);

		PricebookEntry newPBE4 = new PricebookEntry(
		Product2Id = tmpproduct4.id,
		isActive = true,
		//PriceBook2Id              = priceBook.id,
		PriceBook2Id = standardPB.id,
		UnitPrice = 400.0,
		UseStandardPrice = false);
		newPricebookEntries.add(newPBE4);

		PricebookEntry newPBE5 = new PricebookEntry(
		Product2Id = tmpproduct5.id,
		isActive = true,
		//PriceBook2Id              = priceBook.id,
		PriceBook2Id = standardPB.id,
		UnitPrice = 500.0,
		UseStandardPrice = false);
		newPricebookEntries.add(newPBE5);


		insert newPricebookEntries;



		//#
		//# test Notifications (AllOpportunityLineItemTriggers)
		//#

		List < OpportunityLineItem > newOLIs = new List < OpportunityLineItem > ();

		OpportunityLineItem opplineitem1 = new OpportunityLineItem();
		opplineitem1.OpportunityId = oppty.Id;
		opplineitem1.Quantity = 10;
		opplineitem1.UnitPrice = 100;
		opplineitem1.PricebookEntryId = newPBE1.Id;
		opplineitem1.ServiceDate = date.today() + 5;
		opplineitem1.active__c = true;
		newOLIs.add(opplineitem1);

		OpportunityLineItem opplineitem2 = new OpportunityLineItem();
		opplineitem2.OpportunityId = oppty.Id;
		opplineitem2.Quantity = 10;
		opplineitem2.UnitPrice = 100;
		opplineitem2.PricebookEntryId = newPBE2.Id;
		opplineitem2.ServiceDate = date.today() + 5;
		opplineitem1.active__c = true;
		newOLIs.add(opplineitem2);

		OpportunityLineItem opplineitem3 = new OpportunityLineItem();
		opplineitem3.OpportunityId = oppty.Id;
		opplineitem3.Quantity = 10;
		opplineitem3.UnitPrice = 100;
		opplineitem3.PricebookEntryId = newPBE3.Id;
		opplineitem3.ServiceDate = date.today() + 5;
		opplineitem1.active__c = true;
		newOLIs.add(opplineitem3);

		OpportunityLineItem opplineitem4 = new OpportunityLineItem();
		opplineitem4.OpportunityId = oppty.Id;
		opplineitem4.Quantity = 10;
		opplineitem4.UnitPrice = 100;
		opplineitem4.PricebookEntryId = newPBE4.Id;
		opplineitem4.ServiceDate = date.today() + 5;
		opplineitem1.active__c = true;
		newOLIs.add(opplineitem4);

		OpportunityLineItem opplineitem5 = new OpportunityLineItem();
		opplineitem5.OpportunityId = oppty.Id;
		opplineitem5.Quantity = 10;
		opplineitem5.UnitPrice = 100;
		opplineitem5.PricebookEntryId = newPBE5.Id;
		opplineitem5.ServiceDate = date.today() + 5;
		opplineitem1.active__c = true;
		newOLIs.add(opplineitem5);


		system.runAs(testUser) {
			insert newOLIs;
		}

		newConstH.IsManager__c = true;
		update newConstH;

		System.debug('newOLIs[0]:' + newOLIs[0]);

		return newOLIs[0];

	}



	static testMethod void ActivateDeactivatePitchIdeaContrTest() {

		List < Selectoption > inactiveOpts;
		List < Selectoption > lostToCompOptions;


		OpportunityLineItem oli = CreateTestOpportunity();


		ApexPages.currentPage().getParameters().put('id', oli.Id);
		Apexpages.Standardcontroller stdCon = new Apexpages.Standardcontroller(oli);


		Test.startTest();


		system.runAs(testUser) {

			ActivateDeactivatePitchIdeaController adpic = new ActivateDeactivatePitchIdeaController(stdCon);

			inactiveOpts = adpic.getInactiveOpts();
			lostToCompOptions = adpic.getLostToCompOpts();
			adpic.oli = oli;
			System.debug('pitchIdeaId:' + adpic.pitchIdeaId);

			//#
			//# Deactivate Pitch Idea (cover all possibilities)
			//#

			adpic.Deactivate();

			System.debug('oli:' + oli);

			adpic.inactiveReason = 'Lost to Competitor';
			adpic.Deactivate();
			System.debug('oli:' + oli);

			adpic.competitorTitle = 'Mobile';
			adpic.Deactivate();
			System.debug('oli:' + oli);


			//#
			//# Activate deactivated Pitch Idea (cover all possibilities)
			//#

			Inactive_Pitch_Idea__c ipi = [
			select id, name, Reason_for_Inactive2__c, Opportunity__c, Opportunity__r.Id, Opportunity__r.CloseDate, ServiceDate__c
			from Inactive_Pitch_Idea__c
			//where Reason_for_Inactive2__c = 'Lost to Competitor' and Competitor_Title__c = 'Mobile' 
			limit 1];

			System.debug('ipi:' + ipi);
			ApexPages.currentPage().getParameters().put('id', ipi.Id);


			Apexpages.Standardcontroller stdCon2 = new Apexpages.Standardcontroller(ipi);
			ActivateDeactivatePitchIdeaController adpic2 = new ActivateDeactivatePitchIdeaController(stdCon2);


			ipi.ServiceDate__c = date.today() - 10;
			try {
				update ipi;
			} catch (Exception e) {
				system.debug('>>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
			}


			ipi.ServiceDate__c = date.today() + 20;
			ipi.Cost__c = 10000;
			update ipi;


			adpic2.Activate();

			adpic.cancel();

		}


		Test.stopTest();

	}
}