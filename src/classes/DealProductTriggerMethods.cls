public with sharing class DealProductTriggerMethods 
{
    public static void setProductNames(List<Deal_Product__c> dealProductList)
    {
            List<Id> oppIds = new List<Id>();
            
            for( Deal_Product__c deal : dealProductList ) 
            {
                oppIds.add( deal.Opportunity__c );
            }
            
            List<Opportunity> opps = [SELECT
                                        Deal_Products__c
                                        From Opportunity
                                        Where Id IN :oppIds];
            
            List<Deal_Product__c> deals = [SELECT
            								Name,
                                            Opportunity__c,
                                            Product_Cap__c,
                                            Product_price__c, 
                                            Product_media_surcharge__c,
                                            Product_description__c,
                                            Product_supplier_rate__c,
                                            Product_supplier_unredeemed_rate__c, 
                                            Product_usual_selling_price__c,
                                            Product_wowcher_commission__c, 
                                            Discount_percentage__c 
                                            From Deal_Product__c
                                            Where Opportunity__c IN :opps];
            
            Map<Id,List<Deal_Product__c>> dealsMap = new Map<Id,List<Deal_Product__c>>();
            
            for( Deal_Product__c deal : deals ) 
            {
                List<Deal_Product__c> curDeals = dealsMap.get( deal.Opportunity__c );
                if( curDeals == null ) 
                {
                    curDeals = new List<Deal_Product__c>();
                    
                    dealsMap.put(deal.Opportunity__c, curDeals);
                }
                
                curDeals.add(deal);
            }
            
            for( Opportunity opp : opps ) 
            {
                opp.Deal_Products__c = '';
                if(dealsMap.containsKey(opp.Id))
                {
                
	                List<Deal_Product__c> curDeals = dealsMap.get(opp.Id);
	                
	                for( Deal_Product__c deal : curDeals )
	                {
	                    
	                    String prodMediaSurcharge;
	                    String prodSupplierUnredeemedRate;
	                    
	                  if (deal.Product_media_surcharge__c != Null)
	                  {
	                    prodMediaSurcharge=', Media Surcharge: ' + deal.Product_media_surcharge__c;
	                  }
	                  else
	                  {
	                    prodMediaSurcharge='';
	                  }
	               
	                  
	                  if (deal.Product_supplier_unredeemed_rate__c != Null)
	                  {
	                    prodSupplierUnredeemedRate=', Supplier Unredeemed Rate: ' + deal.Product_supplier_unredeemed_rate__c +'%';
	                  }
	                  else
	                  {
	                    prodSupplierUnredeemedRate='';
	                  }                 
	                 
	                     opp.Deal_Products__c += ( 'Product Title: ' + deal.Name + ', Deal Price: £' + deal.Product_price__c + ', Usual Selling Price: £' + deal.product_usual_selling_price__c +', Discount Percentage: ' + deal.discount_percentage__c +'%'+', Deal Cap: ' + deal.Product_Cap__c +', Supplier Percentage Rate: ' + deal.Product_supplier_rate__c +'%'+'\r\n\r\n\r\n');
	                    //prodMediaSurcharge='';
	                    //prodSupplierUnredeemedRate='';
	                  
	                }
                }
            }
            
            update opps;
        
    }
}