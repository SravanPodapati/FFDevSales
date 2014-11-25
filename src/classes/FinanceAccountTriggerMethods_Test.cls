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
 */@isTest
public class FinanceAccountTriggerMethods_Test {
  public static void setUpData() {
    insert TestData.createCountriesList();
    ConstantsH__c ch = new ConstantsH__c();
    ch.Acc_and_Contact_owner__c = 'A&N Media';
    ch.Department__c = 'IT';
    insert ch;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    User u = new User(Alias = 'anmedia', Email = 'ANMedia@dmgmedia.com',
    EmailEncodingKey = 'UTF-8', FirstName = 'A&N', LastName = 'Media', LanguageLocaleKey = 'en_US',
    LocaleSidKey = 'en_US', ProfileId = p.Id,
    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ANMedia@dmgmedia.com');

    insert u;

    //insert custom settings for BookingSystemSettings
    insert TestData.createBookingSystemSettings();

    //insert categories  
    insert TestData.createCustomerCategory();
    insert TestData.buildCompany();
    insert TestData.buildMetroCompany();
    insert TestData.createCountryCodeSettings();

  }

  private static testMethod void testUpdateFinanceAccount() {
    setUpData();

    Account acc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
    acc.Industry_Minor_Category__c = '10.01.00 - FIRST AID';
    insert acc;
    
   FinanceAccount__c finAcc= TestData.buildFinanceAccount(acc);
   insert finAcc;
   Test.startTest();
   finAcc.CloseStatus__c='Dead';
   update finAcc;

    Test.stopTest();
  }

 
  
  



}