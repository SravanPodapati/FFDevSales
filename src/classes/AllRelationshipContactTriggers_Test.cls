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
private class AllRelationshipContactTriggers_Test {
	static{
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
	}
	
    static testMethod void beforeInsert_Test() {
        Relationship_Contact__c rC = new Relationship_Contact__c();
        rC.Active__c = true;
        insert rC;
    }
    
    static testMethod void afterUpdate_Test() {
        
        Relationship__c rel = new Relationship__c();
        rel.Active__c = false;
        insert rel;
        
        Relationship_Contact__c rC = new Relationship_Contact__c();
        rC.Active__c = false;
        rc.Relationship__c = rel.id; 
        insert rC;
        
        test.startTest();
        	rC.Active__c = true;
        	update rC;
        	Relationship__c resultRelationship = [SELECT ID, Active__c from Relationship__c where id =: rel.Id];
        	system.assertEquals(true, resultRelationship.Active__c);
        test.stopTest();
    }
}