trigger QueryTrigger on Query__c (before insert, before update, after insert, after update) 
{
	TriggerFactory.createAndExecuteHandler(QueryHandler.class);
}