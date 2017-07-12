({
	getFields: function(component) {
    var currentObject = component.get("v.currentObject");
    var fieldSetName = component.get("v.fieldSetName");
    var action = component.get('c.getFieldsForFieldSet');

    component.set("v.showLoading", true);

    action.setParams({
      currentObject: currentObject,
      fieldSetName: fieldSetName
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        var allFields = JSON.parse(a.getReturnValue());
        component.set("v.fields", allFields);

        console.log(currentObject);

        if (!allFields) {
          return;
        }

        var newObject = JSON.parse(JSON.stringify(currentObject,
          function(k, v) { if (v === undefined) { return null; } return v; }));

        for (var i = 0; i < allFields.length; i++) {
          var f = allFields[i].fieldName;
          newObject[f] = currentObject[f];
        }

        console.log(newObject);

        component.set("v.currentObject", newObject);

        this.fireFormUpdate(component);
        component.set("v.showLoading", false);
      }
    });

    $A.enqueueAction(action);
	},
  getDescribeInfo: function(component) {
    var currentObject = component.get("v.currentObject");
    var action = component.get('c.getDescribeInfoForObject');

    component.set("v.showLoading", true);

    action.setParams({
      currentObject: currentObject,
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        component.set("v.objectDescribe", JSON.parse(a.getReturnValue()));
        component.set("v.showLoading", false);
      }
    });

    $A.enqueueAction(action);
  },
  clearFields: function(component) {

    var allFields = component.get("v.fields");
    var object = component.get("v.currentObject");

    for(var i = 0; i < allFields.length; i++) {
      var field = allFields[i];
      object[field.fieldName] = null;
    }

  },
  fireFormUpdate: function(component) {
    var e = component.getEvent("formUpdated");
    var allFields = component.get("v.fields");
    var requiredFields = [];

    for (var i = 0; i < allFields.length; i++) {
      if (allFields[i].required && allFields[i].isVisible) {
        requiredFields.push(allFields[i].fieldName);
      }
    }
    
    e.setParams({
      "requiredFields": requiredFields,
      "fieldSetName": component.get("v.fieldSetName")
    });

    e.fire();
  }
})