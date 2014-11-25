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
private class AccountTriggerMethods_Test {
    public static void setUpData() {
        insert TestData.createCountriesList();
        list < Account > accountList = new list < Account > ();

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

        //insert custom settings for BookingSystemSettings
        insert TestData.createBookingSystemSettings();
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        insert TestData.createCountryCodeSettings();

        //insert test accounts 
        for (integer i = 1; i <= 3; i++) {
           Account agencyAccount = TestData.buildAccount('agency', 'Direct Advertiser');
           
            agencyAccount.name = 'Agency Account ' + i;
            agencyAccount.BillingPostalCode = 'yy' + i + ' ' + i + 'yy';

            accountList.add(agencyAccount);
        }

        insert accountList;
        
    }

    static testMethod void afterupdateMethod_Test() {
        setUpData();
        test.startTest();
        Account mailAccount = [SELECT ID, name, Phone, BillingState, BillingCity, BillingPostalCode, BillingStreet, CCIMailCustID__c, BillingCountry, NPA__c, Industry_Minor_Category__c from Account limit 1];
        mailAccount.CCIMailCustID__c = '123456';

        mailAccount.Name = 'Test';
        mailAccount.Phone = '01234567890';
        mailAccount.BillingStreet = 'test';
        mailAccount.BillingCity = 'test';
        mailAccount.BillingPostalCode = 'sw114bd';
        mailAccount.BillingState = 'test';
        mailAccount.BillingCountry = 'United Kingdom';
        mailAccount.Industry_Minor_Category__c = '04.01.12 - LAGER';
        mailAccount.NPA__c = true;

        update mailAccount;
        test.stopTest();
        Account testAccount = [SELECT ID, name, Phone, BillingState, BillingCity, BillingPostalCode, BillingStreet, CCIMailCustID__c, BillingCountry, NPA__c, Industry_Minor_Category__c from Account where ID = : mailAccount.Id];

        system.assertEquals(mailAccount.Name, testAccount.Name);
        system.assertEquals(mailAccount.Phone, testAccount.Phone);
        system.assertEquals(mailAccount.BillingStreet, testAccount.BillingStreet);
        system.assertEquals(mailAccount.BillingCity, testAccount.BillingCity);
        system.assertEquals(mailAccount.BillingPostalCode, testAccount.BillingPostalCode);
        system.assertEquals(mailAccount.BillingState, testAccount.BillingState);
        system.assertEquals(mailAccount.BillingCountry, testAccount.BillingCountry);
        system.assertEquals(mailAccount.Industry_Minor_Category__c, testAccount.Industry_Minor_Category__c);
        system.assertEquals(mailAccount.NPA__c, testAccount.NPA__c);
    }

    static testMethod void afterupdateMethod_TotalSyncTest() {
        setUpData();
        test.startTest();
        Account mailAccount = [SELECT ID, name, Phone, BillingState, BillingCity, BillingPostalCode, BillingStreet, CCIMailCustID__c, BillingCountry, NPA__c, Industry_Minor_Category__c, DoCCIInt__c from Account limit 1];
        mailAccount.CCIMailCustID__c = '123456';
        mailAccount.DoCCIInt__c = true;

        update mailAccount;
        test.stopTest();
        Account testAccount = [SELECT ID, DoCCIInt__c from Account where ID = : mailAccount.Id];

        system.assertEquals(mailAccount.DoCCIInt__c, testAccount.DoCCIInt__c);
    }
    
    static testmethod void typeChange_Test(){
        setUpData();
        Account newAcc = TestData.buildAccount('Advertiser', 'Client');
      //  newAcc.CCIMailCustID__c = '123456';
        insert newAcc;
        test.startTest();
            newAcc.Type = 'Direct Advertiser';
            update newAcc;
        test.stopTest();
        
        Account updatedAccount = [SELECT ID,Type from Account where ID = : newAcc.Id];

        system.assertEquals('Direct Advertiser', updatedAccount.Type );
        
    }
    
     static testMethod void reviewUpdateAccount_Test() {
        setUpData();
        Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
        oldAcc.Name = 'Old Account';
        oldAcc.Phone = '01234567891';
        oldAcc.BillingStreet = 'old account';
        oldAcc.BillingCity = 'old city';
        oldAcc.BillingPostalCode = 'aa111aa';
        oldAcc.BillingState = 'old state';
        oldAcc.BillingCountry = 'United Kingdom';
        oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
        oldAcc.CCIMailCustID__c = null;
       // oldAcc.CCIMetroCustID__c = 'testmetro123';
       // oldAcc.NPA__c = false;
        oldAcc.Type = 'Direct Advertiser';
        insert oldAcc;
        test.startTest();
        oldAcc.Type='Client';
        update oldAcc;
              
        test.stopTest();
        Account updatedAccount = [SELECT ID,Type from Account where ID = : oldAcc.Id];

        system.assertEquals('Client', updatedAccount.Type );
    }
}