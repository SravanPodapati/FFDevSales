trigger AllDealProductTriggers on Deal_Product__c (after insert, after update, after delete) 
{
		DealProductTriggerMethods.setProductNames(!trigger.isDelete?trigger.new:trigger.old);
}