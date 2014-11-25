global with sharing class WebServices {
    /**
     * Custom webservice used to insert or update ADS Customers and ContactPersons as
     * one single unit.
     **/
    /*
  webservice static String upsertCustomer(Account account,Contact[] contacts)
  {
    if(account.RecordType.Name!='Customer')
       return 'Account must be of type Customer';

    // If the SFDC ID is null, the customer (and contacts) are all new. Just insert them.
    // Otherwise it's an update which may have new, changed as well as deleted items.
    
    if(account.Id==null)
      insert account;
    else
      update account;
    
    // Lookup customer (parent account) by CCI id. If the customer doesn't exist,
    // insert him, otherwise do an update. Note: this won't work, if customers can
    // be created in SFDC.
    /*
    List<Account> accounts = [select id from Account where CCI_Customer_Id__c = :account.CCI_Customer_Id__c];
      
    if(accounts.size()==0)
      insert account;
    else
    {
        account.Id = accounts[0].Id;
        
        update account;
    }
    */
    /*
    // Create a map of the customer's current contacts, using the CCI_Contact_Id__c as key.

    Map<String,Contact> currentContacts = new Map<String,Contact>();
    
    for(Contact c: [select Id,CCI_Contact_Id__c from Contact where AccountId= :account.Id])
      currentContacts.put(c.CCI_Contact_Id__c,c);

    Map<String,Contact> contactsToBeCreated = new Map<String,Contact>();
    Map<String,Contact> contactsToBeUpdated = new Map<String,Contact>();
    Map<String,Contact> contactsToBeDeleted = new Map<String,Contact>();
    
    // Of the given order's items, find out which ones we already have in the
    // database and which ones are new.
          
    for(Contact c: contacts)
    {
      if(currentContacts.containsKey(c.CCI_Contact_Id__c))
        contactsToBeUpdated.put(c.CCI_Contact_Id__c,c);
      else
        contactsToBeCreated.put(c.CCI_Contact_Id__c,c);
    }

    // Find out which of the curent items we should delete.
        
    for(Contact c: currentContacts.values())
    {
      if(!contactsToBeUpdated.containsKey(c.CCI_Contact_Id__c))
        contactsToBeDeleted.put(c.CCI_Contact_Id__c,c);
    }
          
    for(Contact c: contactsToBeCreated.values())
    { 
      // Link contact to account...
         
      c.AccountId = account.Id;
          
      // ...and set the item's name to be the CCI ADS Id.
             
      //oi.Name = oi.CCI_Item_Id__c;
    }          

    // Make sure we maintain SFDC's internal ids on items that are
    // about to be updated...
      
    for(Contact c: contactsToBeUpdated.values())
      c.Id = currentContacts.get(c.CCI_Contact_Id__c).Id;

    //..or deleted.
      
     for(Contact c: contactsToBeDeleted.values())
      c.Id = currentContacts.get(c.CCI_Contact_Id__c).Id;
     
    // Do the actual insert, update and delete operations.
 
    insert contactsToBeCreated.values();
    update contactsToBeUpdated.values();
    delete contactsToBeDeleted.values();
      
    String result = 'Processed account with id ' +account.Id;
    
    return  result;
  }*/

    /**
     * Custom web-service used to retrieve a single ADS Customer. The account
     * is specified by an SFDC Account Id.
     **/
    /*
  webservice static List<sObject> retrieveCustomer(String id)
  {  
    List<Account> accounts = [select Id,
                                Name,
                                CCIMetroCustID__c,
                                CCIMailCustID__c,
                                RecordType.Name,
                                Website,
                                Description,
                                BillingStreet,
                                BillingPostalCode,
                                BillingCity,
                                BillingState,
                                BillingCountry,
                                ShippingStreet,
                                ShippingPostalCode,
                                ShippingCity,
                                ShippingState,
                                ShippingCountry,
                                Phone
                              from Account
                              where Id=:id];

    if(accounts.size()==0)
        return null;

    List<sObject> result = new List<sObject>();
      
    result.add( accounts[0]);

    for(Contact c: [select Id,
                      Name,
                      CCI_Contact_Id__c,
                      Salutation,
                      Email,
                      Title,
                      MailingStreet,
                      MailingPostalCode,
                      MailingCity,
                      MailingState,
                      MailingCountry,
                      Phone
                    from Contact
                    where AccountId= :accounts[0].Id])
      result.add(c);

    return result;
  }
    */
    /**
     * Custom webservice used to insert or update ADS Accounts and advertisers as
     * one single unit.
     **/
    /*  
  // webservice static void upsertAccount(Account account,Agency__c[] advertisers)
  webservice static void upsertAccount(FinanceAccount__c account,Account[] advertisers)
  {
    // Note these are Finance Accounts
    // If the SFDC ID is null, the account (and advertisers) are all new. Just insert them.
    // Otherwise it's an update which may have new, changed as well as deleted items.

    if(account.Id==null)
      insert account;
    else
      update account;
  }
    */
    /**
     * Custom web-service used to retrieve a single ADS Account. The account
     * is specified by an SFDC Account Id.
     **/
    /*  
  webservice static FinanceAccount__c retrieveAccount(String id)
  {  
    // These are Finance Accounts
    // List<Account> accounts = [select id,name,CCI_Account_Id__c from Account where Id= :id];
    
    List<FinanceAccount__c> faccounts = [select id,name,Finance_Id__c from FinanceAccount__c where Id= :id];

    if(faccounts.size()>0)
      return faccounts[0];

    return null;
  }*/

    /**
     * Custom webservice used to insert or update ADS Orders and OrderItems as
     * one single unit.
     **/

    webservice static String upsertOrder(Order order, List < OrderItem > orderItems) {
        return upsertOrder( order,orderItems, null);
    }


    public static String upsertOrder(Order order, List < OrderItem > orderItems, ErroredOrder__c eOrder) {
        // Link order to account based on CCI Account ID.
         Order eOrderCopy = order;
         List<OrderItem> eOrderItemsCopy = orderItems;
        //List<Account> accounts = [select Id,Name from Account where CCI_Account_Id__c= :order.CCI_Account_Id__c];
        String errorMsg;
        System.debug('Order: ' + Order);
        System.debug('OrderItems: ' + OrderItems);
        List < User > userList = new List<User>();

        // The Original Order Status has to be preserved. During creation of an Order the Order cannot be set at status Activated. It can only be Draft
        // until such time as the Order has item (or Products as SF calls it). The Original Order status will be preseved towards the end of this method.
        // String originalOrderStatus = (order.Status == 'NOR' ? 'Activated' : 'Draft');
        String originalOrderStatus = (order.Booking_Status__c != 'INCOMPLETE' ? 'Activated' : 'Draft');

        String createdInCCIBy = (order.Created_In_CCI_By__c).replace('DM.CCI', '.');
        createdInCCIBy = createdInCCIBy.replace('CCI', '');

        String priceBookName;
        String department;
        Set < String > productCodeSet = new Set < String > ();

        if (String.IsBlank(createdInCCIBy)) {
            priceBookName = 'Mail Display';
        } else {
            // priceBookName = 'Mail Display';
            // The above is temporary, we need to derive the Price Book based on the user who created the Order in CCI. i.e use the Created_In_CCI_By__c
            try
            {
                userList = [Select profileId
                From User
                Where FederationIdentifier like :createdInCCIBy + '%'
                And profile.Name != 'Integration Profile'
                And ( profile.Name like 'Mail Display%'
                Or profile.Name like 'Mail Classified%'
                Or profile.Name like 'Group Client%'
                Or profile.Name like 'London%'
                Or profile.Name like 'Metro%'
                Or profile.Name like 'System%')
                And IsActive = True];
            }
            catch(Exception e)
            {
           
            }
            System.debug('userList:' + userList);
            if(userList.Size() == 0) {
                userList = [Select profileId
                From User
                Where Email like :createdInCCIBy + '%'
                And profile.Name != 'Integration Profile'
                And ( profile.Name like 'Mail Display%'
                Or profile.Name like 'Mail Classified%'
                Or profile.Name like 'Group Client%'
                Or profile.Name like 'London%'
                Or profile.Name like 'Metro%'
                Or profile.Name like 'System%')
                And IsActive = True];             
            }
            if (userList.Size() == 0) {
                errorMsg = 'Created By User does not exist in Glue.';
                if(eOrder==null)
                    CreateErroredOrdernItems(errorMsg,eOrderCopy,eOrderItemsCopy );
                
               // return 'Created By User does not exist in Glue.';
               return errorMsg;
                
            }
            ConstantsH__c c = ConstantsH__c.getInstance(userList[0].profileId);
            priceBookName = c.Price_Book__c;
            department = c.department__c;
        }

        // Get the PriceBook Id
        PriceBook2 pricebook = [Select Id From PriceBook2 Where Name = : priceBookName];

        FinanceAccount__c fAccount;

        try {
            fAccount = [Select
            Name,
            Account__c
            From FinanceAccount__c
            Where SOP_Id__c = : order.CCI_Account_Id__c];
        } catch (QueryException q) {
            errorMsg = 'Cannot identify the Finance Account: ' + order.CCI_Account_Id__c + ' in Glue.';
            if(eOrder==null)
                    CreateErroredOrdernItems(errorMsg,eOrderCopy ,eOrderItemsCopy);
            
           // return 'Cannot identify the Finance Account: ' + order.CCI_Account_Id__c + ' in Glue.';
            return errorMsg;
        }
        
        Account bookingAgency;
        
        if(!String.IsBlank(Order.CCIBookingAgencyId__c))
        {
            try
            {
                bookingAgency=[Select
                                Id
                                From Account
                                Where (CCIMailCustID__c = :order.CCIBookingAgencyId__c
                                Or    CCIMetroCustID__c = :order.CCIBookingAgencyId__c)];
                order.Booking_Agency__c=bookingAgency.Id;
            }
            catch (QueryException q)
            {
                errorMsg = 'Cannot identify the Booking Agency: ' + order.CCIBookingAgencyId__c + ' in Glue.';
                if(eOrder==null)
                        CreateErroredOrdernItems(errorMsg,eOrderCopy ,eOrderItemsCopy);
                return errorMsg;        
            }           
        }
        
        

        Account acc;

        if (String.ISBLANK(order.CCI_Customer_ID__c)) {
            errorMsg = 'The Customer ID is Blank.';
            if(eOrder==null)
                    CreateErroredOrdernItems(errorMsg,eOrderCopy,eOrderItemsCopy);
               
            //return 'The Customer ID is Blank.';
           return errorMsg;
        }

        try {
            acc = [Select
            Name
            From Account
            Where(CCIMailCustID__c = : order.CCI_Customer_ID__c
            OR CCIMetroCustID__c = : order.CCI_Customer_ID__c)];
        } catch (QueryException q) {
            errorMsg = 'Cannot locate the Customer ID: ' + order.CCI_Customer_ID__c + ' in Glue';
            if(eOrder==null)
                    CreateErroredOrdernItems(errorMsg,eOrderCopy,eOrderItemsCopy);
                
            //return 'Cannot locate the Customer ID: ' + order.CCI_Customer_ID__c + ' in Glue';
            return errorMsg;
        }
        try{
        order.Finance_Account__c = fAccount.Id;
        order.Agency__c = fAccount.Account__c;
      //  if (!Test.isRunningTest()) {
            order.AccountId = acc.Id;
            order.Pricebook2Id = pricebook.Id;
      //  }
        //order.Status = (order.Status == 'NOR' ? 'Draft' : 'Draft');
        
        order.Status = (order.Status == 'INCOMPLETE' ? 'Draft' : 'Draft');
        
        // order.Status = (order.Status=='Activated'?'Draft':'Draft');

        // Set the order's name to be the CCI ADS Id.

        order.Name = order.CCI_Order_Id__c;
        if(order.Opportunity__c==null)
        {
        //creating a  new opportunity before inserting an order for it
         Opportunity newOp = new Opportunity();
            newOp.AccountId = acc.Id;
            newOp.Name = 'Direct Order for '  +acc.Name +' ' +System.now();
            newOp.Type = 'Proactive';
            newOp.StageName = 'Preparation';
            newOp.Agency__c = fAccount.Account__c;
            if(eOrder!=null)
                newOp.closeDate = eOrder.CreatedDate.Date();
            else
                newOp.closeDate = System.Today();
                newOp.Owners_Department__c = department;
            newOp.CurrencyIsoCode = 'GBP';
          //  newOp.OwnerId=userList[0].id;
            insert newOp;

            order.Opportunity__c = newOp.id;
        }
            order.User__c = userList[0].id;


        // If the SFDC ID is null, the order (and order items) are all new. Just insert them.
        // Otherwise it's an update which may have new, changed as well as deleted items.
        /*
    if(order.Id==null)
      insert order;
    else
      update order;
    */

        // If we run in a mode, where we do not send the SFDC id to ADS,
        // lookup the Order__c based on the ADS OrderId. If we find one,
        // we must update that one; otherwise we insert the new Order__c.

        List < Order > orders = [select id from Order where CCI_Order_Id__c = : order.CCI_Order_Id__c];

        if (orders.size() == 0) {
            System.debug('Order:' + order);
            insert order;
        } else {
            order.Id = orders[0].Id;

            update order;
        }
         
            // Create a map of the order's current items, using the CCI_Order_Item_Id__c as key.

        Map < String, OrderItem > currentOrderItems = new Map < String, OrderItem > ();


        for (OrderItem oi: [select CCI_Order_Item_ID__c from OrderItem where OrderId = : order.Id]) {
            currentOrderItems.put(oi.CCI_Order_Item_ID__c, oi);
        }



        Map < String, OrderItem > orderItemsToBeCreated = new Map < String, OrderItem > ();
        Map < String, OrderItem > orderItemsToBeUpdated = new Map < String, OrderItem > ();
        Map < String, OrderItem > orderItemsToBeDeleted = new Map < String, OrderItem > ();
        List<OpportunityLineItem> oIList = [Select id,Dateflex__c,ServiceDate from OpportunityLineItem where OpportunityId = :order.Opportunity__c];
        Set<String> oppSet = new Set<String>();
        for(OpportunityLineItem ot:oIList){
        oppSet.add(ot.id);
        }
        
        
        Map<Id,String> insertionDatesMap = new Map<Id,String>();
        List<OpportunityLineItem> oppItemsList = new List<OpportunityLineItem>();
       
        for(OpportunityLineItem oi:oIList){
            String date1 = datetime.newInstance(oi.ServiceDate.year(), oi.ServiceDate.month(), oi.ServiceDate.day()).format('yyyy-MM-dd');
            insertionDatesMap.put(oi.id,date1);
         }

        // Of the given order's items, find out which ones we already have in the
        // database and which ones are new.

        for (OrderItem oi: orderItems) {
            productCodeSet.add(oi.Package_Code__c);
            System.debug('Quantity:' + oi.Quantity);
            if (oi.Quantity == 0 || oi.Quantity == null) {
                oi.Quantity = 1;
            }
            if (oi.UnitPrice == null) {
                oi.UnitPrice = 0;
            }
            if (currentOrderItems.containsKey(oi.CCI_Order_Item_ID__c)) {
                orderItemsToBeUpdated.put(oi.CCI_Order_Item_ID__c, oi);
            } else {
                orderItemsToBeCreated.put(oi.CCI_Order_Item_ID__c, oi);
            }
            
           

        }


        System.debug('productCodeSet:' + productCodeSet);

        System.debug('pricebook:' + pricebook);

        List < PricebookEntry > pbeList = [Select ProductCode From PricebookEntry Where PriceBook2Id = : pricebook.Id And ProductCode IN: productCodeSet];

        Map < String, PricebookEntry > pbeMap = new Map < String, PricebookEntry > ();
        for (PricebookEntry p: pbeList) {
            pbeMap.put(p.ProductCode, p);
        }

        // Find out which of the curent items we should delete.

        for (OrderItem oi: currentOrderItems.values()) {
            if (!orderItemsToBeUpdated.containsKey(oi.CCI_Order_Item_ID__c)) {
                orderItemsToBeDeleted.put(oi.CCI_Order_Item_ID__c, oi);
            }
        }

        for (OrderItem oi: orderItemsToBeCreated.values()) {
            // Link order item to order...

            oi.OrderId = order.Id;
            if (!pbeMap.containsKey(oi.Package_Code__c)) {
                return 'Package ' + oi.Package_Code__c + ' does not exist in Glue';
            } else {
                oi.PricebookEntryId = pbeMap.get(oi.Package_Code__c).Id;
            }
            // ...and set the item's name to be the CCI ADS Id.

            // oi.Name = oi.CCI_Order_Item_ID__c;
        }

        // Make sure we maintain SFDC's internal ids on items that are
        // about to be updated...

        for (OrderItem oi: orderItemsToBeUpdated.values()) {
            oi.Id = currentOrderItems.get(oi.CCI_Order_Item_ID__c).Id;
        }
        //..or deleted.

        for (OrderItem oi: orderItemsToBeDeleted.values()) {
            oi.Id = currentOrderItems.get(oi.CCI_Order_Item_ID__c).Id;
        }
        // Do the actual insert, update and delete operations.

        System.debug('orderItemsToBeCreated:' + orderItemsToBeCreated);
        insert orderItemsToBeCreated.values();
        update orderItemsToBeUpdated.values();
        delete orderItemsToBeDeleted.values();
        if(order.Booking_Status__c=='Canceled'){
        order.Status = 'Cancelled';
        update Order;
        }
        else if(orderItems!=null&& orderItems.size()>0){
            order.Status = originalOrderStatus;
            update Order;
        }
        }catch(Exception e){
          errorMsg = 'An exception has occured in upserting order or orderItem';
          if(eOrder==null)
              CreateErroredOrdernItems(errorMsg,eOrderCopy,eOrderItemsCopy);
          return errorMsg;
        }
        String result = 'Processed order with id ' + order.Name;
        if(eOrder==null)
            return result;
        else
            return order.id;
    }

    /**
     * Custom Order__c retrieve used to get SFDC id into ADS.
     **/

    webservice static Order retrieveOrder(String id) {
        List < Order > orders = [select CCI_Order_Id__c, Is_Accepted__c from Order where Id = : id];

        if (orders.size() > 0) return orders[0];

        return null;
    }

    
    //Method to handle any failures in Order or order Item Creation
    
    public static  void CreateErroredOrdernItems(String errorMessage,Order order,List<OrderItem> orderItems){
       System.debug('Entered CreateErroredOrdernItems');
       ErroredOrder__c eOrder = new ErroredOrder__c();
       eOrder.ErrorDesc__c = errorMessage;
       Set<String> nonEditableFields = new Set<String>{'isdeleted','createdbyid','systemmodstamp','createddate','lastvieweddate','lastmodifiedbyid','lastmodifieddate','lastreferenceddate','id','currencyisocode','name'};
       Set<String> fieldsToSkip = new Set<String>{'pricebook2id'};
       try{
       List<ErroredOrderLine__c> eOrderItems = new List<ErroredOrderLine__c>();
       Map <String, Schema.SObjectType > m = Schema.getGlobalDescribe();
       Map <String, Schema.SObjectField > fields=  m.get('Order').getDescribe().fields.getMap();
       Map <String, Schema.SObjectField > orderItemfieldsMap=  m.get('OrderItem').getDescribe().fields.getMap();
       Map <String, Schema.SObjectField > EOrderfieldsMap =  m.get('ErroredOrder__c').getDescribe().fields.getMap();
       Map <String, Schema.SObjectField > EOrderItemfieldsMap =  m.get('ErroredOrderLine__c').getDescribe().fields.getMap();
       Set<String> eOrderFields = EOrderfieldsMap.keySet();
       Set<String> eOrderItemFields = EOrderItemfieldsMap.keySet();
       
       for (string field: fields.keySet()) {
       System.debug('field for order..'+ field);
              if(order.get(field)!=null&& !nonEditableFields.contains(field)&&!fieldsToSkip.contains(field) ){
                   if(eOrderFields.contains(field)){
                       eOrder.put(field,order.get(field)); 
                    }else if(eOrderFields.contains(field+'__c')){
                       eOrder.put(field+'__c',order.get(field)); 
                    }else {
                     System.debug('Fiels does not exist in ErroredOrder..'+ field);
                    }
                }
                
         }
        System.debug('before inserting eorder..'+eOrder);
        insert  eOrder;
        if(orderItems!=null ){
            for(OrderItem oItem: orderItems){
                ErroredOrderLine__c eol = new ErroredOrderLine__c();
                for (string field: orderItemfieldsMap.keySet()) {
                    System.debug('field for orderitem...'+ field);
                  if(oItem.get(field)!=null && !nonEditableFields.contains(field)){
                   if(eOrderItemFields.contains(field)){
                       eol.put(field,oItem.get(field)); 
                    }else if(eOrderItemFields.contains(field+'__c')){
                       eol.put(field+'__c',oItem.get(field)); 
                    }else {
                     System.debug('Fiel does not exist in ErroredOrderLineItem..'+ field);
                    }
                }
                
                }
                eol.ErroredOrder__c = eOrder.id;
                eOrderItems.add(eol);
        
        }
        
          insert eOrderItems;
          }
          List<OrderItem> itemsToBeDeleted = new List<OrderItem>();
          if(order.id!=null){
              for(OrderItem oi:orderItems){
                  if(oi.id!=null)
                      itemsToBeDeleted.add(oi);
              }
          delete itemsToBeDeleted;
          delete order;
          }
        
                
             
             }catch(Exception e){
             System.debug('An exception occured in creating ErroredOrder or ErroredorderItems'+e);
             }
             System.debug('Exiting CreateErroredOrdernItems');
             }
             
             
             
          //web service to be called by a button on ErroredOrder page to replay  reation of Order and Order Line Item   
             
       webService static  String CreateOrdernItemsFromErroredOrder(String erroredOrderId){
           
           System.debug('Entered CreateOrdernItemsFromErroredOrder..'+ erroredOrderId);
           Order order = new order();
           String result;
           Set<String> nonEditableFields = new Set<String>{'isdeleted','createdbyid','systemmodstamp','createddate','lastvieweddate','lastmodifiedbyid','lastmodifieddate','lastreferenceddate','id','currencyisocode','name'};
           try{
               List<OrderItem> orderItems = new List<OrderItem>();
               Map <String, Schema.SObjectType > m = Schema.getGlobalDescribe();
               Map <String, Schema.SObjectField > fields=  m.get('Order').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > orderItemfieldsMap=  m.get('OrderItem').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > EOrderfieldsMap =  m.get('ErroredOrder__c').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > EOrderItemfieldsMap =  m.get('ErroredOrderLine__c').getDescribe().fields.getMap();
               Set<String> orderFields = fields.keySet();
               Set<String> orderItemFields = orderItemfieldsMap.keySet();
               String orderqueryFields = '';
               for(String fieldName : EOrderfieldsMap .keyset()){
                    if(orderqueryFields == null || orderqueryFields == ''){
                        orderqueryFields = fieldName;
                    }else{
                    orderqueryFields = orderqueryFields + ', ' + fieldName;
                  }
               }
            
            String orderQuery = 'select ' + orderqueryFields + ' from ErroredOrder__c where id ='+'\''+erroredOrderId + '\'';
            System.debug('Order Query is..'+ orderQuery);
               
              ErroredOrder__c  erroredOrder = Database.query(orderQuery) ;
              System.debug('ErroredOrder id is..'+ erroredOrder.id);
               
               
               String querySepratedFields = '';
               for(String fieldName : EOrderItemfieldsMap .keyset()){
                    if(querySepratedFields == null || querySepratedFields == ''){
                        querySepratedFields = fieldName;
                    }else{
                    querySepratedFields = querySepratedFields + ', ' + fieldName;
            }
        }
 
            String query = 'select ' + querySepratedFields + ' from ErroredOrderLine__c where ErroredOrder__c = : erroredOrderId';
            System.debug('Order line item query is..'+ query);
            List<ErroredOrderLine__c> erroredItems = Database.query(query);
 
             
               for (string field: EOrderfieldsMap.keySet()) {
                   if(erroredOrder.get(field)!=null && !nonEditableFields.contains(field)){
                       if(orderFields.contains(field)){
                           order.put(field,erroredOrder.get(field)); 
                        }else if(orderFields.contains(field.replace('__c',''))){
                           order.put(field.replace('__c',''),erroredOrder.get(field)); 
                        }else{
                           System.debug('Field does not exist in order ..'+ field);
                        }
                 }
                 }
                
         
                System.debug('before inserting order..'+order);
                           

                if(erroredItems!=null ){
                    for(ErroredOrderLine__c erroredItem: erroredItems){
                        OrderItem oItem = new OrderItem();
                        oItem.Order = order;
                        for(string itemField: EOrderItemfieldsMap.keySet()) {
                            if(erroredItem.get(itemField)!=null && ! nonEditableFields.contains(itemField)){
                               if(orderItemFields.contains(itemField)){
                                   oItem.put(itemField,erroredItem.get(itemField)); 
                              }else if(orderItemFields.contains(itemField.replace('__c',''))){
                                   oItem.put(itemField.replace('__c',''),erroredItem.get(itemField)); 
                              }else{
                                System.debug('Field does not exist in order Item..'+ itemField);
                              }
                            }
                
                        }
               orderItems.add(oItem);
                
        
          }
        System.debug('before calling upsertOrder');
        String outcome = upsertOrder(order,orderItems,erroredOrder);
        if(outcome.startsWith('801L')){
            erroredOrder.order__c = outcome;
            erroredorder.OrderStatus__c = 'Complete';
           result='Success';
            }
           else{
           erroredOrder.errorDesc__c = outcome;
           result = 'Failure';
            }
          }upsert erroredOrder;
          }Catch(Exception e){
              System.debug('An exception occured in creating order or order line item'+ e);
              result='Failure';
          }
          return result;
          }
          
          
        
               
       /*    webService static  String CreateOrdernItemsFromErroredOrderList(ErroredOrder__c erroredOrder1){
           System.debug('input is..'+erroredOrder1);
           String erroredOrderId = erroredOrder1.id;
           System.debug('Entered CreateOrdernItemsFromErroredOrder..'+ erroredOrderId);
           Order order = new order();
           String result;
           Set<String> nonEditableFields = new Set<String>{'isdeleted','createdbyid','systemmodstamp','createddate','lastvieweddate','lastmodifiedbyid','lastmodifieddate','lastreferenceddate','id','currencyisocode','name'};
           try{
               List<OrderItem> orderItems = new List<OrderItem>();
               Map <String, Schema.SObjectType > m = Schema.getGlobalDescribe();
               Map <String, Schema.SObjectField > fields=  m.get('Order').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > orderItemfieldsMap=  m.get('OrderItem').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > EOrderfieldsMap =  m.get('ErroredOrder__c').getDescribe().fields.getMap();
               Map <String, Schema.SObjectField > EOrderItemfieldsMap =  m.get('ErroredOrderLine__c').getDescribe().fields.getMap();
               Set<String> orderFields = fields.keySet();
               Set<String> orderItemFields = orderItemfieldsMap.keySet();
               String orderqueryFields = '';
               for(String fieldName : EOrderfieldsMap .keyset()){
                    if(orderqueryFields == null || orderqueryFields == ''){
                        orderqueryFields = fieldName;
                    }else{
                    orderqueryFields = orderqueryFields + ', ' + fieldName;
                  }
               }
            
            String orderQuery = 'select ' + orderqueryFields + ' from ErroredOrder__c where id = : erroredOrderId';
            System.debug('Order Query is..'+ orderQuery);
               
              ErroredOrder__c  erroredOrder = Database.query(orderQuery) ;
              System.debug('ErroredOrder id is..'+ erroredOrder.id);
               
               
               String querySepratedFields = '';
               for(String fieldName : EOrderItemfieldsMap .keyset()){
                    if(querySepratedFields == null || querySepratedFields == ''){
                        querySepratedFields = fieldName;
                    }else{
                    querySepratedFields = querySepratedFields + ', ' + fieldName;
            }
        }
 
            String query = 'select ' + querySepratedFields + ' from ErroredOrderLine__c where ErroredOrder__c = : erroredOrderId';
            System.debug('Order line item query is..'+ query);
            List<ErroredOrderLine__c> erroredItems = Database.query(query);
 
             
               for (string field: EOrderfieldsMap.keySet()) {
                   if(erroredOrder.get(field)!=null && !nonEditableFields.contains(field)){
                       if(orderFields.contains(field)){
                           order.put(field,erroredOrder.get(field)); 
                        }else if(orderFields.contains(field.replace('__c',''))){
                           order.put(field.replace('__c',''),erroredOrder.get(field)); 
                        }else{
                           System.debug('Field does not exist in order ..'+ field);
                        }
                 }
                 }
                
         
                System.debug('before inserting order..'+order);
                           

                if(erroredItems!=null ){
                    for(ErroredOrderLine__c erroredItem: erroredItems){
                        OrderItem oItem = new OrderItem();
                        oItem.Order = order;
                        for(string itemField: EOrderItemfieldsMap.keySet()) {
                            if(erroredItem.get(itemField)!=null && ! nonEditableFields.contains(itemField)){
                               if(orderItemFields.contains(itemField)){
                                   oItem.put(itemField,erroredItem.get(itemField)); 
                              }else if(orderItemFields.contains(itemField.replace('__c',''))){
                                   oItem.put(itemField.replace('__c',''),erroredItem.get(itemField)); 
                              }else{
                                System.debug('Field does not exist in order Item..'+ itemField);
                              }
                            }
                
                        }
               orderItems.add(oItem);
                
        
          }
        System.debug('before calling upsertOrder');
        String outcome = upsertOrder(order,orderItems,erroredOrder);
        if(outcome.startsWith('801L')){
            erroredOrder.order__c = outcome;
            erroredorder.OrderStatus__c = 'Complete';
           result='Success';
            }
           else{
           erroredOrder.errorDesc__c = outcome;
           result = 'Failure';
            }
          }upsert erroredOrder;
          }Catch(Exception e){
              System.debug('An exception occured in creating order or order line item'+ e);
              result='Failure';
          }
          return result;
          }*/
          
          
        
            
             
            
             
             
             
             
             
             
             
             
}