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
 public class TestData {
    public static BookingSystemSettings__c createBookingSystemSettings() {
        return new BookingSystemSettings__c(Name = 'CCI',
        Domain__c = 'https://test.cci-webaccess-dmgmedia.co.uk',
        ContentType__c = 'application/json',
        CustomerPath__c = '/api/customers',
        TempDomain__c = 'https://demo.ads.ccieurope.com',
        AccountPath__c = '/api/accounts',
        BookingPluginPath__c = '/salesforce/plugin/orders/create?',
        ClientId__c = 'SharedSecretUser',
        SharedSecret__c = '969c2855-2882-484c-95f1-c02b22eb1d06',
        UserProfilePath__c = '/api/setup/user/profiles',
        UserGroupPath__c = '/api/setup/user/groups',
        EditBookingPluginPath__c = '/salesforce/plugin/orders/edit/',
        AuthenticationPath__c = '/api/authentication/oauth/token?grant_type=password&client_id=app&username=<username>&password=<password>',
        AuthenticationPathClient__c = '/api/authentication/oauth/token?grant_type=client_credentials&client_id=<clientId>&&client_secret=<clientsecret>',
        ServiceUserName__c = 'GLUECCI.servicet',
        ServiceUserGroup__c='Glue',
        ServiceUserMailProfile__c='ML Systems',
        AuthPath__c='/api/authentication/oauth/authorize?response_type=code&client_id=app&redirect_uri=http',
        ServiceUserMetroProfile__c='MT Manager',
        PackagePath__c = '/api/setup/product/packages',
        ConceptValuePath__c='/api/setup/product/conceptvalues', 
        ProductKeyPath__c ='/api/setup/product/key',     
        CalendarPath__c='/api/setup/product/publishingcalendar/',
        ReadTimeout__c = 30000,
        OrderPath__c='api/orders');
    }



       public static BookingSystemSettings__c createIncompleteBookingSystemSettings1() {
        return new BookingSystemSettings__c(Name = 'CCI',
        // Domain__c='https://test.cci-webaccess-dmgmedia.co.uk', 
        // ContentType__c='application/json', 
        CustomerPath__c = '/api/customers',
        TempDomain__c = 'https://demo.ads.ccieurope.com',
        AccountPath__c = '/api/accounts',
        BookingPluginPath__c = '/salesforce/plugin/orders/create?',
        ClientId__c = 'SharedSecretUser',
        SharedSecret__c = '969c2855-2882-484c-95f1-c02b22eb1d06',
        UserProfilePath__c = '/api/setup/user/profiles',
        UserGroupPath__c = '/api/setup/user/groups',
        EditBookingPluginPath__c = '/salesforce/plugin/orders/edit/',
        AuthenticationPath__c = '/api/authentication/oauth/token?grant_type=password&client_id=app&username=<username>&password=<password>',
        AuthenticationPathClient__c = '/api/authentication/oauth/token?grant_type=client_credentials&client_id=<clientId>&&client_secret=<clientsecret>');
    }

     public static OrderParams__c createOrderParamSettings() {
        return new OrderParams__c(Name = 'CCI',
        Accountid__c = '&accountid=',
        Advertiser__c= '&advertiserid=',
        AuthCode__c= '&authorizationcode',
        ClientId__c= '&clientid=app&redirecturi=http',
        ConfirmationURL__c= '&confirmationurl=',
        Group__c= '&group=',
        OpportunityId__c= '&opportunityid=',
        Password__c= '&password=',
        Profile__c= '&profile=',
        RelatedCustomers__c = '&relatedcustomers=',
        UserId__c= 'userid=');
               
    }


    public static BookingSystemSettings__c createIncompleteBookingSystemSettings2() {
        return new BookingSystemSettings__c(Name = 'CCI',
        Domain__c = 'https://test.cci-webaccess-dmgmedia.co.uk',
        ContentType__c = 'application/json',
        CustomerPath__c = '/api/customers',
        TempDomain__c = 'https://demo.ads.ccieurope.com',
        AccountPath__c = '/api/accounts',
        BookingPluginPath__c = '/salesforce/plugin/orders/create?',
        ClientId__c = 'SharedSecretUser',
        // SharedSecret__c='969c2855-2882-484c-95f1-c02b22eb1d06', 
        UserProfilePath__c = '/api/setup/user/profiles',
        UserGroupPath__c = '/api/setup/user/groups',
        EditBookingPluginPath__c = '/salesforce/plugin/orders/edit/',
        AuthenticationPath__c = '/api/authentication/oauth/token?grant_type=password&client_id=app&username=<username>&password=<password>',
        AuthenticationPathClient__c = '/api/authentication/oauth/token?grant_type=client_credentials&client_id=<clientId>&&client_secret=<clientsecret>');
    }


    public static Account buildAccount(String recordType, String accountType) {
        Account testAcc = new Account();
        testAcc.Name = 'TestAccount';
        testAcc.Type = accountType;
        testAcc.Phone = '0208426234';
        testAcc.BillingStreet = 'testStreet';
        testAcc.BillingPostalCode = 'ha5 4re';
        testAcc.BillingCountry = 'United Kingdom';

        //insert testAcc;
        if (recordType == 'Advertiser') {
            Id advertiserRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Advertiser').RecordTypeId;
            testAcc.RecordTypeId = advertiserRecordTypeId;
            testAcc.Industry = '04-Drinks'; // Industry only valid for Advertiser
        } else if (recordType == 'Agency') {
            Id agencyRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Agency').RecordTypeId;
            testAcc.RecordTypeId = agencyRecordTypeId;
        }
        return testAcc;
    }

    public static Company__c buildCompany() {

        Company__c c = new Company__c();
        c.Name = 'MailTestCo';
        return c;
    }

    public static Company__c buildMetroCompany() {

        Company__c c = new Company__c();
        c.Name = 'MetroTestCo';
        return c;
    }

    public static FinanceAccount__c buildFinanceAccount(Account acc) {

        Company__c c = buildCompany();
        insert c;
        FinanceAccount__c testAcc = new FinanceAccount__c();
        testAcc.Name = 'TestFinAccount';
        testAcc.Account__C = acc.Id;
        testAcc.Company__c = c.Id;


        return testAcc;
    }
    public static FinanceAccount__c buildMetroFinanceAccount(Account acc) {

        Company__c c = buildMetroCompany();
        insert c;
        FinanceAccount__c testAcc = new FinanceAccount__c();
        testAcc.Name = 'TestFinAccount';
        testAcc.Account__C = acc.Id;
        testAcc.Company__c = c.Id;


        return testAcc;
    }

    public static BookingSystemSettings__c initBookingSystemSettings() {
        BookingSystemSettings__c bookingSystemSetting = new BookingSystemSettings__c(Name = 'CCI', AuthenticationPath__c = '/api/authentication/oauth/token?grant_type=password&client_id=app&username=<username>&password=<password>', CustomerPath__c = '/api/customers', AccountPath__c = '/api/accounts', tempDomain__c = 'https://demo.ads.ccieurope.com', ContentType__c = 'application/json', Domain__c = 'https://test.cci-webaccess-dmgmedia.co.uk',ReadTimeout__c=30000);
        return bookingSystemSetting;

    }

    public static list < Industry_Category_Mapping__c > initIndustryCategoryMapping() {
        list < Industry_Category_Mapping__c > categoryList = new list < Industry_Category_Mapping__c > ();
        Industry_Category_Mapping__c category1 = new Industry_Category_Mapping__c(Industry__c = '08 - COSMETICS & TOILETRIES', Minor_Category__c = '08.06.00 - PROFESSIONAL/B2B HAIR;08.06.05 - PROF/B2B COLOUR PROD/SER;08.06.10 - PROF SHAMPOO/CONDITIONER;08.06.11 - PROF STYLING PRODUCTS;08.06.15 - PERMS;08.06.20 - STRAIGHTENING;08.06.25 - PROF HAIRDRESSING RANGE AD;08.06.30 - PROF HAIR/BEAUTY EXH/EVENTS;08.06.35 - HAIR EXTENSIONS;08.06.40 - SALONS;08.06.45 - SALON EQUIPMENT/FURNITURE;08.06.55 - PROF BEAUTY SPA/SKINCARE', Name = '08.06 - PROFESSIONAL/B2B HAIR', UniqueKey__c = '08 - COSMETICS & TOILETRIES08.06 - PROFESSIONAL/B2B HAIR');
        categoryList.add(category1);
        Industry_Category_Mapping__c category2 = new Industry_Category_Mapping__c(Industry__c = '08 - COSMETICS & TOILETRIES', Minor_Category__c = '08.80.05 - COSM & TOIL - INTERNET SPEND', Name = '08.80 - COSM & TOIL - INTERNET SPEND', UniqueKey__c = '08 - COSMETICS & TOILETRIES08.80 - COSM & TOIL - INTERNET SPEND');
        categoryList.add(category2);

        return categoryList;
    }

    public static Account addIndustryCategory(Account acc, Industry_Category_Mapping__c ind) {
        // Industry_Category_Mapping__c ind =initIndustryCategoryMapping();
        acc.Industry = ind.Industry__c;
        acc.Industry_Sub_Category__c = ind.Name;
        acc.Industry_Minor_Category__c = ind.Minor_Category__c;
        return acc;
    }


    public static Opportunity createOpportunity(Account acc) {
        Opportunity newOp = new Opportunity();
        if (acc != null) {
            newOp.AccountId = acc.Id;
            newOp.Name = 'Direct Order for ' + +acc.Name +' '+ System.now();
            newOp.Type = 'Proactive';
            newOp.StageName = 'Preparation';
            //  newOp.Agency__c = agencyId;
            newOp.closeDate = System.Today();
            newOp.CurrencyIsoCode = 'GBP';

            //insert newOp;

        }
        return newOp;

    }
    
        
      public static OpportunityLineItem createOpportunityLineItem(Opportunity opp) {
      
       
      return new OpportunitylineItem(
              
                OpportunityId       = opp.id, 
                Quantity            = 1, 
                ServiceDate         = Date.today()+1,
                UnitPrice           = 100.00,
                URN__c              = '1234');
                
              
      }
    
    
    public static Order createOrder(Account acc, Opportunity opp) {
        return new Order(AccountID = acc.id, EffectiveDate = System.Today(), CCI_Account_ID__c = '1',
        Is_Cancelled__c = false, Has_Complaint__c = false, IsReductionOrder = false,
        Is_Accepted__c = true, CCI_Order_ID__c = '123456', Base_Price__c = 50,
        First_Delivery_Date__c = System.Today(), Last_Delivery_Date__c = System.today(),
        Opportunity__c = opp.Id, CCI_Customer_ID__c = '1', Status = 'Draft',
        Booking_Source__c = 'CCIBookingPlugin',Caller_Name__C='TestContact',Caller_Phone__c = '004412345678');
    }

    public static OrderItem createOrderItem(Order tempOrder) {
        return new OrderItem(OrderID = tempOrder.id,CCI_Order_Item_ID__c='345688',CCI_Schedule_Item_Id__c='672536273',CCI_Package_Item_Id__c='76274876',Quantity=1,UnitPrice=100.00);
    }

    public static list < Account_Mapping__c > buildAccountMaping(Id accountID, String mailID, String metroID) {
        list < Account_Mapping__c > resultMappings = new list < Account_Mapping__c > ();
        if (!String.isBlank(mailID)) {
            resultMappings.add(new Account_Mapping__c(Account__c = accountID, Active__c = true, Source_Key__c = mailID, Source_System__c = 'CCI Mail', UniqueSourceKey__c = 'CCI' + mailID + 'Active'));
        }
        if (!String.IsBlank(metroID)) {
            resultMappings.add(new Account_Mapping__c(Account__c = accountID, Active__c = true, Source_Key__c = metroID, Source_System__c = 'CCI Metro', UniqueSourceKey__c = 'CCI' + metroID + 'Active'));
        }
        return resultMappings;
    }

    public static list < CustomerCategory__c > createCustomerCategory() {
        list < CustomerCategory__c > resultList = new list < CustomerCategory__c > ();
        resultList.add(new CustomerCategory__c(Name = 'Brand', CategoryCode__c = 'BRAND'));
        resultList.add(new CustomerCategory__c(Name = 'Charity', CategoryCode__c = '05'));
        resultList.add(new CustomerCategory__c(Name = 'Direct Advertiser', CategoryCode__c = '04'));
        resultList.add(new CustomerCategory__c(Name = 'DMGT Group', CategoryCode__c = '11'));
        resultList.add(new CustomerCategory__c(Name = 'Holding Agency', CategoryCode__c = 'HOLDINGAG'));
        resultList.add(new CustomerCategory__c(Name = 'Holding Company', CategoryCode__c = 'Holding Company'));
        resultList.add(new CustomerCategory__c(Name = 'NonNPA', CategoryCode__c = '02'));
        resultList.add(new CustomerCategory__c(Name = 'NPA', CategoryCode__c = '01'));
        resultList.add(new CustomerCategory__c(Name = 'Private Advertiser', CategoryCode__c = 'PRIVATE'));

        return resultList;
    }

    public static list < BookingSystemCountryCodes__c > createCountryCodeSettings() {
        list < BookingSystemCountryCodes__c > resultList = new list < BookingSystemCountryCodes__c > ();
        resultList.add(createCountryCodeSetting('United Kingdom', 'UK'));
        resultList.add(createCountryCodeSetting('Country', 'cc'));
        return resultList;
    }

    public static BookingSystemCountryCodes__c createCountryCodeSetting(String name, String cc) {
        return new BookingSystemCountryCodes__c(Name = name, CountryCode__c = cc);
    }
    
    public static list<pw_cc__CountryObject__c> createCountriesList(){
        list<pw_cc__CountryObject__c> resultList = new list<pw_cc__CountryObject__c>();
        resultList.add(createCountry('United Kingdom','GB','GBR'));
        resultList.add(createCountry('United States','US','USA'));
        return resultList;
    }
    
    public static pw_cc__CountryObject__c createCountry(String countryName, String ISO2, String ISO3){
        return new pw_cc__CountryObject__c(name = countryName, pw_cc__IsoCode_2__c = ISO2, pw_cc__IsoCode_3__c = ISO3);
    }
}