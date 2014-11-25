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
public class CCICustomerWrapper_Test {

	public static testMethod void testCCICustomerWrapper() {
		insert TestData.createCountriesList();
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		insert TestData.createCustomerCategory();

		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		Account acc2 = TestData.buildAccount('Advertiser', 'Private Advertiser');
		Test.startTest();
		CCICustomerWrapper wrapper = new CCICustomerWrapper();
		CCICustomerWrapper wrapper1 = new CCICustomerWrapper(acc, 'Mail');
		CCICustomerWrapper wrapper2 = new CCICustomerWrapper(acc2, 'Metro');

		System.assert(wrapper != null);
		System.assert(wrapper2 != null);
		Test.stopTest();

	}

}