public with sharing class OrderFlowController {
    public Account acc;
    public Order ord;
    public Boolean finished {
        get;
        set;
    }
    public String url1 {
        get;
        set;
    }
    public String userType {
        get;
        set;
    }
    public Id userId {
        get;
        set;
    }    
    public List<String> userCCIGroups {
        get;
        set;
    }
    public List<String> userCCIProfiles {
        get;
        set;
    }
    public String Group0 {
        get;
        set;
    }
    public String Group1 {
        get;
        set;
    } 
    public String Group2 {
        get;
        set;
    }    
    public String Group3 {
        get;
        set;
    }
     public String Group4 {
        get;
        set;
    }   
    public String Profile0 {
        get;
        set;
    }
    public String Profile1 {
        get;
        set;
    }
    public String Profile2 {
        get;
        set;
    }
    public String Profile3 {
        get;
        set;
    }
    public String Profile4 {
        get;
        set;
    }    
    public Integer noOfCCIGroups {
        get;
        set;
    }
    public Integer noOfCCIProfiles {
        get;
        set;
    }
    public Flow.Interview.DirectOrderProcessingFlow directOrderProcessingFlow {
        get;
        set;
    }

    public Flow.Interview.SelectCCIGroupAndProfile selectCCIGroupAndProfile {
        get;
        set;
    }

    public OrderFlowController(ApexPages.StandardController controller) {
        // Id objectId = controller.getId();
        SObject record = controller.getRecord();
        if(record instanceof Account)
        {
            this.acc = (Account) controller.getRecord();
        }
        else
        {
            this.ord = (Order) controller.getRecord();
            System.debug('Order is:'+ this.ord);
        }        
        // this.acc = (Account) controller.getRecord();
        User u = Common.getUserInfo();
        userType = u.Profile.Name;
        // userCCIProfiles =  new List<String>(Common.CCIProfiles());
        // userCCIGroups =  new List<String>(Common.CCIGroups());

        userCCIProfiles =  new List<String>();
        userCCIGroups =  new List<String>();
        Set<String>  profiles = new Set<String>();
        if (Test.isRunningTest()){
            profiles.add('md manager');
            profiles.add('md sales');
            profiles.add('system administrator');
            profiles.add('system user');
        }
        else
        {
            profiles = Common.CCIProfiles();
        }
        Set<String>  grps = new Set<String>();
        if (Test.isRunningTest()){
            grps.add('mail display');
            grps.add('mail classified');
            grps.add('systems support');
            grps.add('system administrator');
           
        }
        else
        {
            grps = Common.CCIGroups();
        }
       // for(String s: Common.CCIProfiles())
          for(String s: profiles)
        {
            if((s.toLowerCase().contains('md sales')||s.toLowerCase().contains('md manager')||s.toLowerCase().contains('system'))&&(!s.toLowerCase().contains('ml'))&&(!s.toLowerCase().contains('esc')))
            {
                userCCIProfiles.add(s);
            }
        }

       // for(String s: Common.CCIGroups())
        for(String s: grps)
        {
            if(s.toLowerCase().contains('mail')||s.toLowerCase().contains('system'))
            {
                userCCIGroups.add(s);
            }
        }        
        
        noOfCCIProfiles = userCCIProfiles.size();
        noOfCCIGroups = userCCIGroups.size();
        
        for(Integer g=0; g<noOfCCIGroups; g++)
        {
            if(g==0)
            {
                group0=userCCIGroups[g].trim();
            }
            else if(g==1)
            {
                group1=userCCIGroups[g].trim();
            }
            else if(g==2)
            {
                group2=userCCIGroups[g].trim();
            }                
            else if(g==3)
            {
                group3=userCCIGroups[g].trim();
            } 
            else if(g==4)
            {
                group4=userCCIGroups[g].trim();
            } 
        }

        for(Integer p=0;p<noOfCCIProfiles;p++)
        {
            if(p==0)
            {
                profile0=userCCIProfiles[p].trim();
            }
            else if(p==1)
            {
                profile1=userCCIProfiles[p].trim();
            }
            else if(p==2)
            {
                profile2=userCCIProfiles[p].trim();
            }
            else if(p==3)
            {
                profile3=userCCIProfiles[p].trim();
            }                
            else if(p==4)
            {
                profile4=userCCIProfiles[p].trim();
            }
        }
        
        System.debug('profile0:'+profile0);
        System.debug('profile1:'+profile1);
        
    }

    /*   public void PageReference getChecks(){
        
         User u = Common.getUserInfo();
         String userType =   Common.getUserType(u);
         If(userType!=Common.mailUser){
          PageReference p  = Apexpages.currentPage();
            Apexpages.addMessage( new ApexPages.Message (ApexPages.Severity.ERROR, 'Unauthorised User ')); 
           // return p;
            }
            //return null;
        
        
        
        }*/

    public PageReference getFlowFinishLocation() {
        //System.debug('Flow is' + directOrderProcessingFlow);
        String clientId;
        String agencyId;
        String bookingAgencyId;
        String bookingcciCusId;
        String sopId;
        String cciCusId;
        String parentCCIMailId;
        String parentCCIMetroId;
        String parentcciId;
        String holdingCompanycciId;
        String holdingAgencycciId;
        String agencysParent;
        String contactName;
        String contactPhone;
        String contactId;
        String cciProfile;
        String cciGroup;
        String dbType;
        String parentAccType;
        
        if (directOrderProcessingFlow != null) {
            clientId = directOrderProcessingFlow.AccId;
            agencyId = directOrderProcessingFlow.BillingAgencyId;
            sopId = directOrderProcessingFlow.sopId;
            cciCusId = directOrderProcessingFlow.CCICusId;
            bookingAgencyId = directOrderProcessingFlow.bookingAgencyId;
            bookingcciCusId = directOrderProcessingFlow.BookingAgencyCCICusId;
            parentCCIMailId = directOrderProcessingFlow.ParentCCIMailId;
            parentCCIMetroId = directOrderProcessingFlow.ParentCCIMetroId; 
            holdingCompanycciId = directOrderProcessingFlow.TopParentCCIId;
            holdingAgencycciId = directOrderProcessingFlow.HoldingAgencyCCIId;
            agencysParent = directOrderProcessingFlow.AgencysParent;
            contactName=directOrderProcessingFlow.contactFirstName +directOrderProcessingFlow.ContactLastName;
            contactPhone = directOrderProcessingFlow.contactPhone;
            contactId = directOrderProcessingFlow.contactId;
            cciProfile = directOrderProcessingFlow.UserSelectedProfile;
            cciGroup = directOrderProcessingFlow.UserSelectedGroup;
            dbType = directOrderProcessingFlow.DbType;
            parentAccType = directOrderProcessingFlow.ParentAccType;
            System.debug('dbType ='+dbType+'..parentAccType..'+parentAccType);
            }
            if(contactPhone!=null)
                contactPhone =contactPhone.replace( ' ','%20'); 
            if(cciProfile!=null)
                cciProfile =cciProfile.replace( ' ',';'); 
            if(cciGroup!=null)
                cciGroup =cciGroup.replace( ' ',';'); 
            
               

        if (agencyId == null) agencyId = '';
        if (bookingAgencyId == null) bookingAgencyId = '';
        if (bookingcciCusId == null) bookingcciCusId = '';
        
        if(dbType=='Mail'){
            if (parentCCIMailId == null) parentcciId = '';
            else parentcciId = parentCCIMailId;
         }else{
            if (parentCCIMetroId == null) parentcciId = '';
            else parentcciId = parentCCIMetroId ;
        }
        if(parentAccType=='Holding Company'){
            holdingCompanycciId  = parentcciId;
            parentcciId = '';
        }
        if (holdingCompanycciId == null) holdingCompanycciId = '';
        if (holdingAgencycciId == null) holdingAgencycciId = '';
        if(agencysParent==null )agencysParent ='';
        if(contactName==null)contactName='';
        if(contactPhone==null)contactPhone='';
        if(cciProfile==null)cciProfile='';
        if(cciGroup==null)cciGroup='';
        
        
        
        Pagereference p;
        if (sopId == null || sopId == '' || cciCusId == null || cciCusId == '') p = new Pagereference('/' + clientId);
        else 
        {
            System.debug('/apex/iframepage?agencyId=' + agencyId + '&bookingId=' + bookingAgencyId + '&bookingcciId=' + bookingcciCusId + '&cciCusId=' + cciCusId + '&clientId=' + clientId + '&sopId=' + sopId + '&parentcciId=' + parentcciId + '&holdingCompanycciId=' + holdingCompanycciId + '&holdingAgencycciId=' + holdingAgencycciId+'&contactId='+contactId+'&cciProfile='+cciProfile+'&cciGroup='+cciGroup);
            p = new Pagereference('/apex/iframepage?agencyId=' + agencyId + '&bookingId=' + bookingAgencyId + '&bookingcciId=' + bookingcciCusId + '&cciCusId=' + cciCusId + '&clientId=' + clientId + '&sopId=' + sopId + '&parentcciId=' + parentcciId + '&holdingCompanycciId=' + holdingCompanycciId + '&holdingAgencycciId=' + holdingAgencycciId+'&contactId='+contactId+'&cciProfile='+cciProfile+'&cciGroup='+cciGroup);
            // p = new Pagereference('/apex/iframepage?agencyId=' + agencyId + '&bookingId=' + bookingAgencyId + '&bookingcciId=' + bookingcciCusId + '&cciCusId=' + cciCusId + '&clientId=' + clientId + '&sopId=' + sopId + '&parentcciId=' + parentcciId + '&holdingCompanycciId=' + holdingCompanycciId + '&holdingAgencycciId=' + holdingAgencycciId+'&contactId='+contactId+'&cciProfile='+cciProfile+'&cciGroup='+cciGroup);
            //p = new Pagereference('/apex/iframepage?agencyId=' + agencyId + '&bookingId=' + bookingAgencyId + '&bookingcciId=' + bookingcciCusId + '&cciCusId=' + cciCusId + '&clientId=' + clientId + '&sopId=' + sopId + '&parentcciId=' + parentcciId + '&holdingCompanycciId=' + holdingCompanycciId + '&holdingAgencycciId=' + holdingAgencycciId+'&contactName=' + contactName+'&contactPhone=' + contactPhone);
            p.setRedirect(true);
        }
        System.debug('Before returning page reference' + p);
        return p;

    }

    public PageReference getFlowEditFinishLocation() {
        System.debug('Flow is' + selectCCIGroupAndProfile);
        String clientId;
        String agencyId;
        String bookingAgencyId;
        String bookingcciCusId;
        String sopId;
        String cciCusId;
        String parentCCIMailId;
        String parentCCIMetroId;
        String parentcciId;
        String holdingCompanycciId;
        String holdingAgencycciId;
        String agencysParent;
        String contactName;
        String contactPhone;
        String contactId;
        String cciProfile;
        String cciGroup;
        String dbType;
        String parentAccType;
        
        if (selectCCIGroupAndProfile != null) {
            cciProfile = selectCCIGroupAndProfile.UserSelectedProfile;
            cciGroup = selectCCIGroupAndProfile.UserSelectedGroup;
            
            if(cciProfile!=null)
            {
                cciProfile =cciProfile.replace( ' ',';'); 
            }
            else
            {
                cciProfile = profile0.replace( ' ',';');
            }
            if(cciGroup!=null)
            {
                cciGroup =cciGroup.replace( ' ',';'); 
            }
            else
            {
                cciGroup=group0.replace( ' ',';');
            }
            System.debug('group..'+cciGroup+'group flow..'+selectCCIGroupAndProfile.UserSelectedGroup);
            System.debug('profile..'+cciProfile+'group flow..'+selectCCIGroupAndProfile.UserSelectedProfile);
       
        }
        else
        {
           cciProfile=profile0.replace( ' ',';'); 
           cciGroup=group0.replace( ' ',';');
        }

        if(cciProfile==null)cciProfile='';
        if(cciGroup==null)cciGroup='';
        
        
        
        Pagereference p;
        if (String.isBlank(cciGroup) || String.isBlank(cciProfile)) p = new Pagereference('/' + clientId);
        else 
        {
            System.debug('/apex/EditOrderPage?Id='+ord.id+'&group=' + cciGroup + '&profile=' + cciProfile);
            p = new Pagereference('/apex/EditOrderPage?Id='+ord.id+'&group=' + cciGroup + '&profile=' + cciProfile);
            p.setRedirect(true);
        }
        System.debug('Before returning page reference' + p);
        return p;

    }
}