/*******************************************************************************************
********************************************************************************************
****                                                                                    ****
****    RevenueSchedule is used to perform custom revenue scheduling.  Inputs are       ****
****    a Start Date, End Date and Amount which is then split scheduled monthly.        ****
****                                                                                    ****
********************************************************************************************
*******************************************************************************************/

public class RevenueSchedule
{    
    public static Boolean recordProcessed = false;
    public static Set<Id> processedIds = new Set<Id>();
    // Class to represent each Schedule Item
    public class RevenueScheduleItem
    {
        public String scheduleMonth;
        public Decimal scheduleAmount;
        public Date scheduleDate;
    }

    // Take the start date, end date and amount and output a list of items for revenue scheduling
    public List<RevenueScheduleItem> generateSchedule(Date startDate, Date endDate, Decimal amount)
    {
        // Output Parameters to check
        //System.Debug('----->Inside generateSchedule - Input Parameters');
        //System.Debug('----->Start Date: '+startDate);
        //System.Debug('----->End Date: '+endDate);   
        //System.Debug('----->Amount: '+amount);      
        //System.Debug('----->Start Month: '+startDate.month());
        //System.Debug('----->End Month: '+endDate.month());

        // Declare variables
        
        Integer numberofDays = 1;
        if (endDate != null) 
        {
            numberofDays = startDate.daysBetween(endDate);
            if(numberofDays==0)
            {
                numberofDays=1;
            }
        }
        Decimal dailyAmount = 0.00;
        Decimal reconcileAmount = 0.00;

        String RevenueMonth = null;
        Decimal RevenueAmount = 0.00;
        
        Map<String,Decimal> outputSchedule = new Map<String,Decimal>();
        Map<String,String> revPeriodMap = new Map<String,String>();
        
        revPeriodMap.put('1','January');
        revPeriodMap.put('2','February');
        revPeriodMap.put('3','March');
        revPeriodMap.put('4','April');
        revPeriodMap.put('5','May');
        revPeriodMap.put('6','June');
        revPeriodMap.put('7','July');
        revPeriodMap.put('8','August');
        revPeriodMap.put('9','Setptember');
        revPeriodMap.put('10','October');
        revPeriodMap.put('11','November');
        revPeriodMap.put('12','December');

        List<RevenueScheduleItem> outputSchduleLine = new List<RevenueScheduleItem>();
        
        // Work out the daily amount
        if (amount != null && amount != 0.00)
        {
            dailyAmount = amount/numberofDays;
        }
        
        // Check that the end date is after or on the start date        
        If (endDate != null && endDate >= startDate)
        {
            Integer monthsInBetween = startDate.monthsBetween(endDate);

            // Loop through each month between the start date and end date
            for (Integer i = 0; i <= monthsInBetween; i++) 
            {
                RevenueScheduleItem currentLine = new RevenueScheduleItem();

                // Pro-rate the initial month
                if (i == 0) 
                {
                    // Exception for when start and end date are in the same month
                    if (monthsInBetween == 0) 
                    {
                        RevenueMonth = revPeriodMap.get(string.valueOf(startDate.addMonths(i).month())) + ' ' + string.valueOf(startDate.addMonths(i).year());
                        RevenueAmount = dailyAmount * numberofDays;
                        currentLine.scheduleDate = startDate.addMonths(i).toStartOfMonth();
                        currentLine.scheduleMonth = RevenueMonth;
                        currentLine.scheduleAmount = RevenueAmount;
                        reconcileAmount = reconcileAmount+RevenueAmount;
                        System.Debug('----->Period/Amount INITIAL: '+RevenueMonth+' / '+RevenueAmount+' ATD: '+reconcileAmount);
                        outputSchedule.put(RevenueMonth,RevenueAmount);
                        outputSchduleLine.add(currentLine);
                        currentLine = null;

                        continue;
                    }
                    
                    RevenueMonth = revPeriodMap.get(string.valueOf(startDate.addMonths(i).month())) + ' ' + string.valueOf(startDate.addMonths(i).year());
                    RevenueAmount = dailyAmount * (date.daysInMonth(startDate.year(), startDate.month()) - startDate.day());
                    currentLine.scheduleDate = startDate.addMonths(i).toStartOfMonth();
                    currentLine.scheduleMonth = RevenueMonth;
                    currentLine.scheduleAmount = RevenueAmount;
                    reconcileAmount = reconcileAmount+RevenueAmount;
                    System.Debug('----->Period/Amount INITIAL: '+RevenueMonth+' / '+RevenueAmount+' ATD: '+reconcileAmount);
                    outputSchedule.put(RevenueMonth,RevenueAmount);
                    outputSchduleLine.add(currentLine);
                    currentLine = null;

                    continue;
                }
                
                // Pro-rate the final month
                if (i == monthsInBetween) 
                {
                    RevenueMonth = revPeriodMap.get(string.valueOf(startDate.addMonths(i).month())) + ' ' + string.valueOf(startDate.addMonths(i).year());
                    RevenueAmount = dailyAmount * endDate.day();
                    currentLine.scheduleDate = startDate.addMonths(i).toStartOfMonth();
                    currentLine.scheduleMonth = RevenueMonth;
                    currentLine.scheduleAmount = RevenueAmount;
                    reconcileAmount = reconcileAmount+RevenueAmount;

                    System.Debug('----->Period/Amount FINAL: '+RevenueMonth+' / '+RevenueAmount+' ATD: '+reconcileAmount);

                    outputSchedule.put(RevenueMonth,RevenueAmount);
                    outputSchduleLine.add(currentLine);
                    currentLine = null;

                    continue;
                }
                
                // Calculate the revenue for each month
                RevenueMonth = revPeriodMap.get(string.valueOf(startDate.addMonths(i).month())) + ' ' + string.valueOf(startDate.addMonths(i).year());
                RevenueAmount = dailyAmount * (date.daysInMonth(startDate.addMonths(i).year(),startDate.addMonths(i).month()));
                currentLine.scheduleDate = startDate.addMonths(i).toStartOfMonth();
                currentLine.scheduleMonth = RevenueMonth;
                currentLine.scheduleAmount = RevenueAmount; 
                reconcileAmount = reconcileAmount+RevenueAmount;
                outputSchedule.put(RevenueMonth,RevenueAmount);
                outputSchduleLine.add(currentLine);

                System.Debug('----->Period/Amount: '+RevenueMonth+' / '+RevenueAmount+' ATD: '+reconcileAmount);

                currentLine = null;
            }
                              
            //System.Debug('----->Days: '+numberofDays);
            //System.Debug('----->Daily Amount: '+dailyAmount);
            //System.Debug('----->Final Total: '+reconcileAmount);
            //System.Debug('----->Output: '+outputSchduleLine);
                                
        }
        return outputSchduleLine;
    } // end generateSchedule    
}