({
	doInit: function(component, event, helper) {
    var referenceId = component.get("v.referenceObjectId");

    if (referenceId) {
      helper.getReferenceObject(component);
    }
	},

  fieldChanged: function(component, event, helper) {
    helper.performSearch(component);
  },

  clearLookup: function(component, event, helper) {
    component.set("v.selectedReference", null);
  },

  handleLookupSelection: function(component, event, helper) {

    component.set("v.resultComponents", null);
    component.set("v.showResults", false);
    component.set("v.searchTerm", null);

    var so = event.getParam("selectedResult");

    component.set("v.selectedReference", so);
    component.set("v.referenceObjectId", so.Id);
  }
})