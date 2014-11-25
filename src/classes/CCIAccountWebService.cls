global class CCIAccountWebService {

	private final Id accID;

	WebService static String createCCIAccount(String accId, boolean directOrder) {
		System.debug('Direct order on top' + directOrder);
		FinanceAccount__c acc;

		String errorResponse;
		String successResponse;
		String dbType;

		try {

			acc = [SELECT ID, Neo_ID__c, Account__r.Type, Company__r.Name, CCIMailCustomerID__c, CCIMetroCustomerID__c, SOP_ID__c, SOP_Source__c
			FROM FinanceAccount__c WHERE ID = : accID LIMIT 1];

			if ((acc.Company__r.Name).contains('Mail')) {
				dbType = 'Mail';
			} else if (acc.Company__r.Name.contains('Metro')) {
				dbType = 'Metro';
			}

			User u = Common.getUserInfo();
			System.debug('User is' + u);
			String userType = Common.getUserType(u);
			System.debug('UserType' + userType);
			System.debug('User Type is ' + userType);
			//if(String.IsBlank(u.CCI_User_Id__c)||String.IsBlank(u.CCI_Profile__c)||String.IsBlank(u.CCI_User_Password__c)||String.IsBlank(u.CCI_Group_Id__c) )
			//   errorResponse = Label.InvalidCCIUser;
			/* if (String.IsBlank(Common.sharedSecret) ){
                errorResponse = Label.Missing_Shared_Secret;
            } */
			if (userType != Common.mailUser && userType != Common.metroUser && userType != Common.londonClassified && userType != Common.systemAdministrator && userType != Common.groupClientSales && userType != Common.creditController) {
				errorResponse = Label.Invalid_Finance_User;
			} else if (acc.SOP_Source__c == 'CCI' && !String.IsBlank(acc.SOP_ID__c)) {
				errorResponse = Label.CCIAccount_already_exists;
			} else if (acc.Account__r.Type != 'Direct Advertiser' && acc.Account__r.Type != 'Billing Agency' && acc.Account__r.Type != 'Charity' && acc.Account__r.Type != 'Private Advertiser' && acc.Account__r.Type != 'Brand') {
				errorResponse = 'CCI Finance account can not be created for this account type';
			} else if (dbType == 'Mail' && String.IsBlank(acc.CCIMailCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else if (dbType == 'Metro' && String.IsBlank(acc.CCIMetroCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else {
				List < Id > accIds = new List < Id > ();
				List < FinanceAccount__c > accs = new List < FinanceAccount__c > ();
				// accIds.add(acc.Id);
				accs.add(acc);
				// Map <ID, String> mResponse = CCIFinanceAccountManager.createCCIAccount(accIds,u,directOrder);
				Map < String, String > mResponse = CCIFinanceAccountManager.createCCIAccount(accs, u, directOrder);
				if (directorder) successResponse = mResponse.get(acc.ID);
				else errorResponse = mResponse.get(acc.ID);
			}
		} Catch(Exception e) {
			// pr = new Pagereference('/' + acc.ID);
			//  ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.CCI_Exception));
		}

		System.debug('Error is' + errorResponse);
		if (String.isBlank(errorResponse)) {
			Common.addChatterFeedToObject((Id) accId, 'Finance Account has been successfully integrated with CCI Mail.');
			Integration_Logs__c intL = new Integration_Logs__c(Source__c = 'CCI', Finance_Account__c = (Id) accId, Status__c = 'Success',
			Description__c = 'Finance Account has been successfully integrated with CCI.');
			insert intL;
		}
		System.debug('Direct order on bottom' + directOrder);
		if (directOrder) return successResponse;
		return errorResponse;
	}

	@future(callout = true)
	WebService static void createCCIAccountFromOrder(String accId) {

		FinanceAccount__c acc;

		String errorResponse;
		String successResponse;
		String dbType;



		try {

			acc = [SELECT ID, Account__r.Type, Neo_ID__c, Company__r.Name, CCIMailCustomerID__c, CCIMetroCustomerID__c, SOP_ID__c, SOP_Source__c
			FROM FinanceAccount__c
			WHERE ID = : accID LIMIT 1];

			if ((acc.Company__r.Name).contains('Mail')) {
				dbType = 'Mail';
			} else if (acc.Company__r.Name.contains('Metro')) {
				dbType = 'Metro';
			}


			User u = Common.getUserInfo();
			System.debug('User is' + u);
			String userType = Common.getUserType(u);
			System.debug('UserType' + userType);
			System.debug('User Type is ' + userType);
			//if(String.IsBlank(u.CCI_User_Id__c)||String.isBlank(u.CCI_Profile__c)||String.IsBlank(u.CCI_User_Password__c)||String.IsBlank(u.CCI_Group_Id__c))
			//   errorResponse = Label.InvalidCCIUser;
			/*  if (String.IsBlank(Common.sharedSecret) )
            {
                errorResponse = Label.Missing_Shared_Secret;
            }*/
			if (userType != Common.mailUser && userType != Common.metroUser && userType != Common.londonClassified && userType != Common.systemAdministrator && userType != Common.groupClientSales && userType != Common.creditController) {
				errorResponse = Label.Invalid_Finance_User;
			} else if (acc.SOP_Source__c == 'CCI' && acc.SOP_ID__c != null && acc.SOP_ID__c != '') {
				errorResponse = Label.CCIAccount_already_exists;


			} else if (acc.Account__r.Type != 'Direct Advertiser' && acc.Account__r.Type != 'Private Advertiser' && acc.Account__r.Type != 'Charity' && acc.Account__r.Type != 'DMGT Group' && acc.Account__r.Type != 'Billing Agency' && acc.Account__r.Type != 'Brand') {
				errorResponse = 'CCI Finance account can not be created for this user';
			} else if (dbType == 'Mail' && String.IsBlank(acc.CCIMailCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else if (dbType == 'Metro' && String.IsBlank(acc.CCIMetroCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else {
				List < Id > accIds = new List < Id > ();
				List < FinanceAccount__c > accs = new List < FinanceAccount__c > ();
				//                 accIds.add(acc.Id);
				accs.add(acc);
				// Map <ID, String> mResponse = CCIFinanceAccountManager.createCCIAccount(accIds,u,true);
				Map < String, String > mResponse = CCIFinanceAccountManager.createCCIAccount(accs, u, true);

				successResponse = mResponse.get(accID);

			}



		} Catch(Exception e) {
			// pr = new Pagereference('/' + acc.ID);
			//  ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.CCI_Exception));

		}

		System.debug('Error is' + errorResponse);
		if (String.isBlank(errorResponse) && successResponse != null) {
			Common.addChatterFeedToObject((Id) accId, 'Finance Account has been successfully integrated with CCI Mail.');
			Integration_Logs__c intL = new Integration_Logs__c(
			Source__c = 'CCI',
			Finance_Account__c = (Id) accId, Status__c = 'Success',
			Description__c = 'Finance Account has been successfully integrated with CCI.');
			insert intL;

		}


	}
	
	@future(callout = true)
	WebService static void createFutureCCIAccount(String accId, boolean directOrder)
	{
		createNonFutureCCIAccount(accId, directOrder);
	}
	
	public static void createNonFutureCCIAccount(String accId, boolean directOrder) {
		System.debug('Direct order on top' + directOrder);
		FinanceAccount__c acc;

		String errorResponse;
		String successResponse;
		String dbType;



		try {

			acc = [SELECT ID, Neo_ID__c, Account__r.Type, Company__r.Name, CCIMailCustomerID__c, CCIMetroCustomerID__c, SOP_ID__c, SOP_Source__c
			FROM FinanceAccount__c
			WHERE ID = : accID LIMIT 1];

			if ((acc.Company__r.Name).contains('Mail')) {
				dbType = 'Mail';
			} else if (acc.Company__r.Name.contains('Metro')) {
				dbType = 'Metro';
			}


			User u = Common.getUserInfo();
			System.debug('User is' + u);
			String userType = Common.getUserType(u);
			System.debug('UserType' + userType);
			System.debug('User Type is ' + userType);
			//if(String.IsBlank(u.CCI_User_Id__c)||String.IsBlank(u.CCI_Profile__c)||String.IsBlank(u.CCI_User_Password__c)||String.IsBlank(u.CCI_Group_Id__c))
			//   errorResponse = Label.InvalidCCIUser;
			/*  if (String.IsBlank(Common.sharedSecret) )
            {
                errorResponse = Label.Missing_Shared_Secret;
            }
            else */
			if (userType != Common.mailUser && userType != Common.metroUser && userType != Common.londonClassified && userType != Common.systemAdministrator && userType != Common.groupClientSales && userType != Common.creditController) {
				errorResponse = Label.Invalid_Finance_User;
			} else if (acc.SOP_Source__c == 'CCI' && String.IsBlank(acc.SOP_ID__c)) {
				errorResponse = Label.CCIAccount_already_exists;


			} else if (acc.Account__r.Type != 'Direct Advertiser' && acc.Account__r.Type != 'Billing Agency' && acc.Account__r.Type != 'Charity' && acc.Account__r.Type != 'Private Advertiser' && acc.Account__r.Type != 'Brand') {
				errorResponse = 'CCI Finance account can not be created for this user';
			} else if (dbType == 'Mail' && String.IsBlank(acc.CCIMailCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else if (dbType == 'Metro' && String.IsBlank(acc.CCIMetroCustomerID__c)) {
				errorResponse = Label.CCICustomer_does_not_exist;
			} else {
				List < Id > accIds = new List < Id > ();
				List < FinanceAccount__c > accs = new List < FinanceAccount__c > ();
				//                 accIds.add(acc.Id);
				accs.add(acc);
				//  Map <ID, String> mResponse = CCIFinanceAccountManager.createCCIAccount(accIds,u,directOrder);
				Map < String, String > mResponse = CCIFinanceAccountManager.createCCIAccount(accs, u, directOrder);
				if (directorder) successResponse = mResponse.get(accID);
				else errorResponse = mResponse.get(accID);
			}



		} Catch(Exception e) {
			// pr = new Pagereference('/' + acc.ID);
			//  ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.CCI_Exception));

		}

		System.debug('Error is' + errorResponse);
		if (String.isBlank(errorResponse)) {
			Common.addChatterFeedToObject((Id) accId, 'Finance Account has been successfully integrated with CCI Mail.');
			Integration_Logs__c intL = new Integration_Logs__c(
			Source__c = 'CCI',
			Finance_Account__c = (Id) accId, Status__c = 'Success',
			Description__c = 'Finance Account has been successfully integrated with CCI.');
			insert intL;

		}
		System.debug('Direct order on bottom' + directOrder);

	}



}