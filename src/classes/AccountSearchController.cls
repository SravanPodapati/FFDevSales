public class AccountSearchController {

	public String accountName {get; set;}
	public String recordTypeID {get; set;}
	public String postCode {get; set;}
	public String alias {get; set;}
	public String sortOption {get; set;}
	public String sortDirection {get; set;}
	public integer accountSearchLimit {get; set;}
	public integer sizeOfSearchResults {get; set;}
	public string requestedToSearch {get; set;}

	/*
	 * Constructure
	 ***/
	public AccountSearchController(ApexPages.StandardController controller) {
		this.sortOption = 'Name';
		this.sortDirection = 'ASC';
		this.getRecordTypes();
		this.accountSearchLimit = 100;
		this.requestedToSearch = '0';
	}

	/*
	 * This method queries data according to the passed parameters
	 ***/@RemoteAction
	public static List < Sobject > getData(String param, String selectedType) {
		param = String.escapeSingleQuotes(param);
		list < Sobject > accountlist;

		if (param == null) {
			param = '';
		}

		if (selectedType != null && selectedType != '') {
			accountlist = new list < Sobject > (Database.query('SELECT ID, Name FROM Account WHERE Name LIKE \'' + param + '%\' and RecordTypeID=\'' + selectedType + '\''));
		} else {
			accountlist = new list < Sobject > (Database.query('SELECT ID, Name FROM Account WHERE Name LIKE \'' + param + '%\''));
		}
		return accountlist;
	}

	public Pagereference doSearch() {
		this.requestedToSearch = '1';
		system.debug('***in search method***');
		return null;
	}

	/*
	 * This method returns all the available record types and its IDs as a list of Select Options 
	 ***/
	public list < SelectOption > getRecordTypes() {
		list < SelectOption > recordTypesList = new list < SelectOption > ();
		recordTypesList.add(new SelectOption('', 'All'));
		//Describe the Account Object. 
		Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
		for (Schema.RecordTypeInfo rT: accountDescribe.getRecordTypeInfos()) {
			//remove Master from picklist as it should not visible to the users
			if (rt.isAvailable()) {
				if (rt.getName().toUpperCase() != 'MASTER') {
					recordTypesList.add(new SelectOption(rT.getRecordTypeId(), rt.getName()));
				}
			}
		}
		//update the default record Type 
		this.recordTypeID = recordTypesList[0].getValue();

		return recordTypesList;
	}

	/*
	 * This method return the list of Accounts for the given search perameters
	 ***/
	public list < Account > getSearchAccounts() {
		system.debug('***requestedToSearch: ' + requestedToSearch);
		list < Account > resultAccountsList = new list < Account > ();
		if ((this.alias != null && this.alias != '') || (this.accountName != null && this.accountName != '') || (this.postCode != null && this.postCode != '')) {
			//build the query
			String query = buildQuery();

			system.debug('***query : ' + query);
			//Get the size of search results
			this.sizeOfSearchResults = database.query(query).size();

			//append the limit to query string limit the Search to 100. 
			query += ' LIMIT ' + this.accountSearchLimit;

			//retrive the search results that display on the page. 
			resultAccountsList = database.query(query);

			Utility_DynamicSort uDS = new Utility_DynamicSort();
			resultAccountsList = uDS.sObjectListSort(resultAccountsList, this.sortOption, this.sortDirection);
		} else {
			this.sizeOfSearchResults = 0;
		}
		return resultAccountsList;
	}

	/*
	 * This method return the fields from field set
	 ***/
	public List < Schema.FieldSetMember > getFields() {
		return SObjectType.Account.FieldSets.Search_Results.getFields();
	}

	/*
	 * This method build and returns a SOQL query as a string
	 ***/
	private string buildQuery() {
		string query = 'SELECT ';
		//Append field API names from Fied Sets to query string
		for (Schema.FieldSetMember fM: getFields()) {
			query += fM.getFieldPath() + ', ';
		}

		//Append Record Id if it is not available in query sting 
		if (!query.toUpperCase().contains('ID,')) {
			query += 'id, ';
		}

		//append Record Name if it is not available in query string 
		if (!query.toUpperCase().contains('NAME,')) {
			query += 'Name, ';
		}

		//removes the last comma from query string
		if (query.endsWith(', ')) {
			query = query.substring(0, query.length() - 2);
		}

		//append account name 
		if (this.accountName == null) {
			this.accountName = '';
		} else {
			this.accountName = this.accountName.trim();
		}
		query += ' FROM Account where (Name like \'%' + string.escapeSingleQuotes(this.accountName) + '%\')';

		if (this.accountName != '') {
			if (this.accountName.endsWith('*')) {
				String nameStr = this.accountName;
				Integer indexWildChar = nameStr.lastIndexOf('*');
				this.accountName = nameStr.subString(0, indexWildChar);
				System.debug('AccountName is' + this.accountName);
			}
			set < Id > aliasAccountIdsSet = new set < ID > ();
			//query the alias accounts
			string aliaseQuery = 'SELECT ID, Name, Account__c from Account_Alias__c where Is_Active__c = true and Name LIKE \'%' + string.escapeSingleQuotes(this.accountName) + '%\'';
			list < Account_Alias__c > resultAliases = new list < Account_Alias__c > ();
			resultAliases = database.query(aliaseQuery);

			for (Account_Alias__c aA: resultAliases) {
				if (aA.Account__c != null) aliasAccountIdsSet.add(aA.Account__c);
			}

			//append the alias to query
			if (aliasAccountIdsSet.size() > 0) {
				//string tempQuery = query;
				query = query.substring(0, query.lastIndexOf(')'));
				query += ' OR ID IN (';
				for (id accountID: aliasAccountIdsSet) {
					query += '\'' + accountID + '\',';
				}
				query = query.subString(0, query.length() - 1) + '))';
			}
		}

		//append post code to query string
		if (this.postCode != null && this.postCode != '') {
			this.postCode = this.postCode.trim();
			if (this.postCode.endsWith('*')) {
				String postCodeStr = this.postCode;
				Integer indexWildChar = postCodeStr.lastIndexOf('*');
				this.postCode = postCodeStr.subString(0, indexWildChar);
				System.debug('postCode is' + this.postCode);
			}
			query += ' and (BillingPostalCode like \'' + string.escapeSingleQuotes(this.postCode) + '%\' OR Post_Code__c like \'' + string.escapeSingleQuotes(this.postCode) + '%\') ';

		}

		//append recordtype if selected
		if (this.recordTypeID != null && this.recordTypeID != '') {
			query += 'and recordTypeID= \'' + this.recordTypeID + '\'';
		}

		//Sort Direction
		//query += ' ORDER BY '+this.sortOption+' '+this.sortDirection;
		system.debug('***query : ' + query + '***');

		return query;
	}

	public Pagereference clear() {
		this.recordTypeID = getRecordTypes()[0].getValue();
		this.accountName = null;
		this.postCode = null;
		return null;
	}

}