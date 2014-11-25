public with sharing class NielsenMarketShareChartController
{
    public Account acc;
    
    public String retUrl = apexpages.currentpage().getParameters().get('retURL');   


    public static Id nielsenMarketSummaryReportId
    { 
        get
        {
            if(nielsenMarketSummaryReportId==null)
            {
                try
                {
                    nielsenMarketSummaryReportId = [Select
                                                    Id
                                                From Report
                                                Where Name = 'Nielsen Market Summary'
                                                ].Id;
                }
                catch(QueryException qe0)
                {
                
                }
            }
            return nielsenMarketSummaryReportId;
        }
         set;
    }
    
    
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
		                al = [ SELECT a.Type, a.ParentId, a.OwnerId, a.Name, a.Industry, a.Id FROM Account a WHERE a.id IN : CurrentParent ORDER BY a.Name ];
		            } 
		            else 
		            {
		                //Change below      
		                al = [ SELECT a.Type, a.ParentId, a.OwnerId, a.Name, a.Industry, a.Id FROM Account a WHERE a.ParentID IN : CurrentParent ORDER BY a.Name ];
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
    
    
    public NielsenMarketShareChartController.NielsenMarketShareChartController()
    {
        // accountId = Apexpages.currentPage().getParameters().get('id');
        Set<Id> a = accountSet;

    }
        
    public NielsenMarketShareChartController.NielsenMarketShareChartController(ApexPages.StandardController controller)
    {
        this.acc= (Account)controller.getRecord();
        Set<Id> a = accountSet;
    }
    

    public static List<NielsenMarketShareChartController.NielsenMarketShare > getMarketShareChartData() 
    {
        List<NielsenMarketShare > nmsDataList = getExpenditureChartData();
        List<NielsenMarketShare > marketShareDataList = new List<NielsenMarketShare >();
        
        for(NielsenMarketShare n: nmsDataList)
        {
            NielsenMarketShare marketShareData = new NielsenMarketShare();
            Decimal totalShare = n.cinema+n.dailyMail+n.directMail+n.doorDrops+n.magazines+n.mailOnSunday+n.metro+n.nationalNewspapers+n.outDoor+n.radio+n.regionalNewspapers+n.tv ;
            marketShareData.index = n.index;
            marketShareData.month = n.month;
            marketShareData.cinema = (n.cinema*100/totalShare).SetScale(1);
            marketShareData.dailyMail = (n.dailyMail*100/totalShare).SetScale(1);
            marketShareData.directMail = (n.directMail*100/totalShare).SetScale(1);
            marketShareData.doorDrops = (n.doorDrops*100/totalShare).SetScale(1);
            marketShareData.magazines = (n.magazines*100/totalShare).SetScale(1);
            marketShareData.mailOnSunday = (n.mailOnSunday*100/totalShare).SetScale(1);
            marketShareData.metro = (n.metro*100/totalShare).SetScale(1);
            marketShareData.nationalNewspapers = (n.nationalNewspapers*100/totalShare).SetScale(1);
            marketShareData.outDoor = (n.outDoor*100/totalShare).SetScale(1);
            marketShareData.radio = (n.radio*100/totalShare).SetScale(1);
            marketShareData.regionalNewspapers = (n.regionalNewspapers*100/totalShare).SetScale(1);
            marketShareData.tv = (n.tv*100/totalShare).SetScale(1);
            marketShareDataList.add(marketShareData);
        }

        return marketShareDataList;
    }    

    public static List<NielsenMarketShareChartController.NielsenMarketShare > getExpenditureChartData() 
    {      
        
        Decimal totalCinema=0;
        Decimal totalDailyMail=0;
        Decimal totalDirectMail=0; 
        Decimal totalDoorDrops=0;           
        Decimal totalMagazines=0;
        Decimal totalMailOnSunday=0;
        Decimal totalMetro=0;
        Decimal totalNationalNewspapers=0;
        Decimal totalOutdoor=0;
        Decimal totalRadio=0;
        Decimal totalRegionalNewspapers=0;
        Decimal totalTv=0;
       
        Map<String, NielsenMarketShareChartController.NielsenMarketShare > nielsenMarketShareMap = new Map<String, NielsenMarketShareChartController.NielsenMarketShare>();
        List<AggregateResult> marketShareAggr =  new List<AggregateResult>();
        System.debug('accountSet:'+accountSet);
        
        marketShareAggr = [
                            Select 
                                Media_Type__c media,
                                CALENDAR_MONTH(Expenditure_Month__c) month,
                                CALENDAR_YEAR(Expenditure_Month__c) year,
                                SUM(Expenditure_Amount__c)
                            From Nielsen_Market_Summary__c
                            Where AccountID__c IN :accountSet // = :accountId
                            And   Expenditure_Month__c < LAST_N_DAYS:42
                            Group By CALENDAR_YEAR(Expenditure_Month__c), CALENDAR_MONTH(Expenditure_Month__c), Media_Type__c
                            Order By CALENDAR_YEAR(Expenditure_Month__c), CALENDAR_MONTH(Expenditure_Month__c), Media_Type__c
                           ];           

        Integer i=0;                               
        For(AggregateResult ar:marketShareAggr)
        {
            System.debug('month:'+(Integer)ar.get('month'));
            System.debug('year:'+(Integer)ar.get('year'));
            System.debug('Amount:'+(Decimal)ar.get('expr0'));
            Integer year=(Integer)ar.get('year')==null?0:(Integer)ar.get('year');
            Integer monthInt=(Integer)ar.get('month')==null?0:(Integer)ar.get('month');

            String month=(String)(monthInt+'/'+year);
            String mediaType = (String)(ar.get('media'));
            Decimal expenditure = (Decimal)ar.get('expr0');
            expenditure = expenditure==null?0:expenditure;
                       
            Decimal cinema=0;
            Decimal dailyMail=0;
            Decimal directMail=0; 
            Decimal doorDrops=0;           
            Decimal magazines=0;
            Decimal mailOnSunday=0;
            Decimal metro=0;
            Decimal nationalNewspapers=0;
            Decimal outdoor=0;
            Decimal radio=0;
            Decimal regionalNewspapers=0;
            Decimal tv=0;
            
            
            if(nielsenMarketShareMap.containsKey(month))
            {
                NielsenMarketShareChartController.NielsenMarketShare NielsenExpenditure = nielsenMarketShareMap.get(month);
                if(mediaType=='Cinema')
                {
                    NielsenExpenditure.cinema += expenditure;
                    TotalCinema += expenditure;
                }
                else if(mediaType=='Daily Mail')
                {
                    NielsenExpenditure.dailyMail += expenditure;
                    TotalDailyMail += expenditure;
                }
                else if(mediaType=='Direct Mail')
                {
                    NielsenExpenditure.directMail += expenditure;
                    TotalDirectMail += expenditure;
                }
                else if(mediaType=='Door Drops')
                {
                    NielsenExpenditure.doorDrops += expenditure;
                    TotalDoorDrops += expenditure;
                }            
                else if(mediaType=='Magazines')
                {
                    NielsenExpenditure.magazines += expenditure;
                    TotalMagazines += expenditure;
                }                 
                else if(mediaType=='Mail On Sunday')
                {
                    NielsenExpenditure.mailOnSunday += expenditure;
                    TotalMailOnSunday += expenditure;
                } 
                else if(mediaType=='Metro')
                {
                    NielsenExpenditure.metro += expenditure;
                    TotalMetro += expenditure;
                }
                else if(mediaType=='National Newspapers')
                {
                    NielsenExpenditure.nationalNewspapers += expenditure;
                    TotalNationalNewspapers += expenditure;
                }
                else if(mediaType=='Outdoor')
                {
                    NielsenExpenditure.outDoor += expenditure;
                    TotalOutdoor += expenditure;
                }                 
                else if(mediaType=='Radio')
                {
                    NielsenExpenditure.radio += expenditure;
                    TotalRadio += expenditure;
                }
                else if(mediaType=='Regional Newspapers')
                {
                    NielsenExpenditure.regionalNewspapers += expenditure;
                    TotalRegionalNewspapers += expenditure;
                }
                else if(mediaType=='TV')
                {
                    NielsenExpenditure.tv += expenditure;
                    TotalTv += expenditure;
                }                
                nielsenMarketShareMap.put(month,NielsenExpenditure);
                 
            }
            else
            {
                i+=1;
                if(mediaType=='Cinema')
                {
                    cinema += expenditure;
                    TotalCinema += expenditure;
                }
                else if(mediaType=='Daily Mail')
                {
                    dailyMail += expenditure;
                    TotalDailyMail += expenditure;
                }
                else if(mediaType=='Direct Mail')
                {
                    directMail += expenditure;
                    TotalDirectMail += expenditure;
                }
                else if(mediaType=='Door Drops')
                {
                    doorDrops += expenditure;
                    TotalDoorDrops += expenditure;
                }            
                else if(mediaType=='Magazines')
                {
                    magazines += expenditure;
                    TotalMagazines += expenditure;
                }                 
                else if(mediaType=='Mail On Sunday')
                {
                    mailOnSunday += expenditure;
                    TotalMailOnSunday += expenditure;
                } 
                else if(mediaType=='Metro')
                {
                    metro += expenditure;
                    TotalMetro += expenditure;
                }
                else if(mediaType=='National Newspapers')
                {
                    nationalNewspapers += expenditure;
                    TotalNationalNewspapers += expenditure;
                }
                else if(mediaType=='Outdoor')
                {
                    outDoor += expenditure;
                    TotalOutdoor += expenditure;
                }                 
                else if(mediaType=='Radio')
                {
                    radio += expenditure;
                    TotalRadio += expenditure;
                }
                else if(mediaType=='Regional Newspapers')
                {
                    regionalNewspapers += expenditure;
                    TotalRegionalNewspapers += expenditure;
                }
                else if(mediaType=='TV')
                {
                    tv += expenditure;
                    TotalTv += expenditure;
                }                  
                nielsenMarketShareMap.put(month, new NielsenMarketShareChartController.NielsenMarketShare(month, i, cinema==null?0:cinema, dailyMail==null?0:dailyMail, directMail==null?0:directMail, doorDrops==null?0:doorDrops, magazines==null?0:magazines, mailOnSunday==null?0:mailOnSunday, metro==null?0:metro, nationalNewspapers==null?0:nationalNewspapers, outdoor==null?0:outdoor, radio==null?0:radio, regionalNewspapers==null?0:regionalNewspapers, tv==null?0:tv));
            }
            
        }
        

        List<Integer> indexList = new List<Integer>();
        Map<Integer, NielsenMarketShareChartController.NielsenMarketShare > expenditureIndexMap = new Map<Integer, NielsenMarketShareChartController.NielsenMarketShare>();
        for(NielsenMarketShareChartController.NielsenMarketShare r:nielsenMarketShareMap.Values())
        {
            indexList.add(r.index);
            expenditureIndexMap.put(r.index, r);
        }
        indexList.sort();
        List<NielsenMarketShareChartController.NielsenMarketShare> expenditureList = new List<NielsenMarketShareChartController.NielsenMarketShare>();
        for(Integer ind:indexList)
        {
            expenditureList.add(expenditureIndexMap.get(ind));
        }
        System.debug('expenditureList:'+expenditureList);
        return expenditureList;
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

    public class NielsenMarketShare 
    {
        public String month { get; set; }
        public Integer index { get; set; }

        public Decimal cinema { get; set; }
        public Decimal dailyMail { get; set; }

        public Decimal directMail { get; set; }
        public Decimal doorDrops { get; set; }
        public Decimal magazines { get; set; }
        public Decimal mailOnSunday {get; set; }
        
        public Decimal metro {get; set; }
        public Decimal nationalNewspapers {get; set; }

        public Decimal outDoor {get; set; }
        
        public Decimal radio {get; set; }
        
        public Decimal regionalNewspapers {get; set; }
        
        public Decimal tv {get; set; }
        
        public NielsenMarketShare()
        {
            month = null;
            index = 0;
    
            cinema = 0;
            dailyMail = 0;
    
            directMail = 0;
            doorDrops = 0;
            magazines = 0;
            mailOnSunday = 0;
            
            metro = 0;
            nationalNewspapers = 0;
    
            outDoor = 0;
            
            radio = 0;
            
            regionalNewspapers = 0;
            
            tv = 0;
        }
        
        public NielsenMarketShare(String monthInfo, Integer indexInfo, Decimal cinemaInfo, Decimal dailyMailInfo, Decimal directMailInfo, Decimal doorDropsInfo, Decimal magazinesInfo, Decimal mailOnSundayInfo, Decimal metroInfo, Decimal nationalNewspapersInfo, Decimal outDoorInfo, Decimal radioInfo, Decimal regionalNewspapersInfo, Decimal tvInfo)
        {
            month = monthInfo;
            index = indexInfo;
    
            cinema = cinemaInfo;
            dailyMail = dailyMailInfo;
    
            directMail = directMailInfo;
            doorDrops = doorDropsInfo;
            magazines = magazinesInfo;
            mailOnSunday = mailOnSundayInfo;
            
            metro = metroInfo;
            nationalNewsPapers = nationalNewspapersInfo;
    
            outDoor = outDoorInfo;
            
            radio = radioInfo;
            
            regionalNewspapers = regionalNewspapersInfo;
            
            tv = tvInfo;
        }
    } 




}