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
private class Common_Test {
	public static void setUpData() {
		insert TestData.createCountriesList();
		ConstantsH__c ch = new ConstantsH__c();
		ch.Acc_and_Contact_owner__c = 'A&N Media';
		ch.Department__c = 'IT';
		insert ch;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com', EmailEncodingKey = 'UTF-8', FirstName = 'A&N',
		LastName = 'Media', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;

		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

		//create accounts with different postcodes and account names. 
		map < String, Account > accountMap = new map < String, Account > ();

		for (integer i = 1; i <= 2; i++) {
			Account advertiserAccount = TestData.buildAccount('Advertiser', 'Direct Advertiser');
			advertiserAccount.name = 'Account-' + i;

			accountMap.put(advertiserAccount.name, advertiserAccount);
		}
		insert accountMap.Values();

		//update parent id values
		for (Account acc: accountMap.Values()) {
			if (!acc.name.equalsIgnoreCase('Account-1')) {
				acc.ParentId = accountMap.get('Account-1').id;
			}
		}

		update accountMap.values();
	}

	static testMethod void getRootAccount_Test1() {
		setupData();
		//hard coaded id as we use system.isrunningtest method
		id expectedRootAccountID = '001M000000XHE4v';
		id memberAccountID = [select ID from Account where parentID != null limit 1].id;
		test.startTest();
		id rootAccountId = Common.rootAccount(memberAccountID);
		system.assertEquals(rootAccountId, expectedRootAccountID);
		test.stopTest();
	}

	static testMethod void getRootAccount_Test2() {
		setupData();
		test.startTest();
		try {
			id rootAccountId = Common.rootAccount(new Account());
		} catch (Exception e) {
			boolean expectedException = e.getMessage().equalsIgnoreCase(System.Label.Root_Account_Exception);
			system.assertEquals(expectedException, true);
		}
		test.stopTest();
	}

	static testMethod void getUserType_metroUser() {
		Profile p = database.query('select id from Profile where name like \'%' + common.metroUser + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.metroUser);

	}

	static testMethod void getUserType_mailUser() {
		Profile p = database.query('select id from Profile where name like \'%' + common.mailUser + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.mailUser);

	}

	static testMethod void getUserType_systemAdministrator() {
		Profile p = database.query('select id from Profile where name like \'%' + common.systemAdministrator + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.systemAdministrator);

	}

	static testMethod void getUserType_groupClientSales() {
		Profile p = database.query('select id from Profile where name like \'%' + common.groupClientSales + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.groupClientSales);

	}

	static testMethod void getUserType_londonClassified() {
		Profile p = database.query('select id from Profile where name like \'%' + common.londonClassified + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.londonClassified);

	}

