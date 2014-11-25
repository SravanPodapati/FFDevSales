global with sharing class SendSuccessEmailStep
    implements ffps_dmgcp.ISynchronousProcessStep
{
    private Boolean m_hasSucceeded;
    private Boolean m_hasWarnings;
    private List<ffps_dmgcp.Log> m_logs;

    global SendSuccessEmailStep()
    {   
        m_logs = new List<ffps_dmgcp.Log>();
    }

    /**
     * Register Process Configuration used by this Process Step
     *
     * Arguments:   n/a
     *
     * Returns:     A List of ffps_dmgcp.Config objects
     */
    global List<ffps_dmgcp.Config> registerConfig()
    {
        List<ffps_dmgcp.Config> configuration = new List<ffps_dmgcp.Config>();
        
        configuration.add(new ffps_dmgcp.Config('To Name', '', 'Enter the receipients name.'));
        configuration.add(new ffps_dmgcp.Config('Email', '', 'Enter the receipients email address.'));

        return configuration;
    }
    
    /**
     * Register Process Instance Variables used by this Process Step
     *
     * Arguments:   n/a
     *
     * Returns:     A List of ffps_dmgcp.InstanceVariable objects
     */
    global List<ffps_dmgcp.InstanceVariable> registerInstanceVariables()
    {
        List<ffps_dmgcp.InstanceVariable> variables = new List<ffps_dmgcp.InstanceVariable>();
        
        variables.add(new ffps_dmgcp.InstanceVariable('Email Sent', ffps_dmgcp.InstanceVariable.VarType.TYPE_BOOLEAN, true));

        return variables;
    }
    
    /**
     * Execute the Process Step - This is called when the step is executed
     *
     * Arguments:   Map<String, ffps_dmgcp.Config>          Map of all the ffps_dmgcp.Config keyed on Name
     *              Map<String, ffps_dmgcp.InstanceVariable>    Map of all the Instance Variables keyed on Name
     */
    global void execute(Map<String, ffps_dmgcp.Config> configMap, Map<String, ffps_dmgcp.InstanceVariable> instanceVariableMap)
    {
        // Get the Config Values
        ffps_dmgcp.Config nameCfg = configMap.get('To Name');

        if (nameCfg == null || String.isEmpty(nameCfg.getStringValue()))
        {
            throw new StepException('No To Name defined.');
        }

        String name = nameCfg.getStringValue();

        ffps_dmgcp.Config emailCfg = configMap.get('Email');

        if (emailCfg == null || String.isEmpty(emailCfg.getStringValue()))
        {
            throw new StepException('No Email defined.');
        }

        String email = emailCfg.getStringValue();

        // Determine if this is the first step
        ffps_dmgcp.InstanceVariable firstStepVar = instanceVariableMap.get('#IsFirstStep');

        // Get the success status of the last step
        ffps_dmgcp.InstanceVariable successVar = instanceVariableMap.get('#LastStepSucceeded');

        Boolean success;

        if (firstStepVar.getBooleanValue() == true || successVar.getBooleanValue() == true)
        {
            success = true;
        }
        else
        {
            success = false;
        }

        try
        {
            Messaging.reserveSingleEmailCapacity(1);

            // Send out an Email with a Report
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { email });

            if (success)
            {
                mail.setSubject('Process Succeeded');
                mail.setPlainTextBody('Congratulations the process has completed!\n\n');
            }
            else
            {
                mail.setSubject('Process Failed');
                mail.setPlainTextBody('Unfortunately the process has failed!\n\n');
            }            

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            instanceVariableMap.get('Email Sent').setValue(true);
            m_hasSucceeded = true;
        }
        catch (Exception e)
        {
            instanceVariableMap.get('Email Sent').setValue(false);
            m_logs.add(new ffps_dmgcp.Log(e.getMessage()));
            m_hasSucceeded = false;
        }
    }

    /**
     * Returns the Success state of the Process Step
     *
     * Arguments:   n/a
     *
     * Returns:     Boolean True if Suceeded
     */
    global Boolean hasSucceeded()
    {
        return m_hasSucceeded;
    }
    
    /**
     * Returns the Warning state of the Process Step
     *
     * Arguments:   n/a
     *
     * Returns:     Boolean True if Warnings exist
     */
    global Boolean hasWarnings()
    {
        return m_hasWarnings;
    }

    /**
     * Returns the Log messages to write away
     * Arguments:   n/a
     *
     * Returns:     List of Log objects
     */
    global List<ffps_dmgcp.Log> getLogs()
    {
        return m_logs;
    }   

    /**
     * Returns true if it can execute in batch
     * Arguments:   n/a
     *
     * Returns:     Boolean
     */
    public Boolean canRunInBatch()
    {
        return true;
    }

    public class StepException extends Exception {}
}