({
	selectResult: function(component, event, helper) {
    var e = component.getEvent("lookupResultSelected");
    e.setParams({
      selectedResult: component.get("v.currentObject")
    });
    e.fire();
	},
  doInit: function(component, event, helper) {
    var urlLabel;
    var fieldList = component.get("v.fieldList");
    var currentObject= component.get("v.currentObject");

    urlLabel = currentObject.Name;

    if (!fieldList) {
      component.set("v.urlLabel", urlLabel);
      return;
    }

    for (var i = 0; i < fieldList.length; i++) {
      if (currentObject[fieldList[i]]) {
        urlLabel += ", " + currentObject[fieldList[i]];
      }
    }

    component.set("v.urlLabel", urlLabel);
  }
})