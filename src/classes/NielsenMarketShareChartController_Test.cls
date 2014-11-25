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
private class NielsenMarketShareChartController_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testMethod void myUnitTest() {
		String advertiserRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Advertiser_Record_Type__c).getRecordTypeId();

		Account acctAdv = new Account(
		Name = 'Test Nielsen Account',
		AccountNumber = 'ABC123456',
		Type = 'Advertiser',
		BillingStreet = 'Street',
		BillingState = 'TestState',
		BillingPostalCode = 'SW1 3DE',
		BillingCountry = 'United Kingdom',
		BillingCity = 'London',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acctAdv;

		List < Nielsen_Market_Summary__c > nmsList = new List < Nielsen_Market_Summary__c > ();

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Cinema',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));


		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Daily Mail',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Direct Mail',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Door Drops',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Magazines',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Mail On Sunday',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Metro',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));
		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'National Newspapers',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Outdoor',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Radio',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'Regional Newspapers',
		Expenditure_Month__c = date.today(),
		Expenditure_Amount__c = 5000));

		nmsList.add(new Nielsen_Market_Summary__c(
		AccountId__c = acctAdv.Id,
		Media_Type__c = 'TV',
		Expenditure_Month__c = date.today().addYears(-1),
		Expenditure_Amount__c = 5000));
		insert nmsList;

		ApexPages.StandardController sc = new ApexPages.StandardController(acctAdv);
		NielsenMarketShareChartController testAcc = new NielsenMarketShareChartController(sc);

		PageReference pageRef = Page.NielsenMarketShareChartWithinAccount;

		pageRef.getParameters().put('id', String.valueOf(acctAdv.Id));
		Test.setCurrentPage(pageRef);

		List < NielsenMarketShareChartController.NielsenMarketShare > getList = NielsenMarketShareChartController.getExpenditureChartData();
		System.assert(getList.size() > 0);

	}
}