/**
 * Servie class for Query Management
 */
public with sharing class QueryManagementService 
{
    public static final String QUERY_STATUS_OPEN = 'Open';
    public static final String QUERY_STATUS_QUERY_DENIED = 'Query Denied';
    public static final String QUERY_STATUS_QUERY_PASSED = 'Query Passed';
    public static final String QUERY_STATUS_QUERY_CREDIT_NOTE_CREATED = 'Credit Note Created';

    public static final String DOCUMENT_CREDIT_STATUS_QUERY = 'Query';
    public static final String DOCUMENT_CREDIT_STATUS_CREDIT_DENIED = 'Credit Denied';
    public static final String DOCUMENT_CREDIT_STATUS_GOOD = 'Good';

    /**
     * Create a Query from a Sales Invoice Id
     *
     * Arguments:   Id  Sales Invoice Id
     *
     * Returns:     The Id of the created Query
     */
    public static Id createQueryFromSalesInvoicId(Id invoiceId)
    {
        Query__c qry = new Query__c(
            SalesInvoice__c = invoiceId
        );

        insert qry;

        return qry.Id;
    }

    /**
     * Populate the Query / Query Line Item structure from the supplied 
     * Query objects. 
     *
     * This is invoked from the after insert trigger via the QueryHandler class.
     *
     * Arguments:   List<Query__c>  List of Query object to process
     */
    public static void populateQueriesFromSalesInvoices(List<Query__c> queries)
    {
        // Begin by querying the Sales Invoices and Lines
        Set<Id> invoiceIds = new Set<Id>();

        for (Query__c q : queries)
        {
            invoiceIds.add(q.SalesInvoice__c);
        }

        Map<Id, c2g__codaInvoice__c> invoiceMap = SalesInvoiceGateway.mapInvoicesAndLinesByIds(invoiceIds);

        // Loop through the Queries creating the Query Line Items
        List<Query__c> queriesToUpdate = new List<Query__c>();
        List<QueryLineItem__c> queryLineItemsToInsert = new List<QueryLineItem__c>();

        for (Query__c q : queries)
        {
            c2g__codaInvoice__c inv = invoiceMap.get(q.SalesInvoice__c);

            // No Invoice, don't process
            if (inv == null)
            {
                continue;
            }

            // clone the query (since it should have been passed in via the after trigger)
            Query__c qry = q.clone(true, true, true, true);
            
            // populate client and finance account
            qry.Client__c = inv.c2g__Account__c;
            qry.FinanceAccount__c = inv.ffps_dmg__FinanceAccount__c;
            qry.CustomerContact__c = inv.ffps_dmg__FinanceAccount__r.ffps_dmg__DocumentDestinationContact__c;
            qry.SalesPerson__c = inv.SalesPerson__c;
            qry.OrderBillingNotes__c = (String)inv.get('ffps_dmgi__Order_Billing_Notes__c');
            
            queriesToUpdate.add(qry);

            // Determine if there is an amount to be allocated
            Decimal toAllocate = qry.TotalQueryAmount__c == null ? 0 : qry.TotalQueryAmount__c;

            // create the line items
            for (c2g__codaInvoiceLineItem__c line : inv.c2g__InvoiceLineItems__r)
            {
                QueryLineItem__c qryLine = new QueryLineItem__c(
                    Query__c = q.Id,
                    SalesInvoiceLineItem__c = line.Id,
                    LongDescription__c = (String)line.get('ffps_dmgi__LongDescription__c')
                );

                // If an allocation amount has been specified then apply it
                if (toAllocate >= 0)
                {
                    if (toAllocate > line.c2g__NetValue__c)
                    {
                        qryLine.QueryValue__c = line.c2g__NetValue__c;
                    }
                    else
                    {
                        qryLine.QueryValue__c = toAllocate;
                    }

                    toAllocate -= qryLine.QueryValue__c;
                }
                else
                {
                    qryLine.QueryValue__c = 0;
                }

                queryLineItemsToInsert.add(qryLine);
            }
        }

        // update headers and insert lines
        if (!queriesToUpdate.isEmpty())
        {
            update queriesToUpdate;
        }

        if (!queryLineItemsToInsert.isEmpty())
        {
            insert queryLineItemsToInsert;
        }

        // Update the invoices (if applicable)
        updateInvoicesDocumentCreditStatus(queries, invoiceMap);
    }

    /**
     * Allocate Query Amount accross Lines. 
     *
     * This is invoked from the after update trigger via the QueryHandler class.
     *
     * Arguments:   List<Id>    List of Query Ids to process
     */
    public static void allocateQueryAmount(Set<Id> queryIds)
    {
        // Begin by querying the Queries and Lines
        Map<Id, Query__c> queryMap = QueryGateway.mapQueriesAndLinesByIds(queryIds);

        List<QueryLineItem__c> queryLineItemsToUpdate = new List<QueryLineItem__c>();

        // Loop through the Queries allocating the Query Line Items
        for (Query__c qry : queryMap.values())
        {
            // Determine the amount to be allocated
            Decimal toAllocate = qry.TotalQueryAmount__c == null ? 0 : qry.TotalQueryAmount__c;

            // loop through line items
            for (QueryLineItem__c qryLine : qry.QueryLineItems__r)
            {
                // If an allocation amount has been specified then apply it
                if (toAllocate >= 0)
                {
                    if (toAllocate > qryLine.NetValue__c)
                    {
                        qryLine.QueryValue__c = qryLine.NetValue__c;
                    }
                    else
                    {
                        qryLine.QueryValue__c = toAllocate;
                    }

                    toAllocate -= qryLine.QueryValue__c;
                }
                else
                {
                    qryLine.QueryValue__c = 0;
                }

                queryLineItemsToUpdate.add(qryLine);
            }
        }

        // update lines
        if (!queryLineItemsToUpdate.isEmpty())
        {
            update queryLineItemsToUpdate;
        }
    }

    /**
     * Update the Invoices Document Credit Status from the Query 
     *
     * Arguments:   List<Query__c>                  List of Query object to process
     */
    public static void updateInvoicesDocumentCreditStatus(List<Query__c> queries)
    {
        // Begin by querying the Sales Invoices and Lines
        Set<Id> invoiceIds = new Set<Id>();

        for (Query__c q : queries)
        {
            invoiceIds.add(q.SalesInvoice__c);
        }

        Map<Id, c2g__codaInvoice__c> invoiceMap = SalesInvoiceGateway.mapInvoicesAndLinesByIds(invoiceIds);

        updateInvoicesDocumentCreditStatus(queries, invoiceMap);
    }

    /**
     * Validate able to Create a Sales Credit Note from a Query
     *
     * Arguments:   Id      Query Id
     *
     * Returns:     The Id of the created Credit Note
     */
    public static void validateCreateSalesCreditNote(Id queryId)
    {
        // Get the Query and Invoice (we ignore sharing to obtain the invoice if it belongs in a different company)
        Query__c qry = QueryGatewayNS.findQueryAndLoadInvoiceByQueryId(queryId);

        validateCreateSalesCreditNote(qry);
    }

    /**
     * Validate able to Create a Sales Credit Note from a Query
     *
     * Arguments:   Id      Query Id
     *
     * Returns:     The Id of the created Credit Note
     */
    public static void validateCreateSalesCreditNote(Query__c qry)
    {
        // Validate Status is Query Passed
        if (qry.Status__c != QUERY_STATUS_QUERY_PASSED)
        {
            throw new ServiceException('The Query must be at status: Query Passed before a credit Note can be raised.');
        }

        // Get current company and validate it matches the company on the query
        c2g__codaCompany__c currentCompany = CompanyGateway.getCurrentCompany();

        if (qry.SalesInvoice__r.c2g__OwnerCompany__c != currentCompany.Id)
        {
            throw new ServiceException('You must be in Company ' + qry.SalesInvoice__r.c2g__OwnerCompany__r.Name + ' to credit this query.');
        }
    }

    /**
     * Create a Sales Credit Note from a Query
     *
     * Arguments:   Id      Query Id
     *              String  Credit Note Reason
     *
     * Returns:     The Id of the created Credit Note
     */
    public static Id createSalesCreditNote(Id queryId, String reason)
    {
        // Get the Query and Invoice (we ignore sharing to obtain the invoice if it belongs in a different company)
        Query__c qry = QueryGatewayNS.findQueryAndLoadInvoiceByQueryId(queryId);

        // Validate
        validateCreateSalesCreditNote(qry);

        // Create the Credit Note header
        c2g__codaInvoice__c inv = qry.SalesInvoice__r;

        c2g__codaCreditNote__c crd = new c2g__codaCreditNote__c();

        // Populate the header fields from the invoice fields
        crd.c2g__Account__c = inv.c2g__Account__c;
        // Note that the currency will be pushed in via the trigger using the Finance Account Currency
        // So no currency is passed in here.
        crd.c2g__CreditNoteDate__c = System.today();
        crd.c2g__CreditNoteDescription__c = inv.c2g__InvoiceDescription__c;
        crd.c2g__CreditNoteReason__c = reason;
        crd.c2g__CustomerReference__c = inv.c2g__CustomerReference__c;
        crd.c2g__Dimension1__c = inv.c2g__Dimension1__c;
        crd.c2g__Dimension2__c = inv.c2g__Dimension2__c;
        crd.c2g__Dimension3__c = inv.c2g__Dimension3__c;
        crd.c2g__Dimension4__c = inv.c2g__Dimension4__c;
        crd.c2g__DueDate__c = inv.c2g__DueDate__c;
        crd.c2g__Invoice__c = inv.Id;
        crd.c2g__InvoiceDate__c = inv.c2g__Invoicedate__c;
        crd.c2g__Opportunity__c = inv.c2g__Opportunity__c;
        crd.c2g__OwnerCompany__c = inv.c2g__OwnerCompany__c;
        crd.c2g__DerivePeriod__c = true;
        crd.c2g__PrintedText1AllowEdit__c = inv.c2g__PrintedText1AllowEdit__c;
        crd.c2g__PrintedText1Heading__c = inv.c2g__PrintedText1Heading__c;
        crd.c2g__PrintedText1Text__c = inv.c2g__PrintedText1Text__c;
        crd.c2g__PrintedText1TextDefinitionName__c = inv.c2g__PrintedText1TextDefinitionName__c;
        crd.c2g__PrintedText2AllowEdit__c = inv.c2g__PrintedText2AllowEdit__c;
        crd.c2g__PrintedText2Heading__c = inv.c2g__PrintedText2Heading__c;
        crd.c2g__PrintedText2Text__c = inv.c2g__PrintedText2Text__c;
        crd.c2g__PrintedText2TextDefinitionName__c = inv.c2g__PrintedText2TextDefinitionName__c;
        crd.c2g__PrintedText3AllowEdit__c = inv.c2g__PrintedText3AllowEdit__c;
        crd.c2g__PrintedText3Heading__c = inv.c2g__PrintedText3Heading__c;
        crd.c2g__PrintedText3Text__c = inv.c2g__PrintedText3Text__c;
        crd.c2g__PrintedText3TextDefinitionName__c = inv.c2g__PrintedText3TextDefinitionName__c;
        crd.c2g__PrintedText4AllowEdit__c = inv.c2g__PrintedText4AllowEdit__c;
        crd.c2g__PrintedText4Heading__c = inv.c2g__PrintedText4Heading__c;
        crd.c2g__PrintedText4Text__c = inv.c2g__PrintedText4Text__c;
        crd.c2g__PrintedText4TextDefinitionName__c = inv.c2g__PrintedText4TextDefinitionName__c;
        crd.c2g__PrintedText5AllowEdit__c = inv.c2g__PrintedText5AllowEdit__c;
        crd.c2g__PrintedText5Heading__c = inv.c2g__PrintedText5Heading__c;
        crd.c2g__PrintedText5Text__c = inv.c2g__PrintedText5Text__c;
        crd.c2g__PrintedText5TextDefinitionName__c = inv.c2g__PrintedText5TextDefinitionName__c;
        crd.c2g__TaxCode1__c = inv.c2g__TaxCode1__c;
        crd.c2g__TaxCode2__c = inv.c2g__TaxCode2__c;
        crd.c2g__TaxCode3__c = inv.c2g__TaxCode3__c;
        crd.ffps_dmg__FinanceAccount__c = inv.ffps_dmg__FinanceAccount__c;
        crd.ffps_dmg__DMGTransactionType__c = inv.ffps_dmg__DMGTransactionType__c.replace('Invoice', 'Credit Note');
        crd.Query__c = qry.Id;

        insert crd;

        // Create the lines
        List<c2g__codaCreditNoteLineItem__c> creditLines = new List<c2g__codaCreditNoteLineItem__c>();

        for (QueryLineItem__c qryLine : qry.QueryLineItems__r)
        {
            c2g__codaInvoiceLineItem__c invLine = qryLine.SalesInvoiceLineItem__r;

            c2g__codaCreditNoteLineItem__c creditLine = new c2g__codaCreditNoteLineItem__c();

            creditLine.c2g__CreditNote__c = crd.Id;
            creditLine.c2g__LineDescription__c = invLine.c2g__LineDescription__c;
            creditLine.c2g__OwnerCompany__c = invLine.c2g__OwnerCompany__c;
            creditLine.c2g__Product__c = invLine.c2g__Product__c;
            creditLine.c2g__Quantity__c = 1;
            creditLine.c2g__TaxCode1__c = invLine.c2g__TaxCode1__c;
            creditLine.c2g__TaxCode2__c = invLine.c2g__TaxCode2__c;
            creditLine.c2g__TaxCode3__c = invLine.c2g__TaxCode3__c;
            creditLine.c2g__UnitPrice__c = qryLine.QueryValue__c;
            creditLine.ffps_dmg__ReceivingCompany__c = invLine.ffps_dmg__ReceivingCompany__c;
            creditLine.c2g__DeriveUnitPriceFromProduct__c = false;
            creditLine.c2g__DeriveTaxRateFromCode__c = true;
            creditLine.c2g__DeriveTaxRate2FromCode__c = true;
            creditLine.c2g__DeriveTaxRate3FromCode__c = true;
            creditLine.c2g__CalculateTaxValueFromRate__c = true;
            creditLine.c2g__CalculateTaxValue2FromRate__c = true;
            creditLine.c2g__CalculateTaxValue3FromRate__c = true;     
            creditLine.c2g__LineNumber__c = invLine.c2g__LineNumber__c;
            creditLine.c2g__DeriveLineNumber__c = false;
            // Using V11 Field (Defect #37 8-Sep-2014 TS)
            //creditLine.ffps_dmg__GeneralLedgerAccount__c = invLine.ffps_dmg__GeneralLedgerAccount__c; 
            creditLine.c2g__GeneralLedgerAccount__c = invLine.c2g__GeneralLedgerAccount__c;
            creditLine.c2g__Dimension1__c = invLine.c2g__Dimension1__c;
            creditLine.c2g__Dimension2__c = invLine.c2g__Dimension2__c;
            creditLine.c2g__Dimension3__c = invLine.c2g__Dimension3__c;
            creditLine.c2g__Dimension4__c = invLine.c2g__Dimension4__c;
    
            creditLines.add(creditLine);
        }

        insert creditLines;

        // update status of query
        qry.Status__c = QUERY_STATUS_QUERY_CREDIT_NOTE_CREATED;

        update qry;

        return crd.Id;
    }

    /**
     * Update the Invoices Document Credit Status from the Query 
     *
     * Arguments:   List<Query__c>                  List of Query object to process
     *              Map<Id, c2g__codaInvoice__c>    Map of Invoice Ids to Invoices
     */
    private static void updateInvoicesDocumentCreditStatus(List<Query__c> queries, Map<Id, c2g__codaInvoice__c> invoiceMap)
    {
        // Loop through the Queries updating the Invoices as appropriate
        List<c2g__codaInvoice__c> invoicesToUpdate = new List<c2g__codaInvoice__c>();

        for (Query__c q : queries)
        {
            c2g__codaInvoice__c inv = invoiceMap.get(q.SalesInvoice__c);

            // No Invoice, don't process
            if (inv == null)
            {
                continue;
            }

            if (q.Status__c == QUERY_STATUS_OPEN)
            {
                inv.ffps_dmg__DocumentCreditStatus__c = DOCUMENT_CREDIT_STATUS_QUERY;
                invoicesToUpdate.add(inv);
            }
            else if (q.Status__c == QUERY_STATUS_QUERY_DENIED)
            {
                inv.ffps_dmg__DocumentCreditStatus__c = DOCUMENT_CREDIT_STATUS_CREDIT_DENIED;
                invoicesToUpdate.add(inv);
            }
            else if (q.Status__c == QUERY_STATUS_QUERY_PASSED)
            {
                inv.ffps_dmg__DocumentCreditStatus__c = DOCUMENT_CREDIT_STATUS_GOOD;
                invoicesToUpdate.add(inv);
            }
        }

        // update invoices
        if (!invoicesToUpdate.isEmpty())
        {
            update invoicesToUpdate;
        }
    }

    public class ServiceException extends Exception {}
}