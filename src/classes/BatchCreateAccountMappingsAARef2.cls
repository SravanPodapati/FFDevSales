public with sharing class BatchCreateAccountMappingsAARef2 implements Database.Batchable < sObject > , Database.Stateful {
	//Integer queryLimit;
	Double failedUpdates {
		get;
		set;
	}

	public final String custRef;
	public final Decimal oppCount;

	public BatchCreateAccountMappingsAARef2() {

	}

	//////////start
	public Database.querylocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(
		[
		Select
		CustomerRef1__c,
		CustomerRef2__c,
		CustomerRef3__c,
		CustomerRef4__c,
		CustomerRef5__c
		From Account
		Where AccountMappingDone__c != 'Yes'
		And AccountMappingDone__c != 'Dupe'
		And IsActive__c = True
		And CustomerRef2__c != Null
		// And (CustomerRef1__c!=Null Or CustomerRef2__c!=Null Or CustomerRef3__c!=Null Or CustomerRef4__c!=Null Or CustomerRef5__c!=Null)
		]);
	}


	//////////execute

	public void execute(Database.BatchableContext BC, List < sObject > scope) {

		List < Account > accns = (List < Account > ) scope;
		List < Account > allaccs = new List < Account > ();
		List < Account_Mapping__c > newAccList = new List < Account_Mapping__c > ();
		Set < String > customerRef2List = new Set < String > ();

		for (Account a: accns) {
			if (a.CustomerRef2__c != null) {
				customerRef2List.add(a.CustomerRef2__c);
			}

		}


		List < AggregateResult > result = [Select
		CustomerRef2__c,
		MAX(CountOfOpportunity__c)
		From Account
		Where AccountMappingDone__c != 'Yes'
		And AccountMappingDone__c != 'Dupe'
		And IsActive__c = True
		And CustomerRef2__c IN: customerRef2List
		Group By CustomerRef2__c];
		for (AggregateResult ar: result) {
			//custRefList.add(new CallBatchAccountMappings.customerRef((String)ar.get('CustomerRef1__c'), (Decimal)ar.get('expr0')));  
			//Id batchInstanceId = Database.executeBatch(new BatchCreateNonDupeAccountMappings((String)ar.get('CustomerRef1__c'), (Decimal)ar.get('expr0')), 1);    
			createMappings((String) ar.get('CustomerRef2__c'), (Decimal) ar.get('expr0'));
		}



	}

	public void createMappings(String custRefInfo, Decimal oppCountInfo) {
		List < Account_Mapping__c > newAccList = new List < Account_Mapping__c > ();
		List < Account > allaccs = new List < Account > ();
		List < Account > accList = [Select
		CustomerRef1__c,
		CustomerRef2__c,
		CustomerRef3__c,
		CustomerRef4__c,
		CustomerRef5__c,
		CountOfOpportunity__c,
		AccountMappingDone__c
		From Account
		Where AccountMappingDone__c != 'Yes'
		And AccountMappingDone__c != 'Dupe'
		And IsActive__c = True
		And CustomerRef2__c = : custRefInfo];
		for (Account a: accList) {

			if (a.CountOfOpportunity__c == oppCountInfo) {
				if (a.CustomerRef1__c != Null) {
					String custref = a.CustomerRef1__c;
					List < string > split1 = new List < string > ();
					for (String ss1: custref.Split(',')) {
						if (ss1.trim() != null || ss1.trim() != '') {
							split1.add(ss1.trim());
						}
					}

					for (String s1: split1) {
						Account_Mapping__c am = new Account_Mapping__c();
						am.Account__c = a.Id;
						am.Source_System__c = 'CCI Metro';
						am.Source_Key__c = s1;
						am.Active__c = True;
						newAccList.add(am);
					}

				}
				if (a.CustomerRef2__c != Null)

				{
					String custref = a.CustomerRef2__c;
					List < string > split2 = new List < string > ();
					for (String ss2: custref.Split(',')) {
						if (ss2.trim() != null || ss2.trim() != '') {
							split2.add(ss2.trim());
						}
					}

					for (String s2: split2) {
						Account_Mapping__c am = new Account_Mapping__c();
						am.Account__c = a.Id;
						am.Source_System__c = 'Advance';
						am.Source_Key__c = s2;
						am.Active__c = True;
						newAccList.add(am);

					}

				}

				if (a.CustomerRef3__c != Null) {

					String custref = a.CustomerRef3__c;
					List < string > split3 = new List < string > ();
					for (String ss3: custref.Split(',')) {
						if (ss3.trim() != null || ss3.trim() != '') {
							split3.add(ss3.trim());
						}
					}

					for (String s3: split3) {

						Account_Mapping__c am = new Account_Mapping__c();
						am.Account__c = a.Id;
						am.Source_System__c = 'CCI Mail';
						am.Source_Key__c = s3;
						am.Active__c = True;
						newAccList.add(am);

					}

				}
				if (a.CustomerRef4__c != Null) {
					String custref = a.CustomerRef4__c;
					List < string > split4 = new List < string > ();
					for (String ss4: custref.Split(',')) {
						if (ss4.trim() != null || ss4.trim() != '') {
							split4.add(ss4.trim());
						}
					}

					for (String s4: split4) {

						Account_Mapping__c am = new Account_Mapping__c();
						am.Account__c = a.Id;
						am.Source_System__c = 'Operative One';
						am.Source_Key__c = s4;
						am.Active__c = True;
						newAccList.add(am);

					}

				}
				if (a.CustomerRef5__c != Null) {
					String custref = a.CustomerRef5__c;
					List < string > split5 = new List < string > ();
					for (String ss5: custref.Split(',')) {
						if (ss5.trim() != null || ss5.trim() != '') {
							split5.add(ss5.trim());
						}
					}

					for (String s5: split5) {

						Account_Mapping__c am = new Account_Mapping__c();
						am.Account__c = a.Id;
						am.Source_System__c = 'IDM Origins';
						am.Source_Key__c = s5;
						am.Active__c = True;
						newAccList.add(am);

					}

				}

				System.debug('***newAccMaps=' + newAccList.size());
				a.AccountMappingDone__c = 'Yes';
				allaccs.add(a);
			} else {
				a.AccountMappingDone__c = 'Dupe';
				allaccs.add(a);
			}

		}

		if (newAccList.size() > 0) {
			for (Account_Mapping__c a: newAccList) {
				try {
					insert a;
				} catch (Exception qe1) {

				}
			}
			// Insert newAccList;
		}
		if (allaccs.size() > 0) {
			update allaccs;
		}
	}
	/////////Finish
	public void finish(Database.BatchableContext bc) {


		AsyncApexJob a = [SELECT id, ApexClassId,
		JobItemsProcessed,
		TotalJobItems,
		NumberOfErrors,
		CreatedBy.Email
		FROM AsyncApexJob
		WHERE id = : bc.getJobId()];

		String emailMessage =
			'Your batch job ' + 'BatchCreateAccountMappingsActiveAccounts' + ' has finished.  It executed ' + a.totalJobItems +
			' batches.  Of which, ' + a.jobitemsprocessed + ' processed without any exceptions' + 'thrown and ' + a.numberOfErrors +
			' batches threw unhandled exceptions.' + '  Of the batches that executed' + 'without error, ' + failedUpdates + ' records were not updated successfully.';

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {
			a.createdBy.email
		};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('Batch Job Summary');
		mail.setSubject('Batch job completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		Messaging.sendEmail(new
		Messaging.SingleEmailMessage[] {
			mail
		});

	}

	//////////////Test
	// Test Method
	private static TestMethod void testAll() {
		insert TestData.createCountriesList();
		Test.startTest();
		User testUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
		limit 1];

		String testProfileId = [select id from Profile limit 1].id;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'Test Department 1',
		IsManager__c = false,
		//Price_Book__c             = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = 'Advertiser'
		limit 1].id;

		Account acct = new Account(
		Name = 'TestAccount',
		AccountNumber = 'ABC123456',
		Type = 'Client',
		BillingStreet = 'Test Billing Street',
		BillingState = 'Test Billing State',
		BillingPostalCode = 'A111AA',
		BillingCountry = 'United Kingdom',
		BillingCity = 'London',
		Industry = 'Finance',
		IndClassLvl1__c = 'Finance',
		IndClassLvl2__c = 'Finance',
		Classified_Minor_Category__c = 'Finance',
		CustomerRef1__c = '12345',
		CustomerRef2__c = '23456',
		CustomerRef3__c = '34567',
		CustomerRef4__c = 'TestA',
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		/*        Account_Mapping__c a = new Account_Mapping__c();
                            a.Account__c       = acct.Id;
                            a.Source_System__c = 'CCI Metro';
                            a.Source_Key__c    = '23747';
                            a.Active__c        = True;
                            
        insert a;
        Account_Mapping__c b = new Account_Mapping__c();
                            b.Account__c       = acct.Id;
                            b.Source_System__c = 'CCI Mail';
                            b.Source_Key__c    = '28462';
                            b.Active__c        = True;
                            
        insert b;
        Account_Mapping__c c = new Account_Mapping__c();
                            c.Account__c       = acct.Id;
                            c.Source_System__c = 'Advance';
                            c.Source_Key__c    = '2347239';
                            c.Active__c        = True;
                            
        insert c;
        Account_Mapping__c d = new Account_Mapping__c();
                            d.Account__c       = acct.Id;
                            d.Source_System__c = 'Operative One';
                            d.Source_Key__c    = 'optest23';
                            d.Active__c        = True;
                            
        insert d;
        
        Account_Mapping__c e = new Account_Mapping__c();
                            e.Account__c       = acct.Id;
                            e.Source_System__c = 'IDM Origins';
                            e.Source_Key__c    = 'IDM123';
                            e.Active__c        = True;
                            
        insert e;*/

		BatchCreateAccountMappingsAARef2 controller = new BatchCreateAccountMappingsAARef2();
		Integer batchSize = 1;
		database.executebatch(controller, batchSize);
		Test.stopTest();

		List < Account_Mapping__c > acList = [Select Source_Key__c from Account_Mapping__c where Account__c = : acct.Id];


		System.assertEquals('12345', acList[0].Source_Key__c);
		System.assertEquals('23456', acList[1].Source_Key__c);
		System.assertEquals('34567', acList[2].Source_Key__c);
		System.assertEquals('TestA', acList[3].Source_Key__c);


	}
	//////////////
}