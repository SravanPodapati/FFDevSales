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
@isTest
private class DirectOrderController_test {

	public static void createSettingsData() {
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
		insert TestData.createOrderParamSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;


	}

	static testMethod void defaultValuesVerification_Test() {
		createSettingsData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
		test.startTest();
		PageReference currentPage = Page.iframepage;
		currentPage.getParameters().put('clientId', '012345');
		currentPage.getParameters().put('agencyId', '012345');
		currentPage.getParameters().put('sopId', 'TestsopID');
		currentPage.getParameters().put('cciCusId', '0123');
		currentPage.getParameters().put('bookingId', '123456');
		currentPage.getParameters().put('bookingcciId', '0123456');
		currentPage.getParameters().put('parentcciId', '0987654');

		DirectOrderController controller = new DirectOrderController(new ApexPages.Standardcontroller(acc));
		test.setCurrentPage(currentPage);

		test.stopTest();
	}

	static testmethod void createOrderException_Test() {
		createSettingsData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
		test.startTest();
		PageReference currentPage = Page.iframepage;
		currentPage.getParameters().put('clientId', '');
		currentPage.getParameters().put('agencyId', '');
		currentPage.getParameters().put('sopId', '');
		currentPage.getParameters().put('cciCusId', '');
		currentPage.getParameters().put('bookingId', '');
		currentPage.getParameters().put('bookingcciId', '');
		currentPage.getParameters().put('parentcciId', '');
		currentPage.getParameters().put('holdingCompanycciId', '');

		test.setCurrentPage(currentPage);
		DirectOrderController controller = new DirectOrderController(new ApexPages.Standardcontroller(acc));
		try {
			controller.createOrder();
		} catch (Exception e) {
			boolean expectedMessage = e.getMessage().contains(Label.CCI_Exception) ? true : false;
			system.assertEquals(expectedMessage, true);
			system.assertEquals(controller.renderPlugin, false);
			system.assertEquals(controller.renderError, true);
		}

		test.stopTest();
	}

}