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
private class AccountIndustryCategoryController_Test {

    public static void createSettingsData(){
    	insert TestData.createCountriesList();
        ConstantsH__c ch = new ConstantsH__c();
        ch.Acc_and_Contact_owner__c = 'A&N Media';
        ch.Department__c = 'IT';
        insert ch;
            
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'anmedia', Email='ANMedia@dmgmedia.com', 
        EmailEncodingKey='UTF-8', FirstName='A&N', LastName='Media', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='ANMedia@dmgmedia.com');  
        
        insert u; 
		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings(); 
        Account acc = TestData.buildAccount('Advertiser','Direct Advertiser');
        insert acc;

        insert TestData.initIndustryCategoryMapping();
    } 
    
    private static testMethod void testAcccIndCategoryController(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            List<String> subValues = new List<String>();
            subValues.add('Alcohal');
            subValues.add('Non-Alcohal');
            List<String> minorValues = new List<String>();
            minorValues.add('Cola');
            minorValues.add('Wine');
            controller.parentPicklistVal = '08 - COSMETICS & TOILETRIES';
            controller.childMultiPicklistVal = subValues;
            controller.ChildSinglePicklistVal = minorValues;
            controller.save();
            List<SelectOption> parentOptions = controller.getParentPicklistOptions();
            List<SelectOption> subCategoryOptions = controller.getChildMultiPicklistOptions();
            // List<SelectOption> minorCategoryOptions = controller.getChildSinglePicklistOptions();
            System.assertNotEquals(null,parentOptions);
            System.assertNotEquals(null,subCategoryOptions);
            //  System.assertNotEquals(null,minorCategoryOptions);
        Test.stopTest();
    }
    
    private static testmethod void edit_test(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            Pagereference currentPage = Page.AccountIndustryCategory;
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            
            controller.edit();
            
        Test.stopTest();
    }
    
    private static testmethod void cancel_test(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            Pagereference currentPage = Page.AccountIndustryCategory;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            
            test.setCurrentPage(currentPage);
            controller.cancel();
            
        Test.stopTest();
    }
    
    private static testmethod void actionUpdatePicklistVals_test(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            Pagereference currentPage = Page.AccountIndustryCategory;
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            
            controller.actionUpdatePicklistVals();
            
            controller.parentPicklistVal = null;
            controller.actionUpdatePicklistVals();
            
            controller.parentPicklistVal = '08 - COSMETICS & TOILETRIES';
            controller.childMultiPicklistVal = new list<string>{'08.06 - PROFESSIONAL/B2B HAIR'};
            controller.actionUpdatePicklistVals();
        Test.stopTest();
    }
    
    private static testmethod void setChildMultiPicklistOptions_test(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            Pagereference currentPage = Page.AccountIndustryCategory;
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            
            controller.parentPicklistVal = '08 - COSMETICS & TOILETRIES';
            test.setCurrentPage(currentPage);
            controller.childMultiPicklistVal = new list<string>{'08.06 - PROFESSIONAL/B2B HAIR'};
            controller.childSinglePicklistVal = new list<string>{'08.06.00 - PROFESSIONAL/B2B HAIR','08.06.05 - PROF/B2B COLOUR PROD/SER'};
            controller.setChildMultiPicklistOptions();
            
        Test.stopTest();
    }
    
    private static testmethod void getChildSinglePicklistOptions_test(){
        createSettingsData();
        Account acc = [select id, Industry, Industry_Sub_Category__c, Industry_Minor_Category__c from account limit 1];
        Test.startTest();
            Pagereference currentPage = Page.AccountIndustryCategory;
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountIndustryCategoryController controller = new AccountIndustryCategoryController(sc);
            
            controller.parentPicklistVal = '08 - COSMETICS & TOILETRIES';
            controller.childMultiPicklistVal = new list<string>{'08.06 - PROFESSIONAL/B2B HAIR'};
            controller.getChildSinglePicklistOptions();
        Test.stopTest();
    }
    
    
}