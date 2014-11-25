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
private class RevenueSchedule_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testMethod void TestRevenueSchedule() {

		Constants__c oldC = [select id, Name from Constants__c where Name = 'All'
		limit 1];
		if (oldC != null) delete oldC;

		Constants__c newC = new Constants__c(
		Name = 'All',
		Regular_Opp_Record_Type__c = 'New_Business',
		Media_Partner_Record_Type__c = 'Media_Partner',
		Media_Lead_Opp_Record_Type__c = 'Media_Opportinities',
		Agency_Record_Type__c = 'Agency',
		Advertiser_Record_Type__c = 'Advertiser',
		CustomerRef5email__c = 'ssfoperative@anmedia.co.uk.andev',
		CustomerRef4email__c = 'ssfoperative@anmedia.co.uk.andev',
		CustomerRef3email__c = 'ssfoperative@anmedia.co.uk.andev',
		CustomerRef2email__c = 'ssfoperative@anmedia.co.uk.andev',
		CustomerRef1email__c = 'ssfoperative@anmedia.co.uk.andev');
		insert newC;

		// Set up an Account
		String advertiserRecTypeId = [Select id From RecordType Where Name = : Constants__c.getInstance('All').Advertiser_Record_Type__c limit 1].id;
		String agencyRecTypeId = [Select id from RecordType Where Name = : Constants__C.getInstance('All').Agency_Record_Type__c limit 1].id;

		User tmpUser = [select id from User where UserType = : 'Standard' /*and managerId != null*/ and isActive = true LIMIT 1];
		User testUser = [select name, email, ProfileId, Profile.Name from User where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
		limit 1];

		List < Pricebook2 > standardPB = [select id, name from Pricebook2 where isStandard = true limit 1];
		// system.debug('+++++++++ Standard Pricebook: ' + testPB);

		String testProfileId = [select id from Profile limit 1].id;

		ConstantsH__c oldConstH = [select id, Name, Price_Book__c, Acc_and_Contact_owner__c from ConstantsH__c where SetupOwnerId = : testUser.ProfileId limit 1];
		if (oldConstH != null) delete oldConstH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'None',
		IsManager__c = false,
		Price_Book__c = standardPB[0].Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		List < Account > acctsToInsert = new List < Account > ();

		Account client = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId,
		BillingCountry = 'United Kingdom',
		ownerId = tmpUser.Id,
		BillingPostalCode = 'A111AA',
		Phone = '0123654789654');
		acctsToInsert.Add(client);

		Account agency = new Account(
		Name = 'Test Agency',
		AccountNumber = 'AGN123456',
		Type = 'Billing Agency',
		Industry = 'Finance',
		RecordTypeId = agencyRecTypeId,
		BillingStreet = '1',
		BillingPostalCode = 'A111AA',
		Phone = '0123654789654',
		BillingCountry = 'United Kingdom',
		ownerId = tmpUser.Id);
		acctsToInsert.Add(agency);
		//system.debug('++++++++++ Accounts: ' + acctsToInsert);

		insert acctsToInsert;

		Opportunity opp = new Opportunity(
		Name = 'Test Opportunity',
		AccountId = acctsToInsert[0].Id,
		Agency__c = acctsToInsert[1].Id,
		StageName = 'Qualification',
		CloseDate = date.newinstance(2012, 10, 20));
		insert opp;

		Product2 prod1 = new Product2(
		Name = 'Prod1',
		Schedule_Revenue__c = 'Monthly',
		Revenue_Group__c = 'Digital',
		IsActive = true);
		insert prod1;

		PricebookEntry pbeToInsert = new PricebookEntry(
		UnitPrice = 100,
		Product2Id = prod1.Id,
		Pricebook2Id = standardPB[0].Id,
		IsActive = true,
		CurrencyIsoCode = 'GBP');
		insert pbeToInsert;

		Date firstDate = date.newinstance(2012, 10, 20);
		Date lastDate = date.newinstance(2013, 10, 20);
		OpportunityLineItem oli = new OpportunityLineItem(
		Quantity = 1,
		PricebookEntryId = pbeToInsert.Id,
		OpportunityId = opp.Id,
		ServiceDate = firstDate,
		First_Insertion_Date__c = firstDate,
		Last_Insertion_Date__c = lastDate,
		Active__c = true,
		UnitPrice = 100);
		insert oli;

		OpportunityLineItem o = [select ServiceDate, Last_Insertion_Date__c, UnitPrice from OpportunityLineItem where ServiceDate = : firstDate limit 1];

		RevenueSchedule rs = new RevenueSchedule();
		List < RevenueSchedule.RevenueScheduleItem > rsi;
		rsi = rs.generateSchedule(o.ServiceDate, o.Last_Insertion_Date__c, o.UnitPrice);

	}
}