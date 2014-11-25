global class BatchDelete implements Database.Batchable < sObject > , Database.Stateful {

	global List < sObject > RecsToUpdate = new List < sObject > ();
	global string objectname;
	//global string query;

	global BatchDelete(List < Business_Team_Activity__c > listofBTARecords, String objectn) {
		RecsToUpdate = listofBTARecords;
		objectname = objectn;
	}


	global Database.QueryLocator start(Database.BatchableContext BC) {
		return DataBase.getQueryLocator('SELECT Id FROM ' + objectname + ' WHERE Id IN :RecsToUpdate ');
	}

	global void execute(Database.BatchableContext bc, List < sObject > scope) {
		List < sObject > recsToUpdate = new List < sObject > ();
		for (sObject a: scope) {

			recsToUpdate.add(a);
		}
		delete recsToUpdate;

	}
	global void finish(Database.batchableContext bc) {

	}

}