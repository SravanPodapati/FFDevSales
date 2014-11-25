public Class ObjectUpdateFromCCIResponse {



	public static String createAccounMapping(String jsonResponse, String dbType, Id accId) {


		System.debug('Response is' + jsonResponse);

		// consume response (json)
		Map < String, Object > mWholeResponse = (Map < String, Object > ) JSON.deserializeUntyped(jsonResponse);
		System.debug('Whole response is' + mWholeResponse);
		//  Map<String, Object> mRespContent = (Map<String, Object>)mWholeResponse.get('Content');
		String customerId = (String) mWholeResponse.get('customerId');

		Account_Mapping__c accMapping = new Account_Mapping__c();
		if (dbType == 'Mail') {
			accMapping.Account__c = accId;
			accMapping.Source_Key__c = customerId;
			accMapping.Source_System__c = 'CCI Mail';
		} else if (dbType == 'Metro') {
			accMapping.Account__c = accId;
			accMapping.Source_Key__c = customerId;
			accMapping.Source_System__c = 'CCI Metro';
		}
		insert accMapping;


		return customerId;
	}



	public static String updateFinanceMapping(String jsonResponse) {



		// consume response (json)
		Map < String, Object > mWholeResponse = (Map < String, Object > ) JSON.deserializeUntyped(jsonResponse);
		System.debug('Whole response is' + mWholeResponse);
		String accountID = (String) mWholeResponse.get('accountId');
		System.debug('Account ID is' + accountID);

		return accountID;
	}



}