global with sharing class BatchCreateNewAccountBTAs1 implements Database.Batchable < sObject > , Database.Stateful {
	//Integer queryLimit;
	Double failedUpdates {
		get;
		set;
	}


	/*global BatchCreateNewAccountBTAs1(Integer intLimit)
    {
        queryLimit = intLimit;  
    }*/

	global Database.queryLocator
	start(Database.BatchableContext ctx) {
		return Database.getQueryLocator([select id, Name, (select Name from Business_Teams2__r) from Account]);

	}


	global void execute(Database.BatchableContext bc,
	List < sObject > scope) {
		System.debug('********IN EXECUTE***********');
		List < Account > acctlst = (List < Account > ) scope;
		System.debug('acctlst:' + acctlst);
		Map < Id, Set < String >> mapAcct = new Map < Id, Set < String >> ();
		List < Business_Team_Activity__c > newBTAs = new List < Business_Team_Activity__c > ();

		Set < String > uniqueDepartments = new Set < String > ();
		Set < String > uniqueNames = new Set < String > ();

		Map < String, String > departmentOwnerMap = new Map < String, String > ();
		Map < String, String > mapUserNameId = new Map < String, String > ();

		// Existing departments retrieved from custom setting
		List < ConstantsH__c > constHlst = [select id, Name, Department__c, Acc_and_Contact_owner__c from ConstantsH__c];
		List < ConstantsH__c > filteredConstH = new List < ConstantsH__c > ();

		for (ConstantsH__c cnstH: constHlst) {
			if (cnstH.Department__c != null && cnstH.Department__c != '' && cnstH.Department__c != 'None') {
				if (!uniqueDepartments.contains(cnstH.Department__c)) {
					uniqueDepartments.add(cnstH.Department__c);
					filteredConstH.add(cnstH);
					departmentOwnerMap.put(cnstH.Department__c, cnstH.Acc_and_Contact_owner__c);

					if (!uniqueNames.contains(cnstH.Acc_and_Contact_owner__c)) {
						uniqueNames.add(cnstH.Acc_and_Contact_owner__c);
					}
				}
			}
		}

		// Create a map where key will be user's name and value will be id of that user
		Map < Id, User > mapUser;
		if (uniqueNames.size() > 0) {
			mapUser = new Map < Id, User > ([select id, Name from User where Name in : uniqueNames and isActive = true]);

			for (String tmpKey: mapUser.keyset()) {
				string tmpUsername = mapUser.get(tmpKey).Name;

				if (!mapUserNameId.containsKey(tmpUsername)) {
					mapUserNameId.put(tmpUsername, tmpKey);
				}
			}
		}

		for (Account a: acctlst) {
			if (!mapAcct.containsKey(a.Id)) {
				// Departments for which BTAs on Account already exist
				Set < String > departments = new Set < String > ();
				for (Business_Team_Activity__c b: a.Business_Teams2__r) {
					departments.add(b.Name);
				}
				mapAcct.put(a.Id, departments);

				// system.debug('++++++++++++++++++ Account: ' + a.Name);   
				// system.debug('++++++++++++++++++ Departments: ' + departments);  

				for (ConstantsH__c constH: filteredConstH) {
					boolean create = true;
					for (String dName: departments) {
						if (dName.contains(constH.Department__c)) {
							create = false;
							break;
						}
					}
					if (create) {
						Business_Team_Activity__c bta = new Business_Team_Activity__c(
						Account__c = a.Id,
						Visibility__c = 'Departmental',
						Owner_s_Department__c = constH.Department__c,
						Name = a.Name + ' (' + constH.Department__c + ')',
						OwnerId = mapUserNameId.get(constH.Acc_and_Contact_owner__c));

						newBTAs.add(bta);
					}
				}
			}
		}

		// system.debug('++++++++++++++++++ New BTAs: ' + newBTAs); 
		insert newBTAs;
	}

	global void finish(Database.BatchableContext bc) {


		AsyncApexJob a = [SELECT id, ApexClassId,
		JobItemsProcessed,
		TotalJobItems,
		NumberOfErrors,
		CreatedBy.Email
		FROM AsyncApexJob
		WHERE id = : bc.getJobId()];

		String emailMessage =
			'Your batch job ' + 'AccountOwnerReassignment' + ' has finished.  It executed ' + a.totalJobItems +
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

	// Test Method
	public static TestMethod void testAll() {
		insert TestData.createCountriesList();
		User testUser = [
		select name, email, ProfileId, Profile.Name
		from User
		where isActive = true /*and managerId != null*/ and Profile.Name = 'System Administrator'
		limit 1];

		//Pricebook2    testPB          = [select id, name  from Pricebook2                 limit 1];
		String testProfileId = [select id from Profile limit 1].id;

		ConstantsH__c newConstH = new ConstantsH__c(
		Acc_and_Contact_owner__c = testUser.Name,
		Department__c = 'Test Department 1',
		IsManager__c = false,
		//Price_Book__c             = testPB.Name,
		SetupOwnerId = testUser.ProfileId);
		insert newConstH;

		String advertiserRecTypeId = [
		select id
		from RecordType
		where DeveloperName = 'Advertiser'
		limit 1].id;

		insert TestData.createBookingSystemSettings();
		insert TestData.buildCompany();
		insert TestData.buildMetroCompany();
		insert TestData.createCountryCodeSettings();

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
		RecordTypeId = advertiserRecTypeId);
		insert acct;

		//Database.executeBatch(new BatchCreateNewAccountBTAs1(10)); 

		BatchCreateNewAccountBTAs1 controller = new BatchCreateNewAccountBTAs1();
		Integer batchSize = 10;
		database.executebatch(controller, batchSize);


		ConstantsH__c constH = [
		select id, Name, Department__c
		from ConstantsH__c
		limit 1];
		constH.Department__c = 'Test Department 2';

		update constH;

		//Database.executeBatch(new BatchCreateNewAccountBTAs1(10));      
		BatchCreateNewAccountBTAs1 controller1 = new BatchCreateNewAccountBTAs1();
		Integer batchSize1 = 10;
		database.executebatch(controller1, batchSize1);
	}

}