/**
 * Controller class for creating a New Query
 */
public with sharing class CreateQueryController 
{
	private Id m_invoiceId;

	/**
	 * Constructor takes a standard controller
	 */
	public CreateQueryController( ApexPages.StandardController stdController )
	{
		m_invoiceId = stdController.getId();
	}

	/**
	 * Action method to create the Query
	 */
	public PageReference createQuery()
	{
		Id qryId;

		try
		{
 			qryId = QueryManagementService.createQueryFromSalesInvoicId(m_invoiceId);
		}
		catch(Exception e)
		{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}

		return new PageReference('/' + qryId);
	}
}