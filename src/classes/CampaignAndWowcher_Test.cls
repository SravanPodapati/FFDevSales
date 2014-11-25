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
 */@isTest(SeeAllData = true)
private class CampaignAndWowcher_Test {
	static {
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();

		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		map < String, BookingSystemCountryCodes__c > bSCC = BookingSystemCountryCodes__c.getAll();
		if (bSCC.size() <= 0) insert TestData.createCountryCodeSettings();

	}

	static User testUser = [
	select name, email, ProfileId, Profile.Name
	from User
	where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
	limit 1];

	static testmethod void testCheckContactsOnCampaignMembers() {
		Campaign newCampaign = new Campaign(name = 'Test Campaign');
		insert newCampaign;

		/*List<RecordType> accountRecType = [
                                            Select
                                                Name
                                            From RecordType
                                            Where SObjectType = 'Account'
                                            And   DeveloperName = 'Advertiser'
                                            ];*/

		Map < String, RecordTypeInfo > accountRecTypeByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
		final String developerName = 'Advertiser';

		test.startTest();
		Account newAccount = new Account(
		name = 'Test Account',
		RecordTypeId = accountRecTypeByName.get(developerName).RecordTypeId,
		Type = 'Direct Advertiser',
		BillingStreet = 'Westminster Rd',
		BillingPostalCode = 'SW1 2AU',
		Industry = 'Display', Phone = '01236547891');
		insert newAccount;
		test.stopTest();

		Contact newContact = new Contact(AccountId = newAccount.Id, FirstName = 'Johnny', LastName = 'Doe', Active__c = True);
		insert newContact;

		CampaignMember newCampaignMember = new CampaignMember(CampaignId = newCampaign.Id, ContactId = newContact.Id);
		insert newCampaignMember;

		List < AggregateResult > countCampaignMember = [Select
		Count(Id) ccount
		From CampaignMember
		Where Id = : newCampaignMember.Id];
		Integer result;
		for (AggregateResult ag: countCampaignMember) {
			result = Integer.ValueOf(ag.get('ccount'));
		}
		System.assert(result > 0);

		newContact.Active__c = False;
		newContact.Reason_for_inactive__c = 'Test Feature';
		update newContact;

		try {
			update newCampaignMember;
		} catch (DMLException d) {
			System.debug(d.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION',
			d.getDmlStatusCode(0));
		}
	}

	static testmethod void testWowcherPitch() {

		User wowcherTestUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true
		and Profile.Name Like 'Wowcher Manager%'
		limit 1];

		Map < string, RecordTypeInfo > oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
		Id inStoreRecordTypeId = oppRecTypesByName.get('Wowcher Merchant (instore)').RecordTypeId;

		System.debug('wowcherTestUser:' + wowcherTestUser);




		List < RecordType > accountRecType = [
		Select
		Name
		From RecordType
		Where SObjectType = 'Account'
		And DeveloperName = 'Advertiser'];
		Account newAccount = new Account();
		Contact newContact = new Contact();
		System.runAs(testUser) {
			newAccount = new Account(
			name = 'Test Account',
			RecordTypeId = accountRecType[0].Id,
			Type = 'Direct Advertiser',
			BillingStreet = 'Westminster Rd',
			BillingPostalCode = 'SW1 2AU',
			BillingCountry = 'United Kingdom',
			Industry = 'Display',
			isMerchant__c = True,
			isActive__c = True,
			Phone = '01236547896');
			insert newAccount;

			newContact = new Contact(AccountId = newAccount.Id, FirstName = 'John', LastName = 'Doe', Active__c = True);
			insert newContact;
		}


		// System.runAs(wowcherTestUser)
		// {   
		test.startTest();
		Opportunity op = new Opportunity(
		Name = 'Test',
		AccountId = newAccount.Id,
		Deal_Region__c = 'Scotland',
		Deal_Location__c = 'Aberdeen',
		Opportunity_Type__c = 'InStore',
		RecordTypeId = inStoreRecordTypeId,
		StageName = 'Open',
		CloseDate = Date.today(),
		OwnerId = wowcherTestUser.Id);
		insert op;
		test.stopTest();





