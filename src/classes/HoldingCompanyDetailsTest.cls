@isTest(SeeAllData = true)
private class HoldingCompanyDetailsTest {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	
	static testmethod void HoldingAgencyDetailsTestMailInvoke() {
		//  setUpData(); 
		Account acc = TestData.buildAccount('Agency', 'Billing Agency');
		insert acc;

		Account acc2 = new Account();
		acc2.Name = 'TestAccount2';
		acc2.Type = 'Billing Agency';
		acc2.Phone = '0208426234';
		acc2.BillingStreet = 'testStreet2';
		acc2.BillingPostalCode = 'ha5 4re';
		Id agencyRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Agency').RecordTypeId;
		acc2.RecordTypeId = agencyRecordTypeId;
		acc2.Parent = acc;
		acc2.CCIMailCustID__c = '1';
		insert acc2;
		HoldingAgencyDetails plugin = new HoldingAgencyDetails();

		Map < String, Object > inputParams = new Map < String, Object > ();
		InputParams.put('Id', acc2.id);
		InputParams.put('userType', 'Mail');
		Test.startTest();
		plugin.describe();
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		plugin.invoke(request);
		Test.stopTest();
	}

	static testmethod void HoldingCompanyDetailsTestMailInvoke() {
		//  setUpData(); 
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		insert acc;

		Account acc2 = new Account();
		acc2.Name = 'TestAccount2';
		acc2.Type = 'Direct Advertiser';
		acc2.Phone = '0208426234';
		acc2.BillingStreet = 'testStreet2';
		acc2.BillingPostalCode = 'ha5 4re';
		Id advertiserRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Advertiser').RecordTypeId;
		acc2.RecordTypeId = advertiserRecordTypeId;
		acc2.Industry = '04-Drinks'; // Industry only valid for Advertiser
		acc2.Parent = acc;
		acc2.CCIMailCustID__c = '1';
		insert acc2;
		HoldingCompanyDetails plugin = new HoldingCompanyDetails();

		Map < String, Object > inputParams = new Map < String, Object > ();
		InputParams.put('Id', acc2.id);
		InputParams.put('userType', 'Mail');
		Test.startTest();
		plugin.describe();
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		plugin.invoke(request);
		Test.stopTest();
	}
	static testmethod void HoldingCompanyDetailsTestMetroInvoke() {
		//  setUpData(); 
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
		insert acc;

		Account acc2 = new Account();
		acc2.Name = 'TestAccount2';
		acc2.Type = 'Direct Advertiser';
		acc2.Phone = '0208426234';
		acc2.BillingStreet = 'testStreet2';
		acc2.BillingPostalCode = 'ha5 4re';
		Id advertiserRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Advertiser').RecordTypeId;
		acc2.RecordTypeId = advertiserRecordTypeId;
		acc2.Industry = '04-Drinks'; // Industry only valid for Advertiser
		acc2.Parent = acc;
		acc2.CCIMailCustID__c = '1';
		insert acc2;
		HoldingCompanyDetails plugin = new HoldingCompanyDetails();
		Map < String, Object > inputParams = new Map < String, Object > ();

		InputParams.put('Id', acc2.id);
		InputParams.put('userType', 'Metro');
		Test.startTest();
		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		plugin.invoke(request);
		Test.stopTest();
	}
}