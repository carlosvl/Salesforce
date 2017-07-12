({
	doInit: function(component, event, helper) {
    var readOnly = component.get("v.readOnly");
    var fi = component.get("v.field");

    if (fi.isEditable && !readOnly) {
      helper.createField(component);
    } else {
      helper.createReadOnlyField(component);
    }
	},
  fieldChanged: function(component, event, helper) {
    helper.fireFieldUpdate(component);
    helper.fireDependencyEvent(component);
    helper.fireVisiblityEvent(component);
  },
  handleDependencyEvent: function(component, event, helper) {
    helper.updateDependentOptions(component, event.getParam("fieldName"),
      event.getParam("fieldValue"));
  },
  handleVisibilityEvent: function(component, event, helper) {
    helper.handleVisibilityEvent(component, event);
  },
  dateChange: function(component, event, helper) {
    var currentObject = component.get("v.currentObject");
    var fieldInfo = component.get("v.field");

    currentObject[fieldInfo.fieldName] = component.get("v.dateValue");
    helper.fireFieldUpdate(component);
  }
})