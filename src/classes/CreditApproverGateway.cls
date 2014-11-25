/**
 * Gateway methods for Credit Approvers
 */
public with sharing class CreditApproverGateway
{
	/**
	 * Map Credit Approvers by Ids
	 *
	 * Arguments:	Set<Id>		Set of Credit Approver Ids
	 *
	 * Returns:		Map<Id, CreditApprover__c> Map of Creid Approvers keyed on Id
	 */
	public static Map<Id, CreditApprover__c> mapCreditApproversByIds(Set<Id> approverIds)
	{
		return new Map<Id, CreditApprover__c>([Select Id, Name, BusinessUnit__c, CCISource__c, CreditApprovalLevel__c, Email__c,
														OP1Source__c, SalesManager__c, SalesSection__c, SalesSectionEmail__c,
														SalesManager__r.Email__c
												From CreditApprover__c
												Where Id in :approverIds]);
	}
}