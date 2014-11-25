/*******************************************************************************************
 ********************************************************************************************
 ****                                                                                    ****
 ****    Business Team Activity objects are also created (upon account insert) and       ****
 ****    assigned to new account. Number of created objects depends on number of         ****
 ****    unique departments. Owner field will be populated from custom settings field    ****
 ****    Acc_and_Contact_owner__c for that department.                                   ****
 ****                                                                                    ****
 ****    Also, this trigger is used for setting ownerId field on Accounts.               ****
 ****                                                                                    ****
 ********************************************************************************************
 *******************************************************************************************/



trigger AllAccountTriggers on Account(after delete, after insert, after undelete,
after update, before delete, before insert, before update) {


    ConstantsH__c ch = ConstantsH__c.getInstance(UserInfo.getProfileId());
    if (ch == null) {
        ch = new ConstantsH__c();
        ch.Acc_and_Contact_owner__c = 'A&N Media';
    }


    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

    if (notriggers == null || !notriggers.Flag__c) {
        /*if(trigger.isBefore&&trigger.isInsert)
        {
            // Update OwnerId Field on the Account
            Id newOwnerId = [select id from User where Name = :ch.Acc_and_Contact_owner__c limit 1].id;
            for(Account a: trigger.new)
            {
                a.OwnerId = newOwnerId;
            }
        }*/




             if (trigger.isBefore && trigger.isUpdate) {
                 AccountTriggerMethods.reviewUpdateAccount(trigger.New, trigger.oldMap);
             
             }



        //#######################################################
        //################ After Insert Trigger #################
        //#######################################################

        if (trigger.isAfter && trigger.isInsert) {

            List < Task > tasks = new List < Task > ();
            List < Account > accnts = new List < Account > ();
            Set < Id > accIds = new Set < Id > ();



            //#
            //# Update ownerId field
            //#
            Id newOwnerId = [select id from User where Name = : ch.Acc_and_Contact_owner__c and isActive = true limit 1].id;

            for (Account a: trigger.new) accIds.add(a.Id);

            accnts = [select ownerId, name from Account where id IN: accIds];
            for (Account a: accnts)
            a.ownerId = newOwnerId;
            update accnts;


            //#######################################################
            //# 
            //# Create and insert Business Team Activity objects        
            //#

            List < Business_Team_Activity__c > newBTAlst = new List < Business_Team_Activity__c > ();
            List < ConstantsH__c > constHlst = new List < ConstantsH__c > ();
            List < ConstantsH__c > filteredConstH = new List < ConstantsH__c > ();


            Set < String > uniqueDepartments = new Set < String > ();
            Set < String > uniqueNames = new Set < String > ();

            Map < String, String > departmentOwnerMap = new Map < String, String > ();
            Map < String, String > mapUserNameId = new Map < String, String > ();
            Map < Id, User > mapUser;


            constHlst = [select id, Name, Department__c, Acc_and_Contact_owner__c from ConstantsH__c];


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


            //#
            //# Create a map where key will be user's name and value will be id of that user
            //#
            if (uniqueNames.size() > 0) {
                mapUser = new Map < Id, User > ([select id, Name from User where Name in : uniqueNames]);

                String tmpUsername;


                for (String tmpKey: mapUser.keyset()) {
                    tmpUsername = mapUser.get(tmpKey).Name;

                    if (!mapUserNameId.containsKey(tmpUsername)) {
                        mapUserNameId.put(tmpUsername, tmpKey);
                    }
                }
            }


            for (Account acc: accnts) {

                for (ConstantsH__c constH: filteredConstH) {

                    Business_Team_Activity__c bta = new Business_Team_Activity__c(
                    Account__c = acc.Id,
                    Visibility__c = 'Departmental',
                    Owner_s_Department__c = constH.Department__c,
                    Name = acc.name + ' (' + constH.Department__c + ')',
                    OwnerId = mapUserNameId.get(constH.Acc_and_Contact_owner__c));

                    newBTAlst.add(bta);

                }


            }


            //#
            //# Insert new Business Team Activities
            //#
            if (!newBTAlst.isEmpty()) {
                try {
                    insert newBTAlst;
                } catch (Exception e) {
                    System.debug('>>>>>>>>>>>>>>>> EXCEPTION ' + e);
                }
            }


            // CCI POC - Create Finance Accounts
            /*List<FinanceAccount__c> finAccountList = new List<FinanceAccount__c>();
            
            List<Company__c> cList = [Select Name
                                        From Company__c
                                     ];
            
            Map<String, Company__c> cMap = new Map<String, Company__c>();
            
            for(Company__c c:cList)
            {
                cMap.put(c.Name, c);
            }
            
            for(account a:trigger.new)
            {
                finAccountList.add(new FinanceAccount__c(Account__c=a.Id, Name=a.Name+' - Metro', Company__c=cMap.get('Metro').Id));
                finAccountList.add(new FinanceAccount__c(Account__c=a.Id, Name=a.Name+' - Mail', Company__c=cMap.get('Mail').Id));
            }
            if(finAccountList.size()>0)
            {
                insert finAccountList;
            }*/

        }

        // For merge-actions we have to manually merge the business-team-activities of the merged Account
        if (trigger.isAfter && trigger.isDelete) {
            List < Id > mergedAccountIds = new List < Id > ();
			//Gar-130
			map<id, id> oldAccountToNewAccountMap = new map<id, id>();
            for (Account a: trigger.old) {
                if (a.MasterRecordId != null) {
                    mergedAccountIds.add(a.MasterRecordId);
					//Gar-130
					oldAccountToNewAccountMap.put(a.ID, a.MasterRecordId);
                }
            }
            if (mergedAccountIds.size() > 0) {
                AccountMergeUtility.MergeAccountsBusinessTeamActivities(mergedAccountIds);
            }
			//Gar-130
			if(oldAccountToNewAccountMap.size()>0){
				AccountMergeUtility.mergeChatterFeeds(oldAccountToNewAccountMap);
			}
			
        }


        //If an update has happened on the Account name
        if (trigger.isAfter && trigger.isUpdate) {

            AccountTriggerMethods.updateCCIAccount(trigger.New, trigger.oldMap, trigger.isUpdate, Trigger.isAfter);

            Set < Id > AccountsToUpdateIds = new Set < Id > ();

            for (Account a: trigger.new) {
                if (a.Name != Trigger.oldMap.get(a.id).Name) {

                    AccountsToUpdateIds.add(a.Id);

                }

                System.debug('***Account=' + a.Name);
            }
            List < Business_Team_Activity__c > currbtaList = [Select
            id, name, Account__c, Owner_s_Department__c
            From Business_Team_Activity__c
            Where Account__r.id IN: AccountsToUpdateIds];
            System.debug('***AccountsToUpdateIds=' + AccountsToUpdateIds);
            for (Business_Team_Activity__c bta: currbtaList) {
                bta.Name = trigger.newmap.get(bta.Account__c).Name + ' (' + bta.Owner_s_Department__c + ')';

            }

            List < Relationship__c > currrellista = [Select
            id, name, Account_A__c, Account_B__c, Account_B__r.name
            From Relationship__c
            Where Account_A__r.id IN: AccountsToUpdateIds];
            List < Relationship__c > currrellistb = [Select
            id, name, Account_A__c, Account_B__c, Account_A__r.name
            From Relationship__c
            Where Account_B__r.id IN: AccountsToUpdateIds];

            if (currbtaList.size() > 0) {
                System.debug('***currbtaList=' + currbtaList);
                update currbtaList;
            }
			try{
	            update currrelLista;
	            update currrelListb;
			}catch(Exception ex){
				string error;
				error = common.handelExceptionMessage(ex.getMessage());
				trigger.new[0].adderror(error);
			}
        }
        ///////////////////////////////////////////////////////////////////      
        if (trigger.isBefore && trigger.isUpdate) {
            //Set<Id> CatAccsToUpdateIds = new Set<Id>();
            for (Account a: trigger.new) {
                /*if(a.Industry != Trigger.oldMap.get(a.id).Industry || a.IndClassLvl1__c != Trigger.oldMap.get(a.id).IndClassLvl1__c || a.IndClassLvl2__c != Trigger.oldMap.get(a.id).IndClassLvl2__c || a.Classified_Minor_Category__c != Trigger.oldMap.get(a.id).Classified_Minor_Category__c)
                    {
                           
                               //a.Categorisation_Has_Changed__c=True;                   
                                            
                    }
                                        
                            System.debug('***Account=' + a.Name); */
                if ((a.Review_Status__c == 'Reviewed' && trigger.oldMap.get(a.Id).Review_Status__c != 'Reviewed')) {
                    a.Last_Reviewed_By__c = UserInfo.getUserId();
                    a.Last_Reviewed_Date__c = DateTime.now();
                }
            }
            /* List<Contact> consToUpdate = [Select 
                                               id,AccountId
                                               From Contact
                                               Where AccountId IN :CatAccsToUpdateIds]; 
                                                     System.debug('***CatAccsToUpdateIds=' + CatAccsToUpdateIds); 
             if (consToUpdate.size()>0){
                        System.debug('***consToUpdate=' + consToUpdate); 
                        update consToUpdate;
                   } */
        }
        ///////////////////////////////////////////////////////////////////            
        //////////////////
        if (trigger.isafter && trigger.isupdate) {


            Map < String, Account_Mapping__c > existMaps = new Map < String, Account_Mapping__c > ();
            //List<Account_Mapping__c> existAms = new List<Account_Mapping__c>();
            List < Account_Mapping__c > tmpList = new List < Account_Mapping__c > ();
            /* for(Account a : trigger.new)
        {
                    
            existAms=[Select Id,Source_System__c,Source_Key__c,UniqueSourceKey__c,Account__r.name from Account_Mapping__c where Account__c=:a.id];
            System.debug('***existAms=' + existAms); 
       
        
        
        for (Account_Mapping__c am : existAms){
        String amskey = am.Account__r.name + am.Source_System__c + am.Source_Key__c;
        if(existMaps.containsKey(amskey))
            {
                
                tmpList.add(am);
                
                 System.debug('***existMaps1=' + existMaps);
                //existMaps.remove(amskey, am);
            }
            else
            {
                existMaps.put(amskey, am);
                System.debug('***existMaps2=' + existMaps);
            }
            System.debug('***amskey=' + amskey);
        }
        
       
        }  */
            List < Account_Mapping__c > existAms = [Select
            Source_System__c,
            Source_Key__c,
            UniqueSourceKey__c,
            Account__r.name
            From Account_Mapping__c
            Where Account__c = : trigger.newMap.KeySet()];



            for (Account_Mapping__c am: existAms) {
                String amskey = am.Account__r.name + am.Source_System__c + am.Source_Key__c;
                if (existMaps.containsKey(amskey)) {

                    tmpList.add(am);
                    System.debug('***existMaps1=' + existMaps);
                    //existMaps.remove(amskey, am);
                } else {
                    existMaps.put(amskey, am);
                    System.debug('***existMaps2=' + existMaps);
                }
                System.debug('***amskey=' + amskey);
            }



            system.debug('***tmpList=' + tmpList);
            if (tmpList.size() > 0) {
                delete tmpList;
            }
        }

        //////////////////  

        // CCI POC
        /*if(trigger.isAfter&&(trigger.isInsert||trigger.isUpdate))
        {
            //List<Account> accList = new List<Account>();
            Set<Id> accIdSet = new Set<Id>();
            for(Account a:trigger.new)
            {
                if(a.DoCCIIntMetro__c&&(trigger.isInsert||(trigger.isUpdate&&a.CCIMetroCustID__c==null&&!trigger.oldMap.get(a.Id).DoCCIIntMetro__c)))
                {
                    accIdSet.add(a.Id);
                }
                else if(a.DoCCIIntMail__c&&(trigger.isInsert||(trigger.isUpdate&&a.CCIMailCustID__c==null&&!trigger.oldMap.get(a.Id).DoCCIIntMail__c)))
                {
                    accIdSet.add(a.Id);
                }
                
            }
            System.debug('accIdSet:'+accIdSet);
            if(accIdSet.size()>0)
            {
                CCIEuropeIntegration.createCCICustomer(accIdSet);
            }
        }*/

    }
}