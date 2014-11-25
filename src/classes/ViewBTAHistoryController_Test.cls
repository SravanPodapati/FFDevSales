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
private class ViewBTAHistoryController_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	
	static User testUser = [
	select id, name, email, ProfileId, Profile.Name
	from User
	where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
	limit 1];

	static testMethod void myUnitTest() {
		string advertiserRecTypeId = [select id from RecordType where DeveloperName = : Constants__c.getInstance('All').Advertiser_Record_Type__c limit 1].id;

		ConstantsH__c constH = [
		select id, Name, Price_Book__c, Acc_and_Contact_owner__c
		from ConstantsH__c
		where SetupOwnerId = : testUser.ProfileId
		limit 1];
		delete constH;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'Mail Display',
		IsManager__c = false,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		Account acct = new Account(
		Name = 'Test - TestBTAAA',
		AccountNumber = 'ABC123456',
		Industry = 'Finance',
		Type = 'Booking Agency',
		BillingStreet = 'Agency Street',
		BillingState = 'Agency TestState',
		BillingPostalCode = 'A111AA',
		Phone = '01236547896',
		BillingCountry = 'United Kingdom',
		BillingCity = 'Agency City',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		Business_Team_Activity__c bta = new Business_Team_Activity__c(
		Name = newConstH.Department__c,
		Account__c = acct.id);
		insert bta;

		ApexPages.StandardController sc = new ApexPages.StandardController(acct);

		ViewBTAHistoryController c = new ViewBTAHistoryController(sc);
		c.acc = acct;
		c.getactivityPagination();
		c.geteventactivityPagination();
	}
}