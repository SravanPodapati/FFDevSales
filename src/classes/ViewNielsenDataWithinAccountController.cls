public with sharing class ViewNielsenDataWithinAccountController
{

	private transient Account acc;
	// public Account acc;
	
	// public transient final String creativeSnapshotURL = Constants__c.getInstance('All').Creative_Snapshot_URL__c ;
	
	public transient String creativeSnapshotURL{get; set;}
	
    private Set<Id> accountSet
    {
    	get
    	{
    		if(accountSet==null||accountSet.size()==0)
    		{
    			accountSet = new Set<Id>();
    			String currentId;
    			List<Account> al            = new List<Account>{};
        		Set<ID> currentParent      = new Set <ID>();
        		//Set<ID> accountIdSet      = new Set <ID>();
		        Integer count               = 0;
        		Integer level               = 0;
        		Boolean endOfStructure      = false;
        		currentParent.add(acc.Id);
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
		                 }
		                 level++;
		            }
		        }

				System.debug('accountSet:'+accountSet);    	
		
    		}
            return accountSet;
    	}
    	set;
    }
	
	
 	public ViewNielsenDataWithinAccountController(ApexPages.StandardController std1controller) 
 	{
        this.acc= (Account)std1Controller.getRecord();
        // System.debug('Account: '+acc);
        try
        {
        	creativeSnapshotURL = Constants__c.getInstance('All').Creative_Snapshot_URL__c;
        }
        catch(exception e)
        {
        	creativeSnapshotURL = 'http://www.addynamix.co.uk/Press/Alerts/CreativeSnapshot.aspx';
        }

 	}

	public List<Nielsen_Data__c> getAllNielsenData()
	{
		List<Nielsen_Data__c> ndList = [Select
											Publication__c,
											Publication_Group__c,
											Name,
											Media_Type__c,
											Last_Seen__c, 
											Incidence__c,
											First_Seen__c,
											Expenditure__c,
											Description__c,
											CreativeId__c,
											Category__c,
											Brand_Name__c,
											Advert_Size__c, 
											AccountID__c
											From Nielsen_Data__c
											Where AccountID__c IN :accountSet
											Order By Last_Seen__c Desc];
		return ndList;
	}

}