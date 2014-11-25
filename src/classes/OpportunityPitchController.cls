/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2013-10-25
 *	@description:
 *	    controller for OpportunityPitch VF page
 *	    Displays a VF page for Opportunity entry used on Account Chatter Publisher
 *
 *	    see Jira: Gl-10 for detailed requriements
 *	
 *	Version History :   
 *		
 */
global with sharing class OpportunityPitchController {
	private static Integer ICONS_PER_LINE = 2;//change this constant if number of icons needs to be different
	static {
		ConstantsH__c iconConfig = ConstantsH__c.getInstance(UserInfo.getUserId());
		if (null != iconConfig && null != iconConfig.Quick_Pitch_Icons_Per_Line__c) {
			ICONS_PER_LINE = Integer.valueOf(iconConfig.Quick_Pitch_Icons_Per_Line__c);
		}
	}


	private static String RT_ADVERTISER = 'Advertiser';
	private static String RT_AGENCY = 'Agency';
	private static String NONE = '--None--';

	@TestVisible 
	private static String NO_ICON = '/img/msg_icons/error32.png';//ideally this shall be replaced with some meaningful image URL
	
	private final ApexPages.StandardController stdCon;

	public Opportunity opportunity;
	private final Map<String, String> lookupValues = new Map<String, String>();//fName -> Value

	public String selectedAdvertiserId15 {
		get { 
			return get15(lookupValues.get('AccountId'));
		} 
		set { lookupValues.put('AccountId', value);}
	}

	public String selectedAgencyId15 {
		get {
			return get15(lookupValues.get('Agency__c'));
		} 
		set { lookupValues.put('Agency__c',value);}
	}

	public String selectedCampaign15 {
		get {
			return get15(lookupValues.get('CampaignId'));
		} 
		set { 
			lookupValues.put('CampaignId', value);
		}
	}

	public String teamMemberIds { get; set;} //comma separated list of selected Team Member Ids
	public String productDataJSON { get; set;} //JSON string which contains product data (all added products)

	public OpportunityLineItem dummyLineItem {get; set;}//used on Product Entry to render End Date control

	public OpportunityPitchController (ApexPages.StandardController stdCon) {
		if (!Test.isRunningTest()) {
			stdCon.addFields(new String[] {'Name', 'RecordType.Name'});
		}
		this.stdCon = stdCon;
		dummyLineItem = new OpportunityLineItem();

	}

	final static String[] LOOKUP_FIELDS = new String[] {'AccountId', 'Agency__c', 'CampaignId'};
	private void initLookupValues() {
		Opportunity opp = getOpportunity();
		for(String fName : LOOKUP_FIELDS) {
			lookupValues.put(fName, (Id)opp.get(fName));
		}
	}
	private void dumpLookupValues() {
		Opportunity opp = getOpportunity();
		for(String fName : LOOKUP_FIELDS) {
			if (!String.isBlank(lookupValues.get(fName))) {
				opp.put(fName, lookupValues.get(fName));
			} else {
				opp.put(fName, null);
			}
		}
	}

	public String getUserLocale() {
		return UserInfo.getLocale();
	}

	public Opportunity getOpportunity() {
		if (opportunity == null) {
			opportunity = new Opportunity();
			opportunity.OwnerId = UserInfo.getUserId();
			opportunity.Type = 'Not Specified';
			opportunity.StageName = 'Preparation';
			opportunity.CreationMethod__c = 'Chatter (OpportunityPitch)';
			//load CurrencyIsoCode
			opportunity.CurrencyIsoCode = getCurrencyIsoCode();
			//set record type same way as it is done in PitchHubController
			RecordType rt = MockUtils.getRecordType('Opportunity', Constants__c.getInstance('All').Regular_Opp_Record_Type__c);
			if (null != rt) {
				opportunity.RecordTypeId = rt.Id;
			}

			//assign accounts
			Account acc = (Account)stdCon.getRecord();
			if (null != acc) {
				if (isAdvertiser) {
					opportunity.AccountId = acc.Id;
					List<Relationship__c> rels = getRelationships(acc.Id, RT_AGENCY);
					if (1 == rels.size()) {
						String[] vals = getIdAndAccountName(rels[0], RT_AGENCY);
						opportunity.Agency__c = vals[0];
					}

				} else if (isAgency) {
					opportunity.Agency__c = acc.Id;
					List<Relationship__c> rels = getRelationships(acc.Id, RT_ADVERTISER);
					if (1 == rels.size()) {
						String[] vals = getIdAndAccountName(rels[0], RT_ADVERTISER);
						opportunity.AccountId = vals[0];
					}

				}
			}
			initLookupValues();
		}
		return opportunity;
	}

	public Boolean isAgency {
		get {
			Account acc = (Account)stdCon.getRecord();
			return null != acc && RT_AGENCY == acc.RecordType.Name;
		}
	}
	public Boolean isAdvertiser {
		get {
			Account acc = (Account)stdCon.getRecord();
			return null != acc && RT_ADVERTISER == acc.RecordType.Name;
		}
	}

	@TestVisible
	private static Date[] getDatesFromString(final String val) {
		final List<Date> dates = new List<Date>();
		if (!String.isBlank(val)) {
			for(String dateStr : val.split(',')) {
				if (!String.isBlank(dateStr)) {
					try {
						Date dateVal = Date.parse(dateStr);
						dates.add(dateVal);
					} catch (Exception e) {
						addError('Unable to parse date:' + dateStr);
					}
				}
			    
			}
		}
		return dates;
	}
	public PageReference cancel() {
		PageReference ref = preparePageReference();
		return ref;
	}
	/**
	 * save this opportunity and if OK then display blank page with fading "success message"
	 */
	public PageReference save() {
		Savepoint sp = Database.setSavepoint();
		System.debug('agX productDataJSON=' + productDataJSON);
		final Opportunity opp = getOpportunity();

		//try to save Opportunity
		dumpLookupValues();
		System.debug('agX Opportunity.2=' + getOpportunity());
		if (null == opp.Id) {
			try {
			Database.SaveResult res = Database.insert(getOpportunity());
			if (!res.isSuccess()) {
				Database.Error err = res.getErrors()[0];
				addError(err.getMessage());
			}
			} catch (Exception e) {
				addError('Can not save Pitch. ' + e.getMessage());
			}
		}

		if (!hasErrors() && !String.isBlank(teamMemberIds) ) {

			//add Opportunity Team
			final String[] memberIds = teamMemberIds.split(',');
			//load all involved users
			final Map<Id, User> userMap = new Map<Id, User> ([select Id, ProfileId from User where Id =: opportunity.OwnerId or Id in: memberIds]);
			final User owner = userMap.get(opportunity.OwnerId);
			final String ownerDepartment = getDepartment(owner.ProfileId);
			final List<OpportunityTeamMember> members = new List<OpportunityTeamMember>();
			final Map<Id, String> accessByMember = new Map<Id, String>();
			for(String userIdStr : memberIds) {
				Id userId = userIdStr;
				User u = userMap.get(userId);
				if (null != u) {
					OpportunityTeamMember member = new OpportunityTeamMember();
					member.UserId = u.Id;
					member.OpportunityId = opp.Id;

					String department = getDepartment(u.ProfileId);
					if (null != department && department == ownerDepartment) {
						//read/write
						accessByMember.put(u.Id, 'Edit');
					} else {
						//read only
						accessByMember.put(u.Id, 'Read');
					}
					members.add(member);
				}
			    
			}
			if (!members.isEmpty()) {
				Database.SaveResult[] results = Database.insert(members);

				if (checkSaveResult(results)) {

					//sort out sharing rules
					// get all of the team members' sharing records
					List<OpportunityShare> shares = [select Id, OpportunityAccessLevel, RowCause, UserOrGroupId from OpportunityShare 
						where OpportunityId = :opp.Id and RowCause = 'Team' and UserOrGroupId = :accessByMember.keySet()];

					// set all team members access to read/write
					for (OpportunityShare share : shares) {
						String access = accessByMember.get(share.UserOrGroupId);
						if (null != access) {
							share.OpportunityAccessLevel = access;
						}
					}

					Database.update(shares);
				}

			}
		}

		//prepare products for Insert
		if (!hasErrors()) {
			try {
				final List<OpportunityLineItem> itemsToInsert = getOpportunityLineItemsFromJSON(productDataJSON, opp.Id, opp.CloseDate);	
				if (!hasErrors()) {
					Database.SaveResult[] results = Database.insert(itemsToInsert);
					checkSaveResult(results);
				}
			} catch (Exception e) {
				addError('Unable to parse or save product list.' + e.getMessage());
			}
		}

		if (!hasErrors()) {
			PageReference ref = preparePageReference();
			ref.getParameters().put('saveOk', 'true');
			return ref;
		}
		//reset id because it will be invalid after transaction rollback
		getOpportunity().Id = null;
		Database.rollback(sp);
		return null;

	}

	/**
	 * Using serialised (JSON) product data - generate OpportunityLineItem records, ready to insert
	 * Data Example:
	 * [{"pbeId":"01tD0000002McPgIAK", "id":"01tD0000002McPgIAK","name":"Daily Mail newspaper - Advertorials","amount":1,"startDate":"10/01/2013, 10/02/2013,...", "endDate":"10/01/2013"} ...]
	 */
	@TestVisible
	private static List<OpportunityLineItem> getOpportunityLineItemsFromJSON (final String productDataJSON, final Id oppId, final Date closeDate) {
		final List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();	
		if (!String.isBlank(productDataJSON)) {
			final List<Object> m = (List<Object>)JSON.deserializeUntyped(productDataJSON);
			//m is array of product objects
			//[{"pbeId":"01tD0000002McPgIAK", "id":"01tD0000002McPgIAK","name":"Daily Mail newspaper - Advertorials","amount":1,"startDate":"10/01/2013, 10/02/2013,...", "endDate":"10/01/2013"} ...]
			for(Object prodObject : m) {
				Map<String, Object> prod = (Map<String, Object>)prodObject;
				String name = (String)prod.get('name');
				Id productId = (Id)prod.get('id');
				Id pbeId = (Id)prod.get('pbeId');
				Decimal amount = (Decimal)prod.get('amount');
				String startDatesStr = (String)prod.get('startDate');
				final List<Date> startDates = getDatesFromString(startDatesStr);
				for(Date startDate : startDates) {
					if (startDate < closeDate) {
						addError(name + ': Start Date must be greater than or equal to the Pitch Close Date.');
						break;
					}
				}

				String endDateStr = (String)prod.get('endDate');
				Date endDate = !String.isBlank(endDateStr) ? Date.parse(endDateStr) : null;
				System.debug('agX Id=' + productId + '; amount=' + amount + '; startDates=' + startDatesStr + '; endDate=' + endDate);
				if (null != endDate && endDate < closeDate) {
					addError(name + ': End Date can not be less than Close Date.' );
					break;
				}
				if (hasErrors()) {
					break;
				}

				for(Date startDate : startDates) {
					OpportunityLineItem item = new OpportunityLineItem();
					item.OpportunityId = oppId;
					item.PricebookEntryId = pbeId;
					item.UnitPrice = amount;
					item.Quantity = 1;
					item.ServiceDate = startDate;
					item.Last_Insertion_Date__c = endDate;
					itemsToInsert.add(item);
					System.debug('agX item=' + item);
				}

			}
		}
		return itemsToInsert;
	}

	private PageReference preparePageReference() {
		PageReference ref = Page.OpportunityPitch;
		//copy parameters
		final Set<String> keepParams = new Set<String>{'id', 'debug'};
		for(String key : ApexPages.currentPage().getParameters().keySet()) {
			if (keepParams.contains(key)) {
				ref.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
			}

		}
		ref.setRedirect(true);
		return ref;
	}

	private Boolean checkSaveResult(Database.SaveResult[] results) {
		Boolean resOK = true;
		for(Database.SaveResult res : results) {
			if (!res.isSuccess()) {
				Database.Error err = res.getErrors()[0];
				addError(err.getMessage());
				resOK = false;
			}
		}
		return resOK;
	}

	private static String getDepartment(final Id profileId) {
		ConstantsH__c settings = ConstantsH__c.getInstance(profileId);
		String department = null;
		if (null != settings) {
			department = settings.Department__c;
		}
		return department;

	}

	private static Boolean hasErrors() {
		return ApexPages.hasMessages(ApexPages.Severity.ERROR);
	}
	private static void addError(final String msg) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
	}


	public List<SelectOption> getCampaigns() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', NONE));

		final Id advertiserId = getOpportunity().AccountId;
		if (null != advertiserId) {
			for(Campaign c : [select Id, Name from Campaign where IsActive = true and StartDate <= TODAY and EndDate >= TODAY and Account__c =: advertiserId]) {
				options.add(new SelectOption(get15(c.Id), c.Name));
			}
		}
		if (2 == options.size()) {
			//there is only 1 campaign, set it as default
			selectedCampaign15 = options[1].getValue();
			
		}
		
		return options;
	}
	public void reloadCampaigns() {
		dumpLookupValues();
	}

	public List<SelectOption> getAdvertisers() {
		return loadAccountPicklist(getOpportunity().Agency__c, RT_ADVERTISER);
	}

	public String getAdvertiserType() {
		String type = '';
		final Id advertiserId = getOpportunity().AccountId;
		if (null != advertiserId) {
			try {
				type = [select Type from Account where Id =: advertiserId].Type;
			} catch (Exception eIgnore) {}
		}
		return type;

	}

	public List<SelectOption> getAgencies() {
		return loadAccountPicklist(getOpportunity().AccountId, RT_AGENCY);
	}

	private static String getPriceBook() {
		final ConstantsH__c config = ConstantsH__c.getInstance(UserInfo.getProfileId());
		return config.Price_Book__c;
	}

	/**
	 * @return: List of icon rows, each row contains ICONS_PER_LINE or less icon URLs
	 * e.g. if ICONS_PER_LINE = 3 and there are only 8 unique icons in a Price Book available to user
	 * then result may look like so:
	 * ['/image1.jpg', '/image2.jpg', 'image3.gif']
	 * ['/image4.jpg', '/image5.jpg', 'image6.gif']
	 * ['/image7.jpg', '/image8.jpg']
	 *
	 */
	public List<String[]> getProductIconRows() {
		final List<List<String>> rows = new List<List<String>>();
		final ConstantsH__c config = ConstantsH__c.getInstance(UserInfo.getProfileId());
		final String priceBook = getPriceBook();
		Boolean needNewList = true;
		List<String> currentRow = new List<String>();
		rows.add(currentRow);
		if (null != priceBook) {
			for (AggregateResult ar : [select Icon__c from Product2 
										where Id in (select Product2Id from PricebookEntry 
														where Pricebook2.Name = :priceBook and IsActive = true 
															and CurrencyIsoCode =: getOpportunity().CurrencyIsoCode) 
										group by Icon__c order by max(Icon_Order__c) NULLS LAST]) {
				if (currentRow.size() == ICONS_PER_LINE) {
					currentRow = new List<String>();
					rows.add(currentRow);
				}
				String icon = (String)ar.get('Icon__c');
				if (!String.isBlank(icon)) {
					currentRow.add(icon);
				} else {
					currentRow.add(NO_ICON);
				}
			}
		}
		return rows;
	}

	private static String getCurrencyIsoCode() {
		String priceBook = getPriceBook();
		//we assume that ALL items in Pricebook available to user are in the SAME currency, so we only load CurrencyIsoCode once
		List<PricebookEntry> pbes = [select CurrencyIsoCode from PricebookEntry where Pricebook2.Name = :priceBook and IsActive = true limit 1];
		System.assert(!pbes.isEmpty(), 'Configuration Error: Current User does not have assigned pricebook in ConstantsH__c');
		return pbes[0].CurrencyIsoCode;
	}
	/**
	 * depends on selected Icon__c value
	 */
	@RemoteAction
	global static List<ProductInfo> getProductsByIcon(final String icon) {
		List<ProductInfo> options = new List<ProductInfo>();

		final String priceBook = getPriceBook();
		String iconKey = icon;
		if (icon == NO_ICON) {
			iconKey = null;
		}
		if (null != priceBook) {
			final List<PricebookEntry> entries = [select Id, Product2Id, UnitPrice, Product2.Name, Product2.Schedule_Revenue__c from PricebookEntry 
													where Pricebook2.Name = :priceBook and IsActive = true 
														and Product2.Icon__c = :iconKey and CurrencyIsoCode =: getCurrencyIsoCode()
													order by Product2.Order_Inside_Icon__c NULLS LAST];
			for(PricebookEntry pbe : entries) {
				options.add(new ProductInfo(pbe));
			}
		}
		return options;
	}
	global class ProductInfo {
		public final String name {get; private set;}
		public final Id id {get; private set;}
		public final Id pbeId {get; private set;}
		public final Decimal unitPrice {get; private set;}
		public final Boolean isEndDateRequired {get; private set;}

		public ProductInfo(final PricebookEntry pbe) {
			pbeId = pbe.Id;
			id = pbe.Product2Id;
			name = pbe.Product2.Name;
			unitPrice = pbe.UnitPrice;
			isEndDateRequired = pbe.Product2.Schedule_Revenue__c == 'Monthly';
		}

	}

	/**
	 * return all users who can be potential Pitch Team Member
	 */
	private static List<User> getPotentialPitchTeamMembers() {
		final List<User> users = [select Id, Name from User where IsActive=true and UserType = 'Standard' order by Name];
		return users;
	}
	/**
	 * @return List of string arrays, each element consists of user-name and id
	 * ['user a': '005124334']
	 * ['user b': '00598765']
	 * ...
	 */
	@RemoteAction
	global static List<String[]> getAvailableUserMap() {
		List<String[]> res = new List<String[]>();
		final List<User> users = getPotentialPitchTeamMembers();
		if (users.isEmpty()) {
			return res;
		}
		
		for(User usr : users) {
			String[] row = new String[] {usr.Name, usr.Id};
			res.add(row);
		}
		return res;
	}
	/**
	 * load relationships for given account where counterpart/other accounts have given RT name
	 * for Advertiser - counterpart/other is Agency and vice versa
	 *
	 */
	private List<SelectOption> loadAccountPicklist(final Id accId, final String otherRecordTypeName) {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', NONE));

		List<Relationship__c> rels = getRelationships(accId, otherRecordTypeName);		
		Boolean hasCurrentAccount = false;
		final Id currentAccountId = stdCon.getId();
		for(Relationship__c r : rels) {
			String[] vals = getIdAndAccountName(r, otherRecordTypeName);
			if (null != vals) {
				options.add(new SelectOption(get15(vals[0]), vals[1]));
				if (null != currentAccountId && currentAccountId == (Id)vals[0]) {
					hasCurrentAccount = true;
				}
			}
		}
		//make sure that the account in context is always on the appropriate list
		if (!hasCurrentAccount && accId != currentAccountId ) {
			Account acc = (Account)stdCon.getRecord();
			options.add(new SelectOption(get15(acc.Id), acc.Name));
		}
		return options;
	}

	private static String[] getIdAndAccountName(final Relationship__c rel, String recordTypeName) {
		if (null != rel.Account_A__c && recordTypeName == rel.Account_A__r.RecordType.Name) 
			return new String[] {''+ rel.Account_A__c, rel.Account_A__r.Name};
		else if (null != rel.Account_B__c && recordTypeName == rel.Account_B__r.RecordType.Name) 
			return new String[] {''+ rel.Account_B__c, rel.Account_B__r.Name};
		return null;
	}

	private static List<Relationship__c> getRelationships(final Id accountAId, final String recordTypeName) {
		final List<Relationship__c> allRels = [select Id, Account_B__c, Account_B__r.Name, Account_B__r.RecordType.Name,
														Account_A__c, Account_A__r.Name, Account_A__r.RecordType.Name 
										from Relationship__c 
										where Active__c = true 
										and	(
											(Account_A__c =: accountAId and Account_B__c <> null and Account_B__r.RecordType.Name = :recordTypeName)
											or
											(Account_B__c =: accountAId and Account_A__c <> null and Account_A__r.RecordType.Name = :recordTypeName)
											)
										];
		final List<Relationship__c> singleRtRels = new List<Relationship__c>();
		for(Relationship__c r : allRels) {
			if (recordTypeName == r.Account_A__r.RecordType.Name ) {
				singleRtRels.add(r);
			}
			if (recordTypeName == r.Account_B__r.RecordType.Name ) {
				singleRtRels.add(r);
			}
		}

		return singleRtRels;
	}


	private static String get15(String objId) {
		return String.isBlank(objId) ? null : objId.substring(0, 15);
	}


}