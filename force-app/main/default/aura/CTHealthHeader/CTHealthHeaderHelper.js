({
    fetchStatusCount: function(component, event, helper) {
        const scope = component.get('v.scope');
        let action = scope==="person"? component.get('c.getPersonHealthStatusCount'): component.get('c.getLocationHealthStatusCount');
        action.setCallback(this, function(response){
            const stateOfResponse = response.getState();
            if(stateOfResponse === 'SUCCESS'){
                component.set('v.count', response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    }
})
