@RestResource(urlMapping='/RESTPopulateSalesRevenueOnAccount/*')
global with sharing class RESTPopulateSalesRevenueOnAccount 
{
    @HttpGet
    global static String PopulateSalesRevenue()
    {
          //ID batchprocessid = database.executebatch(new BatchAccountRevenueUpdateLastMonth() , 50);
          BatchAccountResetRevenue.StartBatch();
          return '200';
    }   
}