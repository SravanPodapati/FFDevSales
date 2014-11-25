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
 */@isTest
private class ViewNielsenDataWithinAccountControl_Test {

	static testMethod void testNielsenData() {
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		insert TestData.createCountriesList();

		Map < String, RecordTypeInfo > oppRecTypesByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
		final String developerName = 'Advertiser';

		id Profile1 = userinfo.getProfileId();
		String timeZone = UserInfo.getTimeZone().getID();

		User ownerInit = new User(ProfileId = Profile1, LastName = 'A&N Media', Alias = 'ANMedia', email = 'a@dmgmedia.co.uk', username = 'A&NMedia@dmgmedia.co.uk', TimeZoneSidKey = timeZone, LocaleSidKey = 'en_GB', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
		insert ownerInit;

		User owner = [Select Name, ProfileId
		From User
		Where Id = : ownerInit.Id];

		System.debug(owner.Name);

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = owner.Name,
		Department__c = 'IT',
		IsManager__c = false,
		Price_Book__c = owner.Name,
		SetupOwnerId = owner.ProfileId);
		insert newConstH;

		Account acct = new Account(
		Name = 'Test - TestNielsenData',
		AccountNumber = 'ABC123456',
		Industry = 'Finance',
		Type = 'Booking Agency',
		BillingStreet = 'Agency Street',
		BillingState = 'Agency TestState',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'Agency City',
		RecordTypeId = oppRecTypesByName.get(developerName).RecordTypeId);
		insert acct;

		Nielsen_Data__c nd = new Nielsen_Data__c(
		Publication__c = 'Metro London',
		Publication_Group__c = '',
		Media_Type__c = 'Press',
		Last_Seen__c = date.today(),
		Incidence__c = 1,
		First_Seen__c = date.today(),
		Expenditure__c = 100000,
		Description__c = 'test',
		CreativeId__c = 123456,
		Category__c = 'test',
		Brand_Name__c = 'test',
		Advert_Size__c = '10X10',
		AccountID__c = acct.Id);
		insert nd;

		ApexPages.StandardController sc = new ApexPages.StandardController(acct);
		ViewNielsenDataWithinAccountController c = new ViewNielsenDataWithinAccountController(sc);
		System.assertEquals(1, c.getAllNielsenData().size());
	}
}