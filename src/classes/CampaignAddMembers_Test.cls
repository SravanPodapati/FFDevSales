@isTest(SeeAllData=true)
public with sharing class CampaignAddMembers_Test {
static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}

	static testMethod void TestCampaignAddMembers() {
		User testUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true
		and Profile.Name = 'System Administrator'
		limit 1];

		String testProfileId = [Select id
		From Profile
		Limit 1].id;
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
		
		Contact cnt1 = new Contact();
		cnt1.AccountId = agency.Id;
		cnt1.LastName = 'Test Last Name1';
		cnt1.FirstName = 'Test First Name1';
		cnt1.MailingCity = 'Test Mailing City';
		cnt1.MailingCountry = 'United Kingdom';
		cnt1.MailingPostalCode = 'TestMPC';
		cnt1.MailingState = 'Test Mailing State';
		cnt1.MailingStreet = 'Test Mailing Street';
		insert cnt1;

		Campaign newCampaign = new Campaign(name = 'Test NK Campaign', IsActive=True);
		insert newCampaign;
		
		List < Business_Team_Activity__c > btaList = [Select Name
		From Business_Team_Activity__c
		Where Account__c = : acct.Id];
		System.debug('btaList:' + btaList);

		Id checkLondonRecordTypeId = Schema.SObjectType.event.getRecordTypeInfosByName().get('Structured Sales Meeting').getRecordTypeId();
		System.debug('checkLondonRecordTypeId:' + checkLondonRecordTypeId);
		
		 Id checkTaskLondonRecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('London Classified Task').getRecordTypeId();
		
		 Test.startTest();

			Event ev = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				ActivityDateTime = DateTime.now(),
				WhatId = newCampaign.Id,
				Strategic_Campaign__c=newCampaign.Id,
				WhoId = cnt.Id,
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
				WhatId = newCampaign.Id,
				Strategic_Campaign__c=newCampaign.Id,
				WhoId = cnt1.Id,
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
				WhatId = newCampaign.Id,
				Strategic_Campaign__c=newCampaign.Id,
				WhoId = cnt.Id,
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
				WhatId = newCampaign.Id,
				Strategic_Campaign__c=newCampaign.Id,
				WhoId = cnt1.Id,
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
                                        WhatId = newCampaign.Id,
                                        Strategic_Campaign__c=newCampaign.Id,
                                        WhoId = cnt.Id,
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
                                        WhatId = newCampaign.Id,
                                        Strategic_Campaign__c=newCampaign.Id,
                                        WhoId = cnt1.Id,
                                        Description = 'Test',
                                        Prepare__c='Prepare',
                                        Open__c='Open',
                                        Probe__c='Probe',
                                        Match__c='Match',
                                        Agreement__c='Agreement',
                                        Close__c='Close'
                                        ); 
			insert ta2;
			Test.stopTest();
        }
}