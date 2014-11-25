public with sharing class AccountIndustryCategoryController{

    public String parentPicklistVal{public get; public set;}
    public String[] childMultiPicklistVal{public get; public set;}
    public String[] childSinglePicklistVal{public get; public set;}
    public Account acc;
    public String styleSub{public get; public set;}
    public String styleMinor{public get; public set;}
    public Boolean refreshPage {get; set;}
    public String mode{get;set;}
    // maps to hold your dependencies between picklists
    private Map<String, List<String>> parentDepMap;
    private Map<String, List<String>> childDepMap;
    private String originalIndustry;
   
    Set<String> parentList = new Set<String>();

    public AccountIndustryCategoryController(ApexPages.StandardController controller) {
         parentDepMap=  new Map<String, List<String>>();
         childDepMap = new Map<String, List<String>>();
         String accId = controller.getId();
         this.acc = [Select id,Status__c,CCIMailCustID__c,CCIMetroCustID__c,Industry,Industry_Sub_Category__c,Industry_Minor_Category__c from Account where id=:accId];
        // acc.Mode__C = 'View';
         this.mode = 'View';
         String subCategory;
         String minorCategory; 
         originalIndustry= acc.Industry;
         if(originalIndustry!=null && originalIndustry!='' &&originalIndustry.contains('-')){
        
            this.parentPickListVal = acc.Industry;
            subCategory   = acc.Industry_Sub_Category__c;
            minorCategory = acc.Industry_Minor_Category__c;
             }
          if(subCategory!=null&&subcategory!=''){
             childMultiPicklistVal = acc.Industry_Sub_Category__c.split(';');
             styleSub = 'height:80px';
         }else if(this.parentPickListVal!=null && this.parentPickListVal!=''){
           //  childMultiPicklistVal = this.setChildMultiPicklistOptions();
              styleSub = 'height:80px';
         }
         else{
             styleSub ='height: 0px';
         }
         
         if(minorCategory!=null&&minorCategory!=''){
             childSinglePicklistVal = acc.Industry_Minor_Category__c.split(';');
             styleMinor ='height: 80px';
         }else if(this.childMultiPicklistVal !=null && this.childMultiPicklistVal.size()>0){
           //  childMultiPicklistVal = this.setChildMultiPicklistOptions();
              styleSub = 'height:80px';
         }
        
         else{
          styleMinor ='height: 0px';}
         
         List<Industry_Category_Mapping__c> mappingList = [Select Name,Minor_Category__c,Industry__c from Industry_Category_Mapping__c];
         System.debug('Mappings are:' + mappingList);
        
         for (Industry_Category_Mapping__c i: mappingList){
            parentList.add(i.Industry__c);
            System.debug('Minor is' + i.Minor_Category__c);
            String[] minors = i.Minor_Category__c.split(';');
            System.debug('Minors are :' + minors);
            childDepMap.put(i.Name,minors);
                    
         }
        System.debug('Childdep map'+childDepMap);
       for (String industry: parentList){
            List<String> validList =new List<String>() ;
            for (Industry_Category_Mapping__c i : mappingList){
                 if(i.Industry__c == industry){
                    validList.add(i.Name);
                    
             }}
           
            
             parentDepMap.put(industry,validList);
           
               System.debug('ParentDepMap'+ parentDepMap)        ;
        
       }
       
           
        
       
        
    }

    public List<SelectOption> getParentPicklistOptions() {
      List<SelectOption> selectOpts = new List<SelectOption>();
      List<String> subList = new List<String>();
      Map<String,String> map1 = new Map<String,String>();
      List<String> sortedList = new List<String>();
      System.debug('ParentList'+ parentList );
      List<String> nonformattedCategories = new List<String>();
      for(String s1: parentList ){
         String s2; 
         
              s2 = s1.substringBefore('-');
              subList.add(s2);
          map1.put(s2,s1);
          }
       subList.sort();
       for(String s4:subList){
          sortedList.add(map1.get(s4));
            
            }
            
      
        
      
        for ( String s : sortedList)
            selectOpts.add(new SelectOption(s, s));
        return selectOpts;
    }

    public List<SelectOption> getChildMultiPicklistOptions() {
        List<SelectOption> selectOpts = new List<SelectOption>();
        if ( parentPicklistVal != null ) {
            // build a set of values to avoid dupes, since there may be overlapping dependencies
            Set<String> possibleOpts = new Set<String>();
            List<String> subList = new List<String>();
            Map<String,String> map1 = new Map<String,String>();
            List<String> sortedList = new List<String>();
            possibleOpts.addAll(parentDepMap.get(parentPicklistVal));
            for(String s: possibleOpts){
            String s1;
            String s2;
            
               s1 = s.substringBefore('-');
            
          
            s2 =s1.substringAfter('.');
           
            subList.add(s2);
            map1.put(s2,s);
            
            System.debug('subList'+subList );
            }
            subList.sort();
            for(String s4:subList){
                sortedList.add(map1.get(s4));
            
            }
            System.debug('Possible Opts' + sortedList);
            for ( String s : sortedList)
                selectOpts.add(new SelectOption(s, s));
            
        }
        System.debug('Selected options are'+ selectOpts);
        return selectOpts;
    }



 public List<String> setChildMultiPicklistOptions() {
        List<String> selectOpts = new List<String>();
        System.debug('Parentpicklist value is' + parentPicklistVal );
        if ( parentPicklistVal != null ) {
            // build a set of values to avoid dupes, since there may be overlapping dependencies
            Set<String> possibleOpts = new Set<String>();
            List<String> subList = new List<String>();
            Map<String,String> map1 = new Map<String,String>();
            List<String> sortedList = new List<String>();
            possibleOpts.addAll(parentDepMap.get(parentPicklistVal));
            for(String s: possibleOpts){
            String s1;
            String s2;
            
               s1 = s.substringBefore('-');
            
          
            s2 =s1.substringAfter('.');
           
            subList.add(s2);
            map1.put(s2,s);
            
            System.debug('subList'+subList );
            }
            subList.sort();
            for(String s4:subList){
                sortedList.add(map1.get(s4));
            
            }
            System.debug('Possible Opts' + sortedList);
            for ( String s : sortedList)
                selectOpts.add(s);
            
        }
        System.debug('Selected options are'+ selectOpts);
        return selectOpts;
    }




    public List<SelectOption> getChildSinglePicklistOptions() {
        List<SelectOption> selectOpts = new List<SelectOption>();
        
        List<String> subList2 = new List<String>();
        Map<String,String> map2 = new Map<String,String>();
        List<String> sortedList2 = new List<String>();
        if ( childMultiPicklistVal != null && childMultiPicklistVal.size() > 0 ) {
            // build a set of values to avoid dupes, since there may be overlapping dependencies
            Set<String> possibleOpts = new Set<String>();
            for ( String val : childMultiPicklistVal )
                possibleOpts.addAll(childDepMap.get(val));
            
            for(String s: possibleOpts){
                String s1 = s.substringBefore('-');
                String s2 =s1.substringAfter('.');
                subList2 .add(s2);
                map2.put(s2,s);
                       
            }
            subList2.sort();
            for(String s4:subList2){
                sortedList2.add(map2.get(s4));
            
            }
            for ( String s : sortedList2)
                selectOpts.add(new SelectOption(s, s));
                }
        
        return selectOpts;
    }

    public PageReference actionUpdatePicklistVals() {
       if(parentPicklistVal!=null )
           styleSub = 'height:80px';
           else
            styleSub = 'height:0px';
       if(childMultiPicklistVal!=null && childMultiPicklistVal.size()>0)
           styleMinor = 'height:80px';
       else
            styleMinor = 'height:0px';
       return null;
    }
    
      public PageReference edit() {
        System.debug('Inside Edit');
        User u = Common.getUserInfo();
        System.debug('User is'+u);
       // if(!u.Virtual_Data_Team_Member__c &&(!String.isBlank(acc.CCIMailCustID__c)|| !String.IsBlank(acc.CCIMetroCustId__C))){
        if(!u.Virtual_Data_Team_Member__c && (acc.Status__c=='Locked')){
           System.debug('Entered check for VDT');
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.EditCategoryError); 
           ApexPages.addMessage(myMsg);
           this.mode = 'View';
           
           }
           else{
        //acc.Mode__c = 'Edit';
        //upsert acc;
         this.mode = 'Edit';
         }
         
        /*String url   = ApexPages.currentPage().getURL();
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
       System.debug('Page reference is' + pageRef);
        return pageRef;*/
       // setChildMultiPicklistOptions();
        return null;
        
        
      }
      
      
        public PageReference cancel() {
            System.debug('Inside Cancel');
            String url   = ApexPages.currentPage().getURL();
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
        
      }
    
     public PageReference save() {
        System.debug('Inside Save');
        System.debug('Industry:' + parentPicklistVal  + 'Sub Industry are:' + childMultiPicklistVal + 'Minor Category are :' + childSinglePicklistVal);
        try{
        acc.Industry = parentPicklistVal; 
        Boolean Start = true;
        String subCategory;
        String minorCategory;
        
       
        //setting sub category values
        if(!childMultiPicklistVal.IsEmpty()){
            System.debug('loop1');
            for(String str:childMultiPicklistVal){
                if(Start){
                   System.debug('Start is true');
                    subCategory = str;
                    Start = false;
                }else{
                    System.debug('Start is false');
                    subCategory = subCategory + ';' + str;
                }
            }
        }
            Start = true;
            //setting minor Category Values
        if(!childMultiPicklistVal.IsEmpty()&&!childSinglePicklistVal.IsEmpty()){
            for(String str:childSinglePicklistVal){
                if(Start){
                    minorCategory = str;
                    Start = false;
                }
                else{
                    minorCategory = minorCategory + ';' + str;
                    }
            }
        }
        acc.Industry_Minor_Category__c = minorCategory;
        acc.Industry_Sub_Category__c = subCategory;
        //acc.Mode__c = 'View';
        this.mode = 'View';
        upsert acc;
        System.debug('Original Industry'+ this.originalIndustry + 'ParentpicklistVal'+ parentPicklistVal);
      /*  if(this.originalIndustry==null|| (this.originalIndustry!=null && this.originalIndustry !=parentPicklistVal)){
          refreshPage=true;
          return null;
          
          }*/
       String url   = ApexPages.currentPage().getURL();
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
        //return null;
            
          } catch(Exception e){
            ApexPages.addMessages(e);
            System.Debug('Error updating Industry' + e);
            return null;
        }
    }


}