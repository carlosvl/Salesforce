({
	performSearch: function(component) {
    var action = component.get('c.getLookupSearchResults');

    action.setParams({
      searchTerm: component.get("v.searchTerm"),
      objectType: component.get("v.field").referenceObject
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        var results = a.getReturnValue();
        component.set("v.lookupSearchResults", results);
        component.set("v.showResults", results && results.length > 0);
      }
    });

    $A.enqueueAction(action);
	},
  getLookupFieldList: function(component) {
    var action = component.get('c.getFieldList');

    action.setParams({
      objectName: component.get("v.field").referenceObject
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        var results = a.getReturnValue();
        component.set("v.displayFieldList", results);
      }
    });

    $A.enqueueAction(action);
  },
  setLookupSelection: function(component, selectedResult) {
    var co = component.get("v.currentObject");
    var f = component.get("v.field");

    component.set("v.showResults", false);
    component.set("v.selectedResult", selectedResult);

    co[f.fieldName] = selectedResult.Id;

    component.set("v.currentObject", co);
    this.fireUpdateEvent(component);
    this.fireVisibilityEvent(component);
  },
  clearLookup: function(component) {
    var co = component.get("v.currentObject");
    var f = component.get("v.field");

    co[f.fieldName] = null;

    component.set("v.selectedResult", null);
    component.set("v.currentObject", co);
    component.set("v.searchTerm", null);
    this.fireUpdateEvent(component);
    this.fireVisibilityEvent(component);
  },
  fireUpdateEvent: function(component) {
    var e = component.getEvent("fieldUpdated");
    e.fire();
  },
  fireVisibilityEvent: function(component) {
    var fieldInfo = component.get("v.field");

    if (!fieldInfo.isVisiblityControlling) {
      return;
    }

    var de = $A.get("e.c:FieldSetVisibilityChange");
    de.setParams({
      fieldName: fieldInfo.fieldName
    });
    de.fire();
  },
  getInitialLookupResult: function(component) {
    var co = component.get("v.currentObject");
    var f = component.get("v.field");

    if (!co[f.fieldName]) {
      return;
    }

    var action = component.get('c.getLookupObjectById');

    action.setParams({
      objectId: co[f.fieldName]
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        var r = JSON.parse(a.getReturnValue());
        component.set("v.selectedResult", r);
      }
    });

    $A.enqueueAction(action);
  }
})