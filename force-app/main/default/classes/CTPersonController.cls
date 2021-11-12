public with sharing class CTPersonController{
    // create a hash from the user's mobile number
    public static String getToken(String mobileNumber){
        // Turn the string into a blob
        Blob value = Blob.valueOf(mobileNumber);
        Blob hash = Crypto.generateDigest('MD5', value);
        // turn it back into a string
        return EncodingUtil.base64Encode(hash);
    }

    /**
     * Get 100 contacts with recent health status changes
     * @return List<Person__c>
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                ORDER BY Status_Update_Date__C DESC
                NULLS LAST
                LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm += '%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                FROM Person__c
                WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC
                NULLS LAST];
    }

    /**
     * Get 100 contacts with recent health status changes
     * @return List<Person__c>
     */
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                  FROM Person__c
                                  WHERE Id = :personId];
        if (people != null && people.size() > 0){
            return people[0];
        }
        return null;
    }

    // public static Map<String, Integer> getHealthStatusCount(){
    //     Map<String, Integer> healthCountMap = new Map<String, Integer>();
    //     for (AggregateResult ar : [SELECT Health_Status__c, COUNT(Id)total
    //                                FROM Person__c
    //                                GROUP BY Health_Status__c]){
    //         String healthStatus = String.valueOf(ar.get('Health_Status__c'));
    //         Integer count = Integer.valueOf(ar.get('total'));
    //         healthCountMap.put(healthStatus, count);
    //     }
    //     return healthCountMap;
    // }
    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{ 'Green', 'Yellow' };

        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                from People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) AND (Contact_Type__c = 'Cohabitant') AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];

        // check whether person 1 id or person 2 id exists in personIds
        Set<Id> cohabitants = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbors(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                from People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) AND (Contact_Type__c = 'Neighbor') AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        // check whether person 1 id or person 2 id exists in personIds
        Set<Id> neighbors = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                neighbors.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                neighbors.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return neighbors;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{ 'Green', 'Yellow' };
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) AND (Contact_Type__c = 'Other') AND (Contact_Date__c = LAST_N_DAYS:10) AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];

        // check whether person 1 id or person 2 id exists in personIds
        Set<Id> primaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContacts, Set<Id> alreadyProcessed){
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c
                                                from People_Tracing__c
                                                WHERE (Person_1__c IN :primaryContacts OR Person_2__c IN :primaryContacts) AND (Contact_Type__c = 'Other') AND (Contact_Date__c = LAST_N_DAYS:10) AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        // check whether person 1 id or person 2 id exists in primaryContacts
        Set<Id> secondaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces){
            if (!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if (!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }

    public static Map<String, Integer> getHealthStatusCount(){
        AggregateResult[] healthCountMap = [SELECT Status__c, Count(Id)total
                                            FROM Location__c
                                            GROUP BY Status__c];
        if (healthCountMap != null && healthCountMap.size() > 0){
            Map<String, Integer> result = new Map<String, Integer>();
            for (AggregateResult healthCount : healthCountMap){
                result.put(String.valueOf(healthCount.get('Status__c')), Integer.valueOf(healthCount.get('total')));
            }
            return result;
        }
        return null;
    }
}