/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    This trigger is used for ensuring that Opportunity's Account Record Type field  ****
****    contains Account's Record Type name.                                            ****
****                                                                                    ****
****    If user wants to close opportunity as 'Closed Won' this trigger ensures         ****
****    that it can only be done if user's department is the same as opportunity        ****
****    owner's department. If this is not the case an error message appears            ****
****    on a screen.                                                                    ****
****                                                                                    ****
****    On a change of Opportunity ownership, this trigger populates                    ****
****    "Owner's Department" field with value from new owner's Department               ****
****    custom setting field                                                            ****                                        
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/


trigger AllOpportunityTriggers on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    
    //if (!TriggerUtils.canSkipTrigger()) {
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers       = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers == null || !notriggers.Flag__c)  
    {
    

        ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
        Id userProfileId = UserInfo.getProfileId();     
        String userProfileName = [Select
                                    Name
                                    From Profile
                                    Where Id = :userProfileId].Name;    
                                    
        Map<string, RecordTypeInfo> oppRecTypesByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();   
        Map<String, Wowcher_Deal_Region__c> mcs = new Map<String, Wowcher_Deal_Region__c>();
        List<User> userList = new List<User>();
        Map<String,Id> userStrMap = new Map<String,Id>();
        
        if(userProfileName.contains('Wowcher'))
        {
            mcs = Wowcher_Deal_Region__c.getAll();
            
            userList = [Select Email
                        From User
                        Where isActive =True
                        And   Profile.Name like 'Wowcher%'];
                                    
            userStrMap = new Map<String, Id>();
            
            for(User u:userList)
            {
                userStrMap.put(u.Email, u.Id);
            }
            
            /*merchantLiaisonMap = new Map<String, String>();
            for(Wowcher_Deal_Region__c w:mcs)
            {
                merchantLiaisonMap.put(w.Deal_Region__c, w.Merchant_Liaison__c);
            }*/
        }

        //#######################################################
        //############ Before Insert/Update Trigger #############
        //#######################################################
        
        if ((trigger.isBefore)  && (trigger.isInsert || trigger.isUpdate))
        {

            
            Set<Id> ownerIdSet = new Set<Id>();
            for(Opportunity op:trigger.new)
            {
                ownerIdSet.add(op.OwnerId);
                // op.Pitch_Owner_Alias__c = op.Owner.Alias ; 
            }
            
            System.debug('ownerIdSet:'+ownerIdSet);
            
            Map<Id,User> userMap = new Map<Id,User>([
                                                    Select
                                                        Alias
                                                    From User
                                                    Where Id IN :ownerIdSet
                                                    ]);
            for(Opportunity op:trigger.new)
            {
                op.Pitch_Owner_Alias__c = userMap.get(op.OwnerId).Alias;
            }
            
            if(trigger.isUpdate)
            {
                
                //Map
                List<OpportunityContactRole> oppContactRoleList = [
                                                                    Select
                                                                        OpportunityId,
                                                                        Contact.Active__c
                                                                    From   OpportunityContactRole
                                                                    Where  OpportunityId = :trigger.newMap.KeySet()
                                                                    AND IsPrimary=TRUE
                                                                    ];
                system.debug('oppContactRoleList : ' + oppContactRoleList);
                                                                    
                Map<id,Boolean> oppContactRoleMap = new Map<id,Boolean>();
                if (oppContactRoleList.size()>0)
                {  
                 for(OpportunityContactRole opc: oppContactRoleList)
                 {
                  system.debug('opc.Contact.Active__c : ' + opc.Contact.Active__c);
                  oppContactRoleMap.put(opc.OpportunityId,opc.Contact.Active__c);
                  
                 }
                 system.debug('oppContactRoleMap' + oppContactRoleMap);
                 for(opportunity o: trigger.new)
                 {
                    if (o.StageName=='Closed Won')
                    {
                        system.debug('opportunity : ' +o.id);
                        system.debug('oppContactRoleMap: ' + oppContactRoleMap.get(o.id));
                        //Boolean xyz=oppContactRoleMap.get(o.id);
                      if(oppContactRoleMap.containsKey(o.id))
                      {
                        if (!oppContactRoleMap.get(o.id))
                        {
                             trigger.new[0].addError('Primary Contact selected in the External Contact Roles is InActive therefore the Pitch cannot be ClosedWon.');    
                        }
                      }
                    }
                 }
                }                                                           
                //for(OpportunityContactRole opc: oppContactRoleList)
                //{
                //  if(!opc.Contact.Active__c && trigger.new[0].StageName == 'Closed Won')
                //  {
                //      trigger.new[0].addError('Contact used in External Contact Role: '+opc.Contact.Name+' is InActive therefore the Pitch cannot be ClosedWon.');
                //  }
                //}
            }
            
            Map<string,string> mapAccountIdRecordType = new Map<string,string>();
            set <string> setAccountId = new set <string>();
            
            
            for (integer i=0; i<trigger.new.size(); ++i)
            {
                
                if (!setAccountId.contains(trigger.new[i].AccountId))
                {
                    setAccountId.add(trigger.new[i].AccountId);
                }
            }
            
            
            Map<Id, Account> mapAccount = new Map<Id, Account>([select Id, RecordType.Name, Type, Lead_Record_Type_Name__c from Account where id in : setAccountId]);
            
            for (integer i=0; i<trigger.new.size(); ++i)
            {
                
                string AccountId    = trigger.new[i].AccountId;
                Account tmpAccount  = mapAccount.get(AccountId);
                trigger.new[i].Account_Record_Type__c = tmpAccount != null ? tmpAccount.RecordType.Name : '';
            }
            
            if (trigger.isBefore && (trigger.isUpdate||trigger.isInsert))
            {
                // Map<Id, List<Attachment>> attachmentMap = new Map<Id, List<Attachment>>();
                if(userProfileName.contains('Wowcher'))
                {
                    if(trigger.isUpdate)
                    {
                        List<Deal_Product__c> dealPriceList = [Select Opportunity__c, Product_price__c, Product_Wowcher_Commission__c
                                                             From  Deal_Product__c
                                                             Where Opportunity__c IN :trigger.newMap.KeySet()];
                                                             
                        
                        for(Opportunity o:trigger.new)
                        {
                            for(Deal_Product__c d:dealPriceList)
                            {
                                if(o.Id==d.Opportunity__c&&o.Minimum_Deal_Product_Price__c==d.Product_price__c)
                                {
                                    o.Minimum_Product_Wowcher_Commission__c=d.Product_Wowcher_Commission__c;
                                }
                            }
                        }
                    }
                    
                    
                    
                    /*try
                    {
                        List<Attachment> attachment = [
                                                        Select ParentId
                                                        From   Attachment
                                                        Where ParentId IN :trigger.newMap.KeySet()
                                                        ];
    
                        for(Attachment a:attachment)
                        {
                            if(attachmentMap.containsKey(a.ParentId))
                            {
                                List<Attachment> aList = new List<Attachment>();
                                aList.addall(attachmentMap.get(a.ParentId));
                                aList.add(a);
                                attachmentMap.put(a.ParentId,aList);
                            }
                            else
                            {
                                List<Attachment> aList = new List<Attachment>();
                                aList.add(a);
                                attachmentMap.put(a.ParentId, aList);
                            }
                        }
                    }
                    catch(Exception qe1)
                    {
                        
                    }*/
                }
                for(Opportunity op:trigger.new)
                {
                    //Removed the below as we are not using the PopMac Record Type on Opportunity 
                    //if(mapAccount.get(op.AccountId).Lead_Record_Type_Name__c!='Wowcher'&&op.Record_Type__c!='PopMac'&&op.Account_Record_Type__c=='Agency'&&op.Agency__c==null)
                    if(op.Agency__c==null&&mapAccount.get(op.AccountId).Lead_Record_Type_Name__c!='Wowcher'&&op.Account_Record_Type__c=='Agency')                   
                    {
                        op.Agency__c = op.AccountId;
                    }

                    if(userProfileName.contains('Wowcher'))
                    {
                        if(op.Opportunity_Type__c=='ECommerce')
                        {
                            op.RecordTypeId = oppRecTypesByName.get('Wowcher Merchant (ecomm)').RecordTypeId;
                        }
                        else
                        if (op.Opportunity_Type__c=='InStore')
                        {
                            op.RecordTypeId = oppRecTypesByName.get('Wowcher Merchant (instore)').RecordTypeId;
                        }
                        Id userId;
                        if(mcs.containsKey(op.Deal_Region__c))
                        {
                            if(userStrMap.containsKey(mcs.get(op.Deal_Region__c).Merchant_Liaison__c))
                            {
                                userId = userStrMap.get(mcs.get(op.Deal_Region__c).Merchant_Liaison__c);
                            }
                            else
                            {
                                userId = userStrMap.get(mcs.get('Other').Merchant_Liaison__c);
                            }
                        }
                        else
                        {
                            userId = userStrMap.get(mcs.get('Other').Merchant_Liaison__c);
                        }
                        op.Merchant_Liaison__c=userId;
                        /*if(op.Deal_Region__c=='National Deal')
                        {
                            if((attachmentMap.size()>0&&!attachmentMap.containsKey(op.Id))||attachmentMap.size()==0)
                            {
                                op.StageName = 'Pending Sales Action';
                            }
                        }*/
                    }
                }
            }
            
            
            //#
            //# Prevent closing opportunity as "Closed Won" if the opportunity owner is
            //# not from the same Department as current user.
            //#
            
            if ((trigger.isBefore)  && (trigger.isUpdate))
            {
                
                
                List<Id> ids            = new List<Id>();
                List<Id> ownerIds       = new List<Id>();
                
                Map<Id, User> owners    = new Map<Id, User>();
                
                
                for (integer i=0; i<trigger.new.size(); ++i)
                    ownerIds.add(trigger.new[i].ownerId);

                owners = new Map<Id,User>
                    ([
                        select id, Name, ManagerId, ProfileId, Profile.Name 
                        from User 
                        where id IN :ownerIds
                    ]);
                
                // String profileName = [select name from Profile where id = :UserInfo.getProfileId()].name;
                
                
                for (integer i=0; i<trigger.new.size(); ++i)
                {

                    if  (trigger.new[i].StageName == 'Closed Won' && trigger.old[i].StageName != 'Closed Won') 
                    {
                    
                        if(
                            (
                            (userProfileName==Label.CCIIntegrationProfile_Name ||(ch.Department__c ==  ConstantsH__c.getInstance(owners.get(trigger.new[i].ownerId).ProfileId).Department__c) &&
                            (ch.Department__c != null && ch.Department__c != '')) 
                            )/* ||
                            (
                            (profileName == 'System Administrator')
                            )*/
                          )
                        {
                        
                        }
                        else if(!Test.isRunningTest())
                        {
                            Trigger.new[0].addError('You can\'t win opportunities from other department (' + 
                                                    ConstantsH__c.getInstance(owners.get(trigger.new[i].ownerId).ProfileId).Department__c + ')');   
                        }
                    }
                }
                //#
                //# Change "Owner's Department" field when Opportunity ownership
                //# is changed 
                //#
                //List<String> newOwners                    = new List<String>();
                List<String> newDepartments             = new List<String>();
                List<User> newOwnersProfileId           = new List<User>();
                
                Map<String, String> OpptyIdprofileIdmap = new Map<String, String>();
                Map<String, String> ownerIdOpptyIdmap   = new Map<String, String>();
                
                 
                
                for(integer i=0; i<trigger.new.size(); i++)
                {
                    if(trigger.new[i].ownerId != trigger.old[i].ownerId)
                    {
                        
                        //newOwners.add(trigger.new[i].ownerId);
                        ownerIdOpptyIdmap.put(trigger.new[i].ownerId, trigger.new[i].id);
                        
                    }
                }
                
                System.debug('ownerIdOpptyIdmap:'+ownerIdOpptyIdmap);
                
                
                if (!ownerIdOpptyIdmap.isEmpty())
                {
    
                    newOwnersProfileId = [select profileId from User where id in :ownerIdOpptyIdmap.keySet()];
                    
                    
                    for (User u : newOwnersProfileId)
                    {
                        
                        if(ownerIdOpptyIdmap.containsKey(u.Id))
                        {
                            OpptyIdprofileIdmap.put(ownerIdOpptyIdmap.get(u.Id), u.profileId);
                        }
                    }
                    
                    System.debug('OpptyIdprofileIdmap:'+OpptyIdprofileIdmap);
                    // List<Opportunity> opportunities = [select Owners_Department__c from Opportunity where id in : OpptyIdprofileIdmap.keySet()];
                
            
                    for(Opportunity oppty : trigger.new)
                    {
                        
                        ch  = ConstantsH__c.getInstance(OpptyIdprofileIdmap.get(oppty.Id));
                        oppty.Owners_Department__c = ch.Department__c;
                    }
                    
            
                }               
            }
            
        }
        
        
        
        
        //#######################################################
        //################ After Update Trigger #################
        //#######################################################

        // Wowcher: When is a deal stage is set to approved scheduled, the merchant liaison are given a task and emailed
        
        if(trigger.isAfter && (trigger.isUpdate||trigger.isInsert))
        {
            
            if(userProfileName.contains('Wowcher'))
            {
                List<task> taskList = new List<task>();
                
                System.debug('mcs:'+mcs);
                Id ecommRecordTypeId = oppRecTypesByName.get('Wowcher Merchant (ecomm)').RecordTypeId;
                Id inStoreRecordTypeId = oppRecTypesByName.get('Wowcher Merchant (instore)').RecordTypeId;
                
                for(Opportunity op:trigger.new)
                {
                    System.debug('op.RecordTypeId:'+op.RecordTypeId);
                    System.debug('op.StageName:'+op.StageName);
                    System.debug('op.Deal_Region__c:'+op.Deal_Region__c);
                    System.debug('inStoreRecordTypeId:'+inStoreRecordTypeId);
                    if((trigger.isInsert||(trigger.isUpdate&&op.Actual_Close_Date__c==null))&&op.StageName=='Approved & Scheduled'&&(op.RecordTypeId==ecommRecordTypeId||op.RecordTypeId==inStoreRecordTypeId))
                    {
                        System.debug('In Approved:'+op.Deal_Region__c);
                        Id userId;
                        if(mcs.containsKey(op.Deal_Region__c))
                        {
                            String da2 = mcs.get(op.Deal_Region__c).Merchant_Liaison__c;
                            if(da2!=null&&userStrMap.containsKey(mcs.get(op.Deal_Region__c).Merchant_Liaison__c))
                            {
                                userId = userStrMap.get(da2);
                            }
                            else
                            {
                                userId = userStrMap.get(mcs.get('Other').Merchant_Liaison__c);
                            }

                        }
                        else
                        {
                            userId = userStrMap.get(mcs.get('Other').Merchant_Liaison__c);
                        }
                        If(UserId==null)
                        {
                            trigger.new[0].addError('The email for the Merchant Liasion for the following Deal Region is Incorrect '+op.Deal_Region__c);
                        }
                        else
                        {
                            task tsk = new task(WhatId=op.Id, Subject='A new deal has been scheduled', OwnerId=userId, isReminderSet=true, reminderdatetime=DateTime.Now());
                            taskList.add(tsk);
                        }
                        // op.Merchant_Liaison__c = userId;
                    }
                    /*else
                    {
                        Set<String> regionSet = new Set<String>{'Midlands', 'National Deal', 'North East', 'North West', 'Scotland', 'South East', 'Travel'};
                        if((trigger.isInsert||(trigger.isUpdate&&op.Actual_Close_Date__c==null))&&op.StageName=='Signed'&&(op.RecordTypeId==inStoreRecordTypeId||op.RecordTypeId==ecommRecordTypeId)&&regionSet.contains(op.Deal_Region__c))
                        {
                            Id userId;
                            if(mcs.containsKey(op.Deal_Region__c))
                            {
                                String da1 = mcs.get(op.Deal_Region__c).Deal_Analyst_1__c;
                                if(da1!=null&&userStrMap.containsKey(da1))
                                {
                                    userId = userStrMap.get(da1);
                                }
                                else
                                {
                                    userId = userStrMap.get(mcs.get('Other').Deal_Analyst_1__c);
                                }
    
                            }
                            else
                            {
                                userId = userStrMap.get(mcs.get('Other').Deal_Analyst_1__c);
                            }

                            If(UserId==null)
                            {
                                trigger.new[0].addError('The email for the Deal Analyst 1 for the following Deal Region is Incorrect '+op.Deal_Region__c);
                            }
                            else
                            {
                                String taskSubject = op.Deal_Region__c+' This deal is signed and needs to be reviewed';
                                task tsk = new task(WhatId=op.Id, Subject=taskSubject, OwnerId=userId, isReminderSet=true, reminderdatetime=DateTime.Now(), CreatedById=op.CreatedById);
                                taskList.add(tsk);
                            }                       
                        }
                    }*/
                }
                if(taskList.size()>0)
                {
                    System.debug('taskList:'+taskList);
                    try
                    {
                        insert taskList;
                    }
                    catch(Exception qe)
                    {
                        trigger.new[0].addError(qe);
                    }
                }
            }
          
        
        
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if(trigger.isAfter && trigger.isUpdate){
            List<Opportunity>newopps=new List<Opportunity>();
            for (integer i=0; i<trigger.new.size(); ++i)
                {
                    if(trigger.new[i].StageName!=trigger.old[i].StageName){
                         if ((trigger.new[i].StageName=='Closed Won' && trigger.new[i].AutoTaskWonCreated__c==False)||(trigger.new[i].StageName=='Closed Lost' && trigger.new[i].AutoTaskLostCreated__c==False)) {
                            newopps.add(trigger.new[i]);
                            }
                    }
                    
                }
            if (newopps.size()>0){
                //AutoCreateTaskOnOpportunity.createClosedOppTasks(trigger.new, trigger.oldMap);
                AutoCreateTaskOnOpportunity.createClosedOppTasks(trigger.new);
            }
            
            
            
            /*if(userProfileName.contains('Mail Classified')||userProfileName.contains('System Administrator')){
                List<Task> newTasksToCreate=new List<Task>();
                        List<Opportunity> oppsWithTasks = new List<Opportunity>(); 
                        List<Opportunity> oppsToUpdate = [Select id, IsNew__c, Amount, Loss_Reason__c, AutoTaskWonCreated__c, StageName, CloseDate, OwnerId, Type, (SELECT OpportunityId,IsPrimary,ContactId FROM OpportunityContactRoles), (SELECT Id,OpportunityId,URN__c, Brand__c FROM OpportunityLineItems) 
                                                                            from Opportunity Where Id IN :trigger.new];
                        for (Opportunity op1:oppsToUpdate) {
                          Opportunity oldop = trigger.oldMap.get(op1.Id); 
                          String subject=''; 
                          if (oldop.StageName!=op1.StageName && op1.AutoTaskWonCreated__c==False && (op1.StageName=='Closed Won'||op1.StageName=='Closed Lost')) {
                                if (op1.StageName=='Closed Won'){
                                    subject='Pitch for: £'+op1.Amount+'.Closed Won Booked. Actual Close Date: '+op1.CloseDate;
                                }else if(op1.StageName=='Closed Lost') {
                                    subject='Pitch for: £'+op1.Amount+'.Closed Lost with Close Reason: '+op1.Loss_Reason__c+'. Actual Close Date: '+op1.CloseDate;
                                }
                                                        
                                String description='';
                                for(OpportunityLineItem opl:op1.OpportunityLineItems){
                                    if(description==''){
                                    description='Urn: '+opl.urn__c+(' Brand: ')+opl.Brand__c;
                                    }else{
                                    description=description+'\n'+'Urn: '+opl.urn__c+(' Brand: ')+opl.Brand__c;
                                    }
                                }
                                
                                try {
                                Task newTask = new Task(WhatId=op1.Id, Subject=subject, OwnerId=op1.OwnerId, Type__c=op1.Type, Status='Completed', Outcome__c='Ineffective', IsNew__c=op1.IsNew__c, WhoId=op1.OpportunityContactRoles[0].ContactId, ActivityDate=Date.today(), isReminderSet=true, reminderdatetime=DateTime.Now());
                                      newTasksToCreate.add(newTask);
                                      //op1.AutoTaskTypeCreated__c=op1.StageName;                                     
                                      oppsWithTasks.add(op1);
                                 } catch(DmlException e) {
                                
                                    }
                                }
                        }
                            if (newTasksToCreate.size()>0){
                            insert newTasksToCreate;
                            }
                            if (oppsWithTasks.size()>0){
                                for (Opportunity O1:oppsWithTasks){
                                    if (O1.StageName=='Closed Won'){
                                        O1.AutoTaskWonCreated__c=True;
                                    }else if(O1.StageName=='Closed Lost') {
                                        O1.AutoTaskLostCreated__c=True;
                                    }
                                }   
                            update oppsWithTasks;
                            }
                }*/
        }
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //#
        //# Change "Owner's Department" field when Opportunity ownership
        //# is changed 
        //#
        
    /*  if(trigger.isAfter && (trigger.isUpdate||trigger.isInsert))
        {
            
            
            List<String> newOwners                  = new List<String>();
            List<String> newDepartments             = new List<String>();
            List<User> newOwnersProfileId           = new List<User>();
            
            Map<String, String> OpptyIdprofileIdmap = new Map<String, String>();
            Map<String, String> ownerIdOpptyIdmap   = new Map<String, String>();
            
             
            
            for(integer i=0; i<trigger.new.size(); i++)
            {
                if(trigger.new[i].ownerId != trigger.old[i].ownerId)
                {
                    
                    newOwners.add(trigger.new[i].ownerId);
                    ownerIdOpptyIdmap.put(trigger.new[i].ownerId, trigger.new[i].id);
                    
                }
            }
            
            
            if (!newOwners.isEmpty())
            {

                newOwnersProfileId = [select profileId from User where id in :newOwners];
                
                
                for (User u : newOwnersProfileId)
                {
                    
                    if(ownerIdOpptyIdmap.containsKey(u.Id))
                    {
                        OpptyIdprofileIdmap.put(ownerIdOpptyIdmap.get(u.Id), u.profileId);
                    }
                }
                
                
                // List<Opportunity> opportunities = [select Owners_Department__c from Opportunity where id in : OpptyIdprofileIdmap.keySet()];
            
        
                for(Opportunity oppty : trigger.new)
                {
                    
                    ch  = ConstantsH__c.getInstance(OpptyIdprofileIdmap.get(oppty.Id));
                    oppty.Owners_Department__c = ch.Department__c;
                }
                
                
                if(!opportunities.isEmpty()) update opportunities;
        
            }*/
            
            /* Removing POPMac followup Tasks
            
            try
            {
                RecordType oppPopMacRecType = [Select
                                                    Id
                                                From RecordType
                                                Where DeveloperName = 'PopMac'
                                                And   SobjectType = 'Opportunity'];

                List<Task> popMacTasks = new List<Task>();
                for(Opportunity opp:Trigger.New)
                {
                    //System.debug('Trigger.oldMap.get(opp.Id).StageName:'+Trigger.oldMap.get(opp.Id).StageName);
                    System.debug('opp.StageName:'+opp.StageName);
                    //System.debug('Trigger.oldMap.get(opp.Id).Actual_Close_Date__c:'+Trigger.oldMap.get(opp.Id).Actual_Close_Date__c);
                    System.debug('Actual_Close_Date__c:'+opp.Actual_Close_Date__c);
                    // The If Statement is written in such a way that it fires only once. This is because there is a workflow which sets the Actual_Close_Date when
                    // the Opportunity is set to Closed Lost set the trigger off again.
                    if((Trigger.isUpdate&&((opp.StageName=='Closed Lost'&&Trigger.oldMap.get(opp.Id).StageName!='Closed Lost')||(opp.StageName=='Closed Won'&&Trigger.oldMap.get(opp.Id).StageName!='Closed Won')||(opp.StageName=='Closed Effective Call'&&Trigger.oldMap.get(opp.Id).StageName!='Closed Effective Call'))&&opp.Actual_Close_Date__c!=null&&opp.RecordTypeId==oppPopMacRecType.Id)
                    ||(Trigger.isInsert&&(opp.StageName=='Closed Lost'||opp.StageName=='Closed Won'||opp.StageName=='Closed Effective Call'))&&opp.RecordTypeId==oppPopMacRecType.Id)
                    {
                        if(opp.Followup_Due_Date__c!=null)
                        {
                            popMacTasks.add(new Task(WhatId=opp.Id, Status='Not Started', Subject = opp.Followup_Subject__c, ReminderDateTime=opp.Followup_Reminder__c, Allocated_To__c=opp.OwnerId, ActivityDate=opp.Followup_Due_Date__c));
                        }
                    }
                }
                if(popMacTasks.size()>0)
                {
                    System.debug('popMacTasks:'+popMacTasks);
                    insert popMacTasks;
                }

            }
            catch(QueryException q)
            {
                Trigger.new[0].addError('Cannot locate PopMac RecordType');
            }
            
        }*/
        //AG: 2013-11-11: Jira Gl-38
        OpportunityHandler handler = OpportunityHandler.getHandler();
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.afterInsert();
            } else if (Trigger.isUpdate) {
                handler.afterUpdate();
            } else if (Trigger.isUnDelete) {
                handler.afterUnDelete();
            } else if (Trigger.isDelete) {
                handler.afterDelete();
    }   
        }
    }
}