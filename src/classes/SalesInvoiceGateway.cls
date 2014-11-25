/**
 * Gateway methods for the c2g__codaInvoice__c object
 */
public with sharing class SalesInvoiceGateway 
{
    public static Map<Id, c2g__codaInvoice__c> mapInvoicesAndLinesByIds(Set<Id> invoiceIds) 
    {
        String qry = 'Select Id, Name, SalesPerson__c, c2g__Account__c, ffps_dmg__FinanceAccount__c, ' +
                        'ffps_dmg__DocumentCreditStatus__c, ffps_dmgi__Order_Billing_Notes__c, ' +
                        'SalesPerson__r.Email__c, SalesPerson__r.SalesSection__c, SalesPerson__r.SalesSectionEmail__c, ' +
                        'ffps_dmg__FinanceAccount__r.ffps_dmg__DocumentDestinationContact__c, ' +
                        '(Select Id, Name, c2g__NetValue__c, ffps_dmgi__LongDescription__c ' +
                         'from c2g__InvoiceLineItems__r Order By c2g__LineNumber__c) ' +
                     'From c2g__codaInvoice__c ' +
                     'Where Id in :invoiceIds';

        return new Map<Id, c2g__codaInvoice__c>((List<c2g__codaInvoice__c>)Database.query(qry));
    }
}