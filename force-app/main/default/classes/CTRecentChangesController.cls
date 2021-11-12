public with sharing class CTRecentChangesController{
    @AuraEnabled
    public static List<Person__c> getRecentPersonHealthChanges(){
        return CTPersonController.getRecentHealthChanges();
    }

    public static List<Location__c> getRecentLocationHealthChanges(){
        return CTLocationController.getRecentStatusChanges();
    }

    public static List<Person__c> searchPeople(String searchTerm){
        return CTPersonController.searchPeople(searchTerm);
    }

    public static List<Location__c> searchLocation(String searchTerm){
        return CTLocationController.searchLocations(searchTerm);
    }
}