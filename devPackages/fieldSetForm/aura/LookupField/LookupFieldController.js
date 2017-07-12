({
	fieldChanged: function(component, event, helper) {
    helper.performSearch(component);
	},
  handleLookupSelection: function(component, event, helper) {
    helper.setLookupSelection(component, event.getParam("selectedResult"));
  },
  clearLookup: function(component, event, helper) {
    helper.clearLookup(component);
  },
  doInit: function(component, event, helper) {
    helper.getInitialLookupResult(component);
    helper.getLookupFieldList(component);
  },
  handleFieldSetDataChange: function(component, event, helper) {
    var fi = component.get("v.field");
    var fn = event.getParam("fieldName");
    var so = event.getParam("selectedSObject");
    var currentObject = component.get("v.currentObject");

    if (fn != fi.fieldName) {
      return;
    }

    currentObject[fn] = so.Id;

    component.set("v.currentObject", currentObject);
    component.set("v.selectedResult", so);
  }
})