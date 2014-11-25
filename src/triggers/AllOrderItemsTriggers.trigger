trigger AllOrderItemsTriggers on OrderItem (before insert,before update, after Update, After Delete) {
    
    //#
    //# Do not execute for any user that has the No validation flag set to true
    //#
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

    if (notriggers == null || !notriggers.Flag__c) {
        ConstantsH__c ch = ConstantsH__c.getInstance(UserInfo.getProfileId());
        try {
            AllOrderItemTriggerMethods handler = new AllOrderItemTriggerMethods(Trigger.isExecuting, Trigger.size);
            // befor insert
            if (trigger.isBefore && trigger.isInsert) {
                handler.OnBeforeInsert(Trigger.new);
            }
            else if (trigger.isBefore && trigger.isUpdate) {
                handler.OnBeforeUpdate(Trigger.New,trigger.oldMap);
            }
            
            if (trigger.isAfter && trigger.isUpdate){
                system.debug('***After Update in Tirgger***');
                handler.onAfterUpdate(Trigger.New,trigger.oldMap);
            }
            if(trigger.isAfter && trigger.isDelete){
                system.debug('***After Delete in Tirgger***');
                handler.onAfterDelete(Trigger.oldMap);
            }

         
        } catch (Exception ex) {
      system.debug('***Exception in Trigger is : '+ex);
        }
    }


}