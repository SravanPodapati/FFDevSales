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
private class ScheduleUpdateLeadOwner_Test {

	static testMethod void testUpdateLeadOwner() {
		Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Wowcher').getRecordTypeId();
		Constants__c mc = Constants__c.getValues('All');
		if (mc == null) {
			mc = new Constants__c();
			mc.Name = 'All';
			mc.Wowcher_Lead_Owner__c = 'Julian Boardman';
			mc.CustomerRef1email__c = 'a@a.com';
			insert mc;
		} else if (mc.Wowcher_Lead_Owner__c == null) {
			mc.Wowcher_Lead_Owner__c = 'Julian Boardman';
			update mc;
		}


		test.startTest();

		Lead newLead = new Lead(RecordTypeId = leadRecTypeId, LastName = 'Doe', Company = 'Doe Ltd', Country = 'United Kingdom');
		insert newLead;

		ScheduleUpdateLeadOwner.isTest = True;

		String jobId = System.schedule('testBasicScheduledApex', ScheduleUpdateLeadOwner.CRON_EXP, new ScheduleUpdateLeadOwner());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];

		// Verify the expressions are the same 

		System.assertEquals(ScheduleUpdateLeadOwner.CRON_EXP, ct.CronExpression);

		// Verify the job has not run 

		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run 

		System.assertEquals('2030-10-01 00:00:00',
		String.valueOf(ct.NextFireTime));

		test.stopTest();
	}
}