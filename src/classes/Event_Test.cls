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
private class Event_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testMethod void testEventTrigger() {
		String advertiserRecTypeId;
		String agencyRecTypeId;
		User currentUser = New User(Id = (Id) UserInfo.getUserId());


		User testUser = [
		Select name, email, ProfileId, Profile.Name
		From User
		Where isActive = true /*and managerId != null*/
		And Profile.Name = 'System Administrator'
		Limit 1];


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
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		List < RecordType > oppRecType = [
		Select DeveloperName
		From RecordType
		Where SObjectType = 'Account'];
		for (RecordType r: oppRecType) {
			if (r.DeveloperName == Constants__c.getInstance('All').Advertiser_Record_Type__c) {
				advertiserRecTypeId = r.Id;
			} else if (r.DeveloperName == Constants__c.getInstance('All').Agency_Record_Type__c) {
				agencyRecTypeId = r.Id;
			}
		}

		Account acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId,
		BillingCountry = 'United Kingdom');
		insert acct;

		Id checkLondonRecordTypeId = Schema.SObjectType.event.getRecordTypeInfosByName().get('Structured Sales Meeting').getRecordTypeId();
		System.debug('checkLondonRecordTypeId:' + checkLondonRecordTypeId);
		Group londonClassifiedGroup = [
		Select
		Id
		From Group
		Where DeveloperName = 'LonClassMarketingEmailGroup'];

		if (londonClassifiedGroup == null) {
			londonClassifiedGroup = new Group(
			Name = 'LonClassMarketingEmailGroup',
			Type = 'Regular');
			insert londonClassifiedGroup;
		}


		List < GroupMember > londonClassMemList = [Select
		UserOrGroupId
		From GroupMember
		Where GroupId = : londonClassifiedGroup.id];
		System.debug('londonClassMemList:' + londonClassMemList);
		User u;
		//if(londonClassMemList.size()==0)
		{
			System.debug('Before Profile');
			Profile p = [SELECT
			Id
			FROM Profile
			WHERE Name = 'London Classified User'];

			UserRole r = [
			Select
			Id
			From UserRole
			Where Name Like '%London Classified%'
			limit 1];

			System.debug('before user');
			u = new User(Alias = 'lonclass', Email = 'londonclass@anmedia.co.uk',
			EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US', ProfileId = p.Id, UserRoleId = r.Id,
			TimeZoneSidKey = 'America/Los_Angeles', UserName = 'londonclass@anmedia.co.uk',
			isActive = true);

			System.runAs(currentUser) {
				insert u;
			}

			System.debug('****user****' + u.id);

			GroupMember grpMem = new GroupMember(
			GroupId = londonClassifiedGroup.Id,
			UserOrGroupId = u.Id);
			System.runas(currentUser) {
				insert grpMem;
			}
			londonClassMemList = [Select
			UserOrGroupId
			From GroupMember
			Where GroupId = : londonClassifiedGroup.id];
		}

		Event ev;
		List < Business_Team_Activity__c > btaList = [Select Name
		From Business_Team_Activity__c
		Where Account__c = : acct.Id
		And Name like '%London Class%'];
		System.debug('btaList:' + btaList);
		System.debug('before event');
		if (checkLondonRecordTypeId != null) {

			System.debug('before insert');
			//User usr = [Select id from User where Id = :UserInfo.getUserId()];    
			//Try
			//{
			// System.runAs(u)
			{
				/*Business_Team_Activity__c bta = [Select Id
                                                    From Business_Team_Activity__c
                                                    Where Account__c = :acct.Id];*/

				System.debug('Prep event');
				ev = new Event(
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
				// test.startTest();        
				//insert ev;
				//test.stopTest();

				/*String agencyRecTypeId = 
                            [
                            select id 
                             from RecordType 
                            where DeveloperName = :Constants__c.getInstance('All').Agency_Record_Type__c 
                            limit 1
                            ].id;*/

				Account acct2 = new Account(
				Name = 'Test Account2',
				AccountNumber = 'ABC1234562',
				RecordTypeId = agencyRecTypeId,
				BillingStreet = 'Street',
				BillingState = 'TestState',
				BillingPostalCode = 'A111AA',
				BillingCountry = 'United Kingdom',
				BillingCity = 'City',
				Phone = '1234567891');
				insert acct2;

				Opportunity oppty = new Opportunity(
				Name = 'Test Oppty',
				AccountId = acct.id,
				Agency__c = acct2.id,
				StageName = 'Final Negotiations',
				CloseDate = Date.today(),
				LeadSource = 'Organic - Google');

				insert oppty;

				Event ev2 = new Event(
				RecordTypeId = checkLondonRecordTypeId,
				Deadline_for_Info__c = Date.today(),
				DurationInMinutes = 1200,
				Proposed_Agenda__c = 'Discuss the new product',
				ActivityDateTime = DateTime.now(),
				//WhatId = bta.Id,
				WhatId = oppty.Id,
				Do_you_require_marketing_info__c = 'Yes',
				Description = 'Test');
				System.debug('before insert');
				test.startTest();
				insert ev;
				insert ev2;
				test.stopTest();

			}
			//}
			//Catch(Exception e)
			//{
			//  System.debug(e.getMessage() ); 
			//}
			// Assertion needed here
		}

	}
}