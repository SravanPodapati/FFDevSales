<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateIndustryMappingUniqueKey</fullName>
        <field>UniqueKey__c</field>
        <formula>TEXT(Industry__c) + Name</formula>
        <name>UpdateIndustryMappingUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateUniqueKeyOnIndustryMapping</fullName>
        <actions>
            <name>UpdateIndustryMappingUniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Industry_Category_Mapping__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
