public with sharing class CTLocationTriggerHandler {
    // passing the list by reference
    public static void beforeInsert(List<Location__c> newRecords){
        for(Location__c newRecord: newRecords){
            newRecord.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        for(Location__c newRecord: newRecords){
            if(newRecord.Status__c != oldRecordsMap.get(newRecord.Id).Status__c){
                newRecord.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();
        for(Location__c newRecord: newRecords){
            if(newRecord.Status__c == 'Red' && oldRecordsMap.get(newRecord.Id).Status__c != 'Red'){
                statusChange.add(newRecord.Id);
            }
        }
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChange);
        Set<Id> personIds = new Set<Id>();
        for(Location_Tracing__c locationTrace: locationTraces){
            personIds.add(locationTrace.Person__c);
        }

        List<Person__c> peopleToUpdate = new List<Person__c>();
        for(Id pid: personIds){
            peopleToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }
        if(peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }
    }



}
