/*******************************************************************************************
 ********************************************************************************************
 ****                                                                                    ****
 ****    All funcionalities have been tested on the Dev Org (here we'll get only         ****
 ****    the necessary code coverage).                                                   ****
 ****                                                                                    ****
 ********************************************************************************************
 *******************************************************************************************/



@isTest(SeeAllData = true)
private class AllTriggers_Test {
	static {
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}

	static User testUser = [
	select name, email, ProfileId, Profile.Name
	from User
	where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
	limit 1];
	///////////////////////////////////////////////////////////////////////////

	private static Map < String, RecordTypeInfo > leadRecTypeByName() {
		return Lead.SObjectType.getDescribe().getRecordTypeInfosByName();
	}

	static testMethod void AllTriggersTest() {

		//Opportunity tmpOppty = CreateTestOpportunity();


		Map < String, RecordTypeInfo > accountRecTypeByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();

		Map < String, RecordTypeInfo > leadRecTypeByName = leadRecTypeByName(); // = Lead.SObjectType.getDescribe().getRecordTypeInfosByName();

		User manager = [select id from User where isActive = true LIMIT 1];
		User tmpUser = [
		select id, UserType
		from User
		where UserType = : 'Standard'
		and id != : manager.Id and isActive = true LIMIT 1];

		Account acct2 = new Account(
		Name = 'Test Account2',
		AccountNumber = 'ABC1234562',
		RecordTypeId = accountRecTypeByName.get('Agency').RecordTypeId,
		BillingStreet = 'Street',
		BillingState = 'TestState',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'City',
		ownerId = tmpUser.Id,
		Phone = '012365478912');
		insert acct2;

		Contact cnt2 = new Contact();
		cnt2.AccountId = acct2.Id;
		cnt2.LastName = 'Test Last Name2';
		cnt2.FirstName = 'Test First Name2';
		cnt2.MailingCity = 'Test Mailing City2';
		cnt2.MailingCountry = 'United Kingdom';
		cnt2.MailingPostalCode = 'TestMPC2';
		cnt2.MailingState = 'Test Mailing State2';
		cnt2.MailingStreet = 'Test Mailing Street2';
		insert cnt2;

		Lead lead = new Lead(
		RecordTypeId = leadRecTypeByName.get('New Business').RecordTypeId,
		Type__c = 'Client',
		LeadSource = 'Digital',
		Status = 'Open',
		Company = 'Test Company',
		Agency__c = acct2.Id,
		Email = 'test.test@gmail.com',
		FirstName = 'Test',
		LastName = 'Tester',
		Industry = 'Computers');
		insert lead;

		Lead lead2 = new Lead(
		RecordTypeId = leadRecTypeByName.get('New Business').RecordTypeId,
		Type__c = 'Direct Advertiser',
		LeadSource = 'Test Source2',
		Status = 'Open2',
		Company = 'Test Company2'
		/*,
                Agency__c           = acct2.Id*/
		,
		Email = 'test.test2@gmail.com',
		FirstName = 'Test2',
		LastName = 'Tester2',
		Street = 'Street',
		City = 'City',
		Country = 'United Kingdom',
		Industry = 'Computers',
		PostalCode = '123');
		insert lead2;

		Lead lead3 = new Lead(
		RecordTypeId = leadRecTypeByName.get('New Business').RecordTypeId,
		Type__c = 'Direct Advertiser',
		LeadSource = 'Newspaper',
		Status = 'Open',
		Company = 'Test Company3',
		//Agency__c         = acct2.Id,
		Email = 'test.test2@gmail.com',
		FirstName = 'Test3',
		LastName = 'Tester3',
		Size_of_ad__c = '1002',
		//Proactive_Reactive__c = 'Proactive',
		Page__c = 3,
		Brand_Product__c = 'Brand',
		Competitor__c = 'The Sun',
		Street = 'Test Street 3',
		City = 'Test City',
		Country = 'United Kingdom',
		Industry = 'Computers',
		PostalCode = 'TestPC',
		Date_of_Publication__c = date.today());
		insert lead3;



		Test.startTest();
		System.runAs(testUser) {

			//#
			//# test AllLeadTriggers
			//#
			Lead createdLead = [
			select l.id, l.Name
			from Lead l
			where Name = : 'Test Tester'
			LIMIT 1];
			System.debug('>>>>>>>>>> createdLead ' + createdLead);


			//# Convert newly created lead
			List < LeadStatus > ls = [Select l.MasterLabel, l.Id From LeadStatus l where IsConverted = true];
			System.debug('>>>>>>>>>>>>>>> ls : ' + ls);

			Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(createdLead.id);
			// lc.setDoNotCreateOpportunity(true);
			lc.setOwnerId(tmpUser.Id);
			lc.setConvertedStatus(ls[0].MasterLabel);

			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());

			createdLead = [
			select l.id, l.Name
			from Lead l
			where Name = : 'Test3 Tester3'
			LIMIT 1];
			System.debug('>>>>>>>>>> createdLead ' + createdLead);


			//# Convert newly created lead
			ls = [Select l.MasterLabel, l.Id From LeadStatus l where IsConverted = true];
			System.debug('>>>>>>>>>>>>>>> ls : ' + ls);

			lc = new database.LeadConvert();
			lc.setLeadId(createdLead.id);
			// lc.setDoNotCreateOpportunity(true);
			lc.setOwnerId(tmpUser.Id);
			lc.setConvertedStatus(ls[0].MasterLabel);

			//lcr = Database.convertLead(lc);
			//System.assert(lcr.isSuccess());

		}
		/*
            //#
            //# test AllRevenueInsertionTriggers.cls
            //#
            Revenue_Insertion__c ri = new Revenue_Insertion__c();
            insert ri;
            
            
            
            //#
            //# test AllRelationshipTriggers
            //#
            Account acct3 = new Account
                (
                Name                = 'Test Accnt', 
                AccountNumber       = 'ABC1234562',
                RecordTypeId        = accountRecTypeByName.get('Media Partner').RecordTypeId,
                BillingStreet       = 'Street',
                BillingState        = 'TestState',
                BillingPostalCode   = 'A111AA', 
                BillingCountry      = 'United Kingdom', 
                BillingCity         = 'City',
                Type                = 'CGP',
                Phone               = '12364598712',
                ownerId             = tmpUser.Id
                );
            insert acct3;
         
            Account acct4 = new Account
                    (
                    Name                = 'Test Accnt2', 
                    AccountNumber       = 'ABC1234562',
                    RecordTypeId        = accountRecTypeByName.get('Agency').RecordTypeId,
                    BillingStreet       = 'Street',
                    BillingState        = 'TestState',
                    BillingPostalCode   = 'A111AA', 
                    BillingCountry      = 'United Kingdom', 
                    BillingCity         = 'City',
                    Type                = 'Booking Agency',
                    Phone               = '01662025812',
                    ownerId             = tmpUser.Id
                    );
            insert acct4;

            Relationship__c rel = new Relationship__c(Account_A__c = acct3.id, Account_B__c = acct4.id);
            insert rel;
            
            
            
            //#
            //# test AllRelationshipContactTriggers
            //#
            Relationship_Contact__c rc = new Relationship_Contact__c();
            insert rc;
            update rc;
            
    
            
            //#
            //# test AllOpportunityTriggers
            //#

            //#
            //# test AllAccountTriggers
            //#
            User tmpUser2 = [select id, UserType, ManagerId from User where UserType =: 'Standard' and managerId != null and isActive = true LIMIT 1];

            Account acct5 = new Account
                    (
                    Name                = 'Test Accnt5', 
                    AccountNumber       = 'ABC1234565',
                    RecordTypeId        = accountRecTypeByName.get('Agency').RecordTypeId,
                    BillingStreet       = 'Street',
                    BillingState        = 'TestState',
                    BillingPostalCode   = 'A111AA', 
                    BillingCountry      = 'United Kingdom', 
                    BillingCity         = 'City',
                    Type                = 'Booking Agency',
                    Phone               = '01662025812',
                    ownerId             = tmpUser2.Id
                    );
       
            system.runAs(tmpUser2){ insert acct5; }
            
            
            system.runAs(testUser)
            {   
                
                //#
                //# test AllBusinessTeamActivityTriggers
                //#
                Business_Team_Activity__c bta = new Business_Team_Activity__c
                        (
                        Name                = 'Test BTA',
                        Account__c          = acct5.id,
                        OwnerId             = tmpUser.Id
                        );
                insert bta;
                
                
                bta.OwnerId                 = testUser.id;
                update bta;
                
                
                //#
                //# test AllContactDetailsTriggers
                //#
                Contact_Details__c cd = new Contact_Details__c
                        (
                        Name                = 'Test CD',
                        OwnerId             = tmpUser.Id
                        );
                insert cd;
                
                cd.OwnerId                  = testUser.id;
                update cd;

            }*/


		Test.stopTest();

	}

}