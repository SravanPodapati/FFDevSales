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
 */
@isTest(SeeAllData=true)
private class ViewBTAHistoryWithinAccount_Test 
{

static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}

	static testMethod void TestViewBTAHistWithinAcc() {
		User testUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true
		and Profile.Name = 'System Administrator'
		limit 1];



		String testProfileId = [Select id
		From Profile
		Limit 1].id;


		//#  
		//# Ensure that the test results will not depend
		//# on running user's Custom Settings
		//# 
/*
		ConstantsH__c constH = [
		select Name, Department__c, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;
*/
		/*Pricebook2   testPB          = [select name 
                                        from Pricebook2
                                        where isActive = true
                                        limit 1]; 

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'IT',
		IsManager__c = false,
		Price_Book__c = 'Test', // testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

*/
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
		BillingCountry = 'United Kingdom',
		BillingPostalCode = 'a111aa',
		Phone = '01236547896');
		insert acct;

		Account agency = new Account(
		Name = 'Test Agency',
		AccountNumber = 'AGN123456',
		Type = 'Billing Agency',
		Industry = 'Finance',
		RecordTypeId = agencyRecTypeId,
		BillingStreet = '1',
		BillingPostalCode = 'a111aa',
		BillingCountry = 'United Kingdom',
		Phone = '01236547896');
		insert agency;

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


		Opportunity oppty = new Opportunity(
		Name = 'Test Oppty',
		AccountId = acct.id,
		Agency__c = agency.id,
		StageName = 'Final Negotiations',
		CloseDate = Date.today(),
		LeadSource = 'Organic - Google',
		OwnerId = testUser.Id);
		
		Campaign newCampaign = new Campaign(name = 'Test NK Campaign');
		insert newCampaign;
		
		try {
			insert oppty;
		} catch (exception e) {
			system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
		}

		system.debug('>>>>>>>>>>>>>>>>> oppty : ' + oppty);
		////////////////////////////////////////////////////////////////////////////

		/*       OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId=oppty.Id, Role='Agency Planning', ContactId=cnt.Id, IsPrimary=True);
        insert opContactRole;
        
        Pricebook2 priceBook = 
                [
                Select
                    p.Name
                From Pricebook2 p 
                Where p.Name = :newConstH.Price_Book__c
                Limit 1
                ];
                
        
        PricebookEntry priceBookEntry = 
                [
                Select 
                    name,
                    Product2Id 
                From PricebookEntry 
                Where pricebook2Id =: priceBook.Id 
                limit 1
                ];
        
        
        OpportunitylineItem oppline1 = new OpportunitylineItem
                (
                priceBookEntryId    = priceBookEntry.Id, 
                OpportunityId       = oppty.id, 
                Quantity            = 1, 
                ServiceDate         = Date.today()+1,
                UnitPrice           = 100.00,
                URN__c              = '1234');
                
        try
        { 
            insert oppline1;
            oppty.StageName = 'Closed Won';
            update oppty;
        }
        catch (exception e) 
        { 
            system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage()); 
        }*/

		List < Business_Team_Activity__c > btaList = [Select Name
		From Business_Team_Activity__c
		Where Account__c = : acct.Id];
		System.debug('btaList:' + btaList);

		Id checkLondonRecordTypeId = Schema.SObjectType.event.getRecordTypeInfosByName().get('Structured Sales Meeting').getRecordTypeId();
		System.debug('checkLondonRecordTypeId:' + checkLondonRecordTypeId);
		
		 Id checkTaskLondonRecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('London Classified Task').getRecordTypeId();
		
		/*Group londonClassifiedGroup = [
		Select
		Id
		From Group
		Where DeveloperName = 'LonClassMarketingEmailGroup'];*/
		
		ViewBTAHistoryWithinAccount conViewNotes;


		Test.startTest();

		//system.runAs(testUser) {
			ApexPages.StandardController sc = new ApexPages.StandardController(acct);
			
			Event ev = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				ActivityDateTime = DateTime.now(),
				//WhatId = bta.Id,
				WhatId = btaList[0].Id,
				Do_you_require_marketing_info__c = 'Yes',
				Proposed_Agenda__c = 'Discuss the new product',
				Description = 'Test');
				System.debug('before insert');
			insert ev;
			
			Event ev1 = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				ActivityDateTime = DateTime.now(),
				//WhatId = bta.Id,
				WhatId = btaList[0].Id,
				Do_you_require_marketing_info__c = 'Yes',
				Proposed_Agenda__c = 'Discuss the new product',
				Description = 'Test');
				System.debug('before insert');
			insert ev1;
			
			Event ev2 = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				ActivityDateTime = DateTime.now(),
				//WhatId = bta.Id,
				WhatId = oppty.Id,
				Do_you_require_marketing_info__c = 'Yes',
				Proposed_Agenda__c = 'Discuss the new product',
				Description = 'Test');
				System.debug('before insert');
			insert ev2;
			
			Event ev3 = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				ActivityDateTime = DateTime.now(),
				//WhatId = bta.Id,
				WhatId = btaList[0].Id,
				Do_you_require_marketing_info__c = 'Yes',
				Proposed_Agenda__c = 'Discuss the new product',
				Description = 'Test');
				System.debug('before insert');
			insert ev3;
			
			 Task ta1 = new Task (
                                        RecordTypeId = checkTaskLondonRecordTypeId,
                                        Status = 'Completed',
                                        Priority = 'Normal',
                                        Outcome__c = 'Ineffective',
                                        Subject = 'Call',
                                        ActivityDate = System.today(),
                                        WhatId = acct.Id,
                                        Description = 'Test',
                                        Prepare__c='Prepare',
                                        Open__c='Open',
                                        Probe__c='Probe',
                                        Match__c='Match',
                                        Agreement__c='Agreement',
                                        Close__c='Close'
                                        );
             insert ta1;
			
			 Task ta2 = new Task (
                                        RecordTypeId = checkTaskLondonRecordTypeId,
                                        Status = 'Open',
                                        Priority = 'Normal',
                                        Outcome__c = 'Ineffective',
                                        Subject = 'Call',
                                        ActivityDate=date.today()+7,
                                        WhatId = Agency.Id,
                                        WhoId = cnt.Id,
                                        Description = 'Test',
                                        Prepare__c='Prepare',
                                        Open__c='Open',
                                        Probe__c='Probe',
                                        Match__c='Match',
                                        Agreement__c='Agreement',
                                        Close__c='Close'
                                        ); 
			insert ta2;
		ViewBTAHistoryWithinAccount c = new ViewBTAHistoryWithinAccount(sc);
		c.acc = acct;
		c.getallactivitypagination();
		c.getopenactivitypagination();	

		//List < ViewBTAHistoryWithinAccount.openactivitypagination > allNotesList = conViewNotes.openactivitypagination();

			// System.assert(allNotesList.Size()>0);
			//System.assertEquals(4, allNotesList.Size());
		
		

		//}

		Test.stopTest();
	}
    
}