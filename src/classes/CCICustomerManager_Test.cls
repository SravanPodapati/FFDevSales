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
private class CCICustomerManager_Test {

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

	private static testMethod void updateCustomerData_Test1() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo, true);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test2() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test3() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();
		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo, null);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test4() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = true;
		newAcc.Type = 'Billing Agency';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test5() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Billing Agency';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = true;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test6() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Billing Agency';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = true;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":null,"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test7() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = true;
		newAcc.Type = 'Billing Agency';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567891';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":null,"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test8() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '10.05.10 - HEALTH & FITNESS APPLIANCES';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567892';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"testmetro123","externalCustomerId":"001M000000XbjZWIAZ","revisionId":"1","creationUser":"SRAVAN.PODAPATI","creationTime":"2014-05-29","modifierUser":"SRAVAN.PODAPATI","initiatingTime":"2014-05-29","addressAs":null,"name":"Wedclient300","initials":null,"surname":null,"companyName":"Wedclient300","presentationName":"Wedclient300","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":0,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":null,"creditSummaryCreditRiskStatusName":null,"creditSummaryCreditLimitAmount":null,"creditRating":null,"creditScore":null,"summaryAgeBucket0":null,"summaryAgeBucket1":null,"summaryAgeBucket2":null,"summaryAgeBucket3":null,"summaryAgeBucket4":null,"summaryAgeBucket5":null,"summaryOutstandingAmount":null,"unappliedAmount":null,"balanceAmount":null,"exposureAmount":null,"disputedAmount":null,"bookedNotInvoicedAmount":null,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"Global","businessUnitName":"Global","businessUnitDesc":"Global Business Unit - System generated"},"mainAddress":null,"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":null,"cellTelephone":null,"fax":null,"miscTelephones":null,"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":470759898,"aliasType":"System","name":"Wedclient300"}]},"industryCodes":{"industryCode":[{"code":"04.02.07","description":"MINERAL WATER","displayString1":"DRINK","displayString2":"SOFT DRINKS","displayString3":"MINERAL WATER"}]},"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":470759890,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759891,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null},{"id":470759892,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"374430","externalCustomerId":"001M000000XbjZWIAZ","customerFinanceId":null,"presentationName":"Wedclient300","streetAddress":null,"zipCode":null,"countryName":null,"areaCode":null,"extension":null,"number":null,"pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":null,"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo, true);
		Test.stopTest();
	}

	private static testMethod void updateCustomerData_Test9() {
		setUpData();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Account newAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		newAcc.Name = 'New Account';
		newAcc.Phone = '0123456789123';
		newAcc.BillingStreet = 'new account';
		newAcc.BillingCity = 'new city';
		newAcc.BillingPostalCode = 'aa111aa';
		newAcc.BillingState = 'new state';
		newAcc.BillingCountry = 'United Kingdom';
		newAcc.Industry_Minor_Category__c = '';
		newAcc.CCIMailCustID__c = null;
		newAcc.CCIMetroCustID__c = 'testmetro123';
		newAcc.NPA__c = false;
		newAcc.Type = 'Direct Advertiser';
		newAcc.DoCCIInt__c = true;
		insert newAcc;

		Account oldAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
		oldAcc.Name = 'Old Account';
		oldAcc.Phone = '01234567892';
		oldAcc.BillingStreet = 'old account';
		oldAcc.BillingCity = 'old city';
		oldAcc.BillingPostalCode = 'aa111aa';
		oldAcc.BillingState = 'old state';
		oldAcc.BillingCountry = 'United Kingdom';
		oldAcc.Industry_Minor_Category__c = '10.05.11 - ATHLETES PULSE MONITOR';
		oldAcc.CCIMailCustID__c = null;
		oldAcc.CCIMetroCustID__c = 'testmetro123';
		oldAcc.NPA__c = false;
		oldAcc.Type = 'Direct Advertiser';

		List < String > oldAccInfo = new List < String > ();
		List < String > newAccInfo = new List < String > ();

		CCICustomerWrapper.AccountInfo ai = new CCICustomerWrapper.AccountInfo(newAcc.Id, newAcc.Name, newAcc.Phone, newAcc.BillingStreet, newAcc.BillingCity, newAcc.BillingPostalCode, newAcc.BillingState, newAcc.BillingCountry, newAcc.Industry_Minor_Category__c, newAcc.CCIMailCustID__c, newAcc.CCIMetroCustID__c, newAcc.NPA__c, newAcc.Type, newAcc.FirstName__c, newAcc.Salutation__c);
		newAccInfo.add(JSON.serialize(ai));
		CCICustomerWrapper.AccountInfo oldai = new CCICustomerWrapper.AccountInfo(newAcc.Id, oldAcc.Name, oldAcc.Phone, oldAcc.BillingStreet, oldAcc.BillingCity, oldAcc.BillingPostalCode, oldAcc.BillingState, oldAcc.BillingCountry, oldAcc.Industry_Minor_Category__c, oldAcc.CCIMailCustID__c, oldAcc.CCIMetroCustID__c, oldAcc.NPA__c, oldAcc.Type, oldAcc.FirstName__c, oldAcc.Salutation__c);
		oldAccInfo.add(JSON.serialize(oldai));
		CCICustomerWrapper.AccessToken tokenInfo;
		boolean isMail = false;
		String customerJson = '[{"customerId":"373506","externalCustomerId":"001M000000W0ciAIAR","revisionId":"1","creationUser":"YUVIKA.CCIAGGARWAL","creationTime":"2014-02-25","modifierUser":"YUVIKA.CCIAGGARWAL","initiatingTime":"2014-02-25","addressAs":null,"name":"Testad3","initials":null,"surname":null,"companyName":"Testad3","presentationName":"Testad3","tradingName":null,"formatInitials":false,"formatName":true,"formatTradingName":true,"email":null,"website":null,"companyRegistrationNo":null,"purchaseOrderRequired":false,"message":null,"note":null,"vatNo":null,"externalCreditRating":null,"categoryCode":"04","categoryName":"Advertiser","statusCode":"OPEN","statusName":"Open","doQuotesOnly":false,"isBookingAllowed":true,"hasContract":false,"doNeverSolicit":false,"doNeverEmail":false,"doNeverFax":false,"isConfirmationNeeded":false,"source":"AdDesk Sales","prospectSource":null,"languageCode":"ENG","languageName":"ENG","financeId":null,"creditLimitAmount":null,"creditStatusCode":null,"creditStatusName":null,"salesStatusCode":"NONE","salesStatusName":"None","mainAttentionOf":null,"boxForwardingMethod":"MAIL","boxAttentionOf":null,"boxEmail":null,"voucherCopyForwardingMethod":"E_MAIL","voucherCopyAttentionOf":null,"voucherCopyEmail":null,"proofPrintForwardingMethod":"E_MAIL","proofPrintAttentionOf":null,"proofPrintEmail":null,"invoiceForwardingMethod":"MAIL","invoiceAttentionOf":null,"invoiceEmail":null,"materialForwardingMethod":"MAIL","materialAttentionOf":null,"materialEmail":null,"contractForwardingMethod":"MAIL","contractAttentionOf":null,"contractEmail":null,"agencyCommission":null,"rateCode":null,"noOfAccounts":11,"embeddedText":null,"salesNote":null,"extraPaymentReason":null,"creditSummaryCreditRiskStatusCode":"1","creditSummaryCreditRiskStatusName":"1 - New Account","creditSummaryCreditLimitAmount":0.00,"creditRating":null,"creditScore":null,"summaryAgeBucket0":0.00,"summaryAgeBucket1":0.00,"summaryAgeBucket2":0.00,"summaryAgeBucket3":0.00,"summaryAgeBucket4":0.00,"summaryAgeBucket5":0.00,"summaryOutstandingAmount":0.00,"unappliedAmount":0.00,"balanceAmount":0.00,"exposureAmount":0.00,"disputedAmount":0.00,"bookedNotInvoicedAmount":0.00,"noOfBookedActPriceItems":null,"noOfBookedOrders":null,"externalIds":null,"businessUnit":{"businessUnitCode":"ML","businessUnitName":"Mail","businessUnitDesc":"Mail Classified"},"mainAddress":{"streetAddress":"2 Derry Street","streetName":"2 Derry Street","streetNo":null,"additionalAddress":null,"collection1":null,"floorNo":null,"roomNo":null,"roomType":null,"nameOfHouse":null,"station":null,"city":null,"extraCity":null,"county":null,"zipCode":"SW2 3RE","stateCode":null,"stateName":null,"countryCode":"UK","countryName":"United Kingdom","isAddressFormatted":false,"isConfidential":false,"source":"AdDesk Sales","validationStatus":"NOT_INVESTIGATED","validationSource":"Manual","validationDate":null,"barCode":null,"pobox":null,"coaddress":null},"boxAddress":null,"voucherCopyAddress":null,"proofPrintAddress":null,"invoiceAddress":null,"materialAddress":null,"contractAddress":null,"mainTelephone":{"id":468947513,"areaCode":null,"countryCode":null,"extension":null,"number":"0121323233","description":null},"cellTelephone":null,"fax":null,"miscTelephones":{"miscTelephone":[{"id":468947513,"areaCode":null,"countryCode":null,"extension":null,"number":"0121323233","description":null}]},"boxFax":null,"voucherCopyFax":null,"proofPrintFax":null,"materialFax":null,"invoiceFax":null,"contractFax":null,"contactPersons":null,"namedRates":null,"nameAliases":{"nameAlias":[{"id":468947518,"aliasType":"System","name":"Testad3"}]},"industryCodes":null,"salesTerritories":null,"salesContacts":null,"plannedContacts":null,"campaigns":null,"roles":{"custRole":[{"id":468947509,"roleCode":"Owner","roleName":"Owner","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"373506","externalCustomerId":"001M000000W0ciAIAR","customerFinanceId":null,"presentationName":"Testad3","streetAddress":"2 Derry Street","zipCode":"SW2 3RE","countryName":"United Kingdom","areaCode":null,"extension":null,"number":"0121323233","pobox":null},"relatedRoles":null},{"id":468947510,"roleCode":"Advertiser","roleName":"Advertiser","isSelectable":false,"isIndependentsMandatoryRole":true,"customer":{"customerId":"373506","externalCustomerId":"001M000000W0ciAIAR","customerFinanceId":null,"presentationName":"Testad3","streetAddress":"2 Derry Street","zipCode":"SW2 3RE","countryName":"United Kingdom","areaCode":null,"extension":null,"number":"0121323233","pobox":null},"relatedRoles":null},{"id":468947517,"roleCode":"CLIENT","roleName":"Client","isSelectable":true,"isIndependentsMandatoryRole":false,"customer":{"customerId":"373506","externalCustomerId":"001M000000W0ciAIAR","customerFinanceId":null,"presentationName":"Testad3","streetAddress":"2 Derry Street","zipCode":"SW2 3RE","countryName":"United Kingdom","areaCode":null,"extension":null,"number":"0121323233","pobox":null},"relatedRoles":null}]},"clients":null,"agencies":null,"customerCategory":{"categoryCode":"04","categoryName":"Advertiser","categoryDesc":"Direct Advertiser - Commercial"},"paymentTerm":{"code":"SEVENDAYS","name":"7 days","description":null,"numberOfDays":7,"numberOfMonths":0,"text":"Please pay on due date"},"collectionMethod":{"code":"SEVENDAYS","name":"Seven Days","description":"Seven Day Terms","collectionMethod":"INVOICING"},"promptPaymentDiscount":null,"propertyValues":null,"applicableTaxes":{"taxType":[{"taxTypeName":"Standard VAT Type","taxTypeCode":"Standard","taxTypeDesc":"Standard VAT Type"}]},"specialTaxTables":{"taxTable":[{"taxTableName":"Standard","taxTableCode":"STA","taxTableDesc":"Standard","taxPercentage":200000}]},"rateType":null,"dunsno":null,"dunsparentNo":null,"dunsname":null}]';

		Test.startTest();
		CCICustomerManager.updateCustomerData(ai, oldAi, customerJson, tokenInfo, true);
		Test.stopTest();
	}
}