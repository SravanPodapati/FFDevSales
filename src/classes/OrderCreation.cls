global class OrderCreation implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String accId = (String) request.inputParameters.get('Id');
        String bookingAgency = (String) request.inputParameters.get('BookingAgency');
        String billingAgency = (String) request.inputParameters.get('BillingAgency');
        String dbType = (String) request.inputParameters.get('DBType');
        System.debug('accId = ' + accId + 'BookingAgency = ' + bookingAgency + 'BillingAgency = ' + billingAgency+'dbType='+dbType);
      //  String cciCustomerId = CCICustomerWebService.createCCICustomer(accId, 'Mail', true);
        String cciCustomerId = CCICustomerWebService.createCCICustomer(accId, dbtype, true);
        System.debug('ccicustomerid' + cciCustomerId);
        if (cciCustomerId == null || (cciCustomerId != null && cciCustomerId.contains('exception'))) {
            cciCustomerId = 'Fail';
        }
        System.debug('ccicustomerid' + cciCustomerId);
        Map < String, Object > outcome = new Map < String, Object > ();
        //  outcome.put('Result', 'Success');
        // outcome.put('URL',url);
        outcome.put('CCICusId', cciCustomerId);
        System.debug('Outcome is' + outcome);
        return new Process.PluginResult(outcome);
    }
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'This plug-in generates an order.';
        result.tag = 'Create Order';
        result.inputParameters = new List < Process.PluginDescribeResult.InputParameter > {
            new Process.PluginDescribeResult.InputParameter('Id',
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('DBType',
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('BillingAgency',
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('BookingAgency',
            Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List < Process.PluginDescribeResult.OutputParameter > {
            new Process.PluginDescribeResult.OutputParameter('CCICusId',
            Process.PluginDescribeResult.ParameterType.STRING)

        };
        return result;
    }

}