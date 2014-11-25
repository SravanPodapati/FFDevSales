<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AccountMappingUniqueness</fullName>
        <field>UniqueSourceKey__c</field>
        <formula>IF( 
CONTAINS(Text(Source_System__c), &apos;CCI&apos;) , &apos;CCI&apos;, 
IF(CONTAINS(Text(Source_System__c),&apos;Advance&apos;), 
CASE( 
Account__r.RecordType.DeveloperName, 
&apos;Agency&apos;, Text(Source_System__c)+&apos;Agency&apos;, 
&apos;Advertiser&apos;, IF(CONTAINS(TEXT( Account__r.Type ),&apos;Brand&apos;),Text(Source_System__c)+&apos;Brand&apos;+IF(Brand_ID__c,&apos;Brand&apos;,null),Text(Source_System__c)+&apos;Advertiser&apos;+IF(Brand_ID__c,&apos;Brand&apos;,null)), 
Text(Source_System__c)+&apos;Advertiser&apos;+IF(Brand_ID__c,&apos;Brand&apos;,null )
), 
Text(Source_System__c) 
) ) + Source_Key__c</formula>
        <name>AccountMappingUniqueness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCCIMailCustId</fullName>
        <field>CCIMailCustID__c</field>
        <formula>IF( ISPICKVAL(Source_System__c,&apos;CCI Mail&apos; )&amp;&amp; !ISBLANK(Source_Key__c), Source_Key__c, Account__r.CCIMailCustID__c )</formula>
        <name>UpdateCCIMailCustId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCCIMailToNull</fullName>
        <field>CCIMailCustID__c</field>
        <name>UpdateCCIMailToNull</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCCIMetroCustId</fullName>
        <field>CCIMetroCustID__c</field>
        <formula>IF( ISPICKVAL(Source_System__c,&apos;CCI Metro&apos; )&amp;&amp; !ISBLANK(Source_Key__c), Source_Key__c, Account__r.CCIMetroCustID__c )</formula>
        <name>UpdateCCIMetroCustId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCCIMetroToNull</fullName>
        <field>CCIMetroCustID__c</field>
        <name>UpdateCCIMetroToNull</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>AccountMappingDeactivateCCIMail</fullName>
        <actions>
            <name>UpdateCCIMailToNull</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Mapping__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Mapping__c.UniqueSourceKey__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Mapping__c.Source_System__c</field>
            <operation>equals</operation>
            <value>CCI Mail</value>
        </criteriaItems>
        <description>On Account Mapping deactivate,update CCI Mapping field in Account to null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AccountMappingDeactivateCCIMetro</fullName>
        <actions>
            <name>UpdateCCIMetroToNull</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Mapping__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Mapping__c.UniqueSourceKey__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account_Mapping__c.Source_System__c</field>
            <operation>equals</operation>
            <value>CCI Metro</value>
        </criteriaItems>
        <description>On Account Mapping deactivate,update CCI Mapping field in Account to null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AccountMappingUniqueness</fullName>
        <actions>
            <name>AccountMappingUniqueness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AccountMappingUpdateCCI</fullName>
        <actions>
            <name>UpdateCCIMailCustId</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateCCIMetroCustId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Mapping__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
