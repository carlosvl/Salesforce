({
	selectResult: function(component, event, helper) {
    var e = component.getEvent("lookupResultSelected");
    e.setParams({
      selectedResult: component.get("v.currentObject")
    });
    e.fire();
	}
})