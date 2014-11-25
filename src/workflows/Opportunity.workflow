<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>A new deal has been signed</description>
        <protected>false</protected>
        <recipients>
            <recipient>minty.banfield@wowcher.co.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tom.bryan@wowcher.co.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>Alert_Deal_Analyst_When_Der_Lei_Stk_Lin_Lee_Deal_is_Signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>Alert Deal Analyst When Der/Lei/Stk/Lin/Lee Deal is Signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>Alert_Deal_Analyst_when_Notts_Birmingham_deal_is_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>Alert Deal Analyst when Notts/Birmingham deal is signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>Alert_Record_Owner_when_Deal_Goes_to_Approved_Scheduled</fullName>
        <description>Alert Record Owner when Deal Goes to Approved &amp; Scheduled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_is_Approved_and_Scheduled</template>
    </alerts>
    <alerts>
        <fullName>Alert_deal_owner_when_pitch_is_rejected</fullName>
        <description>Alert deal owner when pitch is rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Your_Pitch_has_been_rejected</template>
    </alerts>
    <alerts>
        <fullName>Email_to_merchant_liaison</fullName>
        <ccEmails>merchants@wowcher.co.uk</ccEmails>
        <description>Email to merchant liaison</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Wowcher_Templates/Deal_is_scheduled</template>
    </alerts>
    <alerts>
        <fullName>Feedback_is_due</fullName>
        <description>Feedback is due</description>
        <protected>false</protected>
        <recipients>
            <recipient>julian.boardman@wowcher.co.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Feedback_is_Due</template>
    </alerts>
    <alerts>
        <fullName>LDN_A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>LDN_A new deal has been signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>LDN_A_new_deal_has_been_signed_2</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>LDN_A new deal has been signed 2</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>MID_A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>MID_A new deal has been signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>NAT_A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>NAT_A new deal has been signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>NAT_A_new_deal_has_been_signed_2</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>NAT_A new deal has been signed 2</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>NAT_A_new_deal_has_been_signed_3</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>NAT_A new deal has been signed 3</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>NAT_A_new_deal_has_been_signed_4</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>NAT_A new deal has been signed 4</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>NAT_A_new_deal_has_been_signed_5</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>NAT_A new deal has been signed 5</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>SCOT_NTH_A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>SCOT_NTH_A new deal has been signed</description>
        <protected>false</protected>
        <recipients>
            <recipient>rebecca.johnson@wowcher.co.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>robert.carter@wowcher.co.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>Scheduled_Date_has_Changed</fullName>
        <description>Scheduled Date has Changed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Scheduled_Date_has_changed</template>
    </alerts>
    <alerts>
        <fullName>TRAVEL_A_new_deal_has_been_signed</fullName>
        <ccEmails>orderforms@wowcher.co.uk</ccEmails>
        <description>TRAVEL_A new deal has been signed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Wowcher_Templates/Deal_Is_signed2</template>
    </alerts>
    <alerts>
        <fullName>Your_deal_needs_changes</fullName>
        <description>Your deal needs changes</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Wowcher_Templates/Your_deal_needs_changes</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateActualCloseDate</fullName>
        <field>Actual_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>UpdateActualCloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCloseDate</fullName>
        <field>CloseDate</field>
        <formula>Today()</formula>
        <name>UpdateCloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIsNewBusiness</fullName>
        <description>Wowcher Update - if tick box &apos;New to Market&apos; is ticked then update &apos;Is New Business&apos; tick box to be ticked</description>
        <field>IsNew__c</field>
        <literalValue>1</literalValue>
        <name>UpdateIsNewBusiness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Wowcher_Merchant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Opportunity Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_s_Department</fullName>
        <field>Owners_Department__c</field>
        <formula>$Setup.ConstantsH__c.Department__c</formula>
        <name>Update Owner&apos;s Department</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Stage</fullName>
        <field>Previous_Stage__c</field>
        <formula>TEXT(PRIORVALUE(StageName))</formula>
        <name>Update Previous Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_stage_when_agreement_is_signed</fullName>
        <field>StageName</field>
        <literalValue>Signed</literalValue>
        <name>Update stage when agreement is signed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Alert Analyst when Feedback Is Due</fullName>
        <actions>
            <name>Feedback_is_due</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Wowcher_Feedback_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Feedback is due from the analyst</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Record Owner When Deal Is Rejected</fullName>
        <actions>
            <name>Alert_deal_owner_when_pitch_is_rejected</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Previous_Stage__c</field>
            <operation>notEqual</operation>
            <value>Signed rejected,Signed - rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed rejected,Signed - rejected</value>
        </criteriaItems>
        <description>Wowcher: Alert Record Owner When Deal is rejected</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Record Owner When Deal goes to Approved and Scheduled</fullName>
        <actions>
            <name>Alert_Record_Owner_when_Deal_Goes_to_Approved_Scheduled</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Previous_Stage__c</field>
            <operation>notEqual</operation>
            <value>Approved &amp; Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Approved &amp; Scheduled</value>
        </criteriaItems>
        <description>Wowcher: Alert Record Owner When Deal goes to Approved and Scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Sales About Opportunity Close Dates</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Won Business,Business Won,Closed Won,Lost Business,Closed Lost,Closed</value>
        </criteriaItems>
        <description>DO NOT ACTIVATE - Workflow rule to alert sales when opportunity close date is less than 7 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opp_due_for_closure</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Alert deal analysts when Der%2FLei%2FStk%2FLin%2FLee deal is signed</fullName>
        <actions>
            <name>Alert_Deal_Analyst_When_Der_Lei_Stk_Lin_Lee_Deal_is_Signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when London deal is signed</fullName>
        <actions>
            <name>LDN_A_new_deal_has_been_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>South East</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when London deal is signed 2</fullName>
        <actions>
            <name>LDN_A_new_deal_has_been_signed_2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>South East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>equals</operation>
            <value>David Pelter</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed oand pitch owner is David Pelter</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when Midlands deal is signed</fullName>
        <actions>
            <name>MID_A_new_deal_has_been_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>Midlands</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when NAT deal is signed</fullName>
        <actions>
            <name>NAT_A_new_deal_has_been_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when NAT deal is signed  3</fullName>
        <actions>
            <name>NAT_A_new_deal_has_been_signed_3</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 or 4 or 5)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Fashion</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Jewellery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Beauty</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed for Fashion or Jewellery or Beauty categories</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when NAT deal is signed  5</fullName>
        <actions>
            <name>NAT_A_new_deal_has_been_signed_5</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 or 4)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Beauty</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Electronics</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed for electronics or Beauty categories</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when NAT deal is signed 2</fullName>
        <actions>
            <name>NAT_A_new_deal_has_been_signed_2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND( (3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10) OR ((3 OR 4 OR 5 OR 6 OR 7 OR 8) AND(9 or 10))</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Fitness</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Learning</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>HealthCare</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>FoodBeverage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Activities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Home &amp; Garden</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>equals</operation>
            <value>Charlotte Pelter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>equals</operation>
            <value>Jabbar Shah</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed for cats  fitness learning /healthcare /foodbeverage/ activities / homegarden or pitch owner Charlotte Pelter or Jabbar Shah</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when NAT deal is signed 4</fullName>
        <actions>
            <name>NAT_A_new_deal_has_been_signed_4</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Electronics</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Category__c</field>
            <operation>equals</operation>
            <value>Home &amp; Garden</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed for cats  electronics or home and garden</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when Notts%2FBirmingham deal is signed</fullName>
        <actions>
            <name>Alert_Deal_Analyst_when_Notts_Birmingham_deal_is_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when Scot%2FNorth deal is signed</fullName>
        <actions>
            <name>SCOT_NTH_A_new_deal_has_been_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>Scotland</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>North East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>North West</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert deal analysts when Travel deal is signed</fullName>
        <actions>
            <name>TRAVEL_A_new_deal_has_been_signed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wowcher Merchant (ecomm),Wowcher Merchant (instore)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Deal_Region__c</field>
            <operation>equals</operation>
            <value>Travel</value>
        </criteriaItems>
        <description>This rule will alert the appropriate deal analyst when the deal is signed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert merchant liaison when deal is scheduled</fullName>
        <actions>
            <name>Email_to_merchant_liaison</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>A_new_deal_has_been_scheduled</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Record_Type__c</field>
            <operation>contains</operation>
            <value>Wowcher</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Approved &amp; Scheduled</value>
        </criteriaItems>
        <description>DO NOT REACTIVATE: When is a deal stage is set to approved scheduled, the merchant liaison are given a task and emailed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert pitch owner when scheduled date changes</fullName>
        <actions>
            <name>Scheduled_Date_has_Changed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>send email alert to the pitch owner when the scheduled date changes</description>
        <formula>ISCHANGED(Scheduled_Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alert rep when deal changed to pending sales action</fullName>
        <actions>
            <name>Your_deal_needs_changes</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Your_deal_needs_changes</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Record_Type__c</field>
            <operation>contains</operation>
            <value>Wowcher</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Pending Sales Action</value>
        </criteriaItems>
        <description>emails and creates task whenever a deal is changed to pending sales action</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Record Type</fullName>
        <actions>
            <name>Update_Opportunity_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>DO NOT ACTIVATE - Update the Opportunity to the Correct Record Type for Wowcher</description>
        <formula>Account.Lead_Record_Type_Name__c = &apos;Wowcher&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Previous Stage</fullName>
        <actions>
            <name>Update_Previous_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Previous Stage field when the field changes</description>
        <formula>ISPICKVAL(StageName, &quot;Closed Lost&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update stage when agreement is signed</fullName>
        <actions>
            <name>Update_stage_when_agreement_is_signed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>contains</operation>
            <value>Wowcher</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Agreement_Status__c</field>
            <operation>equals</operation>
            <value>Signed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateActualCloseDate</fullName>
        <actions>
            <name>UpdateActualCloseDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( IsWon,  IsClosed )  &amp;&amp;  !$Setup.No_Workflow__c.Flag__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateIsNewBusiness</fullName>
        <actions>
            <name>UpdateIsNewBusiness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.New_To_Market__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Record_Type__c</field>
            <operation>contains</operation>
            <value>instore</value>
        </criteriaItems>
        <description>Wowcher Update - if tick box &apos;New to Market&apos; is ticked then update &apos;Is New Business&apos; tick box to be ticked if the record type is in store</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>A_new_deal_has_been_scheduled</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>A new deal has been scheduled</subject>
    </tasks>
    <tasks>
        <fullName>Follow_Up_Task</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.Followup_Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow Up Task</subject>
    </tasks>
    <tasks>
        <fullName>LDN_This_deal_is_signed_and_needs_to_be_reviewed</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>LDNThis deal is signed and needs to be reviewed</subject>
    </tasks>
    <tasks>
        <fullName>MID_This_deal_is_signed_and_needs_to_be_reviewedMIDS</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>MIDThis deal is signed and needs to be reviewed</subject>
    </tasks>
    <tasks>
        <fullName>NAT_The_needs_to_be_reviewed</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>NATThis deal is signed and needs to be reviewed</subject>
    </tasks>
    <tasks>
        <fullName>Opp_due_for_closure</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity due for closure</subject>
    </tasks>
    <tasks>
        <fullName>SCOT_NTH_This_deal_is_signed_and_needs_to_be_reviewedSCOT</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>SCOTThis deal is signed and needs to be reviewed</subject>
    </tasks>
    <tasks>
        <fullName>TRAVEL_The_needs_to_be_reviewed</fullName>
        <assignedTo>julian.boardman@wowcher.co.uk</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>This deal is signed and needs to be reviewed - Travel</subject>
    </tasks>
    <tasks>
        <fullName>Your_deal_needs_changes</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Your deal needs changes</subject>
    </tasks>
</Workflow>
