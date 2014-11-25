/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MergeAccountBTAsController_Test {

    static testMethod void myUnitTest() {
        string advertiserRecTypeId = [select id from RecordType where DeveloperName = :Constants__c.getInstance('All').Advertiser_Record_Type__c limit 1].id; 
        if(BookingSystemSettings__c.getAll().get('CCI') == null){
            insert TestData.createBookingSystemSettings();
        }
        if(BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null){
        	insert TestData.createCountryCodeSetting('United Kingdom', 'UK'); 	
        }
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
 
         Account acct = new Account(
                Name                = 'Test - TestMergeAccountBTAsController', 
                AccountNumber       = 'ABC123456',
                Industry            = 'Finance',
                Type                = 'Booking Agency',
                BillingStreet       = 'Agency Street',
                BillingState        = 'Agency TestState',
                BillingPostalCode   = 'A111AA', 
                BillingCountry      = 'United Kingdom', 
                BillingCity         = 'Agency City',
                RecordTypeId        = advertiserRecTypeId
        );
        insert acct;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        MergeAccountBTAsController c = new MergeAccountBTAsController(sc);
        
        c.CancelMergeBTAs();
        c.MergeBTAs();
    }
}