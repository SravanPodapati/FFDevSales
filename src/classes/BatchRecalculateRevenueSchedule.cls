global with sharing class BatchRecalculateRevenueSchedule implements Database.Batchable < sObject > , Database.Stateful {
	Integer queryLimit;
	Double failedUpdates {
		get;
		set;
	}


	global BatchRecalculateRevenueSchedule(Integer intLimit) {
		queryLimit = intLimit;
	}

	global Database.queryLocator
	start(Database.BatchableContext ctx) {
		return Database.getQueryLocator([SELECT UnitPrice
		FROM OpportunityLineItem
		WHERE Id Not IN(Select Opportunitylineitemid
		From OpportunityLineItemSchedule)
		Limit: queryLimit]);
	}


	global void execute(Database.BatchableContext bc,
	List < sObject > scope) {
		System.debug('********IN EXECUTE***********');
		List < OpportunityLineItem > oplList = (List < OpportunityLineItem > ) scope;
		System.debug('oplList:' + oplList);
		Set < Id > oplIdSet = new Set < Id > ();
		for (OpportunityLineItem opl: oplList) {
			opl.unitprice += 0.001;
			oplIdSet.add(opl.Id);
		}

		List < Database.SaveResult > dsrs = Database.update(oplList, false);
		for (Database.SaveResult dsr: dsrs) {
			failedUpdates = 0;
			if (!dsr.isSuccess()) {
				failedUpdates++;
			}
		}
		System.debug('oplList update:' + oplList);
	}

	global void finish(Database.BatchableContext bc) {


		AsyncApexJob a = [SELECT id, ApexClassId,
		JobItemsProcessed,
		TotalJobItems,
		NumberOfErrors,
		CreatedBy.Email
		FROM AsyncApexJob
		WHERE id = : bc.getJobId()];

		String emailMessage =
			'Your batch job ' + 'AccountOwnerReassignment' + ' has finished.  It executed ' + a.totalJobItems +
			' batches.  Of which, ' + a.jobitemsprocessed + ' processed without any exceptions' + 'thrown and ' + a.numberOfErrors +
			' batches threw unhandled exceptions.' + '  Of the batches that executed' + 'without error, ' + failedUpdates + ' records were not updated successfully.';

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {
			a.createdBy.email
		};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('Batch Job Summary');
		mail.setSubject('Batch job completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		Messaging.sendEmail(new
		Messaging.SingleEmailMessage[] {
			mail
		});

	}

	@isTest(SeeAllData = true)
	private static void testBatch() {
		List < OpportunityLineItemSchedule > oplSchedStart = [Select
		Id
		From OpportunityLineItemSchedule];
		Test.startTest();
		Database.executeBatch(new BatchRecalculateRevenueSchedule(2));
		Test.stopTest();
		List < OpportunityLineItemSchedule > oplSchedStop = [Select
		Id
		From OpportunityLineItemSchedule];
		//System.assert(oplSchedStart.Size() < oplSchedStop.Size());
	}
}