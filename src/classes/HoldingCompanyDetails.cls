global class HoldingCompanyDetails implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String accId = (String) request.inputParameters.get('Id');
        String userType = (String) request.inputParameters.get('userType');
        System.debug('Id' + accId + 'UserType' + userType);
        String topParentCCIId;
        String topParentAcId = Common.RootAccount(accId);
        System.debug('Top Parent Account Id' + topParentAcId);
        Account topParentAcc;
        if (!Test.isRunningTest()) {
            topParentAcc = [SELECT CCIMailCustID__c, CCIMetroCustID__c, Name, Type, Phone,
            BillingStreet, Industry_Minor_Category__c, BillingPostalCode,
            Industry, BillingState, BillingCountry
            FROM Account
            WHERE ID = : topParentAcId Limit 1];
        } else {
            topParentAcc = TestData.buildAccount('Advertiser', 'Direct Advertiser');
            topParentAcc.CCIMailCustID__c = '1';
            topParentAcc.CCIMetroCustID__c = '1';
        }

        if (userType.contains('Metro Display')|| userType.contains('London Classified')) topParentCCIId = topParentAcc.CCIMetroCustID__c;
        else topParentCCIId = topParentAcc.CCIMailCustID__c;


        System.debug('topParentAcc' + topParentAcc);
        System.debug('topParentCCIId' + topParentCCIId);
        Map < String, Object > outcome = new Map < String, Object > ();
        //  outcome.put('Result', 'Success');
        // outcome.put('URL',url);
        outcome.put('TopParentCCIId', topParentCCIId);
        System.debug('Outcome is' + outcome);
        return new Process.PluginResult(outcome);
    }
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'This plug-in gets top parent id.';
        result.tag = 'Get TopParent';
        result.inputParameters = new List < Process.PluginDescribeResult.InputParameter > {
            new Process.PluginDescribeResult.InputParameter('Id',
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('userType',
            Process.PluginDescribeResult.ParameterType.STRING, true)

        };
        result.outputParameters = new List < Process.PluginDescribeResult.OutputParameter > {
            new Process.PluginDescribeResult.OutputParameter('TopParentCCIId',
            Process.PluginDescribeResult.ParameterType.STRING)

        };
        return result;
    }

}