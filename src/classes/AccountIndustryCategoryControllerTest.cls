@isTest(seeAllData = false)
public with sharing class AccountIndustryCategoryControllerTest {

	public static testMethod void testAcccIndCategoryControllerSave() {
		insert TestData.createCountriesList();
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

		insert u;
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry = '04-Drink';
		acc.Industry_Sub_Category__c = '04.01-Alcohalic Drinks';
		acc.Industry_Minor_Category__c = '04.01.10 BEER';
		insert acc;
		Map < String, List < String >> parentDepMapData = new Map < String, List < String >> ();
		//insert acc;
		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
		List < String > subValues = new List < String > ();
		subValues.add('04.01-Alcohalic Drinks');
		subValues.add('04.02-SOFT DRINKS');
		subValues.add('04.03-ORGANIC DRINKS');

		List < String > minorValues = new List < String > ();
		minorValues.add('04.01.00 ALCOHLIC DRINKS');
		minorValues.add('04.01.10 BEER');

		controller.parentPicklistVal = '04-Drink';
		controller.childMultiPicklistVal = subValues;
		controller.ChildSinglePicklistVal = minorValues;



		controller.save();
		// controller.getParentPicklistOptions();
		//controller.getChildMultiPicklistOptions();
		// controller.getChildSinglePicklistOptions();
		controller.edit();
	}
}