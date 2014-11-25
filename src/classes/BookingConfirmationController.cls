public with sharing class BookingConfirmationController {
    
    public List<OpportunityLineItem> sOppLineItems {get; set;}
    public Id oppID {get; set;}
    public Boolean showPrice {get; set;}
    public Boolean lineDesc {get; set;}
    
   	public Boolean lc {get;set;}
    
    public List<OpportunityLineItem> getOppLineItems()
    {

        sOppLineItems   =   [Select Opportunity.Agency__r.name, Opportunity.Account.Name, ServiceDate, 
                                                 Brand__c, Size__c, Color_Specification__c, Region__c,
                                                 Position__c, TotalPrice, URN__c, 
                                                 Date_Booked__c,
                                                 Product_Name__c,
                                                 Opportunity.Amount,
                                                 Description
                              From OpportunityLineItem
                              Where OpportunityID = : oppID
                              Order by ServiceDate asc];       
        
        return sOppLineItems;
    }
    
    public Decimal getTotalPrice()
    {
    	return sOppLineItems.size()>0?sOppLineItems[0].Opportunity.Amount:0;
    }
    
/*    public String getLCimageurl () 
    {  
    	document doc = [  
    						Select
    							Id
    						From Document
    						Where Name = 'London Classified Footer Logo'
						];
    	string imageid = doc.id; 
    	imageid = imageid.substring(0,15);
    	System.debug('LC: '+imageid);
    	return '/servlet/servlet.FileDownload?file=' + imageid;
	}

    public String getNCimageurl () 
    {  
    	document doc = [  
    						Select
    							Id
    						From Document
    						Where Name = 'NorthCliffe Footer Logo'
						];
    	string imageid = doc.id; 
    	imageid = imageid.substring(0,15);
    	System.debug('NC: '+imageid);
    	return '/servlet/servlet.FileDownload?file=' + imageid;
	}*/
    
    @isTest   
    private static void testBookingConfirmationController()
    {
       BookingConfirmationController cBookingController    =    new BookingConfirmationController();
       cBookingController.getOppLineItems();  
       System.assert(cBookingController.getTotalPrice()>=0);     
    }

}