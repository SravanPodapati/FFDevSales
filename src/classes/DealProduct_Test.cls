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
private class DealProduct_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testMethod void testDealProduct() {
		// TO DO: implement unit test
		String advertiserRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Advertiser_Record_Type__c).getRecordTypeId();
		String agencyRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Agency_Record_Type__c).getRecordTypeId();
		String wowcherEcommOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Wowcher Merchant (ecomm)').getRecordTypeId();

		Profile p;
		try {
			p = [SELECT Id FROM Profile WHERE Name = 'Wowcher User'];
		} catch (QueryException e) {

		}

		User u = new User(Alias = 'wuser', Email = 'wowcheruser@wowcher.com',
		EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'wowcheruser@wowcher.com');

		insert u;


		Account acctAdv = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		BillingStreet = 'Street',
		BillingState = 'TestState',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'City',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acctAdv;

		Account acctAgency = new Account(
		Name = 'Test Account2',
		AccountNumber = 'ABC1234562',
		RecordTypeId = agencyRecTypeId,
		BillingStreet = 'Street',
		BillingState = 'TestState',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'City',
		ownerId = u.Id,
		Phone = '1236547896');
		insert acctAgency;

		//System.runAs(u)
		{
			Opportunity oppty = new Opportunity(
			Name = 'Test Oppty',
			AccountId = acctAdv.id,
			StageName = 'Final Negotiations',
			CloseDate = Date.today(),
			LeadSource = 'Organic - Google',
			// OwnerId              = testUser.Id,
			Followup_Due_Date__c = Date.today().addDays(4),
			Followup_Subject__c = 'Test Subject',
			RecordTypeId = wowcherEcommOppRecTypeId,
			Deal_Region__c = 'Scotland');

			insert oppty;

			Deal_Product__c dealProduct = new Deal_Product__c(
			Name = 'New Product',
			Opportunity__c = oppty.Id,
			Product_Price__c = 100,
			Product_Usual_Selling_Price__c = 120,
			Product_Supplier_Rate__c = 0.05,
			Product_Media_Surcharge__c = 0.02,
			Product_Cap__c = 98);

			insert dealProduct;

			Deal_Product__c checkDealProduct = [
			Select
			Name,
			Opportunity__c,
			Product_Price__c,
			Product_Usual_Selling_Price__c,
			Product_Supplier_Rate__c,
			Product_Media_Surcharge__c,
			Product_wowcher_commission__c,
			Product_Cap__c,
			Product_supplier_unredeemed_rate__c,
			Product_description__c,
			discount_percentage__c
			From Deal_Product__c
			Where Id = : dealProduct.Id];

			Opportunity checkOpportunity = [
			Select Deal_Products__c
			From Opportunity
			Where Id = : oppty.Id];


			String prodMediaSurcharge;
			String prodSupplierUnredeemedRate;

			if (checkDealProduct.Product_media_surcharge__c != Null) {
				prodMediaSurcharge = ', Media Surcharge: ' + checkDealProduct.Product_media_surcharge__c;
			} else {
				prodMediaSurcharge = '';
			}


			if (checkDealProduct.Product_supplier_unredeemed_rate__c != Null) {
				prodSupplierUnredeemedRate = ', Supplier Unredeemed Rate: ' + checkDealProduct.Product_supplier_unredeemed_rate__c + '%';
			} else {
				prodSupplierUnredeemedRate = '';
			}



			String dealCompare = ('Product Title: ' + checkDealProduct.Name + ', Deal Price: £' + checkDealProduct.Product_price__c + ', Usual Selling Price: £' + checkDealProduct.product_usual_selling_price__c + ', Discount Percentage: ' + checkDealProduct.discount_percentage__c + '%' + ', Deal Cap: ' + checkDealProduct.Product_Cap__c + ', Supplier Percentage Rate: ' + checkDealProduct.Product_supplier_rate__c + '%' + '\r\n\r\n\r\n');



			System.debug('dealCompare:' + dealCompare);
			System.debug('checkOpportunity.Deal_Products__c:' + checkOpportunity.Deal_Products__c);
			System.debug('dealCompare:' + dealCompare.trim().length());
			System.debug('checkOpportunity.Deal_Products__c:' + checkOpportunity.Deal_Products__c.trim().length());
			//System.assertEquals(checkOpportunity.Deal_Products__c.trim(), dealCompare.trim());


		}
	}
}