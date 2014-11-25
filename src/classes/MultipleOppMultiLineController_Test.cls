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
private class MultipleOppMultiLineController_Test {
	static{
		BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
		if (bSS == null) insert TestData.createBookingSystemSettings();
		if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
			insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
		}
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
	}
	Account acct;
	Account agency;
	Contact cnt;
	String advertiserRecTypeId;
	String agencyRecTypeId;
	User testUser;
	PricebookEntry priceBookEntry;

	MultipleOppMultiLineController_Test() {
		testUser = [
		Select name, email, ProfileId, Profile.Name
		From User
		Where isActive = true /*and managerId != null*/
		And Profile.Name = 'System Administrator'
		Limit 1];

		Pricebook2 testPB = [Select
		name
		From Pricebook2
		Where isActive = true
		Limit 1];

		ConstantsH__c constH = [
		select Name, Price_Book__c, Acc_and_Contact_owner__c
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

		List < RecordType > oppRecType = [
		Select DeveloperName
		From RecordType
		Where SObjectType = 'Account'];
		for (RecordType r: oppRecType) {
			if (r.DeveloperName == Constants__c.getInstance('All').Advertiser_Record_Type__c) {
				advertiserRecTypeId = r.Id;
			} else if (r.DeveloperName == Constants__c.getInstance('All').Agency_Record_Type__c) {
				agencyRecTypeId = r.Id;
			}
		}

		Pricebook2 priceBook = [
		Select
		p.Name
		From Pricebook2 p
		Where p.Name = : newConstH.Price_Book__c
		Limit 1];


		priceBookEntry = [
		Select
		name,
		Product2Id
		From PricebookEntry
		Where pricebook2Id = : priceBook.Id
		limit 1];

		System.debug('**************priceBookEntry:' + priceBookEntry);

		acct = new Account(
		Name = 'Test Account',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		Industry = 'Finance',
		RecordTypeId = advertiserRecTypeId,
		BillingCountry = 'United Kingdom');
		insert acct;

		agency = new Account(
		Name = 'Test Agency',
		AccountNumber = 'AGN123456',
		Type = 'Billing Agency',
		Industry = 'Finance',
		RecordTypeId = agencyRecTypeId,
		BillingStreet = '1',
		BillingPostalCode = 'A111AA',
		Phone = '123456789098',
		BillingCountry = 'United Kingdom');
		insert agency;

		cnt = new Contact();
		cnt.AccountId = acct.Id;
		cnt.LastName = 'Test Last Name';
		cnt.FirstName = 'Test First Name';
		cnt.MailingCity = 'Test Mailing City';
		cnt.MailingCountry = 'Test Mailing Country';
		cnt.MailingPostalCode = 'TestMPC';
		cnt.MailingState = 'Test Mailing State';
		cnt.MailingStreet = 'Test Mailing Street';
		cnt.MailingCountry = 'United Kingdom';
		insert cnt;
	}

	/*static testMethod void myUnitTest() 
    {
       User testUser  = 
                [
                Select name, email, ProfileId, Profile.Name 
                From User 
                Where isActive = true
                And Profile.Name = 'System Administrator' 
                Limit 1
                ];
        
        List<SelectOption> productOptions;
        List<SelectOption> stageOptions;
        List<SelectOption> roleOptions;
        List<OpportunityLineItem> oppLine; 
        List<SelectOption> noOfProducts;
        List<SelectOption> dateIncrement;
        
        OpportunityContactRole cr = new OpportunityContactRole();
                
        Pricebook2  testPB          = [Select 
                                        name
                                        From Pricebook2
                                        Where isActive = true
                                        Limit 1];
        
        
        //#  
        //# Ensure that the test results will not depend
        //# on running user's Custom Settings
        //# 
        
        ConstantsH__c constH = 
            [
            select Name, Price_Book__c, Acc_and_Contact_owner__c 
            from ConstantsH__c
            where SetupOwnerId = :testUser.ProfileId 
            limit 1
            ];
        delete constH;
        
        ConstantsH__c newConstH = new ConstantsH__c
            (
                Acc_and_Contact_owner__c    = testUser.Name,
                Department__c               = 'None',
                IsManager__c                = false,
                Price_Book__c               = testPB.Name,
                SetupOwnerId                = testUser.ProfileId        
            );
        insert newConstH;
        
        List<RecordType> oppRecType = [
                                        Select DeveloperName
                                        From RecordType
                                        Where SObjectType = 'Account'];
        
        
        String advertiserRecTypeId; 

        String agencyRecTypeId;      

        for(RecordType r:oppRecType)
        {
            if(r.DeveloperName==Constants__c.getInstance('All').Advertiser_Record_Type__c)
            {
                advertiserRecTypeId = r.Id;
            }
            else if (r.DeveloperName==Constants__c.getInstance('All').Agency_Record_Type__c)
            {
                agencyRecTypeId = r.Id;
            }
        }

        Account acct = new Account
                (
                Name            = 'Test Account', 
                AccountNumber   = 'ABC123456',
                Type            = 'Client',
                Industry        = 'Finance',
                RecordTypeId    = advertiserRecTypeId,
                BillingCountry  = 'United Kingdom'
                );
        insert acct;
        
        Account agency = new Account
                (
                Name            = 'Test Agency', 
                AccountNumber   = 'AGN123456',
                Type            = 'Billing Agency',
                Industry        = 'Finance',
                RecordTypeId    = agencyRecTypeId,
                BillingStreet   = '1',
                BillingPostalCode = 'A111AA',
                BillingCountry  = 'United Kingdom'
                );
        insert agency;

        Contact cnt = new Contact();
            cnt.AccountId           = acct.Id;
            cnt.LastName            = 'Test Last Name';
            cnt.FirstName           = 'Test First Name';
            cnt.MailingCity         = 'Test Mailing City';
            cnt.MailingCountry      = 'Test Mailing Country';
            cnt.MailingPostalCode   = 'TestMPC';
            cnt.MailingState        = 'Test Mailing State';
            cnt.MailingStreet       = 'Test Mailing Street';
            cnt.MailingCountry          = 'United Kingdom';
        insert cnt;
        
        Pricebook2 priceBook = 
                [
                Select
                    p.Name
                From Pricebook2 p 
                Where p.Name = :newConstH.Price_Book__c
                Limit 1
                ];
                
        
        PricebookEntry priceBookEntry = 
                [
                Select 
                    name,
                    Product2Id 
                From PricebookEntry 
                Where pricebook2Id =: priceBook.Id 
                limit 1
                ];
        
        
        MultipleOppMultiLineController cqoc;
        
        
        Test.startTest();

            system.runAs(testUser)
            {
                PageReference pageRef = Page.MultipleOppMultipleLines;
                Test.setCurrentPageReference(pageRef);
                
                cqoc = new MultipleOppMultiLineController();
                
                productOptions      = cqoc.getProductOptions();
                stageOptions        = cqoc.getStageOptions();
                //oppLine             = cqoc.opportunityLineView;
                noOfProducts        = cqoc.getNoOfProducts(); 
                dateIncrement       = cqoc.getDateIncProducts();
                roleOptions                     = cqoc.roleOptions;
                
                cqoc.stageSelectList        = 'Preparation';
                
                cqoc.account                = acct;
                cqoc.opportunity.AccountId  = acct.Id;
                cqoc.opportunity.Type       = 'Proactive';
                cqoc.opportunity.CloseDate  = date.today();
                cqoc.opportunity.Name       = 'Test Oppty';
                cqoc.opportunity.Agency__c  = agency.Id;
                
                //roleOptions             =   cqoc.roleOptions;
                //cqoc.contactRole.ContactId = cnt.Id;
                //cqoc.contactRole.Role = 'PR';
                
                // cqoc.pitchLinesList = new List<MultipleOppMultiLineController.OppLine>();
                cqoc.num = 1;
                cqoc.Add_rows();
                // cqoc.pitchLinesList.add(new MultipleOppMultiLineController.OppLine());
                cqoc.pitchLinesList[0].opLine.ServiceDate = date.today().addDays(5);
                cqoc.pitchLinesList[0].opLine.Description      = 'Test Description';
                cqoc.pitchLinesList[0].opLine.UnitPrice        = 1000;
                cqoc.NoOfIncrements = 3;
                cqoc.DateIncProductsList = 'Daily';
                cqoc.pitchLinesList[0].product     = priceBookEntry.Product2Id;
                // cqoc.pitchLinesList[0].product     = priceBookEntry.name;
                
                // cr.ContactId = cnt.id;
                cqoc.contactRole = new OpportunityContactRole();
                cqoc.contactRole.ContactId = cnt.id;
                
                //#
                //# save with causing an exception (pricebookEntryId is missing)
                //#
                //try
                //{
                    cqoc.save();
                    // cqoc.addNewLine();
                //}
                //catch(Exception e)
                //{
                //  system.debug('>>>>>>>>>>> Exception: ' + e);
               // }
                
                List<Opportunity> opList = [
                                            Select
                                                Id
                                            From Opportunity
                                            Where AccountId = :acct.Id
                                            ];
                System.assertEquals(3, opList.size());
                
                List<OpportunityLineItem> oplList = [
                                                       Select
                                                           Id
                                                       From OpportunityLineItem
                                                       Where Opportunity.AccountId = :acct.Id
                                                     ];
                
                System.assertEquals(3, oplList.size());
                //cqoc.productsSelectList     = priceBookEntry.Product2Id;
                // cqoc.save();
                
               // String nextPage = cqoc.save().getUrl(); 
                
                cqoc = new MultipleOppMultiLineController();
                cqoc.stageSelectList        = 'Preparation';
                
                cqoc.account                = acct;
                cqoc.opportunity.AccountId  = acct.Id;
                cqoc.opportunity.Type       = 'Proactive';
                cqoc.opportunity.CloseDate  = date.today();
                cqoc.opportunity.Name       = 'Weekly Test Oppty';
                cqoc.opportunity.Agency__c  = agency.Id;
                
               // roleOptions             =   cqoc.roleOptions;
               //cqoc.contactRole.ContactId = cnt.Id;
               // cqoc.contactRole.Role = 'PR';
                
                // cqoc.pitchLinesList = new List<MultipleOppMultiLineController.OppLine>();
                // cqoc.pitchLinesList.add(new MultipleOppMultiLineController.OppLine());
                cqoc.num = 1;
                cqoc.Add_rows();
                cqoc.pitchLinesList[0].opLine.ServiceDate = date.today().addDays(5);
                cqoc.pitchLinesList[0].opLine.Description      = 'Test Description';
                cqoc.pitchLinesList[0].opLine.UnitPrice        = 1000;
                cqoc.NoOfIncrements = 2;
                cqoc.DateIncProductsList = 'Weekly';
                cqoc.pitchLinesList[0].product     = priceBookEntry.Product2Id;
                // cqoc.pitchLinesList[0].product     = priceBookEntry.name;
                cqoc.save();
                
                List<Opportunity> opWeeklyList = [
                                            Select
                                                Id
                                            From Opportunity
                                            Where AccountId = :acct.Id
                                            ];
                System.assertEquals(5, opWeeklyList.size());
                
                List<OpportunityLineItem> oplWeeklyList = [
                                                       Select
                                                           Id
                                                       From OpportunityLineItem
                                                       Where Opportunity.AccountId = :acct.Id
                                                     ];
                
                System.assertEquals(5, oplWeeklyList.size());
                
                cqoc = new MultipleOppMultiLineController();
                cqoc.stageSelectList        = 'Preparation';
                
                cqoc.account                = acct;
                cqoc.opportunity.AccountId  = acct.Id;
                cqoc.opportunity.Type       = 'Proactive';
                cqoc.opportunity.CloseDate  = date.today();
                cqoc.opportunity.Name       = 'Monthly Test Oppty';
                cqoc.opportunity.Agency__c  = agency.Id;
                cqoc.NoOfIncrements = 2;
                cqoc.DateIncProductsList = 'Monthly';
                                
                // cqoc.pitchLinesList = new List<MultipleOppMultiLineController.OppLine>();  
                //cqoc.pitchLinesList.add(new MultipleOppMultiLineController.OppLine());         
                cqoc.num = 2;
                cqoc.Add_rows();                
                cqoc.pitchLinesList[0].opLine.ServiceDate = date.today().addDays(5);
                cqoc.pitchLinesList[0].opLine.Description      = 'Test Description';
                cqoc.pitchLinesList[0].opLine.UnitPrice        = 1000;

                cqoc.pitchLinesList[0].product     = priceBookEntry.Product2Id;
                
                cqoc.pitchLinesList[1].opLine.ServiceDate = date.today().addDays(5);
                cqoc.pitchLinesList[1].opLine.Description      = 'Test Description';
                cqoc.pitchLinesList[1].opLine.UnitPrice        = 1000;

                cqoc.pitchLinesList[1].product     = priceBookEntry.Product2Id;
                cqoc.pitchLinesList[1].deleteline = true;
                cqoc.delete_rows();
                // cqoc.pitchLinesList[0].product     = priceBookEntry.name;
                cqoc.save();  
                  
                List<Opportunity> opMonthlyList = [
                                            Select
                                                Id
                                            From Opportunity
                                            Where AccountId = :acct.Id
                                            ];
                System.assertEquals(7, opMonthlyList.size());
                
                List<OpportunityLineItem> oplMonthlyList = [
                                                       Select
                                                           Id
                                                       From OpportunityLineItem
                                                       Where Opportunity.AccountId = :acct.Id
                                                     ];
                
                System.assertEquals(7, oplMonthlyList.size());                         
                cqoc.cancel();

            }
            
            
            newConstH.Price_Book__c = 'None';
            update newConstH;
           
            

        Test.stopTest();
        
    }*/

	static testMethod void multiOppTest() {
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;
		List < SelectOption > roleOptions;
		List < OpportunityLineItem > oppLine;
		List < SelectOption > noOfProducts;
		List < SelectOption > dateIncrement;
		MultipleOppMultiLineController_Test multi = new MultipleOppMultiLineController_Test();

		OpportunityContactRole cr = new OpportunityContactRole();
		MultipleOppMultiLineController cqoc;


		Test.startTest();



		system.runAs(multi.testUser) {
			PageReference pageRef = Page.MultipleOppMultipleLines;
			Test.setCurrentPageReference(pageRef);

			cqoc = new MultipleOppMultiLineController();

			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();
			noOfProducts = cqoc.getNoOfProducts();
			dateIncrement = cqoc.getDateIncProducts();
			roleOptions = cqoc.roleOptions;

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = multi.acct;
			cqoc.opportunity.AccountId = multi.acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Test Oppty';
			cqoc.opportunity.Agency__c = multi.agency.Id;
			cqoc.NoOfIncrements = 2;
			cqoc.DateIncProductsList = 'Daily';



			cqoc.pitchLinesList = new List < MultipleOppMultiLineController.OppLine > ();

			String dateStr = (String)(((datetime) date.today().addDays(5)).format('dd/MM/yyyy') + ',' + ((datetime)(date.today().addDays(6))).format('dd/MM/yyyy') + ',' + ((datetime)(date.today().addDays(7))).format('dd/MM/yyyy'));

			cqoc.SelectedOppLine.SelectedInsertionDates = dateStr;

			cqoc.Add_rows();

			cqoc.pitchLinesList[0].opLine.Description = 'Test Description 1';
			cqoc.pitchLinesList[0].opLine.UnitPrice = 1000;
			cqoc.pitchLinesList[0].product = multi.priceBookEntry.Product2Id;

			cqoc.pitchLinesList[1].opLine.Description = 'Test Description 2';
			cqoc.pitchLinesList[1].opLine.UnitPrice = 1500;
			cqoc.pitchLinesList[1].product = multi.priceBookEntry.Product2Id;

			cqoc.pitchLinesList[2].opLine.Description = 'Test Description 3';
			cqoc.pitchLinesList[2].opLine.UnitPrice = 1300;
			cqoc.pitchLinesList[2].product = multi.priceBookEntry.Product2Id;
			cqoc.pitchLinesList[2].deleteline = true;
			cqoc.delete_rows();

			cqoc.contactRole = new OpportunityContactRole();
			cqoc.contactRole.ContactId = multi.cnt.id;

			//#
			//# save with causing an exception (pricebookEntryId is missing)
			//#
			//try
			//{
			cqoc.save();
			// cqoc.addNewLine();
			//}
			//catch(Exception e)
			//{
			//  system.debug('>>>>>>>>>>> Exception: ' + e);
			// }

			List < Opportunity > opList = [
			Select
			Id
			From Opportunity
			Where AccountId = : multi.acct.Id];
			System.assertEquals(2, opList.size());

			List < OpportunityLineItem > oplList = [
			Select
			Product_Name__c,
			UnitPrice
			From OpportunityLineItem
			Where Opportunity.AccountId = : multi.acct.Id];
			System.debug('OpportunityLineItem:' + oplList);
			//System.assertEquals(4, oplList.size());

		}
		Test.stopTest();
	}

	static testMethod void multiOppTest2() {
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;
		List < SelectOption > roleOptions;
		List < OpportunityLineItem > oppLine;
		List < SelectOption > noOfProducts;
		List < SelectOption > dateIncrement;

		MultipleOppMultiLineController_Test multi = new MultipleOppMultiLineController_Test();

		OpportunityContactRole cr = new OpportunityContactRole();
		MultipleOppMultiLineController cqoc;
		Test.startTest();



		system.runAs(multi.testUser) {
			Business_Team_Activity__c bta = [Select id From Business_Team_Activity__c Where Account__c = : multi.acct.Id Limit 1];
			Event event = new Event(whatid = bta.id, DurationInMinutes = 30, ActivityDateTime = Date.today());
			insert event;

			PageReference pageRef = Page.MultipleOppMultipleLines;
			pageRef.getParameters().put('Eventid', event.Id);
			Test.setCurrentPageReference(pageRef);



			cqoc = new MultipleOppMultiLineController();

			productOptions = cqoc.getProductOptions();
			stageOptions = cqoc.getStageOptions();
			//oppLine             = cqoc.opportunityLineView;
			noOfProducts = cqoc.getNoOfProducts();
			dateIncrement = cqoc.getDateIncProducts();
			roleOptions = cqoc.roleOptions;

			cqoc.stageSelectList = 'Preparation';

			cqoc.account = multi.acct;
			cqoc.opportunity.AccountId = multi.acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Weekly Test Oppty';
			cqoc.opportunity.Agency__c = multi.agency.Id;
			cqoc.NoOfIncrements = 2;
			cqoc.DateIncProductsList = 'Weekly';

			cqoc.contactRole = new OpportunityContactRole();
			cqoc.contactRole.ContactId = multi.cnt.id;
			
			cqoc.SelectedOppLine.SelectedInsertionDates = ((datetime) date.today().addDays(5)).format('dd/MM/yyyy') + ',' + ((datetime) date.today().addDays(6)).format('dd/MM/yyyy');

			cqoc.Add_rows();
			cqoc.pitchLinesList[0].opLine.Description = 'Test Description';
			cqoc.pitchLinesList[0].opLine.UnitPrice = 1000;
			cqoc.pitchLinesList[0].product = multi.priceBookEntry.Product2Id;

			cqoc.pitchLinesList[1].opLine.Description = 'Test Description 2';
			cqoc.pitchLinesList[1].opLine.UnitPrice = 2000;
			cqoc.pitchLinesList[1].product = multi.priceBookEntry.Product2Id;
			cqoc.pitchLinesList[1].deleteline = true;
			cqoc.delete_rows();
			cqoc.save();

			List < Opportunity > opWeeklyList = [
			Select
			Id
			From Opportunity
			Where AccountId = : multi.acct.Id];
			System.assertEquals(2, opWeeklyList.size());

			List < OpportunityLineItem > oplWeeklyList = [
			Select
			Id
			From OpportunityLineItem
			Where Opportunity.AccountId = : multi.acct.Id];

			//System.assertEquals(2, oplWeeklyList.size());
		}
		Test.stopTest();

	}

	static testMethod void multiOppTest3() {
		List < SelectOption > productOptions;
		List < SelectOption > stageOptions;
		List < SelectOption > roleOptions;
		List < OpportunityLineItem > oppLine;
		List < SelectOption > noOfProducts;
		List < SelectOption > dateIncrement;
		MultipleOppMultiLineController_Test multi = new MultipleOppMultiLineController_Test();

		OpportunityContactRole cr = new OpportunityContactRole();
		MultipleOppMultiLineController cqoc;


		Test.startTest();



		system.runAs(multi.testUser) {
			PageReference pageRef = Page.MultipleOppMultipleLines;
			Test.setCurrentPageReference(pageRef);

			cqoc = new MultipleOppMultiLineController();
			cqoc.stageSelectList = 'Preparation';

			cqoc.account = multi.acct;
			cqoc.opportunity.AccountId = multi.acct.Id;
			cqoc.opportunity.Type = 'Proactive';
			cqoc.opportunity.CloseDate = date.today();
			cqoc.opportunity.Name = 'Monthly Test Oppty';
			cqoc.opportunity.Agency__c = multi.agency.Id;
			cqoc.NoOfIncrements = 2;
			cqoc.DateIncProductsList = 'Monthly';
			
			cqoc.contactRole = new OpportunityContactRole();
			cqoc.contactRole.ContactId = multi.cnt.id;
			
			cqoc.SelectedOppLine.SelectedInsertionDates = ((datetime) date.today().addDays(5)).format('dd/MM/yyyy') + ',' + ((datetime) date.today().addDays(10)).format('dd/MM/yyyy');

			cqoc.Add_rows();

			cqoc.pitchLinesList[0].opLine.Description = 'Test Description';
			cqoc.pitchLinesList[0].opLine.UnitPrice = 1000;

			cqoc.pitchLinesList[0].product = multi.priceBookEntry.Product2Id;


			cqoc.pitchLinesList[1].opLine.Description = 'Test Description 2';
			cqoc.pitchLinesList[1].opLine.UnitPrice = 1500;

			cqoc.pitchLinesList[1].product = multi.priceBookEntry.Product2Id;

			cqoc.pitchLinesList[1].deleteline = true;
			cqoc.delete_rows();

			cqoc.save();

			List < Opportunity > opMonthlyList = [
			Select
			Id
			From Opportunity
			Where AccountId = : multi.acct.Id];
			System.assertEquals(2, opMonthlyList.size());

			List < OpportunityLineItem > oplMonthlyList = [
			Select
			Id
			From OpportunityLineItem
			Where Opportunity.AccountId = : multi.acct.Id];

			//System.assertEquals(2, oplMonthlyList.size());                         
			cqoc.cancel();
		}
		Test.stopTest();
	}



}