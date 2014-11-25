/**
 * Trigger handler for the Query Object
 */
public without sharing class QueryHandler
	implements ITrigger
{
	private Map<Id, CreditApprover__c> m_creditApproverMap;
	private Set<Id> m_queriesToAllocate;
	private List<Query__c> m_queriesWithStatusChanged;

	public void bulkBefore()
	{
		if (Trigger.isInsert || Trigger.isUpdate)
		{
			// Populate Map of Credit Approvers
			m_creditApproverMap = new Map<Id, CreditApprover__c>();

			Set<Id> approverIds = new Set<Id>();

			for(Query__c q : (List<Query__c>)Trigger.New)
			{
				approverIds.add(q.SalesPerson__c);
			}

			m_creditApproverMap = CreditApproverGateway.mapCreditApproversByIds(approverIds);
		}
	}
	
	public void bulkAfter()
	{
		if (Trigger.isUpdate)
		{
			m_queriesToAllocate = new Set<Id>();
			m_queriesWithStatusChanged = new List<Query__c>();
		}
	}
		
	public void beforeInsert(SObject so)
	{
		populateSalesPersonFields((Query__c)so);
	}
	
	public void beforeUpdate(SObject oldSo, SObject so)
	{
		Query__c oldQuery = (Query__c)oldSo;
		Query__c query = (Query__c)so;

		// If the Sales Person has changed populate the related fields
		if (query.SalesPerson__c != oldQuery.SalesPerson__c)
		{
			populateSalesPersonFields(query);
		}
	}
	
	public void beforeDelete(SObject so)
	{
	}
	
	public void afterInsert(SObject so)
	{
	}
	
	public void afterUpdate(SObject oldSo, SObject so)
	{
		// Check if we need to Allocate the Total Query Amount down the Lines
		Query__c oldQuery = (Query__c)oldSo;
		Query__c query = (Query__c)so;

		// If the Total Query Amount was previously null or zero and has since changed
		if (query.TotalQueryAmount__c != oldQuery.TotalQueryAmount__c &&
			(oldQuery.TotalQueryAmount__c == null || oldQuery.TotalQueryAmount__c == 0))
		{
			m_queriesToAllocate.add(so.Id);
		}

		// If the Status has changed add it to the list to trigger the necessary invoice updates
		if (query.Status__c != oldQuery.Status__c)
		{
			m_queriesWithStatusChanged.add(query);
		}
	}
	
	public void afterDelete(SObject so)
	{
	}
	
	public void andFinally()
	{
		if (Trigger.isAfter)
		{
			if (Trigger.isInsert)
			{
				// if inserting, populate the Query
				QueryManagementService.populateQueriesFromSalesInvoices(Trigger.new);
			}
			else if (Trigger.isUpdate)
			{
				 if (!m_queriesToAllocate.isEmpty())
				 {
					// if update and we have queries to allocate then allocate down the lines
					QueryManagementService.allocateQueryAmount(m_queriesToAllocate);				 	
				 }

				 if (!m_queriesWithStatusChanged.isEmpty())
				 {
				 	// if we have status changes update the invoices document credit status
				 	QueryManagementService.updateInvoicesDocumentCreditStatus(m_queriesWithStatusChanged);
				 }
			}
		}
	}

	private void populateSalesPersonFields(Query__c qry)
	{
		if (qry.SalesPerson__c == null)
		{
			qry.SalesPersonEmail__c = null;
			qry.SalesSection__c = null;
			qry.SalesSectionEmail__c = null;
			qry.SalesManager__c = null;
			qry.BusinessUnit__c = null;
		}
		else
		{
			CreditApprover__c salesPerson = m_creditApproverMap.get(qry.SalesPerson__c);

			qry.SalesPersonEmail__c = salesPerson.Email__c;
			qry.SalesSection__c = salesPerson.SalesSection__c;
			qry.SalesSectionEmail__c = salesPerson.SalesSectionEmail__c;
			qry.SalesManager__c = salesPerson.SalesManager__c;
			qry.BusinessUnit__c = salesPerson.BusinessUnit__c;
		}
	}
}