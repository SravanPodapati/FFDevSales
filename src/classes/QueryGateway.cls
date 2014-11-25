/**
 * Gateway methods for the Query Object
 */
public with sharing class QueryGateway 
{
    public static Map<Id, Query__c> mapQueriesAndLinesByIds(Set<Id> queryIds) 
    {
        return new Map<Id, Query__c>([Select Id, Name, Client__c, FinanceAccount__c, SalesInvoice__c, SalesPerson__c, SalesPersonEmail__c,
                                            SalesManager__c, SalesManagerEmail__c, SalesSection__c, SalesSectionEmail__c, BusinessUnit__c,
                                            TotalQueryAmount__c, ToBeAllocatedQueryAmount__c,
                                            (Select Id, Name, QueryValue__c, NetValue__c From QueryLineItems__r Order By SalesInvoiceLineItem__r.c2g__LineNumber__c)
                                        From Query__c
                                        Where Id in :queryIds]);
    }

    public static List<Query__c> findOverdueQueries(DateTime targetDateTime)
    {
        return [Select Id, Name, DateOpened__c, Send48HrEmail__c from Query__c Where Send48HrEmail__c = false and DateOpened__c <= :targetDateTime];
    }
}