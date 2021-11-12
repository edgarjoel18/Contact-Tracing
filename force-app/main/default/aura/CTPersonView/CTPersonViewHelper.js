({
    updateStatus : function(component) {
        const recordID = component.get('v.recordId');
        const action = component.get('c.updateHealthStatus');
        action.setParams({
            personId: recordId
        })
        action.setCallback(this, (response) => {
            const state = response.getState();
            if(state === 'SUCCESS'){
                this.showToast('Success', 'Person Health Status Update', 'success');
            }
        })
        $A.enqueueAction(action);
    },

    showToast: function(title, message, type){
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }

})
