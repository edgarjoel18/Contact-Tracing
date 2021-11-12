public with sharing class CTHealthHeaderController{
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatusCount(){
        // string stores the health status, integer stores the count of the number of people in that health status
        return CTPersonController.getHealthStatusCount();
    }

    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount(){
        return CTLocationController.getHealthStatusCount();
    }
}