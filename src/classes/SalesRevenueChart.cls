public with sharing class SalesRevenueChart
{
    public Account acc;
    
    public String retUrl = apexpages.currentpage().getParameters().get('retURL');
    
    
 /*   public static Boolean mailClassifiedRendered
    {
        get
        {
            if(mailClassifiedRendered==null)
            {
                return false;
            }
            else
            {
                return mailClassifiedRendered;
            }
        }
        set;
        } 
    public static Boolean mailDisplayRendered
    {
        get
        {
            if(mailDisplayRendered==null)
            {
                return false;
            }   
            else
            {
                return mailDisplayRendered;
            }       
        }
    set;
    } 
    public static Boolean metroClassifiedRendered
    {
        get
        {
            if(metroClassifiedRendered==null)
            {
                return false;
            }   
            else
            {
                return metroClassifiedRendered;
            }       
        }
    set;
    } 
    public static Boolean metroDisplayRendered
    {
        get
        {
            if(metroDisplayRendered==null)
            {
                return false;
            }   
            else
            {
                return metroDisplayRendered;
            }       
        }
    set;
    }   */     
    
    public static Boolean mailClassifiedRendered{get;set;} 
    public static Boolean mailDisplayRendered{get;set;} 
    public static Boolean metroClassifiedRendered{get;set;} 
    public static Boolean metroDisplayRendered{get;set;} 
    public static Boolean networkRendered{get;set;} 
    public static Boolean mailOnlineRendered{get;set;} 

//    public static Boolean mailPublisherRendered{get;set;} 
//    public static Boolean metroPublisherRendered{get;set;} 

    public static Id publicationGroupReportId
    { 
        get
        {
            if(publicationGroupReportId==null)
            {
                try
                {
                    publicationGroupReportId = [Select
                                                    Id
                                                From Report
                                                Where Name = 'PublicationGroupReport'
                                                ].Id;
                }
                catch(QueryException qe0)
                {
                
                }
            }
            return publicationGroupReportId;
        }
         set;
    }
    
    public static String fieldsToDisplay 
    { 
        get
        {
            if(fieldsToDisplay==null)
            {
                return '';
            }
            else
            {
                return fieldsToDisplay;
            }
        } 
        set;
    }
    public static String titlesToDisplay { get; set;}
    
    public static Id accountId
    { 
        get
        {
            if(accountId==null)
            {
                accountId = Apexpages.currentPage().getParameters().get('Id');
            }
            return accountId;
        }
         set;
    }

    private static Map<String, String> accountNameMap { get; set;}
    
    public static String accountNames { get; set;}
 /*   { 
    	get
    	{
    		if(accountNames==null||accountNames=='')
    		{
	    		for(String a:accountNameMap.keySet())
	    		{
	    			if(accountNames!='')
	    			{
	    				accountNames+=',';
	    			}
	    			accountNames+=a;
	    		}    			
    		}
    		return accountNames;
    	} 
    	set;
    }*/
    
    public static Set<Id> accountSet
    {
    	get
    	{
    		if(accountSet==null||accountSet.size()==0)
    		{
    			accountSet = new Set<Id>();
    			accountNameMap = new Map<String,String>();
    			accountNames='';
    			String currentId;
    			List<Account> al            = new List<Account>{};
        		Set<ID> currentParent      = new Set <ID>();
        		//Set<ID> accountIdSet      = new Set <ID>();
		        Integer count               = 0;
        		Integer level               = 0;
        		Boolean endOfStructure      = false;
        		currentParent.add(accountId);
		        //Loop though all children
       			while ( !endOfStructure )
       			{

		            if( level == 0 )
		            {
		                //Change below     
		                al = [ SELECT a.Type, a.ParentId, a.OwnerId, a.Name, a.Industry
		                		FROM Account a
		                		WHERE a.id IN : CurrentParent
		                		ORDER BY a.Name ];
		            } 
		            else 
		            {
		                //Change below      
		                al = [ SELECT a.Type, a.ParentId, a.OwnerId, a.Name, a.Industry
		                		FROM Account a
		                		WHERE a.ParentID IN : CurrentParent
		                		ORDER BY a.Name ];
		            }
		
		            if( al.size() == 0 )
		            {
		                endOfStructure = true;
		            }
		            else
		            {
		                currentParent.clear();
		                for ( Integer i = 0 ; i < al.size(); i++ )
		                {
		                    //Change below
		                    Account a = al[i];
		                    currentParent.add( a.id );
		                    accountSet.add(a.id);
		                    accountNameMap.put(a.Name,a.Name);
		                 }
		                 level++;
		            }
		        }

				System.debug('accountSet:'+accountSet);    	
		
    		}
    		
    		for(String a:accountNameMap.keySet())
    		{
    			if(accountNames!='')
    			{
    				accountNames+=',';
    			}
    			accountNames+=a;
    		}
    		System.debug('accountNameMap:'+accountNameMap.keyset());
    		System.debug('accountNames:'+accountNames);
            return accountSet;
    	}
    	set;
    }

    public static Account accountDetail
    { 
        get
        {
            /*if(accountName==null)
            {
                accountName = Apexpages.currentPage().getParameters().get('Name');
            }
            System.debug('accountName:'+accountName);*/
            if(accountDetail==null)
            {
                accountDetail = [Select Name, type, Record_Type__c
                                From Account
                                Where Id = :accountId];
            }
            return accountDetail;
        }
         set;
    }
    
    // Return a list of data points for a chart 
   
    public List<SalesRevenue> getData() 
    {
        return SalesRevenueChart.getChartData();
    }
    
    
    public SalesRevenueChart.SalesRevenueChart()
    {
        // accountId = Apexpages.currentPage().getParameters().get('id');
        mailClassifiedRendered=false;
        mailDisplayRendered=false;
        metroClassifiedRendered=false;
        metroDisplayRendered=false;
        Set<Id> a = accountSet;
    }
        
    public SalesRevenueChart.SalesRevenueChart(ApexPages.StandardController controller)
    {
        this.acc= (Account)controller.getRecord();
        Set<Id> a = accountSet;
    }
    
    
    public static List<SalesRevenueChart.SalesRevenue> getChartData() 
    {
        // Id accountId = Apexpages.currentPage().getParameters().get('id');
        // List<SalesRevenue__c> revenueList = new List<SalesRevenue__c>();
        List<SalesRevenueChart.SalesRevenue> revenueList = new List<SalesRevenue>();
        List<AggregateResult> revenueAggr =  
                                        [
                                            Select 
                                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                                CALENDAR_YEAR(Period_End_Date__c) year,
                                                SUM(Revenue_Amount__c)
                                            From SalesRevenue__c
                                            Where AdvertiserID__c IN :accountSet // = :accountId
                                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                                        ];
                                        
        For(AggregateResult ar:revenueAggr)
        {
            System.debug('Period:'+(Integer)ar.get('period'));
            System.debug('Period:'+(Integer)ar.get('year'));
            System.debug('Revenue:'+(Decimal)ar.get('expr0'));
            revenueList.add(new SalesRevenueChart.SalesRevenue((String)('Q '+ar.get('period')+'/'+ar.get('year')), (Decimal)ar.get('expr0')));
        }
        
        return revenueList;
    }

    public static List<SalesRevenueChart.PublicationSalesRevenue> getPublicationGroupChartData() 
    {
       // Id accountId = Apexpages.currentPage().getParameters().get('id');
        // List<SalesRevenue__c> revenueList = new List<SalesRevenue__c>();
        
        /*Decimal TotaldmClassified=0;
        Decimal TotalesDisplay=0;
        Decimal TotalmailPlus=0;*/
        // Decimal TotaltheDailyMail=0;
        // Decimal TotaltheMailOnSunday=0;         
        
        Decimal TotalesClassified=0;
        Decimal TotalmetroClassified=0;
        Decimal TotalmetroDisplay=0;
        Decimal TotalmailClassified=0; 
        Decimal TotalmailDisplay=0;           
        Decimal TotalNetwork=0;
        Decimal TotalMailOnline=0;
        
        // Decimal TotalMailPublisher=0;
        // Decimal TotalMetroPublisher=0;
        /*Boolean mailClassifiedRendered=false; 
        Boolean mailDisplayRendered=false;  
        Boolean metroClassifiedRendered=false; 
        Boolean metroDisplayRendered=false;           
        Boolean networkRendered=false;
        Boolean mailPublisherRendered=false;
        Boolean metroPublisherRendered=false;*/
       
        Map<String, SalesRevenueChart.PublicationSalesRevenue> revenueMap = new Map<String, SalesRevenueChart.PublicationSalesRevenue>();
        List<AggregateResult> revenueAggr =  new List<AggregateResult>();
        
        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where Invoice_AgencyID__c  IN :accountSet 
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                           ];           
        }
        else //if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where ( BrandID__c  IN :accountSet 
                                  OR AdvertiserID__c  IN :accountSet)
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                        ];
        }
        /*else
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where AdvertiserID__c  IN :accountSet //= :accountId
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c), Department__c
                        ];
        }*/
        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            System.debug('Period:'+(Integer)ar.get('period'));
            System.debug('Year:'+(Integer)ar.get('year'));
            System.debug('Revenue:'+(Decimal)ar.get('expr0'));
            System.debug('PublicationGroup:'+(String)(ar.get('dept')));
            Integer year=(Integer)ar.get('year')==null?0:(Integer)ar.get('year');
            Integer quarter=(Integer)ar.get('period')==null?0:(Integer)ar.get('period');
            // String period=(String)((Integer)ar.get('period')+' Q / '+(Integer)ar.get('period'));
            String period=(String)('Q '+(quarter==4?1:quarter+1)+' /'+(quarter==4?year+1:year));
            String publicationGroup = (String)(ar.get('dept'));
            Decimal booked = (Decimal)ar.get('expr0');
            booked = booked==null?0:booked;
            
            /*Decimal dmClassified;
            Decimal esDisplay;
            Decimal mailPlus;*/
            //Decimal theDailyMail;
            //Decimal theMailOnSunday;             
            
            Decimal esClassified;
            Decimal metroClassified=0;
            Decimal metroDisplay=0;
            Decimal mailClassified=0; 
            Decimal mailDisplay=0;           
            Decimal network=0;
            Decimal mailOnline=0;
            
            // Decimal mailPublisher=0;
            //Decimal metroPublisher=0;
            
            
            if(revenueMap.containsKey(period))
            {
                SalesRevenueChart.PublicationSalesRevenue salesRevenue = revenueMap.get(period);
                /*if(publicationGroup=='DM Classified')
                {
                    salesRevenue.dmClassified += booked;
                    TotaldmClassified += booked;
                }
                else if(publicationGroup=='ES Display')
                {
                    salesRevenue.esDisplay += booked;
                    TotalesDisplay += booked;
                }
                else if(publicationGroup=='Mail Plus')
                {
                    salesRevenue.mailPlus += booked;
                    TotalmailPlus += booked;
                }
                else */
                
                if(publicationGroup=='ES Classified')
                {
                    salesRevenue.esClassified += booked;
                    TotalesClassified += booked;
                }
                else if(publicationGroup=='Metro Classified')
                {
                    salesRevenue.metroClassified += booked;
                    TotalmetroClassified += booked;
                }
                else if(publicationGroup=='Metro Display')
                {
                    salesRevenue.metroDisplay += booked;
                    TotalmetroDisplay += booked;
                }
                /*else if(publicationGroup=='The Daily Mail')
                {
                    salesRevenue.theDailyMail += booked;
                    TotaltheDailyMail += booked;
                }
                else if(publicationGroup=='The Mail On Sunday')
                {
                    salesRevenue.theMailOnSunday += booked;
                    TotaltheMailOnSunday += booked;
                }   */            
                else if(publicationGroup=='Mail Classified')
                {
                    salesRevenue.mailClassified += booked;
                    TotalmailClassified += booked;
                }                 
                else if(publicationGroup=='Mail Display')
                {
                    salesRevenue.mailDisplay += booked;
                    TotalmailDisplay += booked;
                } 
                else if(publicationGroup=='ANy Network'||publicationGroup=='AN&Y Network')
                {
                    salesRevenue.network += booked;
                    TotalNetwork += booked;
                }
                else if(publicationGroup=='Mail Online')
                {
                    salesRevenue.mailOnline += booked;
                    TotalMailOnline += booked;
                }
                /*else if(publicationGroup=='Mail Publisher')
                {
                    salesRevenue.mailPublisher += booked;
                    TotalMailPublisher += booked;
                }                 
                else if(publicationGroup=='Metro Publisher')
                {
                    salesRevenue.metroPublisher += booked;
                    TotalMetroPublisher += booked;
                } */
                revenueMap.put(period,salesRevenue);
                 
            }
            else
            {
                i+=1;
                /*if(publicationGroup=='DM Classified')
                {
                    dmClassified = booked;
                    TotaldmClassified += booked;
                }
                else if(publicationGroup=='ES Display')
                {
                    esDisplay = booked;
                    TotalesDisplay =+ booked;
                }
                else if(publicationGroup=='Mail Plus')
                {
                    mailPlus = booked;
                    TotalmailPlus += booked;
                }
                else*/ 
                if(publicationGroup=='ES Classified')
                {
                    esClassified = booked;
                    TotalesClassified += booked;
                }
                else if(publicationGroup=='Metro Classified')
                {
                    metroClassified = booked;
                    TotalmetroClassified += booked;
                }
                else if(publicationGroup=='Metro Display')
                {
                    metroDisplay = booked;
                    TotalmetroDisplay += booked;
                }
                /*else if(publicationGroup=='The Daily Mail')
                {
                    theDailyMail = booked;
                    TotaltheDailyMail += booked;
                }
                else if(publicationGroup=='The Mail On Sunday')
                {
                    theMailOnSunday = booked;
                    TotaltheMailOnSunday += booked;
                }  */             
                else if(publicationGroup=='Mail Classified')
                {
                    mailClassified = booked;
                    TotalmailClassified += booked;
                }  
                else if(publicationGroup=='Mail Display')
                {
                    mailDisplay = booked;
                    TotalmailDisplay += booked;
                }                
                else if(publicationGroup=='ANy Network'||publicationGroup=='AN&Y Network')
                {
                    network = booked;
                    TotalNetwork += booked;
                } 
                else if(publicationGroup=='Mail Online')
                {
                    mailOnline = booked;
                    TotalMailOnline += booked;
                }   
                /*else if(publicationGroup=='Mail Publisher')
                {
                    mailPublisher = booked;
                    TotalMailPublisher += booked;
                }
                else if(publicationGroup=='Metro Publisher')
                {
                    metroPublisher = booked;
                    TotalMetroPublisher += booked;
                }*/               
                // revenueMap.put(period, new SalesRevenueChart.PublicationSalesRevenue(period, i, dmClassified==null?0:dmClassified, esClassified==null?0:esClassified, esDisplay==null?0:esDisplay, mailPlus==null?0:mailPlus, metroClassified==null?0:metroClassified, metroDisplay==null?0:metroDisplay, theDailyMail==null?0:theDailyMail, theMailOnSunday==null?0:theMailOnSunday, mailClassified==null?0:mailClassified, mailDisplay==null?0:mailDisplay));
                //revenueMap.put(period, new SalesRevenueChart.PublicationSalesRevenue(period, i, metroClassified==null?0:metroClassified, metroDisplay==null?0:metroDisplay, mailClassified==null?0:mailClassified, mailDisplay==null?0:mailDisplay, network==null?0:network, mailPublisher==null?0:mailPublisher, metroPublisher==null?0:metroPublisher));
                revenueMap.put(period, new SalesRevenueChart.PublicationSalesRevenue(period, i, metroClassified==null?0:metroClassified, metroDisplay==null?0:metroDisplay, mailClassified==null?0:mailClassified, mailDisplay==null?0:mailDisplay, network==null?0:network, mailOnline==null?0:mailOnline, esClassified==null?0:esClassified));
            }
            // revenueList.add(new SalesRevenueChart.PublicationSalesRevenue((String)(ar.get('Publication_Group__c')),'Q '+(String)(ar.get('period')+'/'+ar.get('year')), (Decimal)ar.get('expr0')));
        }
        
        // DM Classified, Mail Plus, Metro Classified, Metro Display, The Daily Mail, The Mail On Sunday, Mail Classified, Mail Display
        
        /*if(TotaldmClassified!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay='dmClassified,';
            titlesToDisplay='DM Classified,';
        }
        else
        if(TotalmailPlus!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='mailPlus,';
            titlesToDisplay+='Mail Plus,';
        }        
        else*/
        if(TotalmetroClassified!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='metroClassified,';
            titlesToDisplay+='Metro Classified,';
            metroClassifiedRendered=true;
        } 
        if(TotalmetroDisplay!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='metroDisplay,';
            titlesToDisplay+='Metro Display,';
            metroDisplayRendered=true;
        }
        /*else
        if(TotaltheDailyMail!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='theDailyMail,';
            titlesToDisplay+='The Daily Mail,';
        }
        else
        if(TotaltheMailOnSunday!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='theMailOnSunday,';
            titlesToDisplay+='The Mail On Sunday,';
        }*/
        if(TotalmailClassified!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='mailClassified,';
            titlesToDisplay+='Mail Classified,';
            mailClassifiedRendered=true;
        }
        if(TotalmailDisplay!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='mailDisplay,';
            titlesToDisplay+='Mail Display,';
            mailDisplayRendered=true;
        }

        if(TotalNetwork!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='network,';
            titlesToDisplay+='Network,';
            networkRendered=true;
        }  
        if(TotalMailOnline!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='mailOnline,';
            titlesToDisplay+='Mail Online,';
            mailOnlineRendered=true;
        } 
        /*if(TotalMailPublisher!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='mailPublisher,';
            titlesToDisplay+='Mail Publisher,';
            mailPublisherRendered=true;
        }         
        if(TotalMetroPublisher!=0)
        {
            // dmClassified,mailPlus,metroClassified,metroDisplay,theDailyMail,theMailOnSunday,mailClassified,mailDisplay
            fieldsToDisplay+='metroPublisher';
            titlesToDisplay+='Metro Publisher';
            metroPublisherRendered=true;
        }  */

        System.debug('TotalmetroClassified:'+TotalmetroClassified);
        System.debug('TotalmetroDisplay:'+TotalmetroDisplay);
        System.debug('TotalmailClassified:'+TotalmailClassified);
        System.debug('TotalmailDisplay:'+TotalmailDisplay);
        
        System.debug('mailDisplayRendered:'+mailDisplayRendered);
        System.debug('mailClassifiedRendered:'+mailClassifiedRendered);
        System.debug('metroDisplayRendered:'+metroDisplayRendered);
        System.debug('metroClassifiedRendered:'+metroClassifiedRendered);
        
        if(fieldsToDisplay.right(1)==',')
        {
            fieldsToDisplay=fieldsToDisplay.substringBeforeLast(',');
        }
                    
        System.debug('revenueMap:'+revenueMap);
        System.debug('fieldsToDisplay:'+fieldsToDisplay);
        List<Integer> indexList = new List<Integer>();
        Map<Integer, SalesRevenueChart.PublicationSalesRevenue> revenueIndexMap = new Map<Integer, SalesRevenueChart.PublicationSalesRevenue>();
        for(SalesRevenueChart.PublicationSalesRevenue r:revenueMap.Values())
        {
            indexList.add(r.index);
            revenueIndexMap.put(r.index, r);
        }
        indexList.sort();
        List<SalesRevenueChart.PublicationSalesRevenue> revenueList = new List<SalesRevenueChart.PublicationSalesRevenue>();
        for(Integer ind:indexList)
        {
            revenueList.add(revenueIndexMap.get(ind));
        }
        // return revenueMap.Values();
        return revenueList;
    }
    
    public static List<SalesRevenueChart.SalesRevenueByQtr> getRevenueByQtr() 
    {
        // Id accountId = Apexpages.currentPage().getParameters().get('id');
        // List<SalesRevenue__c> revenueList = new List<SalesRevenue__c>();
       
        Map<Integer, SalesRevenueChart.SalesRevenueByQtr> revenueMap = new Map<Integer, SalesRevenueChart.SalesRevenueByQtr>();
        List<AggregateResult> revenueAggr = new List<AggregateResult>();                                      
                                        
        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                            Select
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where Invoice_AgencyID__c  IN :accountSet // = :accountId
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                         ];
        }
        else if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                            Select
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where ( BrandID__c  IN :accountSet //= :accountId
                                 OR AdvertiserID__c  IN :accountSet) //= :accountId)
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                         ];         
        }
        else
        {
            revenueAggr = [
                            Select
                                CALENDAR_QUARTER(Period_End_Date__c) period,
                                CALENDAR_YEAR(Period_End_Date__c) year,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where AdvertiserID__c  IN :accountSet // = :accountId
                            Group By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                            Order By CALENDAR_YEAR(Period_End_Date__c), CALENDAR_QUARTER(Period_End_Date__c)
                         ];             
        }
        // Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            System.debug('Period:'+(Integer)ar.get('period'));
            System.debug('Period:'+(Integer)ar.get('year'));
            System.debug('Revenue:'+(Decimal)ar.get('expr0'));
            Integer year=(Integer)ar.get('year')==null?0:(Integer)ar.get('year');
            Integer quarter=(Integer)ar.get('period')==null?0:(Integer)ar.get('period');

            Integer period=(quarter==4?1:quarter+1);
            Decimal booked = (Decimal)ar.get('expr0');
            
            Decimal q1;
            Decimal q2;
            Decimal q3;
            Decimal q4;
            
            year=quarter==4?year+1:year;
            
            if(revenueMap.containsKey(year))
            {
                SalesRevenueChart.SalesRevenueByQtr salesRevenue = revenueMap.get(year);
                if(period==1)
                {
                    salesRevenue.q1 += booked;
                }
                else if(period==2)
                {
                    salesRevenue.q2 += booked;
                }
                else if(period==3)
                {
                    salesRevenue.q3 += booked;
                }
                else if(period==4)
                {
                    salesRevenue.q4 += booked;
                }               
                
                revenueMap.put(year,salesRevenue);
                 
            }
            else
            {
                // i+=1;
                if(period==1)
                {
                    q1 = booked;
                }
                else if(period==2)
                {
                    q2 = booked;
                }
                else if(period==3)
                {
                    q3 = booked;
                }
                else if(period==4)
                {
                    q4 = booked;
                }

                revenueMap.put(year, new SalesRevenueChart.SalesRevenueByQtr(year, q1==null?0:q1, q2==null?0:q2, q3==null?0:q3, q4==null?0:q4));
            }
            // revenueList.add(new SalesRevenueChart.PublicationSalesRevenue((String)(ar.get('Publication_Group__c')),'Q '+(String)(ar.get('period')+'/'+ar.get('year')), (Decimal)ar.get('expr0')));
        }
        
        System.debug('revenueMap:'+revenueMap);
       /* List<Integer> indexList = new List<Integer>();
        Map<Integer, SalesRevenueChart.SalesRevenueByQtr> revenueIndexMap = new Map<Integer, SalesRevenueChart.SalesRevenueByQtr>();
        for(SalesRevenueChart.SalesRevenueByQtr r:revenueMap.Values())
        {
            indexList.add(r.index);
            revenueIndexMap.put(r.index, r);
        }
        indexList.sort();
        List<SalesRevenueChart.SalesRevenueByQtr> revenueList = new List<SalesRevenueChart.SalesRevenueByQtr>();
        for(Integer ind:indexList)
        {
            revenueList.add(revenueIndexMap.get(ind));
        }*/
        return revenueMap.Values();
        // return revenueList;
    }

    public static List<SalesRevenueChart.SalesRevenueByYearTitle> getRevenueByYearTitle()
    {
        // Id accountId = Apexpages.currentPage().getParameters().get('id');
       
        List<SalesRevenueChart.SalesRevenueByYearTitle> revenueList = new List<SalesRevenueChart.SalesRevenueByYearTitle>();
        Integer currYear = Datetime.now().year();
        System.debug('Year:'+currYear);
        List<AggregateResult> revenueAggr =  new List<AggregateResult>();

        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where Invoice_AgencyID__c  IN :accountSet //= :accountId
                            And   ((CALENDAR_YEAR(Period_End_Date__c) = :currYear-1 And CALENDAR_QUARTER(Period_End_Date__c) = 4)
                            Or   (CALENDAR_YEAR(Period_End_Date__c) = :currYear And CALENDAR_QUARTER(Period_End_Date__c) IN (1,2,3)))
                            Group By Department__c
                            Order By Department__c
                         ];
        }
        else if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where ( BrandID__c  IN :accountSet //= :accountId
                                 OR AdvertiserID__c  IN :accountSet) //= :accountId)
                            And   ((CALENDAR_YEAR(Period_End_Date__c) = :currYear-1 And CALENDAR_QUARTER(Period_End_Date__c) = 4)
                            Or   (CALENDAR_YEAR(Period_End_Date__c) = :currYear And CALENDAR_QUARTER(Period_End_Date__c) IN (1,2,3)))
                            Group By Department__c
                            Order By Department__c
                         ];         
        }
        else
        {
            revenueAggr = [
                            Select 
                                Department__c dept,
                                SUM(Revenue_Amount__c)
                            From SalesRevenue__c
                            Where AdvertiserID__c  IN :accountSet // = :accountId
                            And   ((CALENDAR_YEAR(Period_End_Date__c) = :currYear-1 And CALENDAR_QUARTER(Period_End_Date__c) = 4)
                            Or   (CALENDAR_YEAR(Period_End_Date__c) = :currYear And CALENDAR_QUARTER(Period_End_Date__c) IN (1,2,3)))
                            Group By Department__c
                            Order By Department__c
                         ];             
        }
        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            String publicationGroup = (String)ar.get('dept');
            Decimal booked = (Decimal)ar.get('expr0');
            revenueList.add(new SalesRevenueChart.SalesRevenueByYearTitle(publicationGroup, booked));
        }    
        System.debug('revenueList:'+revenueList);
        return revenueList;
    }

    public static List<SalesRevenueChart.SalesRevenueByYearTitle> getRevenueByYearTitle(String period)
    {
        // Id accountId = Apexpages.currentPage().getParameters().get('id');
       
        List<SalesRevenueChart.SalesRevenueByYearTitle> revenueList = new List<SalesRevenueChart.SalesRevenueByYearTitle>();
        Integer currYear = Datetime.now().year();
        Integer yearToRun;
        Integer quarterToRun;
        Integer currentMonth = date.Today().month();
        
        if(period=='Last')
        {
            if(currentMonth==1||currentMonth==2||currentMonth==3)
            {
                yearToRun=currYear-1;
                quarterToRun=4;
            }
            
        }
        else if(period=='Now')
        {
            yearToRun=currYear;
            quarterToRun=(currentMonth==1||currentMonth==2||currentMonth==3)?1:(currentMonth==4||currentMonth==5||currentMonth==6)?2:(currentMonth==7||currentMonth==8||currentMonth==9)?3:4;           
        }
        else if(period=='Next')
        {
            if(currentMonth==10||currentMonth==11||currentMonth==12)
            {
                yearToRun=currYear+1;
                quarterToRun=1;  
            }
            else
            {
                yearToRun=currYear;
                
            }           
        }
        System.debug('Year:'+currYear);
        List<AggregateResult> revenueAggr =  
                                        [
                                            Select 
                                                Department__c dept,
                                                SUM(Revenue_Amount__c)
                                            From SalesRevenue__c
                                            Where AdvertiserID__c  IN :accountSet //= :accountId
                                            And   CALENDAR_YEAR(Period_End_Date__c) = :yearToRun 
                                            And   CALENDAR_QUARTER(Period_End_Date__c) = :quarterToRun
                                            Group By Department__c
                                            Order By Department__c
                                        ];
        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            String publicationGroup = (String)ar.get('dept');
            Decimal booked = (Decimal)ar.get('expr0');
            revenueList.add(new SalesRevenueChart.SalesRevenueByYearTitle(publicationGroup, booked));
        }    
        System.debug('revenueList:'+revenueList);
        return revenueList;
    }
    
    public static List<SalesRevenueChart.SalesRevenueByYearTitle> getRevenueLastQuarter()
    {  
        List<SalesRevenueChart.SalesRevenueByYearTitle> revenueList = new List<SalesRevenueChart.SalesRevenueByYearTitle>();

        List<AggregateResult> revenueAggr = new List<AggregateResult>();
        
        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where Invoice_AgencyID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = LAST_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];
        }
        else if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where ( BrandID__c  IN :accountSet // = :accountId
                                     OR AdvertiserID__c  IN :accountSet) // = :accountId)
                                And   Period_End_Date__c = LAST_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];         
        }
        else
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where AdvertiserID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = LAST_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];             
        }
        
        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            String publicationGroup = (String)ar.get('dept');
            Decimal booked = (Decimal)ar.get('expr0');
            revenueList.add(new SalesRevenueChart.SalesRevenueByYearTitle(publicationGroup, booked));
        }    
        System.debug('revenueList:'+revenueList);
        return revenueList;
    }

    public static List<SalesRevenueChart.SalesRevenueByYearTitle> getRevenueThisQuarter()
    {  
        List<SalesRevenueChart.SalesRevenueByYearTitle> revenueList = new List<SalesRevenueChart.SalesRevenueByYearTitle>();

        List<AggregateResult> revenueAggr = new List<AggregateResult>();

        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where Invoice_AgencyID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = THIS_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];
        }
        else if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where ( BrandID__c  IN :accountSet // = :accountId
                                     OR AdvertiserID__c  IN :accountSet) // = :accountId)
                                And   Period_End_Date__c = THIS_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];         
        }
        else
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where AdvertiserID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = THIS_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];             
        }


        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            String publicationGroup = (String)ar.get('dept');
            Decimal booked = (Decimal)ar.get('expr0');
            revenueList.add(new SalesRevenueChart.SalesRevenueByYearTitle(publicationGroup, booked));
        }    
        System.debug('revenueList:'+revenueList);
        return revenueList;
    }

    public static List<SalesRevenueChart.SalesRevenueByYearTitle> getRevenueNextQuarter()
    {  
        List<SalesRevenueChart.SalesRevenueByYearTitle> revenueList = new List<SalesRevenueChart.SalesRevenueByYearTitle>();

        List<AggregateResult> revenueAggr = new List<AggregateResult>();

        if(accountDetail.Record_Type__c=='Agency')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where Invoice_AgencyID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = NEXT_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];
        }
        else if(accountDetail.Record_Type__c=='Advertiser'&&accountDetail.type=='Brand')
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where ( BrandID__c  IN :accountSet //= :accountId
                                     OR AdvertiserID__c  IN :accountSet) //= :accountId)
                                And   Period_End_Date__c = NEXT_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];         
        }
        else
        {
            revenueAggr = [
                                Select 
                                    Department__c dept,
                                    SUM(Revenue_Amount__c)
                                From SalesRevenue__c
                                Where AdvertiserID__c  IN :accountSet // = :accountId
                                And   Period_End_Date__c = NEXT_QUARTER
                                Group By Department__c
                                Order By Department__c
                         ];             
        }

        Integer i=0;                               
        For(AggregateResult ar:revenueAggr)
        {
            String publicationGroup = (String)ar.get('dept');
            Decimal booked = (Decimal)ar.get('expr0');
            revenueList.add(new SalesRevenueChart.SalesRevenueByYearTitle(publicationGroup, booked));
        }    
        System.debug('revenueList:'+revenueList);
        return revenueList;
    }
    
    public PageReference returnToAcc() 
    {
       //cancel method to return to the account detail page 
       return new PageReference('/'+retUrl);
    }    

    public class SalesRevenue 
    {
        public String quarter { get; set; }
        public Decimal revenue { get; set; }
        
        public SalesRevenue()
        {
            quarter=null;
            revenue=0;
        }
        
        public SalesRevenue(String quarterInfo, Decimal revenueInfo)
        {
            quarter=quarterInfo;
            revenue=revenueInfo;
        }
    }

   /* public class PublicationSalesRevenue 
    {
        public String publicationGroup { get; set; }
        public String quarter { get; set; }
        public Decimal revenue { get; set; }
        
        public PublicationSalesRevenue()
        {
            publicationGroup=null;
            quarter=null;
            revenue=0;
        }
        
        public PublicationSalesRevenue(String publicationGroupInfo, String quarterInfo, Decimal revenueInfo)
        {
            publicationGroup=publicationGroupInfo;
            quarter=quarterInfo;
            revenue=revenueInfo;
        }
    }   */ 

    public class PublicationSalesRevenue 
    {
        public String quarter { get; set; }
        public Integer index { get; set; }
        // public Decimal dmClassified { get; set; }
        public Decimal esClassified { get; set; }
        // public Decimal esDisplay { get; set; }
        //public Decimal mailPlus { get; set; }
        public Decimal metroClassified { get; set; }
        public Decimal metroDisplay { get; set; }
        // public Decimal theDailyMail { get; set; }
        // public Decimal theMailOnSunday { get; set; }
        public Decimal mailClassified { get; set; }
        public Decimal mailDisplay { get; set; }
        public Decimal network { get; set; }
        public Decimal mailOnline {get; set; }
        
        //public Decimal mailPublisher { get; set; }
        // public Decimal metroPublisher { get; set; }
        
        public PublicationSalesRevenue()
        {
            quarter=null;
            index=0;
            // dmClassified=0;
            esClassified=0;
            /*esDisplay=0;
            mailPlus=0;*/
            metroClassified=0;
            metroDisplay=0;
            // theDailyMail=0;
            // theMailOnSunday=0;
            mailClassified=0;
            mailDisplay=0;
            network=0;
            mailOnline=0;
            //mailPublisher=0;
            //metroPublisher=0;
        }
        
        // public PublicationSalesRevenue(String quarterInfo, Integer indexInfo, Decimal dmClassifiedInfo, Decimal esClassifiedInfo, Decimal esDisplayInfo, Decimal mailPlusInfo, Decimal metroClassifiedInfo, Decimal metroDisplayInfo, Decimal theDailyMailInfo, Decimal theMailOnSundayInfo, Decimal mailClassifiedInfo, Decimal mailDisplayInfo)
        // public PublicationSalesRevenue(String quarterInfo, Integer indexInfo, Decimal metroClassifiedInfo, Decimal metroDisplayInfo, Decimal mailClassifiedInfo, Decimal mailDisplayInfo, Decimal networkInfo, Decimal mailPublisherInfo, Decimal metroPublisherInfo)
        public PublicationSalesRevenue(String quarterInfo, Integer indexInfo, Decimal metroClassifiedInfo, Decimal metroDisplayInfo, Decimal mailClassifiedInfo, Decimal mailDisplayInfo, Decimal networkInfo, Decimal mailOnlineInfo, Decimal esClassifiedInfo)
        {
            quarter=quarterInfo;
            index=indexInfo;
            // dmClassified=dmClassifiedInfo;
            esClassified=esClassifiedInfo;
            /*esDisplay=esDisplayInfo;
            mailPlus=mailPlusInfo;*/
            metroClassified=metroClassifiedInfo;
            metroDisplay=metroDisplayInfo;
            //theDailyMail=theDailyMailInfo;
            //theMailOnSunday=theMailOnSundayInfo;
            mailClassified=mailClassifiedInfo;
            mailDisplay=mailDisplayInfo;
            network=networkInfo;
            mailOnline=mailOnlineInfo;
            // mailPublisher=mailPublisherInfo;
            // metroPublisher=metroPublisherInfo;
        }
    } 

public class SalesRevenueByQtr
    {
        public Integer year { get; set; }
        public Decimal q1 { get; set; }
        public Decimal q2 { get; set; }
        public Decimal q3 { get; set; }
        public Decimal q4 { get; set; }
        // public Integer index { get; set; }

        
        public SalesRevenueByQtr()
        {
            year=0;
            // index=0;
            q1=0;
            q2=0;
            q3=0;
            q4=0;
        }
        
        public SalesRevenueByQtr(Integer yearInfo, Decimal q1Info, Decimal q2Info, Decimal q3Info, Decimal q4Info)
        {
            year=yearInfo;
            // index=indexInfo;
            q1=q1Info;
            q2=q2Info;
            q3=q3Info;
            q4=q4Info;
        }
    }

public class SalesRevenueByYearTitle
    {
        public String title { get; set; }
        public Decimal revenue { get; set; }

        
        public SalesRevenueByYearTitle()
        {
            title=null;
            revenue=0;
        }
        
        public SalesRevenueByYearTitle(String titleInfo, Decimal revenueInfo)
        {
            title=titleInfo;
            revenue=revenueInfo;
        }
    } 


}