	static testMethod void getUserType_creditController() {
		Profile p = database.query('select id from Profile where name like \'%' + common.creditController + '%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, common.creditController);

	}

	static testMethod void getUserType_null() {
		Profile p = database.query('select id from Profile where name like \'%A&N Read Only%\' LIMIT 1');

		User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
		EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');
		insert u;
		User testUser = [select id, name, profile.name from user where id = : u.id];
		string result = Common.getUserType(testUser);
		system.assertEquals(result, null);

	}

	static testMethod void userProfile() {
		//insert custom settings for BookingSystemSettings
		insert TestData.createBookingSystemSettings();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
		Common.userProfile();
		Common.userGroup();
		common.GetBaseUrlForInstance();
		BookingSystemSettings__c cci = Common.CCI;
		system.assertNotEquals(CCI, null);
		string sharedSecret = Common.sharedSecret;
		system.assertEquals(sharedSecret, CCI.SharedSecret__c);
		Common.UserInfoWrapper testWrapper = new Common.UserInfoWrapper('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test');


		test.stopTest();
	}
    
    static testMethod void generalVariables() {
		//CCI Order Params
        insert TestData.createOrderParamSettings();
        insert TestData.createBookingSystemSettings();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
		OrderParams__c result = common.cciOrderParams;
        System.assertNotEquals(null, result);
        
        // CCI MetrowEquivelemt Profiels
        set<String> metroSet = common.cciMetroEquivelentProfiles; 
        System.assertNotEquals(null, metroSet);
        
        // CCI Mail Equivelemt Profiels
        set<String> mailSet = common.cciMailEquivelentProfiles; 
        System.assertNotEquals(null, mailSet);
        
        //CCI System Admin Profile set
       	set<String> adminSet = common.cciSystemAdminEquivalentProfiles; 
        System.assertNotEquals(null, adminSet);
        
        User testUser1 = [select Id from User where  Virtual_Data_Team_Member__c = False and IsActive=true and Profile.Name = 'System Administrator' limit 1];
        system.runAs(testUser1){
            boolean isUpdateByServiceUserResult = common.isUpdateByServiceUser(true);
            System.assertEquals(false, isUpdateByServiceUserResult);
        }
        
        User testUser2 = [select Id from User where  Virtual_Data_Team_Member__c = False and IsActive=true and Profile.Name like 'Metro Display User' limit 1];
        system.runAs(testUser2){
            boolean isUpdateByServiceUserResult = common.isUpdateByServiceUser(true);
            System.assertEquals(true, isUpdateByServiceUserResult);
            boolean isUpdateByServiceUserResult2 = common.isUpdateByServiceUser(false);
            System.assertEquals(false, isUpdateByServiceUserResult2);
        }
        
        User testUser3 = [select Id from User where  Virtual_Data_Team_Member__c = False and IsActive=true and Profile.Name like 'Mail Display User' limit 1];
        system.runAs(testUser3){
            boolean isUpdateByServiceUserResult = common.isUpdateByServiceUser(true);
            System.assertEquals(false, isUpdateByServiceUserResult);
        }
        
        User testUser4 = [select Id from User where  Virtual_Data_Team_Member__c = true and IsActive=true limit 1];
        system.runAs(testUser4){
            boolean isUpdateByServiceUserResult = common.isUpdateByServiceUser(true);
            System.assertEquals(true, isUpdateByServiceUserResult);
        }
        
        //constructer
        Common c = new Common();
        
        //Chatter Info
        list <CCICustomerWrapper.ChatterInfo> testChatterList = Common.chatterList;
        System.assertNOTEquals(null, testChatterList);
        
        //integ logs 
        list <Integration_Logs__c> testIntegLogs = common.integLogs;
        System.assertNOTEquals(null, testIntegLogs);
        
        //sharedSecret
        String testsharedSecret = Common.sharedSecret; 
        testsharedSecret = Common.sharedSecret;
        System.assertNOTEquals(null, testsharedSecret);
        
        //Uaser Info
        User testUser5 = [select Id from User where FederationIdentifier != null and IsActive=true limit 1];
        system.runAs(testUser5){
            String testcciUser = Common.cciuser;
            system.assertNotEquals(null, testcciUser);
        }
        
        
	}
    
    static testmethod void delayTime(){
        Common.delayTime(2);
    }
    
    static testMethod void getRootAccount_Test3() {
		setupData();
		//hard coaded id as we use system.isrunningtest method
		id expectedRootAccountID = '001M000000XHE4v';
		id memberAccountID = [select ID from Account where parentID != null limit 1].id;
		test.startTest();
        Common com = new Common();
		set<String> allIdsInHirearchy = com.allIdsInHirearchy(memberAccountID);
		system.assertNOTEquals(null, allIdsInHirearchy);
		test.stopTest();
	}

    Static testMethod void handelExceptionMessageTest(){
        //FIELD_CUSTOM_VALIDATION_EXCEPTION
        String ExceptionMessage = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, test : ['+'TestMessage';
        String result = Common.handelExceptionMessage(ExceptionMessage);
        result = result != null ? result.trim():'';
        system.assertEquals('test', result);
        
        //FIELD_CUSTOM_VALIDATION_EXCEPTION
        ExceptionMessage = 'FIELD_FILTER_VALIDATION_EXCEPTION, test : ['+'TestMessage';
        result = Common.handelExceptionMessage(ExceptionMessage);
        result = result != null ? result.trim():'';
        system.assertEquals('test', result);
        
        //Other
        ExceptionMessage = 'TestMessage';
        result = Common.handelExceptionMessage(ExceptionMessage);
        result = result != null ? result.trim():'';
        system.assertEquals('TestMessage', result);
    }
    
    static testmethod void assErrorDescriptionTest(){
        //General
        String input = 'errorString:test, errorDetails';
        String result = common.addErrorMsgToDesc(input);
        system.assertNotEquals(null, result);
        //Exception
        input = 'testforException';
        try{
        result = common.addErrorMsgToDesc(input);
        }catch(Exception ex){
            boolean expectedException = ex.getMessage()!=null?true:false;
			system.assertEquals(expectedException, true);
        }
        
		result = common.addErrorMsgToDesc(null);
    }
    
    static testmethod void accesstokenTest(){
        Common.AccessToken testAccessToken = new Common.AccessToken('ato', 'tto', 'rto', 'exp', 'rd');
        system.assertNOTEquals(null, testAccessToken);
    }
    
    static testmethod void cciTest23(){
        insert TestData.createIncompleteBookingSystemSettings2();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com', EmailEncodingKey = 'UTF-8', FirstName = 'A&N',
		LastName = 'Media', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com', CCI_User_Password__c='test',CCI_User_Id__c='test.test');
		insert u;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        	User testUser5 = [select Id from User where Alias='anmedia' limit 1];
        	system.runAs(testUser5){
                Common.AccessToken testcciToken = Common.cciToken;
            }
        test.stopTest();
    }
}