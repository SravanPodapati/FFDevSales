global class CCIAccountCreationFromFlow implements Process.Plugin {
	global Process.PluginResult invoke(Process.PluginRequest request) {
		String finAccs = (String) request.inputParameters.get('FinAccs');
		//  dateTime uniqueKey = (dateTime)request.inputParameters.get('uniquekey');
		//  System.debug('Unique Key is'+ uniqueKey );
		String sopId;
		String sopSource;
		String cciAccountId;

		try {
			//  CCIAccountWebService.createCCIAccountFromOrder(finAccs,uniqueKey );
			CCIAccountWebService.createCCIAccountFromOrder(finAccs);
			//sopId = cciAccountId;
			// sopSource = 'CCI';
		} catch (Exception e) {

		}
		Map < String, Object > outcome = new Map < String, Object > ();

		outcome.put('sopId', '');
		outcome.put('sopSource', '');

		return new Process.PluginResult(outcome);
	}
	global Process.PluginDescribeResult describe() {
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.description = 'This plug-in generates an order.';
		result.tag = 'Create Order';
		result.inputParameters = new List < Process.PluginDescribeResult.InputParameter > {
			new Process.PluginDescribeResult.InputParameter('FinAccs',
			Process.PluginDescribeResult.ParameterType.STRING, true)
			/*,
                  new Process.PluginDescribeResult.InputParameter('uniquekey',
                Process.PluginDescribeResult.ParameterType.dateTime, true)*/

		};
		result.outputParameters = new List < Process.PluginDescribeResult.OutputParameter > {
			new Process.PluginDescribeResult.OutputParameter('sopId',
			Process.PluginDescribeResult.ParameterType.STRING),
			new Process.PluginDescribeResult.OutputParameter('sopSource',
			Process.PluginDescribeResult.ParameterType.STRING)


		};
		return result;
	}
}