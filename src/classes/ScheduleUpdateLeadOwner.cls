global with sharing class ScheduleUpdateLeadOwner implements Schedulable
{
   public static String CRON_EXP = '0 0 0 1 10 ? 2030';
   
   public static Boolean isTest
   {
     get
     {
        if(isTest==null)
        {
            isTest=false;
        }
        return isTest;
     }
     set;
     }
   
   global void execute(SchedulableContext SC) 
   {
      Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Wowcher').getRecordTypeId();
      Constants__c mc = Constants__c.getValues('All');
      try
      {
        User leadOwner = [
                        Select Id
                        From User
                        Where Name = :mc.Wowcher_Lead_Owner__c
                        Limit 1
                    ];
        System.debug('leadOwner:'+leadOwner);           
        List<Lead>  leadList = [
                                    Select OwnerId, LastActivityDate, CreatedDate, LastModifiedDate
                                    From Lead
                                    Where isConverted = False
                                    And   RecordTypeId = :leadRecTypeId
                                    And   OwnerId <> :leadOwner.Id
                                    And   Status <> 'Lead Closed - Lost'
                                    And   Status <> 'Lead Closed - Discarded'
                                    And   ( 
                                            (LastActivityDate!=null And LastActivityDate<LAST_N_DAYS:7)
                                       Or
                                            (LastActivityDate=null And LastModifiedDate<LAST_N_DAYS:7)
                                          )
                                ];
        System.debug('Before leadList:'+leadList);
        List<Lead> leadToUpdate = new List<Lead>();
        DateTime todayDateTime = DateTime.now();
        if(leadList.size()>0)
        {
            for(lead l:leadList)
            {
                System.debug('Lead:'+l);
                System.debug('l.LastActivityDate:'+l.LastActivityDate);
                System.debug('l.LastModifiedDate:'+l.LastModifiedDate);
                //if(((String.ValueOf(l.LastActivityDate)!=null||String.ValueOf(l.LastActivityDate)!='')&&l.LastActivityDate.AddDays(1)<= todayDateTime) ||(l.LastModifiedDate.AddDays(1)<= todayDateTime)||istest)
                
                //{
                    l.OwnerId = leadOwner.Id;
                    leadToUpdate.add(l);
                //}
            }
        }
        System.debug('After leadToUpdate:'+leadToUpdate);
        if(leadToUpdate.size()>0)
        {
            update leadToUpdate;
        }
      }
      catch(QueryException qe)
      {
        
      }
   }

}