public with sharing class CCIOrder{
   
    public String callerName;
    public String purchaseOrderNo ;
    public String opportunityId;
    public String salesRepName;
    public String bookingSource;
    public PackageItems packageItems;
    public Account account;
    public Owner ownerCustomer;
    public Owner advertiserCustomer;
    public Owner  agencyCustomer;
    public Caller callerPhone;
    public OtherCustomers otherCustomers;
    
    public  CCIOrder(){}
    //constructor for creating basic order to get concept values
    public CCIOrder(String code ){
        this.bookingSource = 'PluginOE';
        this.packageItems = new PackageItems(code);                
        
    }
    //constructor to create actual order with all opp n opplItems values
    public  CCIOrder(Opportunity opp, List<OpportunityLineItem> oli,String cciCustomerId,String cciAgencyId,String cciFinAccId,String cciClient,String cciHoldingCo,String cciHoldingAgency,String cciBookingAgency){
     
        this.callerName = opp.Pitch_Contact_Name__c;
        this.purchaseOrderNo = oli[0].Order_Level_PO_Number__c;
        this.opportunityId = opp.id;
        this.salesRepName='James Hooper';
        if(cciAgencyId!=null){
            this.account = new Account(cciFinAccId, new Owner(cciAgencyId));
            this.ownercustomer = new Owner(cciAgencyId);
        }
        else{
            this.account = new Account(cciFinAccId, new Owner(cciCustomerId));
            this.ownercustomer = new Owner(cciCustomerId);
              }
        this.advertiserCustomer = new Owner(cciCustomerId);
        if(cciAgencyId!=null)
        this.agencyCustomer = new Owner(cciAgencyId);
        this.callerPhone = new Caller(opp.Pitch_Contact_Phone__c);
        this.bookingSource = 'PluginOE';
                    
        this.packageItems = new PackageItems(opp,oli);
        System.debug('PackageItems are..'+ this.packageItems);
        if(!String.IsBlank(cciClient)||!String.IsBlank(cciHoldingCo)||!String.IsBlank(cciHoldingAgency)||!String.IsBlank(cciBookingAgency)){
        this.otherCustomers = new OtherCustomers(cciClient,cciHoldingCo,cciHoldingAgency,cciBookingAgency);
        }
        
       
   
      
    }
   
   
  public class OtherCustomers{
  List<OtherCustomer> otherCustomer;
   public OtherCustomers(){}
      public OtherCustomers(String cciClient,String cciHoldingCo,String cciHoldingAgency,String cciBookingAgency ){
      this.otherCustomer = new list<OtherCustomer>();
      if(!String.IsBlank(cciClient)){
          OtherCustomer client= new OtherCustomer('CLIENT',cciClient);
          otherCustomer.add(client);
      }
      if(!String.IsBlank(cciHoldingCo)){
          OtherCustomer holdingCo= new OtherCustomer('HOLDCOMP',cciHoldingCo);
          otherCustomer.add(holdingCo);
      }
      if(!String.IsBlank(cciHoldingAgency)){
          OtherCustomer holdingAgency= new OtherCustomer('HOLDINGAG',cciHoldingAgency);
          otherCustomer.add(holdingAgency);
      }
      if(!String.IsBlank(cciBookingAgency)){
          OtherCustomer bookingAgency= new OtherCustomer('BookAgency',cciBookingAgency);
          otherCustomer.add(bookingAgency);
      }
      }
  
  }
    public class OtherCustomer{
    String roleCode;
    Owner customer;
    String relatedRoles;
    public  OtherCustomer(){}
    public OtherCustomer(String roleCode,String id){
    this.roleCode = roleCode;
    this.Customer = new Owner(id);
    }
    }     
    public class Account{
        String accountId;
        Owner owner;
        public Account(){}
        public Account(String finAccId,Owner owner){
            this.accountId = finAccId;
            this.owner = owner;
        }
    }
    public Class Owner{
        String customerId;
        public Owner(){}
        public Owner(String id){
            this.CustomerId = id;
        }
    }
    
      
    
    public Class Caller{
    String num;
    public Caller(){}
    public Caller(String phoneNo){
        this.num = phoneNo;
       }
    }
    
    public class PackageItems{
        public List<PackageItem> packageItem;
        public PackageItems(){}
        public PackageItems(String code){
            this.packageItem = new List<PackageItem>();
            this.packageItem.add(new PackageItem(code));
        }
       
        public PackageItems(Opportunity opp,List<OpportunityLineItem> oppLItems){
         System.debug('olItems inside package are..'+ oppLItems);
            this.packageItem = new List<PackageItem>();
            Set<String> sIds = new Set<String>();
            Map<String,List<OpportunityLineItem>> packageLineItems = new Map<String,List<OpportunityLineItem>>();
            for(OpportunityLineItem oli:oppLItems){
            System.debug('package name is..'+ oli.package__c);
            if(sIds.contains(oli.Schedule_Identifier__c)){
                packageLineItems.get(oli.Schedule_Identifier__c).add(oli);
            }else{
               sIds.add(oli.Schedule_Identifier__c);
               List<OpportunityLineItem> l = new List<OpportunityLineItem>();
               l.add(oli);
               packageLineItems.put(oli.Schedule_Identifier__c,l);
            }
             }
             System.debug('Pnames are ..'+ sIds);
              System.debug('Packagelineitems are ..'+ packageLineItems);
             for(String name:sIds){
              System.debug('inside for loop for package..'+name);
           
              this.packageItem.add(new PackageItem(name,opp,packageLineItems.get(name)));
              
            }
    }
    }
    
    
      public class PackageItem{
       public String packageCode;
        public Schedules schedules;
        public packageItem(){}
       
        public packageItem(String code){
        this.packageCode = code;
        this.schedules = new Schedules();
        }
        public packageItem(String packageCode,Opportunity opp,List<OpportunityLineItem> oppLItems){
       
            this.packageCode=oppLItems[0].Package__c;
            this.schedules = new schedules(opp,oppLItems);
            
        }
        
    }
    public class OrderItems{
        public List<OrderItem> orderItem;
        public OrderItems(){}
        public OrderItems(List<OpportunityLineItem> olItems){
            this.orderItem = new List<OrderItem>();
            for(OpportunityLineitem oli:olItems){
                this.orderItem.add(new OrderItem(oli));
            }
        }
    }
    public class OrderItem{
        String firstDeliveryDate;
        String lastDeliveryDate;
        Boolean isFlexDate;
        String opportunityId;
        String purchaseOrderNo;
        
        public OrderItem(){}
        public OrderItem(OpportunityLineItem oli){
            this.firstDeliveryDate = datetime.newInstance(oli.ServiceDate.year(), oli.ServiceDate.month(), oli.ServiceDate.day()).format('dd/MM/yyyy');
            this.lastDeliveryDate = datetime.newInstance(oli.ServiceDate.year(), oli.ServiceDate.month(), oli.ServiceDate.day()).format('dd/MM/yyyy');
            this.isFlexDate = oli.Dateflex__c;
            this.opportunityId = oli.Id;
            this.purchaseOrderNo = oli.PO_Number__c;
    }
    }
    public class Schedules{
    public  List<Schedule> schedule;
    public Schedules(){}
    public Schedules(Opportunity opp,List<OpportunityLineItem> olItems){
        this.schedule = new List<Schedule>();
        Map<String,List<OpportunityLineItem>> scheduleItems = new Map<String,List<OpportunityLineItem>>();
        Set<String> packageRuleNames = new Set<String>();
        for(OpportunityLineItem oli:olItems){
        String uniqueString = oli.Package_Rule_Name__c;
            if(packageRuleNames.contains(uniqueString )){
                    scheduleItems.get(uniqueString).add(oli);
            }
            else{
                packageRuleNames.add(uniqueString);
                List<OpportunityLineitem> ols=   new List<OpportunityLineitem>();
                ols.add(oli);
                scheduleItems.put(uniqueString,ols);
            }
        }
        for(String packagerule:packageRuleNames)
             this.schedule.add(new Schedule (opp,scheduleItems.get(packageRule)));
        //for(String uniqueStr:uniqueKey){
         //   this.schedule.add(new Schedule (opp,scheduleItems.get(uniqueStr)));
       // }
       }                
       
      }
    public class Schedule{
        public String packageRuleName;
        boolean isEnabled;
        String purchaseOrderNo;
        String opportunityId;
        public String sectionCode;
        public String subSectionCode;
        public String titleCode;
        public String titleCategoryCode;
        public String adUnitCode;
        public String webSiteCode;
        public String webSiteCategoryCode;
        public String distributionCode;
        public String classificationCode;
        public String classificationCategoryCode;
        public String classificationMainCategoryCode;
        public String productCategoryCode;
        public String productMainCategoryCode;
        public String productUnitCode;
        public String productCode;
        public Integer noOfUnits;
        String dateList;
        String zoneCode;
        public String publicationCode;
        public String mediaCode;
        public boolean isFlexSchedule;
        OrderItems orderItems;
        //OrderItems orderItems;
        String scheduleMethod;
        public Schedule(){}
        public Schedule(String packageRuleName,String mediaCode,String titleCategoryCode){
            this.packageRuleName = packageRuleName;
           /* this.titleCode  = title;
           
            this.publicationCode = publicationCode;
            this.sectionCode=sectionCode;
            this.subsectionCode = subSectionCode;*/
            this.mediaCode = mediaCode;
             this.titleCategoryCode = titleCategoryCode;
        }
        public Schedule(Opportunity opp,List<OpportunityLineItem> olItems){
        System.debug('olist..'+olItems);
           this.packageRuleName =olItems[0].Package_Rule_Name__c;
           this.isEnabled = true;
           this.dateList='';
           this.scheduleMethod='2';
           if(olItems.size()>1){
               this.opportunityId = olItems[0].Schedule_Identifier__c;
           }else{
               
               this.opportunityId = olItems[0].id;
           }
           this.isFlexSchedule = olItems[0].Dateflex__c;
           this.purchaseOrderNo = olItems[0].PO_Number__c;
           this.sectionCode = olItems[0].Display_Section__c;
           this.subsectionCode = olItems[0].Sub_Section__c;
           this.titleCode =olItems[0].Title__c;
           this.zoneCode=olItems[0].Zone__c;
           this.publicationCode = olItems[0].Publication__c;
           this.titleCategoryCode = olItems[0].Title_Category__c;
           this.adUnitCode = olItems[0].Combined_Ad_Unit__c;
           this.webSiteCode= olItems[0].WebSite__c;
           this.webSiteCategoryCode = olItems[0].Website_Category__c;
           this.distributionCode = olItems[0].Distribution__c;
           if(!String.IsBlank(olItems[0].No_of_Units__c))
               this.noOfUnits =Integer.valueOf(olItems[0].No_of_Units__c);
           this.productCategoryCode = olItems[0].Product_Category__c;
           this.productMainCategoryCode = olItems[0].Product_Main_Category__c;
           this.productUnitCode = olItems[0].Product_Unit__c;
           this.productCode = olItems[0].CCI_Product__c;
           this.classificationCode = olItems[0].Classification__c;
           this.classificationCategoryCode = olItems[0].Classification_Category__c;
           this.classificationMainCategoryCode = olItems[0].Classification_Main_Category__c;
           Integer i = 0;
            for(OpportunityLineItem oli:olItems){
            if(oli.Dateflex__c){
                 dateList = oli.Dateflex_Daterange__c;
            }else{
                if(i==0){
                   dateList=datetime.newInstance(oli.ServiceDate.year(), oli.ServiceDate.month(), oli.ServiceDate.day()).format('dd/MM/yyyy');
                   i++;
                   }
                   else{
                   dateList+=','+ datetime.newInstance(oli.ServiceDate.year(), oli.ServiceDate.month(), oli.ServiceDate.day()).format('dd/MM/yyyy');
                   i++;
                   }
                   }
                   
                }
           // this.OrderItems = new OrderItems(olItems);
            }
    }
    
    
   
}