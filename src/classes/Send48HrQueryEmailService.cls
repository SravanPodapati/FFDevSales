/**
 * Scheduleble Service class for Sending the 48 Hour email reminders
 */
public without sharing class Send48HrQueryEmailService 
	implements System.Schedulable
{
	private DateTime m_targetDateTime;

	@TestVisible private static DateTime s_testDate;

	private Enum Weekday {SATURDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY}

	public Send48HrQueryEmailService()
	{
		// Determine 48 weekday hours have passed
		DateTime thisIsNow = s_testDate == null ? System.now() : s_testDate;

		// If today is a monday or tuesday, subtract 48 + the weekend (48) = 96
		Weekday dow = getDOW(thisIsNow);
		
		if (dow == Weekday.MONDAY || dow == Weekday.TUESDAY)
		{
			m_targetDateTime = thisIsNow.addDays(-4);
		}
		else
		{
			m_targetDateTime = thisIsNow.addDays(-2);	
		}
	}
	
	public void execute(SchedulableContext context)
	{
		System.debug('>>> m_targetDateTime=' + m_targetDateTime);
		
		List<Query__c> queries = QueryGateway.findOverdueQueries(m_targetDateTime);
		
		System.debug('>>> queries=' + queries);

		for (Query__c q : queries)
		{
			q.Send48HrEmail__c = true;
		}

		update queries;
	}

	private Weekday getDOW(DateTime myDateTime)
	{
		Date startDate = Date.newInstance(0001, 1, 1);  
		List<Weekday> listDay = new List<Weekday>{Weekday.SATURDAY, Weekday.SUNDAY, Weekday.MONDAY, Weekday.TUESDAY,
												 Weekday.WEDNESDAY, Weekday.THURSDAY, Weekday.FRIDAY};

		Integer remainder = Math.mod(startDate.daysBetween(myDateTime.date()) , 7);  
        return listDay.get(remainder); 		
	}
	
	public class BatchException extends Exception {}
}