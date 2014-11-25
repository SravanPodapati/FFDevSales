public with sharing class TalendTestRestController
{
	private Id m_id;

	/**
     * Standard Controller constructor
     */
	public TalendTestRestController( ApexPages.StandardController stdController )
	{
		m_id = stdController.getId();
	}

	/**
	 * Test REST
	 */
	public PageReference testCallOut()
	{
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();

		req.setEndpoint(' https://dev.integrations.dmg-media.co.uk/services/dmg/EsbTrigger?targetSys=DocOutput&ObjectId=' + m_id);
		req.setMethod('GET');

		req.setCompressed(true); // otherwise we hit a limit of 32000

		try 
		{
		    res = http.send(req);
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Response=' + res.toString() ) );
		} 
		catch(System.CalloutException e) 
		{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Exception=' + e ) );
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Response=' + res.toString() ) );
		}

		return null; 
	}


}