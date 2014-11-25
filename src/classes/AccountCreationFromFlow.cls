global class AccountCreationFromFlow implements Process.Plugin {
	global Process.PluginResult invoke(Process.PluginRequest request) {
		String accId = (String) request.inputParameters.get('Id');
		String bookingAgency = (String) request.inputParameters.get('BookingAgency');
		String billingAgency = (String) request.inputParameters.get('BillingAgency');
		System.debug('accId = ' + accId + 'BookingAgency = ' + bookingAgency + 'BillingAgency = ' + billingAgency);
		// in addition to to adding the calculation below, to use this in the Visual Workflow Workbook, tutorial #3,
		String cciCustomerAgencyId = CCICustomerWebService.createCCICustomer(billingAgency, 'Mail', true);
		if (cciCustomerAgencyId == null || (cciCustomerAgencyId != null && cciCustomerAgencyId.contains('exception'))) {
			cciCustomerAgencyId = 'Fail';
		}
		Map < String, Object > outcome = new Map < String, Object > ();
		//  outcome.put('Result', 'Success');
		// outcome.put('URL',url);
		outcome.put('CCICusAgencyId', cciCustomerAgencyId);
		// outcome.put('FinId',billingAgency);
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
			new Process.PluginDescribeResult.InputParameter('BillingAgency',
			Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('BookingAgency',
			Process.PluginDescribeResult.ParameterType.STRING, true)
		};
		result.outputParameters = new List < Process.PluginDescribeResult.OutputParameter > {
			new Process.PluginDescribeResult.OutputParameter('CCICusAgencyId',
			Process.PluginDescribeResult.ParameterType.STRING)
			//   , new Process.PluginDescribeResult.OutputParameter('FinId',
			//  Process.PluginDescribeResult.ParameterType.STRING)
		};
		return result;
	}

}