@isTest(SeeAllData = true)
private class AutoCreateTaskOnOpportunity_Test {
    //GB-106 : Collaboration
    static{
        BookingSystemSettings__c bSS = BookingSystemSettings__c.getInstance('CCI');
        if (bSS == null) insert TestData.createBookingSystemSettings();
        if (BookingSystemCountryCodes__c.getAll().get('United Kingdom') == null) {
            insert TestData.createCountryCodeSetting('United Kingdom', 'UK');
        }
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        insert TestData.buildCompany();
        insert TestData.buildMetroCompany();
        
        Product2 tmpproduct3 = new Product2();
        tmpproduct3.IsActive = true;
        tmpproduct3.Family = 'Test Family3';
        tmpproduct3.Name = 'Test product3';
        tmpproduct3.CustomerRef__c = 'CustomerRef3';
        tmpproduct3.CurrencyIsoCode = 'GBP';
        insert tmpproduct3;

    }
    static testMethod void testOppTask() {
        Map < string, RecordTypeInfo > oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
        Id oppRecordTypeId = oppRecTypesByName.get('Pitch').RecordTypeId;




        List < RecordType > agencyRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Agency'];

        List < RecordType > accRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Advertiser'];



        Pricebook2 testPB = [Select
        name
        From Pricebook2
        Where isActive = true
        limit 1];



PricebookEntry priceBookEntry = [
        select id, name, Product2Id
        from PricebookEntry
        where Product2.CustomerRef__c = 'CustomerRef3'
        and CurrencyIsoCode = 'GBP'
        and IsActive = true and (Not name like '%Provisional%') 
        limit 1];
        System.debug('ProcebookEntry is' + priceBookEntry);
        User mailClassTestUser = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name = 'System Administrator'
        limit 1];
        //'Mail Classified Manager
        //'Mail Classified User
        User mailClassTestUser1 = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name = 'Mail Classified User'
        limit 1];
        
        System.debug('mailClassTestUser:' + mailClassTestUser);
        Account newAccount = new Account();
        Contact newContact = new Contact();

        newAccount = new Account(
        name = 'Test Account1',
        RecordTypeId = accRecType[0].Id,
        Type = 'Direct Advertiser',
        BillingStreet = 'Westminster Rd',
        BillingPostalCode = 'SW1 2AU',
        BillingCountry = 'United Kingdom',
        Industry = 'Display',
        isActive__c = True,
        Phone = '01236554482');
        insert newAccount;


        Account_mapping__c mapping1 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '98756254');
        insert mapping1;

        Account_mapping__c mapping2 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '23456');
        insert mapping2;

        Account newAgency = new Account(
        Name = 'Test Account2',
        AccountNumber = 'ABC1234562',
        RecordTypeId = agencyRecType[0].Id,
        BillingStreet = 'Street',
        BillingState = 'TestState',
        BillingPostalCode = 'A111AA',
        BillingCountry = 'United Kingdom',
        BillingCity = 'City',
        Phone = '01236547891');
        insert newAgency;

       /* Account_mapping__c mapping3 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364723');
        insert mapping3;

        Account_mapping__c mapping4 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364726');
        insert mapping4;*/

        Contact cnt1 = new Contact();
        cnt1.AccountId = newAccount.Id;
        cnt1.Active__c = True;
        cnt1.LastName = 'Test Last Name';
        cnt1.FirstName = 'Test First Name';
        cnt1.MailingCity = 'Test Mailing City';
        cnt1.MailingCountry = 'Test Mailing Country';
        cnt1.MailingPostalCode = 'TestMPC';
        cnt1.MailingState = 'Test Mailing State';
        cnt1.MailingStreet = 'Test Mailing Street';
        cnt1.MailingCountry = 'United Kingdom';
        insert cnt1;
        test.starttest();
        System.runAs(mailClassTestUser) {

            Opportunity op = new Opportunity(
            Name = 'Test MailClass1',
            AccountId = newAccount.Id,
            //Agency__c=newAgency.id,
            RecordTypeId = oppRecordTypeId,
            StageName = 'Preparation',
            CloseDate = Date.today(),
            Type = 'Proactive',
            OwnerId = mailClassTestUser1.id,
            CurrencyIsoCode = 'GBP');
            insert op;

            OpportunityContactRole op1ContactRole = new OpportunityContactRole(OpportunityId = op.Id, Role = 'Agency Planning', ContactId = cnt1.Id, IsPrimary = True);
            insert op1ContactRole;


            /*Opportunity op1 = new Opportunity(
                                            Name='Test MailClass2',
                                            AccountId=newAccount.Id, 
                                            Agency__c=newAgency.id,
                                            RecordTypeId=oppRecordTypeId,
                                            StageName='Brief',
                                            CloseDate=Date.today(),
                                            Type='Proactive',
                                            OwnerId = mailClassTestUser.id);
            insert op1;

            OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId=op1.Id, Role='Agency Planning', ContactId=cnt1.Id, IsPrimary=True);
            insert opContactRole;
         */

            OpportunityLineItem newline1 = new OpportunityLineItem();

            newline1.OpportunityId = op.id;
            newline1.ServiceDate = date.today() + 5;
            newline1.Description = 'Test Description';
            newline1.UnitPrice = 1000;
            newline1.Quantity = 1;
            newline1.PriceBookEntryId = priceBookEntry.id;
            newline1.Last_Insertion_Date__c = System.today() + 6;


            insert newline1;

            /*           OpportunityLineItem newline=new OpportunityLineItem();
                
                newline.OpportunityId= op1.id;
                newline.ServiceDate = date.today() + 5;
                newline.Description      = 'Test Description';
                newline.UnitPrice        = 1000;
                newline.Quantity=1;
                newline.PriceBookEntryId=priceBookEntry.id;
                
                
               insert newline;*/
            List < Opportunity > newopps = new List < Opportunity > ();
            List < OpportunityLineItem > newlines = new List < OpportunityLineItem > ();

            newopps.add(op);
            //newopps.add(op1);

            //Auto-Task on Opportunity
            if (mailClassTestUser.Profile.Name.contains('Mail Classified') || mailClassTestUser.Profile.Name.contains('System Administrator')) {
                List < Opportunity > newopps1 = new List < Opportunity > ();
                List < OpportunityContactRole > newocrs = new List < OpportunityContactRole > ();
                //newopps1.add(op1);
                newocrs.add(op1ContactRole);
                newlines.add(newline1);
                //newlines.add(newline1);
                map < Id, List < OpportunityContactRole >> newocrsmap = new map < Id, List < OpportunityContactRole >> ();
                map < Id, List < OpportunityLineItem >> newopplinesmap = new map < Id, List < OpportunityLineItem >> ();

                newocrsmap.put(op.id, newocrs);
                newopplinesmap.put(op.id, newlines);

                AutoCreateTaskOnOpportunity.createTasks(newopps, newopplinesmap, newocrsmap);
            }



            //newopps.add(op1);
            //system.runAs(tmpUser)
            //test.startTest();     
            if (newopps.size() > 0) {
                for (Opportunity opp1: newopps) {
                    opp1.Stagename = 'Closed Won';
                    //opp1.Loss_Reason__c='Did not use online';
                    opp1.AutoTaskWonCreated__c = False;
                    //AutoCreateTaskOnOpportunity.createClosedOppTasks(newopps1, newopplinesmap, newocrsmap);
                }
                update newopps;
            }



            //System.assertEquals(1, newtasksToUpdate.size());
            //System.assertEquals(2, newtasksToUpdate.size());    

            test.stopTest();
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////
    static testMethod void testOppTask1() {
        Map < string, RecordTypeInfo > oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
        Id oppRecordTypeId = oppRecTypesByName.get('Pitch').RecordTypeId;




        List < RecordType > agencyRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Agency'];

        List < RecordType > accRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Advertiser'];



        Pricebook2 testPB = [Select
        name
        From Pricebook2
        Where isActive = true
        limit 1];



PricebookEntry priceBookEntry = [
        select id, name, Product2Id
        from PricebookEntry
        where Product2.CustomerRef__c = 'CustomerRef3'
        and CurrencyIsoCode = 'GBP'
        and IsActive = true and (Not name like '%Provisional%') 
        limit 1];
        System.debug('ProcebookEntry is' + priceBookEntry);
        
        User mailClassTestUser = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name = 'System Administrator'
        limit 1];
        
        User mailClassTestUser1 = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name Like 'Mail Display Manager'
        limit 1];
        
        System.debug('mailClassTestUser:' + mailClassTestUser);
        Account newAccount = new Account();
        Contact newContact = new Contact();

        newAccount = new Account(
        name = 'Test Account1',
        RecordTypeId = accRecType[0].Id,
        Type = 'Direct Advertiser',
        BillingStreet = 'Westminster Rd',
        BillingPostalCode = 'SW1 2AU',
        BillingCountry = 'United Kingdom',
        Industry = 'Display',
        isActive__c = True,
        Phone = '01236554482');
        insert newAccount;


        Account_mapping__c mapping1 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '98756254');
        insert mapping1;

        Account_mapping__c mapping2 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '23456');
        insert mapping2;

        Account newAgency = new Account(
        Name = 'Test Account2',
        AccountNumber = 'ABC1234562',
        RecordTypeId = agencyRecType[0].Id,
        BillingStreet = 'Street',
        BillingState = 'TestState',
        BillingPostalCode = 'A111AA',
        BillingCountry = 'United Kingdom',
        BillingCity = 'City',
        Phone = '01236547891');
        insert newAgency;

       /* Account_mapping__c mapping3 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364723');
        insert mapping3;

        Account_mapping__c mapping4 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364726');
        insert mapping4;*/

        Contact cnt1 = new Contact();
        cnt1.AccountId = newAccount.Id;
        cnt1.Active__c = True;
        cnt1.LastName = 'Test Last Name';
        cnt1.FirstName = 'Test First Name';
        cnt1.MailingCity = 'Test Mailing City';
        cnt1.MailingCountry = 'Test Mailing Country';
        cnt1.MailingPostalCode = 'TestMPC';
        cnt1.MailingState = 'Test Mailing State';
        cnt1.MailingStreet = 'Test Mailing Street';
        cnt1.MailingCountry = 'United Kingdom';
        insert cnt1;
        test.starttest();
        System.runAs(mailClassTestUser) {

            Opportunity op = new Opportunity(
            Name = 'Test MailClass1',
            AccountId = newAccount.Id,
            //Agency__c=newAgency.id,
            RecordTypeId = oppRecordTypeId,
            StageName = 'Preparation',
            CloseDate = Date.today(),
            Type = 'Proactive',
            OwnerId = mailClassTestUser.id,
            CurrencyIsoCode = 'GBP');
            insert op;

            OpportunityContactRole op1ContactRole = new OpportunityContactRole(OpportunityId = op.Id, Role = 'Agency Planning', ContactId = cnt1.Id, IsPrimary = True);
            insert op1ContactRole;


            /*Opportunity op1 = new Opportunity(
                                            Name='Test MailClass2',
                                            AccountId=newAccount.Id, 
                                            Agency__c=newAgency.id,
                                            RecordTypeId=oppRecordTypeId,
                                            StageName='Brief',
                                            CloseDate=Date.today(),
                                            Type='Proactive',
                                            OwnerId = mailClassTestUser.id);
            insert op1;

            OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId=op1.Id, Role='Agency Planning', ContactId=cnt1.Id, IsPrimary=True);
            insert opContactRole;
         */

            OpportunityLineItem newline1 = new OpportunityLineItem();

            newline1.OpportunityId = op.id;
            newline1.ServiceDate = date.today() + 5;
            newline1.Description = 'Test Description';
            newline1.UnitPrice = 1000;
            newline1.Quantity = 1;
            newline1.PriceBookEntryId = priceBookEntry.id;
            newline1.Last_Insertion_Date__c = System.today() + 6;


            insert newline1;

            /*           OpportunityLineItem newline=new OpportunityLineItem();
                
                newline.OpportunityId= op1.id;
                newline.ServiceDate = date.today() + 5;
                newline.Description      = 'Test Description';
                newline.UnitPrice        = 1000;
                newline.Quantity=1;
                newline.PriceBookEntryId=priceBookEntry.id;
                
                
               insert newline;*/
            List < Opportunity > newopps = new List < Opportunity > ();
            List < OpportunityLineItem > newlines = new List < OpportunityLineItem > ();

            newopps.add(op);
            //newopps.add(op1);

            //Auto-Task on Opportunity
            if (mailClassTestUser.Profile.Name.contains('Mail Classified') || mailClassTestUser.Profile.Name.contains('System Administrator')) {
                List < Opportunity > newopps1 = new List < Opportunity > ();
                List < OpportunityContactRole > newocrs = new List < OpportunityContactRole > ();
                //newopps1.add(op1);
                newocrs.add(op1ContactRole);
                newlines.add(newline1);
                //newlines.add(newline1);
                map < Id, List < OpportunityContactRole >> newocrsmap = new map < Id, List < OpportunityContactRole >> ();
                map < Id, List < OpportunityLineItem >> newopplinesmap = new map < Id, List < OpportunityLineItem >> ();

                newocrsmap.put(op.id, newocrs);
                newopplinesmap.put(op.id, newlines);

                AutoCreateTaskOnOpportunity.createTasks(newopps, newopplinesmap, newocrsmap);
            }



            //newopps.add(op1);
            //system.runAs(tmpUser)
            //test.startTest();     
            if (newopps.size() > 0) {
                for (Opportunity opp1: newopps) {
                    opp1.Stagename = 'Closed Won';
                    //opp1.Loss_Reason__c='Did not use online';
                    opp1.AutoTaskWonCreated__c = False;
                    //AutoCreateTaskOnOpportunity.createClosedOppTasks(newopps1, newopplinesmap, newocrsmap);
                }
                update newopps;
            }



            //System.assertEquals(1, newtasksToUpdate.size());
            //System.assertEquals(2, newtasksToUpdate.size());    

            test.stopTest();
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////    
//////////////////////////////////////////////////////////////////////////////////////////////////////////
    static testMethod void testOppTask2() {
        Map < string, RecordTypeInfo > oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
        Id oppRecordTypeId = oppRecTypesByName.get('Pitch').RecordTypeId;

        List < RecordType > agencyRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Agency'];

        List < RecordType > accRecType = [
        Select
        Name
        From RecordType
        Where SObjectType = 'Account'
        And DeveloperName = 'Advertiser'];



        Pricebook2 testPB = [Select
        name
        From Pricebook2
        Where isActive = true
        limit 1];



PricebookEntry priceBookEntry = [
        select id, name, Product2Id
        from PricebookEntry
        where Product2.CustomerRef__c = 'CustomerRef3'
        and CurrencyIsoCode = 'GBP'
        and IsActive = true and (Not name like '%Provisional%') 
        limit 1];
        System.debug('ProcebookEntry is' + priceBookEntry);
        
        User mailClassTestUser = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name = 'System Administrator'
        limit 1];
        
        User mailClassTestUser1 = [
        select name, email, ProfileId, Profile.Name
        from User
        where isActive = true
        and Profile.Name Like 'Mail Classified Manager'
        limit 1];
        
        System.debug('mailClassTestUser:' + mailClassTestUser);
        Account newAccount = new Account();
        Contact newContact = new Contact();

        newAccount = new Account(
        name = 'Test Account1',
        RecordTypeId = accRecType[0].Id,
        Type = 'Direct Advertiser',
        BillingStreet = 'Westminster Rd',
        BillingPostalCode = 'SW1 2AU',
        BillingCountry = 'United Kingdom',
        Industry = 'Display',
        isActive__c = True,
        Phone = '01236554482');
        insert newAccount;


        Account_mapping__c mapping1 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '98756254');
        insert mapping1;

        Account_mapping__c mapping2 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAccount.Id,
        Active__c = true,
        Source_Key__c = '23456');
        insert mapping2;

        Account newAgency = new Account(
        Name = 'Test Account2',
        AccountNumber = 'ABC1234562',
        RecordTypeId = agencyRecType[0].Id,
        BillingStreet = 'Street',
        BillingState = 'TestState',
        BillingPostalCode = 'A111AA',
        BillingCountry = 'United Kingdom',
        BillingCity = 'City',
        Phone = '01236547891');
        insert newAgency;

       /* Account_mapping__c mapping3 = new Account_mapping__c(
        Source_system__c = 'CCI Metro',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364723');
        insert mapping3;

        Account_mapping__c mapping4 = new Account_mapping__c(
        Source_system__c = 'CCI Mail',
        Account__c = newAgency.Id,
        Active__c = true,
        Source_Key__c = '92364726');
        insert mapping4;*/

        Contact cnt1 = new Contact();
        cnt1.AccountId = newAccount.Id;
        cnt1.Active__c = True;
        cnt1.LastName = 'Test Last Name';
        cnt1.FirstName = 'Test First Name';
        cnt1.MailingCity = 'Test Mailing City';
        cnt1.MailingCountry = 'Test Mailing Country';
        cnt1.MailingPostalCode = 'TestMPC';
        cnt1.MailingState = 'Test Mailing State';
        cnt1.MailingStreet = 'Test Mailing Street';
        cnt1.MailingCountry = 'United Kingdom';
        insert cnt1;
        test.starttest();
        System.runAs(mailClassTestUser) {

            Opportunity op = new Opportunity(
            Name = 'Test MailClass1',
            AccountId = newAccount.Id,
            //Agency__c=newAgency.id,
            RecordTypeId = oppRecordTypeId,
            StageName = 'Preparation',
            CloseDate = Date.today(),
            Type = 'Proactive',
            OwnerId = mailClassTestUser.id,
            CurrencyIsoCode = 'GBP');
            insert op;

            OpportunityContactRole op1ContactRole = new OpportunityContactRole(OpportunityId = op.Id, Role = 'Agency Planning', ContactId = cnt1.Id, IsPrimary = True);
            insert op1ContactRole;


            /*Opportunity op1 = new Opportunity(
                                            Name='Test MailClass2',
                                            AccountId=newAccount.Id, 
                                            Agency__c=newAgency.id,
                                            RecordTypeId=oppRecordTypeId,
                                            StageName='Brief',
                                            CloseDate=Date.today(),
                                            Type='Proactive',
                                            OwnerId = mailClassTestUser.id);
            insert op1;

            OpportunityContactRole opContactRole = new OpportunityContactRole(OpportunityId=op1.Id, Role='Agency Planning', ContactId=cnt1.Id, IsPrimary=True);
            insert opContactRole;
         */

            OpportunityLineItem newline1 = new OpportunityLineItem();

            newline1.OpportunityId = op.id;
            newline1.ServiceDate = date.today() + 5;
            newline1.Description = 'Test Description';
            newline1.UnitPrice = 1000;
            newline1.Quantity = 1;
            newline1.PriceBookEntryId = priceBookEntry.id;
            newline1.Last_Insertion_Date__c = System.today() + 6;


            insert newline1;

            /*           OpportunityLineItem newline=new OpportunityLineItem();
                
                newline.OpportunityId= op1.id;
                newline.ServiceDate = date.today() + 5;
                newline.Description      = 'Test Description';
                newline.UnitPrice        = 1000;
                newline.Quantity=1;
                newline.PriceBookEntryId=priceBookEntry.id;
                
                
               insert newline;*/
            List < Opportunity > newopps = new List < Opportunity > ();
            List < OpportunityLineItem > newlines = new List < OpportunityLineItem > ();

            newopps.add(op);
            //newopps.add(op1);

            //Auto-Task on Opportunity
            if (mailClassTestUser.Profile.Name.contains('Mail Classified') || mailClassTestUser.Profile.Name.contains('System Administrator')) {
                List < Opportunity > newopps1 = new List < Opportunity > ();
                List < OpportunityContactRole > newocrs = new List < OpportunityContactRole > ();
                //newopps1.add(op1);
                newocrs.add(op1ContactRole);
                newlines.add(newline1);
                //newlines.add(newline1);
                map < Id, List < OpportunityContactRole >> newocrsmap = new map < Id, List < OpportunityContactRole >> ();
                map < Id, List < OpportunityLineItem >> newopplinesmap = new map < Id, List < OpportunityLineItem >> ();

                newocrsmap.put(op.id, newocrs);
                newopplinesmap.put(op.id, newlines);

                AutoCreateTaskOnOpportunity.createTasks(newopps, newopplinesmap, newocrsmap);
            }



            //newopps.add(op1);
            //system.runAs(tmpUser)
            //test.startTest();     
            if (newopps.size() > 0) {
                for (Opportunity opp1: newopps) {
                    opp1.Stagename = 'Closed Won';
                    //opp1.Loss_Reason__c='Did not use online';
                    opp1.AutoTaskWonCreated__c = False;
                    //AutoCreateTaskOnOpportunity.createClosedOppTasks(newopps1, newopplinesmap, newocrsmap);
                }
                update newopps;
            }



            //System.assertEquals(1, newtasksToUpdate.size());
            //System.assertEquals(2, newtasksToUpdate.size());    

            test.stopTest();
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////    
}