		// }



	}
	////////////////////////////////////////////////////////////    
	static testmethod void testMailClassTask() {

		User mailClassTestUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true
		and Profile.Name Like 'System Administrator%'
		limit 1];

		Map < string, RecordTypeInfo > oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
		Id oppRecordTypeId = oppRecTypesByName.get('Pitch').RecordTypeId;

		System.debug('mailClassTestUser:' + mailClassTestUser);


		List < RecordType > agencyRecType = [
		Select
		Name
		From RecordType
		Where SObjectType = 'Account'
		And DeveloperName = 'Agency'];

		List < RecordType > accRecType = [
		Select
		Name
		From RecordType
		Where SObjectType = 'Account'
		And DeveloperName = 'Advertiser'];



		Pricebook2 testPB = [Select
		name
		From Pricebook2
		Where isActive = true
		and name Like 'Mail Classified'
		limit 1];

		Account newAccount = new Account();
		Contact newContact = new Contact();
		System.runAs(mailClassTestUser) {
			newAccount = new Account(
			name = 'Test Account1',
			RecordTypeId = accRecType[0].Id,
			Type = 'Direct Advertiser',
			BillingStreet = 'Westminster Rd',
			BillingPostalCode = 'SW1 2AU',
			BillingCountry = 'United Kingdom',
			Industry = 'Display',
			isActive__c = True,
			Phone = '12365478963');
			insert newAccount;


			Account newAgency = new Account(
			Name = 'Test Account2',
			AccountNumber = 'ABC1234562',
			RecordTypeId = agencyRecType[0].Id,
			BillingStreet = 'Street',
			BillingState = 'TestState',
			BillingPostalCode = 'A111AA',
			BillingCountry = 'United Kingdom',
			BillingCity = 'City',
			Phone = '01236547896');
			insert newAgency;

			/*Contact cnt = new Contact();
            cnt.AccountId           = newAgency.Id;
            cnt.LastName            = 'Test Last Name';
            cnt.FirstName           = 'Test First Name';
            cnt.MailingCity         = 'Test Mailing City';
            cnt.MailingCountry      = 'Test Mailing Country';
            cnt.MailingPostalCode   = 'TestMPC';
            cnt.MailingState        = 'Test Mailing State';
            cnt.MailingStreet       = 'Test Mailing Street';
            cnt.MailingCountry          = 'United Kingdom';
        insert cnt;*/
			test.startTest();
			Opportunity op = new Opportunity(
			Name = 'Test MailClass1',
			AccountId = newAccount.Id,
			Agency__c = newAgency.id,
			RecordTypeId = oppRecordTypeId,
			StageName = 'Preparation',
			CloseDate = Date.today(),
			OwnerId = mailClassTestUser.id);
			insert op;

			Opportunity op1 = new Opportunity(
			Name = 'Test MailClass2',
			AccountId = newAccount.Id,
			Agency__c = newAgency.id,
			RecordTypeId = oppRecordTypeId,
			StageName = 'Brief',
			CloseDate = Date.today(),
			OwnerId = mailClassTestUser.id);
			insert op1;


			//OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId=op.Id, Role='Agency Planning', ContactId=cnt.Id, IsPrimary=True);
			//insert opContactRole;

			List < Opportunity > newopps = new List < Opportunity > ();

			//op1.

			newopps.add(op);
			newopps.add(op1);

			List < Task > newtasksToUpdate = [Select id, Subject, Description from Task
			Where WhatId IN: newopps];

			//System.assertEquals(2, newtasksToUpdate.size());
			//System.assertEquals(2, newtasksToUpdate.size());    

			test.stopTest();
		}



	}

	/*  MobilePhoneNo field has been removed from task as it was not necessary  
    static testmethod void testTaskMobileNo()
    {
         Map<String,RecordTypeInfo> accountRecTypeByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
         final String developerName = 'Advertiser';

                    
         Account acct = new Account(
                Name                = 'Test - TestContactMobileNo', 
                AccountNumber       = 'ABC123456',
                Industry            = 'Finance',
                Type                = 'Booking Agency',
                BillingStreet       = 'Agency Street',
                BillingState        = 'Agency TestState',
                BillingPostalCode   = 'A111AA', 
                BillingCountry      = 'United Kingdom', 
                BillingCity         = 'Agency City',
                RecordTypeId        = accountRecTypeByName.get(developerName).RecordTypeId
        );
        insert acct;
        
        Contact cnt = new Contact (
            AccountId = acct.Id,
            FirstName = 'Jane',
            LastName = 'Doe',
            MobilePhone = '07352435654'         
        );
        
        insert cnt;
        
        Task tsk = new Task(
                            WhatId = acct.Id,
                            Subject = 'Call',
                            WhoId = cnt.Id
                            );
        insert tsk;
        
        Task insertedTask = [Select Contact_Mobile_No__c
                            From Task
                            Where Id = :tsk.Id];
                            
        System.assertEquals('07352435654', insertedTask.Contact_Mobile_No__c);
        
    }*/


	/*  static testmethod void testPopMac()
    {
        String advertiserRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Advertiser_Record_Type__c).getRecordTypeId();
        String agencyRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Agency_Record_Type__c ).getRecordTypeId();
        
        String popMacOpptyRecTypeId = 
                [
                select id 
                from RecordType 
                where DeveloperName = 'PopMac'
                and SObjectType = 'Opportunity'
                ].id; 
                        
        Pricebook2  testPB          = [select name  from Pricebook2                 limit 1];
        String      testProfileId   = [select id        from Profile                    limit 1].id;
        
        
        //#  
        //# Ensure that the test results will not depend
        //# on running user's Custom Settings
        //# 
        
        ConstantsH__c constH = 
            [
            select Name, Price_Book__c, Acc_and_Contact_owner__c 
            from ConstantsH__c
            where SetupOwnerId = :testUser.ProfileId 
            limit 1
            ];
        delete constH;
        
        ConstantsH__c newConstH = new ConstantsH__c
            (
                Acc_and_Contact_owner__c    = testUser.Name,
                Department__c               = 'None',
                IsManager__c                = false,
                Price_Book__c               = testPB.Name,
                SetupOwnerId                = testUser.ProfileId        
            );
        insert newConstH;
        

        User tmpUser    = [select id from User where UserType =: 'Standard' and isActive = true LIMIT 1];
        // User tmpUser = [select id from User where id='005D0000001umqA'];
    
        system.runAs(tmpUser)
        {
            Account acct = new Account
                    (
                    Name                = 'Test Account', 
                    AccountNumber       = 'ABC123456',
                    Type                = 'Client',
                    BillingStreet       = 'Street',
                    BillingState        = 'TestState',
                    BillingPostalCode   = 'A111AA', 
                    BillingCountry      = 'Country', 
                    BillingCity         = 'City',
                    Industry            = 'Finance',
                    RecordTypeId        = advertiserRecTypeId
                    );
            insert acct;
      
            Account acct2 = new Account
                    (
                    Name                = 'Test Account2', 
                    AccountNumber       = 'ABC1234562',
                    RecordTypeId        = agencyRecTypeId,
                    BillingStreet       = 'Street',
                    BillingState        = 'TestState',
                    BillingPostalCode   = 'A111AA', 
                    BillingCountry      = 'Country', 
                    BillingCity         = 'City',
                    ownerId             = tmpUser.Id
                    );
            insert acct2;
                   
            
            Opportunity oppty = new Opportunity
                    (
                    Name                = 'Test Oppty', 
                    AccountId           = acct.id, 
                    StageName           = 'Final Negotiations', 
                    CloseDate           = Date.today(),
                    LeadSource          = 'Organic - Google',
                    // OwnerId              = testUser.Id,
                    Followup_Due_Date__c= Date.today().addDays(4),
                    Followup_Subject__c ='Test Subject',
                    RecordTypeId        = popMacOpptyRecTypeId,
                    Agency__c           = acct2.Id
                    );      
            
            try
            {
                insert oppty;
            }
            catch (exception e) 
            { 
                system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
            }
            
            User tmpUser2   = [Select
                                id 
                                From User
                                Where UserType =: 'Standard' 
                                And isActive = true
                                And Id <>:tmpUser.Id
                                LIMIT 1];
            oppty.OwnerId = tmpUser.Id;
            update oppty;
            oppty.StageName = 'Closed Lost';
            oppty.Close_Reason_Description__c ='Closed and Lost';
            oppty.Loss_Reason__c = 'Activity already booked';
            update oppty;
            List<Task> addedTasks = [Select
                                        Id
                                    From Task
                                    Where WhatId = :oppty.Id];
            System.assert(addedTasks.size()>0);
        }

      }*/
}