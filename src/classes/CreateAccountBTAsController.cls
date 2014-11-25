/**
	Page to create Business Team Activities for Account.
*/
public with sharing class CreateAccountBTAsController {

	private final Account a { get; set; }
	public boolean HasBTAs { get; set; }
	
	public CreateAccountBTAsController(ApexPages.StandardController stdController)
	{
		this.a = (Account)stdController.getRecord();
		this.HasBTAs = [select count() from Business_Team_Activity__c where account__c = :this.a.id] > 0;
	}
	
	public PageReference CreateBTAs()
	{
		try
		{
			AccountBTAsUtility.CreateBTAs(a.id);
			return RedirectToAccountPage();
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
	
	public PageReference CancelCreateBTAs()
	{
		return RedirectToAccountPage();
	}
	
	private PageReference RedirectToAccountPage()
	{
		PageReference pr = new ApexPages.StandardController(a).view();
		pr.setRedirect(true);
		return pr;
	}
}