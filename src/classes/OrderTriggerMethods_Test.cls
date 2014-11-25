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
private class OrderTriggerMethods_Test {


	static testMethod void afterupdateMethod_Test() {
		insert TestData.createCountriesList();
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;

		Profile p = [
		SELECT Id
		FROM Profile
		WHERE Name = 'Standard User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

		insert u;

		//insert custom settings for BookingSystemSettings
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
		insert acc;

		Opportunity newOp = TestData.createOpportunity(acc);
		insert newOp;
		Order order1 = new Order();
		order1.AccountID = acc.id;
		order1.EffectiveDate = System.Today();
		order1.CCI_Account_ID__c = '1';
		order1.Is_Cancelled__c = false;
		order1.Has_Complaint__c = false;
		order1.IsReductionOrder = false;
		order1.Is_Accepted__c = true;
		order1.CCI_Order_ID__c = '123456';
		order1.Base_Price__c = 50;
		order1.First_Delivery_Date__c = System.Today();
		order1.Last_Delivery_Date__c = System.today();
		order1.Opportunity__c = newOp.Id;
		order1.CCI_Customer_ID__c = '1';
		order1.Status = 'Draft';
		order1.Booking_Source__c = 'CCIBookingPlugin';

		Test.startTest();
		insert order1;
		Test.stopTest();

		System.assert(order1.id != null);
	}


}