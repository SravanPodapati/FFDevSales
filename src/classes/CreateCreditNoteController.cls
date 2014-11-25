/**
 * Controller class for Crediting a Query
 */
public with sharing class CreateCreditNoteController 
{
    private Id m_queryId;
    public c2g__codaCreditNote__c CreditNote {get; set;}
    public Boolean HasErrors {get; set;}

    /**
     * Constructor takes a standard controller
     */
    public CreateCreditNoteController( ApexPages.StandardController stdController )
    {
        m_queryId = stdController.getId();
        CreditNote = new c2g__codaCreditNote__c();
        HasErrors = false;
    }

    /**
     * Action method to validate the queries readiness
     */
    public PageReference validate()
    {
        try
        {
            QueryManagementService.validateCreateSalesCreditNote(m_queryId);
        }
        catch(Exception e)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
            HasErrors = true;
            return null;
        }

        return null;
    }

    /**
     * Action method to create the Credit Note
     */
    public PageReference createCreditNote()
    {
        Id creditNoteId;

        try
        {
            creditNoteId = QueryManagementService.createSalesCreditNote(m_queryId, CreditNote.c2g__CreditNoteReason__c);
        }
        catch(Exception e)
        {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }

        return new PageReference('/' + creditNoteId);
    }
}