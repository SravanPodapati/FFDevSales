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
private class SalesRevenueChart_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}

	static testMethod void testPublicationGroupData() {
		String advertiserRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Advertiser_Record_Type__c).getRecordTypeId();
		// String agencyRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants__c.getInstance('All').Agency_Record_Type__c ).getRecordTypeId();

		Account acctAdv = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Advertiser',
		BillingStreet = 'Street',
		BillingState = 'TestState',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'City',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId);
		insert acctAdv;

		/* SalesRevenue__c sr = new SalesRevenue__c(
                                                        AdvertiserId__c=acctAdv.Id,
                                                        Publication_Group__c = 'Metro Display',
                                                        Publication__c = 'Metro',
                                                        Period_Start_Date__c=Date.today(),
                                                        Period_End_Date__c=Date.today(),
                                                        Revenue_Amount__c = 5000
                                                        );   
            insert sr;*/

		List < SalesRevenue__c > srList = new List < SalesRevenue__c > ();

		/* srList.add(new SalesRevenue__c(
                                                        AdvertiserId__c=acctAdv.Id,
                                                        Publication_Group__c = 'Mail Plus',
                                                        Publication__c = 'Metro',
                                                        Period_Start_Date__c=Date.today(),
                                                        Period_End_Date__c=Date.today(),
                                                        Revenue_Amount__c = 15000
                                                        ));*/

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Metro Classified',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 5000));

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Metro Classified',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 6000));

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Metro Display',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 10000));

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Metro Display',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 10500));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Classified',
		Publication__c = 'Mail on Sunday',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 15000));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Classified',
		Publication__c = 'Mail on Sunday',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 16000));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Display',
		Publication__c = 'The Daily Mail',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 25000));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Display',
		Publication__c = 'The Daily Mail',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 27000));

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'ES Classified',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 25000));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'ES Classified',
		Publication__c = 'Metro',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 27000));

		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Online',
		Publication__c = 'World News',
		Period_Start_Date__c = Date.today(),
		Period_End_Date__c = Date.today(),
		Revenue_Amount__c = 25000));
		srList.add(new SalesRevenue__c(
		AdvertiserId__c = acctAdv.Id,
		Department__c = 'Mail Online',
		Publication__c = 'India',
		Period_Start_Date__c = Date.today().addYears(1),
		Period_End_Date__c = Date.today().addYears(1),
		Revenue_Amount__c = 27000));
		insert srList;

		ApexPages.StandardController sc = new ApexPages.StandardController(acctAdv);
		// newAccountPlan testAccPlan = new newAccountPlan(sc);

		SalesRevenueChart testAcc = new SalesRevenueChart(sc);

		PageReference pageRef = Page.SalesRevenueCharts;

		pageRef.getParameters().put('id', String.valueOf(acctAdv.Id));
		Test.setCurrentPage(pageRef);

		List < SalesRevenueChart.SalesRevenue > getChartList = SalesRevenueChart.getChartData();
		List < SalesRevenueChart.PublicationSalesRevenue > getList = SalesRevenueChart.getPublicationGroupChartData();
		List < SalesRevenueChart.SalesRevenueByQtr > getQtrList = SalesRevenueChart.getRevenueByQtr();
		List < SalesRevenueChart.SalesRevenueByYearTitle > getYearList = SalesRevenueChart.getRevenueByYearTitle();


		List < AggregateResult > revenueAggr = [Select CALENDAR_QUARTER(Period_End_Date__c) qtr
		From SalesRevenue__c
		Where AdvertiserId__c = : acctAdv.Id
		Group By CALENDAR_QUARTER(Period_End_Date__c)];

		Integer quarter;
		For(AggregateResult ar: revenueAggr) {
			quarter = (Integer) ar.get('qtr');
		}

		List < SalesRevenueChart.SalesRevenueByYearTitle > getYearList1 = SalesRevenueChart.getRevenueByYearTitle(String.ValueOf(quarter));

		List < SalesRevenueChart.SalesRevenueByYearTitle > getLastQuarter = SalesRevenueChart.getRevenueLastQuarter();
		List < SalesRevenueChart.SalesRevenueByYearTitle > getThisQuarter = SalesRevenueChart.getRevenueThisQuarter();
		List < SalesRevenueChart.SalesRevenueByYearTitle > getNextQuarter = SalesRevenueChart.getRevenueNextQuarter();

		Id pubGroup = SalesRevenueChart.publicationGroupReportId;
		String accountName = SalesRevenueChart.accountDetail.Name;

		SalesRevenueChart.SalesRevenueByQtr src = new SalesRevenueChart.SalesRevenueByQtr();

		SalesRevenueChart.SalesRevenueByYearTitle sryt = new SalesRevenueChart.SalesRevenueByYearTitle();

	}


}