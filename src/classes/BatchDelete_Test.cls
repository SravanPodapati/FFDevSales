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
private class BatchDelete_Test {

	static testMethod void myUnitTest1() {
		// Test Method
		{
			insert TestData.createCountriesList();
			Test.startTest();
			User testUser = [
			select name, email, ProfileId, Profile.Name
			from User
			where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
			limit 1];

			String testProfileId = [select id from Profile limit 1].id;

			ConstantsH__c newConstH = new ConstantsH__c(
			Acc_and_Contact_owner__c = testUser.Name,
			Department__c = 'Test Department 1',
			IsManager__c = false,
			//Price_Book__c             = testPB.Name,
			SetupOwnerId = testUser.ProfileId);
			insert newConstH;
			insert TestData.createBookingSystemSettings();
			insert TestData.buildCompany();
			insert TestData.buildMetroCompany();
			insert TestData.createCountryCodeSettings();
			String advertiserRecTypeId = [
			select id
			from RecordType
			where DeveloperName = 'Advertiser'
			limit 1].id;

			Account acct = new Account(
			Name = 'TestAccount',
			AccountNumber = 'ABC123456',
			Type = 'Client',
			BillingStreet = 'Test Billing Street',
			BillingState = 'Test Billing State',
			BillingPostalCode = 'A111AA',
			BillingCountry = 'United Kingdom',
			BillingCity = 'London',
			Industry = 'Finance',
			IndClassLvl1__c = 'Finance',
			IndClassLvl2__c = 'Finance',
			Classified_Minor_Category__c = 'Finance',
			CustomerRef1__c = '12345',
			CustomerRef2__c = '23456',
			CustomerRef3__c = '34567',
			CustomerRef4__c = 'TestA',
			RecordTypeId = advertiserRecTypeId);
			insert acct;

			Account acct1 = new Account(
			Name = 'TestAccount1',
			AccountNumber = 'ABC123456',
			Type = 'Client',
			BillingStreet = 'Test Billing Street',
			BillingState = 'Test Billing State',
			BillingPostalCode = 'A111AA',
			BillingCountry = 'United Kingdom',
			BillingCity = 'London',
			Industry = 'Finance',
			IndClassLvl1__c = 'Finance',
			IndClassLvl2__c = 'Finance',
			Classified_Minor_Category__c = 'Finance',
			CustomerRef1__c = '12345',
			CustomerRef2__c = '23456',
			CustomerRef3__c = '34567',
			CustomerRef4__c = 'TestA',
			RecordTypeId = advertiserRecTypeId);
			insert acct1;

			merge acct acct1;
			Test.stopTest();
			List < Business_Team_Activity__c > deletedbtas = new List < Business_Team_Activity__c > ();
			deletedbtas = [Select Id From Business_Team_Activity__c Where Account__c = : acct1.id];
			/* List<Sobject> objList=new List<Sobject>();
     
        
         List<Business_Team_Activity__c> btaList1 = [Select Id, Name
                                                    From Business_Team_Activity__c
                                                    Where Account__c =:acct.id];
         List<Business_Team_Activity__c> btaList2 = [Select Id, Name
                                                    From Business_Team_Activity__c
                                                    Where Account__c =:acct1.id];
         
         
         for (Business_Team_Activity__c bta :  btaList1) {
            bta.Account__c=acct1.id;
            objList.add(bta);
         }
         for (Business_Team_Activity__c bta1 :  btaList2) {
            bta1.Account__c=acct.id;
            objList.add(bta1);
         }
        
        BatchDelete taskcontroller = new BatchDelete(btaList2,'Business_Team_Activity__c') ;
        Integer batchSize = 1;
        database.executebatch(taskcontroller , batchSize);
        
        List<Business_Team_Activity__c> deletedbtas=new List<Business_Team_Activity__c>();
        deletedbtas=[SELECT id FROM Business_Team_Activity__c WHERE Id in :btaList2];
                
        Test.stopTest();
        System.assertEquals(0,deletedbtas.size());  */
		}
	}
}