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
 */
@isTest
private class AccountMergeUtility_Test {
	static{
		insert TestData.createCountriesList();

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
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();
	}
    static testMethod void test() 
    {
        // This utility class is tested automatically trough triggers
        // upon merging accounts.
        
        Account mainAccount = new Account(Name = 'TestAccount1', Type = 'Client', Industry = 'Finance', BillingCountry = 'United Kingdom');
        Account duplicateAccount = new Account(Name = 'TestAccount2', Type = 'Client', Industry = 'Finance', BillingCountry = 'United Kingdom');
        insert new Account[] { mainAccount, duplicateAccount };
        
        Business_Team_Activity__c btaMain = new Business_Team_Activity__c(Name = 'Test', Account__c = mainAccount.id);
        Business_Team_Activity__c btaDuplicate = new Business_Team_Activity__c(Name = 'Test', Account__c = duplicateAccount.id);
        insert new Business_Team_Activity__c[] { btaMain, btaDuplicate };
        
        Task task = new Task(WhatId = btaDuplicate.id);
        Attachment att = new Attachment(Body = Blob.valueOf('TESTTEST'), ParentId = btaDuplicate.id, Name = 'Some file.txt');
        Note note = new Note(Body = 'Some note', Title = 'test-note', ParentId = btaDuplicate.id);
        
        insert new SObject[]{ task, att, note};
        
        try 
        {
            merge mainAccount duplicateAccount;
            
            // another test
            AccountMergeUtility.MergeAccountsBusinessTeamActivities(null);
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
    
    static testMethod void mergeChatterFeedsTest1(){
    	//Test Data
    	Account deletingAccount1 = TestData.buildAccount('Advertiser', 'Client');
    	deletingAccount1.name = 'Deleting Account 1';
    	insert deletingAccount1;
    	
    	Account deletingAccount2 = TestData.buildAccount('Advertiser', 'Client');
    	deletingAccount2.name = 'Deleting Account 2';
    	insert deletingAccount2;
    	
    	FeedItem fI1 = new FeedItem(id=null, Body = 'Feed for Deleting Account 1', ContentData= null, ContentDescription = null,	ContentFileName = null, 
    									LinkUrl = null, ParentId = deletingAccount1.Id, RelatedRecordId=null, Title = null,	Type = 'TextPost');
    	insert fI1;
    	
    	FeedComment fC1 = new FeedComment(CommentBody = 'First feed Comment for Feed 1', CommentType = 'TextComment', FeedItemId = fI1.id, RelatedRecordId = null);
    	insert fC1;
    	
    	EntitySubscription eS1 = new EntitySubscription(SubscriberId=UserInfo.getUserId(), ParentId = deletingAccount1.Id);
    	insert eS1;
    	
    	Account masterRecord = TestData.buildAccount('Advertiser', 'Client');
    	masterRecord.name = 'Master Account';
    	insert masterrecord;
    	
    	User tempUser = [SELECT Id from User where Profile.name = 'System Administrator' AND IsActive = true limit 1 ];
    	
    	EntitySubscription eS2 = new EntitySubscription(SubscriberId=tempUser.Id, ParentId = masterrecord.Id);
    	insert eS2;
    	
    	map<ID,ID> oldRecordIdToNewRecordIdMap = new map<ID, ID>();
    	oldRecordIdToNewRecordIdMap.put(deletingAccount1.id, masterrecord.id);
    	oldRecordIdToNewRecordIdMap.put(deletingAccount2.id, masterrecord.id);
    	
    	test.startTest();
    		AccountMergeUtility.mergeChatterFeeds(oldRecordIdToNewRecordIdMap);
    	test.StopTest();
    }
    
}