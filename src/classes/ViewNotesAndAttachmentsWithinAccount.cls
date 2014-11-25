public with sharing class ViewNotesAndAttachmentsWithinAccount 
{
	public Account acc;
	
 	public ViewNotesAndAttachmentsWithinAccount(ApexPages.StandardController std1controller) 
 	{
        this.acc= (Account)std1Controller.getRecord();
        System.debug('Account: '+acc);
 	}
/*   	
	Public String bta_prefix 
	{
		get
		{
			return Schema.SObjectType.Business_Team_Activity__c.getKeyPrefix();
	    } 
	    set; 
	}
	            
	Public String acc_prefix 
	{ 
	 	get
	 	{
	    	return Schema.SObjectType.Account.getKeyPrefix();
	 	}
	 	set;
	 }
	 
	Public String opp_prefix
	{ 
		get
		{
	    	return Schema.SObjectType.Opportunity.getKeyPrefix();
	    }
	    set;
	}
	
	Public String con_prefix
	{ 
		get
		{
	    	return Schema.SObjectType.Contact.getKeyPrefix();
	   	}
	   	set;
	}
*/
	ConstantsH__c ch    = ConstantsH__c.getInstance(UserInfo.getProfileId());
	Public String Department =  ch.Department__c;
	
// 	public List <Business_Team_Activity__c> AllBTAActivity 
	public Set<Id> btaIDs
	{
		get
		{
	     	// if(AllBTAActivity == null) 
	     	Map<Id, Business_Team_Activity__c> btaMap = new Map<Id, Business_Team_Activity__c>();
	     	if(btaIDs == null) 
	        {
	        	//System.debug('Team Activity:'+acc.name + ' ('+Department+')');
	            System.debug('acc.id:'+acc.id);
	            btaMap= new Map<Id, Business_Team_Activity__c>(
			            										[select 
		                                    					  name 
								                                 from Business_Team_Activity__c
								                                 where Business_Team_Activity__c.Account__c= :acc.id ]);
								                                 // and Business_Team_Activity__c.name = :acc.name + ' ('+Department+')']);
	        }
	        // return AllBTAActivity;
	        System.debug('BTA:'+btaMap);
	        return btaMap.KeySet();
	    }
	    set;    
	} 
	
	public Set<ID> pitchIDs 
	{
        get
        {
           Map<Id,Opportunity> pitchMap = new Map<Id,Opportunity>(
           														[select Name, AccountId, Agency__c 
           														from opportunity
           														where AccountId = :acc.id 
           														OR Agency__c = :acc.id
           														]);                  
           return pitchMap.keyset();
        }
        set;
	 }
    
	public Set<Id> contactIDs 
    {
    	get
        {
           Map<Id,Contact> contactMap = new Map<Id,Contact>(
		           											[select Name,
		           													AccountId 
		           											 from Contact
		           											 where AccountId = :acc.id
		           											 ]); 
		   System.debug('contactMap:'+contactMap);           
           return contactMap.keyset();
        }
        set;
    }
               	
	public List<Note> NotesList
	{
		get
		{
		System.debug('acc.id:'+acc.id);
		
		List<Note> allNotesList = [
									Select
										Title,
										ParentId,
										Parent.Name,
										LastModifiedDate,
										LastModifiedById,
										LastModifiedBy.Name
									From Note
									Where (ParentId IN :btaIDs
                    				OR ParentId IN :pitchIDs
				                    OR ParentId IN :contactIDs
				                    OR ParentId= :acc.id)
								];
		return allNotesList;
		}
		set;

	}
	
	public List<Attachment> AttachmentList
	{
		get
		{
		List<Attachment> allAttachmentList = [
												Select
													Name,
													ParentId,
													Parent.Name,
													LastModifiedDate,
													LastModifiedById,
													LastModifiedBy.Name
												From Attachment
												Where (ParentId IN :btaIDs
			                    				OR ParentId IN :pitchIDs
							                    OR ParentId IN :contactIDs
							                    OR ParentId= :acc.id)
											 ];
		return allAttachmentList;
		}
		set;		
	}
	
	public List<ContentDocumentLink> ContentDocumentLinkList
	{
		get
		{
			List<ContentDocumentLink> allContentDocumentLink = [
																Select 
																	ContentDocumentID,
																	LinkedEntity.Name,
																	ContentDocument.Title,
																	ContentDocument.LastModifiedDate,
																	ContentDocument.LastModifiedById,
																	ContentDocument.LastModifiedBy.Name
															    From ContentDocumentLink
																Where LinkedEntityId= :acc.id														
															];
			
		return allContentDocumentLink;
		}
		set;		
	}

	public List<ViewNotesAndAttachmentsWithinAccount.notesAndAttachment> notesAndAttachmentList
	{
		get
		{
			notesAndAttachmentList=new List<ViewNotesAndAttachmentsWithinAccount.notesAndAttachment>();
			for(Note n:notesList)
			{
				System.debug('n:'+n);
				notesAndAttachmentList.add(new notesAndAttachment(n));
			}
			//notesAndAttachmentList.addAll(NotesList);
			for(Attachment a:attachmentList)
			{
				System.debug('a:'+a);
				notesAndAttachmentList.add(new notesAndAttachment(a));
			}	
			for(ContentDocumentLink c:ContentDocumentLinkList)
			{
				System.debug('c:'+c);
				notesAndAttachmentList.add(new notesAndAttachment(c));
			}
			return notesAndAttachmentList;
		}
		set;
	}

	public List<ViewNotesAndAttachmentsWithinAccount.notesAndAttachment> getAllNotesAndAttachment()
	{
		return sortList(notesAndAttachmentList);
	}
	
	public class notesAndAttachment 
	{
	    public Id naId { get; set; }
	    public String type { get; set; }
        public String title { get; set; }
        public Id relatedTo { get; set; }
        public String relatedToName { get; set; }
        public Datetime lastModifiedDate { get; set; }
        public Id lastModifiedBy { get; set; }
        public String lastModifiedByName { get; set; }
        public notesAndAttachment(Note lnote)
        {
        	this.naId=lnote.Id;
        	this.type='Note';
        	this.title=lnote.title;
        	this.relatedTo=lnote.ParentId;
        	this.relatedToName=lnote.Parent.Name;
        	this.lastmodifiedDate=lnote.LastModifiedDate;
        	this.lastModifiedBy=lnote.LastModifiedById;
        	this.lastModifiedByName=lnote.LastModifiedBy.Name;
        }
        public notesAndAttachment(Attachment lattachment)
        {
        	this.naId=lattachment.Id;
        	this.type='Attachment';
        	this.title=lattachment.name;
        	this.relatedTo=lattachment.ParentId;
        	this.relatedToName=lattachment.Parent.Name;
        	this.lastmodifiedDate=lattachment.LastModifiedDate;
        	this.lastModifiedBy=lattachment.LastModifiedById;
        	this.lastModifiedByName=lattachment.LastModifiedBy.Name;
        }
        public notesAndAttachment(ContentDocumentLink lcontent)
        {
        	this.naId=lcontent.ContentDocumentID;
        	this.type='Feed Attachment';
        	this.title=lcontent.ContentDocument.Title;
        	this.relatedTo=lcontent.LinkedEntityId;
        	this.relatedToName=lcontent.LinkedEntity.Name;
        	this.lastmodifiedDate=lcontent.ContentDocument.LastModifiedDate;
        	this.lastModifiedBy=lcontent.ContentDocument.LastModifiedById;
        	this.lastModifiedByName=lcontent.ContentDocument.LastModifiedBy.Name;
        }

	}
	
    private List<notesAndAttachment> sortList(List<notesAndAttachment> unsortedList)
    {
        
        Map<DateTime, List<notesAndAttachment>> allNotesAndAttachmentMap = new Map<DateTime, List<notesAndAttachment>>();
        for(notesAndAttachment w: unsortedList)
        {
            if(allNotesAndAttachmentMap.containsKey(w.lastmodifiedDate))
            {
                List<notesAndAttachment> tmpWrapperList = new List<notesAndAttachment>();
                tmpWrapperList = allNotesAndAttachmentMap.get(w.lastmodifiedDate);
                tmpWrapperList.add(w);
                allNotesAndAttachmentMap.put(w.lastmodifiedDate, tmpWrapperList);
            }
            else
            {
                List<notesAndAttachment> tmpWrapperList = new List<notesAndAttachment>();
                tmpWrapperList.add(w);
                allNotesAndAttachmentMap.put(w.lastmodifiedDate, tmpWrapperList);
            }
        }
        
        Set<DateTime> dateSet = allNotesAndAttachmentMap.keySet();
        List<DateTime> dateList = new List<DateTime>();
        dateList.addAll(dateSet);
        System.debug('BEFORE dateList:'+dateList);
        dateList.Sort();
        System.debug('AFTER dateList:'+dateList);
        
        List<notesAndAttachment> outSortList = new List<notesAndAttachment>();
        List<notesAndAttachment> notesNullDateList = new List<notesAndAttachment>();
        
        for(DateTime d:dateList)
        {
            List<notesAndAttachment> tmpWrapperList = allNotesAndAttachmentMap.get(d);
            if(d!=null)
            {
                outSortList.addAll(tmpWrapperList);
            }
            else
            {
                notesNullDateList.addAll(tmpWrapperList);
            }
        }
        
        outSortList.addAll(notesNullDateList);
        System.debug('AFTER allactivityReturn:'+outSortList);
        
        List<notesAndAttachment> retSortList = new List<notesAndAttachment>();
        
        for(integer i=outSortList.Size()-1;i>-1; i--)
        {
        	retSortList.add(outSortList[i]);
        }
                       
        // return outSortList;
		return retSortList;
    }
}