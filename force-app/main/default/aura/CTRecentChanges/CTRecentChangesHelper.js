({
    fetchRecentHealthChanges : function(component) {
        // call our server side functions
        let action = component.get('v.scope') === 'person'? component.get('c.getRecentPersonHealthChanges'): component.get('c.getRecentLocationHealthChanges')
        // define callback
        action.setCallback(this, (response) => {
            const state = response.getState();
            if(state === 'SUCCESSFUL'){
                // get the data from the return value
                const data = response.getReturnValue();
                component.set('v.data', data); 
            }
        });
        $A.enqueueAction(action);
    },

    searchRecord: function(component, queryTerm){
        let action = component.get('v.scope') === 'person'? component.get('c.searchPeople'): component.get('c.searchLocation');
        action.setParams({
            "searchTerm": queryTerm
        });
        action.setCallback(this, (response) => {
            const state = response.getState();
            if(state === 'SUCCESS'){
                const data = response.getReturnValue();
                if(data && data.length > 0){
                    component.set('v.data', data);
                    component.set('v.initialResponse', data)
                }
                component.set('v.issearching', false);
            }
        })
        $A.enqueueAction(action);
    }

})
