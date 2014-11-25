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
 */@isTest(SeeAllData = true)
private class CreateOpportunity_Test {
    static{
        BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
        if (bSS == null) insert TestData.createBookingSystemSettings();
        if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
            insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
        }
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
    }

    static User testUser = [
    select name, email, ProfileId, Profile.Name
    from User
    where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
    limit 1];


    static testMethod Opportunity CreateTestOpportunity() {


        /*String advertiserRecTypeId = 
                [
                select id 
                from RecordType 
                where DeveloperName = :Constants__c.getInstance('All').Advertiser_Record_Type__c 
                limit 1
                ].id;   */

        Map < String, RecordTypeInfo > accountRecTypeByName = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        final String developerName = 'Advertiser';

        Pricebook2 testPB = [select name from Pricebook2 Where isActive = true limit 1];
        String testProfileId = [select id from Profile limit 1].id;


        //#  
        //# Ensure that the test results will not depend
        //# on running user's Custom Settings
        //# 

        ConstantsH__c constH = [
        select id, Name, Price_Book__c, Acc_and_Contact_owner__c
        from ConstantsH__c
        where SetupOwnerId = : testUser.ProfileId
        limit 1];
        delete constH;

        ConstantsH__c newConstH = new ConstantsH__c(
        Acc_and_Contact_owner__c = testUser.Name,
        Department__c = 'None',
        IsManager__c = false,
        Price_Book__c = testPB.Name,
        SetupOwnerId = testUser.ProfileId);
        insert newConstH;


        User tmpUser = [select id from User where UserType = 'Standard' /*and managerId != null*/ and isActive = true LIMIT 1];
        tmpUser.ManagerId = null;
        update tmpUser;


        Account acct = new Account(
        Name = 'Test Account',
        AccountNumber = 'ABC123456',
        Type = 'Client',
        BillingStreet = 'Street',
        BillingState = 'TestState',
        BillingPostalCode = 'A111AA',
        BillingCountry = 'United Kingdom',
        BillingCity = 'City',
        Industry = 'Finance',
        RecordTypeId = accountRecTypeByName.get(developerName).RecordTypeId);
        insert acct;

        List < Account_Mapping__c > accMappingList = new List < Account_Mapping__c > ();

        /*Account_Mapping__c mapping = new Account_mapping__c (
            Source_system__c = 'Advance',
            Account__c = acct.Id,
            Active__c = true,
            Source_Key__c = '111');*/

        accMappingList.add(new Account_Mapping__c(Source_system__c = 'Advance',
        Account__c = acct.Id,
        Active__c = true,
        Source_Key__c = 'TA111'));

        accMappingList.add(new Account_Mapping__c(Source_system__c = 'CCI Metro',
        Account__c = acct.Id,
        Active__c = true,
        Source_Key__c = 'TA112'));

        accMappingList.add(new Account_Mapping__c(Source_system__c = 'CCI Mail',
        Account__c = acct.Id,
        Active__c = true,
        Source_Key__c = 'TA113'));

        insert accMappingList;

//        acct.Type = 'Direct Advertiser';
     //   acct.Phone = '01236547896';
     //   update acct;

        Contact cnt = new Contact();
        cnt.AccountId = acct.Id;
        cnt.LastName = 'Test Last Name';
        cnt.FirstName = 'Test First Name';
        cnt.MailingCity = 'Test Mailing City';
        cnt.MailingCountry = 'United Kingdom';
        cnt.MailingPostalCode = 'TestMPC';
        cnt.MailingState = 'Test Mailing State';
        cnt.MailingStreet = 'Test Mailing Street';
        insert cnt;
        /////////////////////////////////////////////////////////////////////////////////////        
        /*String agencyRecTypeId = 
                [
                select id 
                from RecordType 
                where DeveloperName = :Constants__c.getInstance('All').Agency_Record_Type__c 
                limit 1
                ].id;*/

        final String agencyDeveloperName = 'Agency';

        Account acct2 = new Account(
        Name = 'Test Account2',
        AccountNumber = 'ABC1234562',
        RecordTypeId = accountRecTypeByName.get(agencyDeveloperName).RecordTypeId,
        BillingStreet = 'Street',
        BillingState = 'TestState',
        BillingPostalCode = 'A111AA',
        BillingCountry = 'United Kingdom',
        BillingCity = 'City',
        ownerId = tmpUser.Id,
        Phone = '01236547896');
        insert acct2;

        accMappingList = new List < Account_Mapping__c > ();
        accMappingList.add(new Account_Mapping__c(Source_system__c = 'Advance',
        Account__c = acct2.Id,
        Active__c = true,
        Source_Key__c = 'TA211'));

        accMappingList.add(new Account_Mapping__c(Source_system__c = 'CCI Metro',
        Account__c = acct2.Id,
        Active__c = true,
        Source_Key__c = 'TA212'));

        accMappingList.add(new Account_Mapping__c(Source_system__c = 'CCI Mail',
        Account__c = acct2.Id,
        Active__c = true,
        Source_Key__c = 'TA213'));

        insert accMappingList;
        /////////////////////////////////////////////////////////////////////////////////////       
        Opportunity oppty = new Opportunity(
        Name = 'Test Oppty',
        AccountId = acct.id,
        Agency__c = acct2.id,
        StageName = 'Final Negotiations',
        CloseDate = Date.today(),
        LeadSource = 'Organic - Google',
        OwnerId = tmpUser.Id);

        try {
            insert oppty;
        } catch (exception e) {
            system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
        }
        system.debug('>>>>>>>>>>>>>>>>> oppty : ' + oppty);
        ////////////////////////////////////////////////////////////////////////////
        test.startTest();
        OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId = oppty.Id, Role = 'Agency Planning', ContactId = cnt.Id, IsPrimary = True);
        insert opContactRole;

        Pricebook2 priceBook = [
        Select
        p.Name
        From Pricebook2 p
        Where p.Name = : newConstH.Price_Book__c
        Limit 1];


        PricebookEntry priceBookEntry = [
        Select
        name,
        Product2Id
        From PricebookEntry
        Where pricebook2Id = : priceBook.Id
        And isActive = true
        limit 1];


        OpportunitylineItem oppline1 = new OpportunitylineItem(
        priceBookEntryId = priceBookEntry.Id,
        OpportunityId = oppty.id,
        Quantity = 1,
        ServiceDate = Date.today() + 1,
        UnitPrice = 100.00,
        URN__c = '1234');

        try {
            
            insert oppline1;
            oppty.StageName = 'Closed Won';
            update oppty;
            
        } catch (exception e) {
            system.debug('>>>>>>>>>>>>>>>>> Exception : ' + e.getMessage());
        }
        //return oppline1;

        String URNSearchable = [Select URNSearchable__c from Opportunity where id = : oppty.id].URNSearchable__c;
        //URNSearchable=oppline1.URN__c;
        //System.assertEquals('1234',URNSearchable);
        
        test.stopTest();
        return oppty;
    }
}