@isTest(SeeAllData = true)
private class OrderCreationTest {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	static testmethod void OrderCreationTests() {
		//  setUpData(); 
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;
		Account billingAcc = new Account();
		billingAcc.Name = 'BillingAgency';
		billingAcc.Type = 'Billing Agency';
		billingAcc.Phone = '0208426234';
		billingAcc.BillingStreet = 'testStreet2';
		billingAcc.BillingPostalCode = 'ha5 4re';
		Id agencyRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Agency').RecordTypeId;
		billingAcc.RecordTypeId = agencyRecordTypeId;
		// billingAcc.CCIMailCustID__c = '1';
		insert billingAcc;

		Account bookingAcc = new Account();
		bookingAcc.Name = 'Booking Agency';
		bookingAcc.Type = 'Booking Agency';
		bookingAcc.Phone = '0208426234';
		bookingAcc.BillingStreet = 'testStreet2';
		bookingAcc.BillingPostalCode = 'ha5 4re';
		bookingAcc.RecordTypeId = agencyRecordTypeId;
		//        bookingAcc.CCIMailCustID__c = '1';
		insert bookingAcc;
		OrderCreation plugin = new OrderCreation();

		Map < String, Object > inputParams = new Map < String, Object > ();
		InputParams.put('Id', acc.id);
		InputParams.put('BookingAgency', bookingAcc.id);
		InputParams.put('BillingAgency', billingAcc.id);
		Test.startTest();
		plugin.describe();
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		plugin.invoke(request);
		Test.stopTest();
	}


}