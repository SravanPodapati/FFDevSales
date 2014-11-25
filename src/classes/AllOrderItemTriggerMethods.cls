public without sharing class AllOrderItemTriggerMethods {

    private Boolean isExecuting = false;
    private Integer BatchSize = 0;

    // CONSTRUCTOR
    public AllOrderItemTriggerMethods (Boolean isExecuting, Integer size) {
        isExecuting = isExecuting;
        BatchSize = size;
    }
    // BEFORE INSERT
    public void onBeforeInsert(OrderItem [] newOrderItems) {

        
        for (OrderItem o: newOrderItems) {
            if(o.Yield__c!=null){
                o.SCC_Rate__c = String.valueOf(o.Yield__c*100);
            }else{
                    Integer index = o.Size__c.indexOf('x');
                    Integer size1 = Integer.valueOf(o.Size__c.substring(0,index).trim());
                    Integer size2 = Integer.valueOf(o.Size__c.substring(index+1,o.size__c.length()).trim());
                    Integer sizeCal = size1*size2;
                    System.debug('sizeCal is..'+ sizeCal);
                    o.SCC_Rate__C = String.valueOf((o.UnitPrice/sizeCal).setScale(2));
             }      
         }
        }
        
        
    public void OnBeforeUpdate(OrderItem[] updatedOrders, Map < ID, OrderItem> oldOrderMap) {
        System.debug('Entered OnBeforeUpdate..');
        for (OrderItem o: updatedOrders) {
            OrderItem oldOrder = oldOrderMap.get(o.id);
            if (o.yield__c != null&& oldOrder.yield__c!= o.yield__c) {
               o.SCC_Rate__c = String.valueOf(o.Yield__c*100);

            }else if(o.UnitPrice!=oldOrder.UnitPrice||o.size__c!=oldOrder.size__c){
            try{
                    System.debug('Entered calc based on size and baseprice..'+ o.Size__c);
                    Integer index = o.Size__c.indexOf('x');
                    Integer size1 = Integer.valueOf(o.Size__c.substring(0,index).trim());
                    Integer size2 = Integer.valueOf(o.Size__c.substring(index+1,o.size__c.length()).trim());
                    Integer sizeCal = size1*size2;
                    o.SCC_Rate__C = String.valueOf((o.UnitPrice/sizeCal).setScale(2));
                    }catch(Exception e){
                    System.debug('Exception is..'+ e);
                    }
                     
              }
          }
    }

    public void onAfterUpdate (OrderItem[] newOrderItems, Map<ID, OrderItem> oldOrderItemsMap){
        system.debug('***After Update Tirggers***');
        map<Id, Value_BacK_Contract__c> valueBalckMap;
        set<id> valueBackContractIdSet = new set<Id>();
        for(OrderItem oI : newOrderItems){
            if(oI.Value_Back_Contract__c != oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c ){
                //adding the value back to Order Item for the first time. 
                if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c == null && oI.Value_Back_Contract__c != null){
                    valueBackContractIdSet.add(oI.Value_Back_Contract__c);
                }
                //Updating the value back contract 
                else if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c != null && oI.Value_Back_Contract__c != null){
                    valueBackContractIdSet.add(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c);
                    valueBackContractIdSet.add(oI.Value_Back_Contract__c);
                }
                //removing the value Back
                else if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c != null && oI.Value_Back_Contract__c == null ){
                    valueBackContractIdSet.add(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c);
                }
            }
        }
        if(valueBackContractIdSet.size() > 0){
            valueBalckMap = new map<Id, Value_Back_Contract__c> ([SELECT ID, Value_Back__c from Value_Back_Contract__c where ID IN: valueBackContractIdSet]);
            for(OrderItem oI : newOrderItems){
                if(oI.Value_Back_Contract__c != oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c ){
                    //adding the value back to Order Item for the first time. 
                    if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c == null && oI.Value_Back_Contract__c != null){
                        //Ading Value Back Amount 
                        valueBalckMap.get(oI.Value_Back_Contract__c).Value_Back__c += oI.Value_Back__c;
                    }
                    //Updating the value back contract 
                    else if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c != null && oI.Value_Back_Contract__c != null){
                        //Adding valueback for new 
                        valueBalckMap.get(oI.Value_Back_Contract__c).Value_Back__c += oI.Value_Back__c;
                        //removing value back for old
                        valueBalckMap.get(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c).Value_Back__c -= oldOrderItemsMap.get(oI.Id).Value_Back__c;
                    }
                    //removing the value Back
                    else if(oldOrderItemsMap.get(oI.Id).Value_Back_Contract__c != null && oI.Value_Back_Contract__c == null ){
                        //removin value back for old 
                        valueBalckMap.get(oI.Value_Back_Contract__c).Value_Back__c -= oldOrderItemsMap.get(oI.Id).Value_Back__c;
                    }
                }
            }
            system.debug('***valueBalckMap : '+valueBalckMap);
            try{
                update valueBalckMap.values(); 
            }catch (exception ex){
                system.debug('***Exception Occurred : ' + ex);
            }
        }
    }

    public void onAfterDelete (Map<ID, OrderItem> oldOrderItemsMap){
        list<OpportunityLineItem> linesToUpdateList = new list<OpportunityLineItem>([SELECT id, Order_Item__c from OpportunityLineItem where Order_Item__c IN: oldOrderItemsMap.keySet()]);
        if(linesToUpdateList != null && linesToUpdateList.size() > 0 ){
            for(OpportunityLineItem line : linesToUpdateList){
                line.Order_Item__c = null;
            }
            update linesToUpdateList;
        }
    }
}