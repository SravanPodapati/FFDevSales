public class AllValueBackContractTriggerMethods {
    private Boolean isExecuting = false;
    private Integer BatchSize = 0;

    // CONSTRUCTOR
    public AllValueBackContractTriggerMethods(Boolean isExecuting, Integer size) {
        isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void onBeforeInsert(list<Value_BAck_Contract__c> newRecordsList ){
        
    }
}