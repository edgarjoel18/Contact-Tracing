public with sharing class CTLocationTracingController {
    /**
     * Get the visitors from a location in the last 30 days
     * @param locationId
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
        FROM Location_Tracing__c WHERE Id =:locationId ORDER BY Visit_Date__c DESC];
    }

    /**
     * Get a list of locations given a set of person ids
     * @param personIds
     * @return List<Location_Tracing__c>
     */
    // LAST_N_DAYS: 10 is the same as LAST_N_DAYS=10
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        return [SELECT Id, Person__c, Location__c
        FROM Location_Tracing__c WHERE Person__c IN :personIds AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * Get a list of locations given a set of location ids
     * @param locationIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id, Person__c, Location__c
        FROM Location_Tracing__c WHERE Location__c IN :locationIds 
        AND Person__r.Health_Status__c = 'Green' 
        AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTracers){
        // store unique location ids
        Set<Id> locationIds = new Set<Id>();
        // store unique person ids
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace: newLocationTracers){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        // Map of location id and a Set of person ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
        // location1, [personId1, personId2]
        // query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c
        FROM Location_Tracing__c WHERE Location__c IN :locationIds AND Person__c IN :personIds];

        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        if(existingRecords != null && existingRecords.size() > 0){
            for(Location_Tracing__c trace: newLocationTracers){
                if(!mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }
            // loop over new location tracing records
            for(Location_Tracing__c trace: newLocationTracers){
                if(mapOfExistingRecords.containsKey(trace.Location__c) && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                    duplicates.add(trace);
                }
            }
        } // end of if
        return duplicates;
    }



}