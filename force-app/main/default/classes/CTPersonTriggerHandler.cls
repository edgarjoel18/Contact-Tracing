public with sharing class CTPersonTriggerHandler{
    public static void beforeInsert(List<Person__c> newRecords){
        for (Person__c person : newRecords){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        for (Person__c newPersonRecord : newRecords){
            // check if this newPersonRecord's health status is not the same as the previous one
            // If so update the date
            if (newPersonRecord.Health_Status__c != oldRecordsMap.get(newPersonRecord.id).Health_Status__c){
                newPersonRecord.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for (Person__c newPersonRecord : newRecords){
            // If the health status of a person changes then we need to update the locations
            if (newPersonRecord.Health_Status__c != oldRecordsMap.get(newPersonRecord.id).Health_Status__c){
                statusChange.add(newPersonRecord.Id);
            }
            if (newPersonRecord.Health_Status__c == 'Red' && oldRecordsMap.get(newPersonRecord.id).Health_Status__c != 'Red'){
                redStatus.add(newPersonRecord.Id);
            }
        }
        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(statusChange);
        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();
        List<Person__c> peopleToUpdate = new List<Person__c>();
        // add the primary contacts to orange and the cohabitants
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        orangeStatus.addAll(CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed));
        // add the secondary contacts and neighbors to the yellow status
        yellowStatus.addAll(CTPersonController.getNeighbors(redStatus, alreadyProcessed));
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(redStatus, alreadyProcessed));

        for (Id pid : orangeStatus){
            peopleToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Orange'));
        }
        for (Id pid : yellowStatus){
            peopleToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
        }

        if (peopleToUpdate.size() > 0){
            update peopleToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);
        if (locationTraces != null && locationTraces.size() > 0){
            Set<Id> locationsIds = new Set<Id>();
            for (Location_Tracing__c trace : locationTraces){
                locationsIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationsIds);
        }
    }
}