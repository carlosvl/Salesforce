({
	  doInit : function(component, event, helper) {
      var globalId = component.getGlobalId();
      component.set("v.globalId", globalId);
    	helper.getFields(component);
      helper.getDescribeInfo(component);
	  },
  	handleFieldChanged: function(component, event, helper) {
    	helper.fireFormUpdate(component);
    	event.stopPropagation();
  	},
  	handleClearFieldSetForm: function(component, event, helper) {
      var eventFieldSet = event.getParam("fieldSetName");

  		if(eventFieldSet && eventFieldSet == component.get("v.fieldSetName")){
  			helper.clearFields(component, eventFieldSet);
  		}
  	}
})