public with sharing class MergeAccountBTAsController 
{
	private final Account a { get; set; }
	
	public MergeAccountBTAsController(ApexPages.StandardController stdController)
	{
		this.a = (Account)stdController.getRecord();
	}

	public PageReference MergeBTAs()
	{
		AccountMergeUtility.MergeAccountsBusinessTeamActivities(new id[] { this.a.id });
		return RedirectToAccountPage();
	}
	
	public PageReference CancelMergeBTAs()
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