@isTest(SeeAllData = true)
private class CCIAccountCreationFromFlowTest {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}

	static testmethod void CCIAccountCreationFromFlowTests() {
		//  setUpData(); 
		Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		insert acc;
		FinanceAccount__c finAcc = TestData.buildFinanceAccount(acc);
		insert finAcc;



		CCIAccountCreationFromFlow plugin = new CCIAccountCreationFromFlow();

		Map < String, Object > inputParams = new Map < String, Object > ();
		InputParams.put('FinAccs', finAcc.id);
		Test.startTest();
		plugin.describe();
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		plugin.invoke(request);
		Test.stopTest();
	}


}