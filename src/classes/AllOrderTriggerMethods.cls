public without sharing class AllOrderTriggerMethods {

    private Boolean isExecuting = false;
    private Integer BatchSize = 0;

    // CONSTRUCTOR
    public AllOrderTriggerMethods(Boolean isExecuting, Integer size) {
        isExecuting = isExecuting;
        BatchSize = size;
    }
    // BEFORE INSERT
    public void onBeforeInsert(Order[] newOrders) {

        List < Order > orderList = new List < Order > ();
        List < String > cciAgencyIds = new List < String > ();
        List < Id > accountIds = new List < Id > ();
        Map < String, String > orderAgencyIdMap = new Map < String, String > ();
        for (Order o: newOrders) {
            orderList.add(o);
            cciAgencyIds.add(o.CCI_Account_ID__c);

        }
        System.debug('Agency ids are' + cciAgencyIds);
        //   List<Account> agencies = [Select id,CCIMailCustID__c ,CCIMetroCustID__c ,CCI_Customer_Id__c from Account where CCIMailCustID__c in : cciAgencyIds or CCIMetroCustID__c in : cciAgencyIds and RecordType.Name='Agency'];
        List < String > sourceSystems = new List < String > {
            'CCI Mail', 'CCI Metro'
        };
        List < Account_Mapping__c > accMappings = [Select id, Source_Key__c, Account__c, Account__r.RecordType.Name
        from Account_Mapping__c
        where Source_Key__c in : cciAgencyIds
        and Source_System__c in : sourceSystems
        and Account__r.RecordType.Name = 'Agency'];
        for (Account_Mapping__c accMapping: accMappings) {
            orderAgencyIdMap.put(accMapping.Source_Key__c, accMapping.Account__c);
            accountIds.add(accMapping.Account__c);
        }
        system.debug('orderAgencyIdMap: ' + orderAgencyIdMap);
        for (Order o: newOrders) {
            System.debug('before updating agency ...Order is' + o);
            o.Agency__c = orderAgencyIdMap.get(o.CCI_Customer_Id__c);
            System.debug('after updating agency ...Order is' + o);
        }
    }

      public void OnAfterUpdate(Order[] oldOrders, Order[] updatedOrders, Map < ID, Order > newOrderMap, Map < ID, Order > oldOrderMap) {
        List < Id > orderIds = new List < Id > ();
        List < Id > oppIds = new List < Id > ();
        List < OpportunityLineItem > oppLineItems = new List < OpportunityLineItem > ();
        List < Order > orderList = new List < Order > ();
        Map < Id, Order > oppOrderMap = new Map < Id, Order > ();
        for (Order o: updatedOrders) {

            Order oldOrder = oldOrderMap.get(o.id);
            if (o.Status != oldOrder.Status && o.Status == 'Activated') {
                System.debug('Inside If block');
                oppIds.add(o.opportunity__c);
                oppOrderMap.put(o.opportunity__c, o);
                orderIds.add(o.id);

            }
        }
        //getting list of opportunities related to this order
        List < Opportunity > oppList = [Select Name from Opportunity where id in : oppIds];
        List < OpportunityLineItem > oppProdList = [Select Opportunity.Name,ServiceDate from OpportunityLineItem where opportunityId in : oppIds];
        Set<String> opplineDateSet = new Set<String>();
        
        Map <Id, List<OpportunityLineItem>> oppMap = new Map <Id, List<OpportunityLineItem>>();
        
        for(OpportunityLineItem o: oppProdList)
        {
            if(oppMap.containsKey(o.OpportunityId))
            {
                List<OpportunityLineItem> oplList1 = oppMap.get(o.OpportunityId);
                oplList1.add(o);
                oppMap.put(o.OpportunityId, oplList1);
            }
            else
            {
                List<OpportunityLineItem> oplList2 = new List<OpportunityLineItem>();
                oplList2.add(o);
                oppMap.put(o.OpportunityId, oplList2);
            }
        }
        
        List < OpportunityLineItem > oppLinesToDelete = new List < OpportunityLineItem >();
        List < OpportunityLineItem > oppLinesToUpdate = new List < OpportunityLineItem >();
        
        
        for(OpportunityLineItem oppl:oppProdList)
        {
            if(oppl.Opportunity.Name.contains('Direct Order for'))
            {
                oppLinesToDelete.add(new OpportunityLineItem(Id=oppl.Id));
            }
            else{
            Date insertionDate = oppl.ServiceDate;
            System.debug('insertion date..'+ insertionDate);
            String insertionDateStr = datetime.newInstance(insertionDate.year(),insertionDate.month(), insertionDate.day()).format('yyyy-MM-dd');
            System.debug('insertionDateStr..'+ insertiondateStr);
             opplineDateSet.add(oppl.id+insertionDateStr);
            }
        }
        System.debug('opplinedateset..'+ opplineDateSet);
        
        //  delete oppProdList;
        //getting list of orderItems related to this order
        List < OrderItem > orderItems = [Select id, ServiceDate,Opportunity_Line_ID__c,Dateflex__c, Order.opportunity__c, Order.opportunity__r.Name, PricebookEntryId, UnitPrice, First_Delivery_Date__c, Last_Delivery_Date__c, CreatedDate from OrderItem where OrderId in : orderIds];
        Map<String,OrderItem> orderItemMap = new Map<String,OrderItem>();
        
       
        for (Opportunity opp: oppList) {
            //update close date for opportunity
            // opp.CloseDate = oppOrderMap.get(opp.id).EffectiveDate;
            opp.StageName = 'Preparation';
        }
        
        Date orderCreationDate;
        
        if(orderItems[0].Order.Opportunity__r.Name.contains('Direct Order for')){
                for (OrderItem o: orderItems) {
                    DateTime dT = o.CreatedDate;
                    orderCreationDate = date.newinstance(dT.year(), dT.month(), dT.day());
            //Product2 = o.Product2,ProductCode=o.ProductCode
           
                    oppLineItems.add(new OpportunityLineItem(ServiceDate = o.ServiceDate, opportunityId = o.Order.opportunity__c, PricebookEntryId = o.PricebookEntryId, UnitPrice = o.UnitPrice, Quantity = 1, Date_Booked__c = orderCreationDate, First_Insertion_Date__c = o.First_Delivery_Date__c, Last_Insertion_Date__c = o.Last_Delivery_Date__c, Related_Order__c=o.OrderId, Order_Item__c=o.Id));             
                    }
                    }
            
            else
            {
            
             for(OrderItem o:orderItems){
                 String oppLineid = o.Opportunity_Line_ID__c;
                 Date insertionDate = o.First_Delivery_Date__c; 
                 String insDateStr = datetime.newInstance(insertionDate.year(),insertionDate.month(), insertionDate.day()).format('yyyy-MM-dd');
                 String uniqueStr = oppLineId+insDateStr;
                 System.debug('UniqueStr..'+ uniqueStr);
                 if(!opplineDateSet.contains(uniqueStr)&& !o.dateflex__c){
                      oppLineItems.add(new OpportunityLineItem(ServiceDate = o.ServiceDate, opportunityId = o.Order.opportunity__c, PricebookEntryId = o.PricebookEntryId, UnitPrice = o.UnitPrice, Quantity = 1, Date_Booked__c = orderCreationDate, First_Insertion_Date__c = o.First_Delivery_Date__c, Last_Insertion_Date__c = o.Last_Delivery_Date__c, Related_Order__c=o.OrderId, Order_Item__c=o.Id));             
                }else{
                System.debug('In else now for line update');
                   if(!o.dateflex__c || (o.Dateflex__c&&o.UnitPrice!=0.0))
                       orderItemMap.put(o.Opportunity_Line_ID__c,o);
                }}
            System.debug('OrderItemMap..'+ orderItemMap);
            List<OpportunityLineItem> opp1List = oppMap.get(orderItems[0].Order.opportunity__c);
            System.debug('Opp1List..'+opp1List);
            for(OpportunityLineItem ol:opp1List)
            {
                System.debug('oppline item is..'+ ol.id);
                OrderItem orderItem = orderItemMap.get(ol.id);
                if(orderItem!=null){
                System.debug('orderItem..' +orderItem);
                System.debug('opp to update..'+ ol);
                ol.Related_Order__c=orderItem.OrderId;
                ol.Order_Item__c = orderItem.id;
                }
                  
              oppLinesToUpdate.add(ol);
                }
            }
            
            
        

        update oppList;
        System.debug('oppList:'+oppList);
        System.debug('oppLinesToDelete:'+oppLinesToDelete);
        System.debug('oppLineItems:'+oppLineItems);
        System.debug('oppLinesToUpdate:'+oppLinesToUpdate);
        
        // delete oppProdList;
        if(oppLinesToDelete.size()>0)
        {
            delete oppLinesToDelete;
        }
        if(oppLineItems.size()>0)
        {  
        System.debug('adding items.'+ oppLineItems)     ;
            insert oppLineItems;
        }
        if(oppLinesToUpdate.size()>0)
        {
            update oppLinesToUpdate;    
        }
        
        for (Opportunity opp: oppList) {
            //update close date for opportunity
            if(opp.Name.contains('Direct Order for')){
            opp.CloseDate = oppOrderMap.get(opp.id).EffectiveDate;
            opp.StageName = 'Closed Won';
            }

        }
        upsert oppList;
    }
}