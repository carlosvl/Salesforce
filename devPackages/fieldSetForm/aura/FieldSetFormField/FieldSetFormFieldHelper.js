({
  configMap: {
        "anytype": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "base64": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "boolean": {
          componentName: "ui:inputCheckbox"
        },
        "combobox": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "phone": {
          componentName: "ui:inputPhone",
          options: {
            "updateOn": "keyup"
          }
        },
        "currency": {
          componentName: "ui:inputNumber",
          options: {
            "updateOn": "keyup"
          }
        },
        "datacategorygroupreference": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "date": {
          componentName: "ui:inputDate",
          options: {
            "displayDatePicker": true
          }
        },
        "datetime": {
          componentName: "ui:inputDateTime",
          options: {
            "displayDatePicker": true
          }
        },
        "double": {
          componentName: "ui:inputNumber",
          options: {
            "updateOn": "keyup",
            "format": "0.00"
          }
        },
        "email": {
          componentName: "ui:inputEmail",
          options: {
            "updateOn": "keyup"
          }
        },
        "encryptedstring": {
          componentName: "ui:inputSecret",
          options: {
            "class": "slds-input",
            "updateOn": "keyup"
          }
        },
        "id": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "integer": {
          componentName: "ui:inputNumber",
          options: {
            "updateOn": "keyup",
            "format": "0"
          }
        },
        "multipicklist": {
          componentName: "ui:inputSelect",
          options: {
            "class": "slds-input multipicklist",
            "multiple": true
          }
        },
        "percent": {
          componentName: "ui:inputNumber",
          options: {
            "updateOn": "keyup",
            "format": "0"
          }
        },
        "picklist": {
          componentName: "ui:inputSelect",
          options: {
          }
        },
        "reference": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "string": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        },
        "textarea": {
          componentName: "ui:inputTextArea",
          options: {
            "updateOn": "keyup",
            "rows": 6
          }
        },
        "url": {
          componentName: "ui:inputText",
          options: {
            "updateOn": "keyup"
          }
        }
    },
  createReadOnlyField: function(component) {
    var options = {};
    var fi = component.get("v.field");
    this.checkFieldVisibility(component);

    options.value = component.getReference(
      "v.currentObject." + fi.fieldName);

    var compType = "aura:unescapedHtml";
    if (fi.type.toLowerCase() == "boolean"){
      compType = "ui:inputCheckbox";
      options.disabled = true;
    }

    $A.createComponent(
        compType,
        options,
        function(newItem, status, statusMessagesList){
            if (component.isValid()) {
                component.set("v.fieldComponent", newItem);
            }
        }
    );

  },
  createField: function(component) {
    var registrationStyle = component.get("v.registrationStyle");
    var fieldInfo = component.get("v.field");
    var currentObject = component.get("v.currentObject");
    var currentConfig = this.configMap[fieldInfo.type.toLowerCase()];
    var currentOptions = {};

    if (fieldInfo.type.toLowerCase() == "reference") {
      this.checkFieldVisibility(component);
      return;
    }

    if (fieldInfo.type.toLowerCase() == "date") {
      component.set("v.dateValue", currentObject[fieldInfo.fieldName]);
      currentOptions.value = component.getReference("v.dateValue");
    } else {
      currentOptions.value = component.getReference(
        "v.currentObject." + fieldInfo.fieldName);
    }

    if (fieldInfo.defaultValue && !currentObject[fieldInfo.fieldName]) {
      currentObject[fieldInfo.fieldName] = fieldInfo.defaultValue;
      component.set("v.currentObject", currentObject);
    }

    currentOptions["aura:id"] = fieldInfo.fieldName;

    currentOptions.maxlength = fieldInfo.maxLength;

    if (fieldInfo.isDependent) {
      currentOptions.options = this.getFieldOptions(component,
        fieldInfo.controllingField, fieldInfo.fieldName,
          currentObject[fieldInfo.controllingField], currentObject.sobjectType);
      currentOptions.disabled = currentOptions.options.length <= 1;
    } else {
      if (fieldInfo.options) {
        currentOptions.options = fieldInfo.options;
      }
    }

    if (currentConfig.options && currentConfig.options.updateOn &&
        currentConfig.options.updateOn == "keyup") {
      currentOptions.keyup = component.getReference("c.fieldChanged");
    } else if (fieldInfo.type.toLowerCase() != "date") {
      currentOptions.change = component.getReference("c.fieldChanged");
    }

    if (registrationStyle) {

      if (fieldInfo.type.toLowerCase() != "date") {
        currentOptions.placeholder = fieldInfo.fieldLabel;
      }

      if (fieldInfo.type.toLowerCase() == "picklist") {
        currentOptions.class = "input-select";
      } else if (fieldInfo.type.toLowerCase() != "boolean") {
        currentOptions.class = "input-text";
      }
    } else {
      if (fieldInfo.type.toLowerCase() != "boolean") {
        currentOptions.class = "slds-input";
      }
    }

    for (var optionKey in currentConfig.options) {
      var co = currentConfig.options[optionKey];

      currentOptions[optionKey] = co;
    }

    $A.createComponent(
        currentConfig.componentName,
        currentOptions,
        function(newItem, status, statusMessagesList){
            if (component.isValid()) {
                component.set("v.fieldComponent", newItem);
            }
        }
    );

    this.checkFieldVisibility(component);

  },
  fireFieldUpdate: function(component) {
    var e = component.getEvent("fieldUpdated");
    e.fire();
  },
  getFieldOptions: function(component, cFieldName, fieldName, cFieldValue,
      objectType) {
    var options = getDependentOptions(objectType,
      cFieldName, fieldName,
        component.get("v.objectDescribe"));

    var newOptions = [];
    var firstOption = {};

    firstOption.value = "";
    firstOption.label = "-- Select One --";
    newOptions.push(firstOption);

    for (var currentIndex in options[cFieldValue]) {
      var currentOption = options[cFieldValue][currentIndex];
      newOptions.push(currentOption);
    }

    return newOptions;
  },
  updateDependentOptions: function(component, cFieldName, cFieldValue) {
    var fieldInfo = component.get("v.field");
    var currentObject = component.get("v.currentObject");

    if (fieldInfo.type.toLowerCase() != "picklist" || !fieldInfo.isDependent ||
        fieldInfo.controllingField != cFieldName) {
      return;
    }

    var currentPicklistField = component.get("v.fieldComponent");

    if (!currentPicklistField) {
      return;
    }

    var fieldOptions = this.getFieldOptions(component,
      cFieldName, fieldInfo.fieldName, cFieldValue, currentObject.sobjectType);

    currentPicklistField.set("v.options", fieldOptions);
    currentPicklistField.set("v.disabled", fieldOptions.length <= 1);
  },
  fireDependencyEvent: function(component) {
    var fieldInfo = component.get("v.field");
    var currentObject = component.get("v.currentObject");

    if (fieldInfo.type.toLowerCase() != "picklist") {
      return;
    }

    var de = $A.get("e.c:FieldSetFieldDependency");
    de.setParams({
      fieldName: fieldInfo.fieldName,
      fieldValue: currentObject[fieldInfo.fieldName]
    });

    de.fire();
  },
  fireVisiblityEvent: function(component) {
    var fieldInfo = component.get("v.field");
    var currentObject = component.get("v.currentObject");

    if (!fieldInfo.isVisiblityControlling) {
      return;
    }

    var de = $A.get("e.c:FieldSetVisibilityChange");
    de.setParams({
      fieldName: fieldInfo.fieldName,
      formId: component.get("v.formId")
    });
    de.fire();
  },
  handleVisibilityEvent: function(component, event) {
    var controllingFieldName = event.getParam("fieldName");
    var fieldInfo = component.get("v.field");
    var formId = component.get("v.formId");
    var fId = event.getParam("formId");

    if (fId != formId ||
        fieldInfo.visibilityControllingField != controllingFieldName) {
      return;
    }

    this.checkFieldVisibility(component);
  },
  checkFieldVisibility: function(component) {
    var currentObject = component.get("v.currentObject");
    var fieldInfo = component.get("v.field");

    if (!fieldInfo.isVisibilityDependent) {
      return;
    }

    if (this.isValidValue(fieldInfo.visibilityControllingValues,
      currentObject[fieldInfo.visibilityControllingField],
        fieldInfo.visibilityMatchType)) {
      fieldInfo.isVisible = true;
    } else {
      fieldInfo.isVisible = false;

      currentObject[fieldInfo.fieldName] = null;
      component.set("v.currentObject", currentObject);
      this.fireVisiblityEvent(component);
    }

    component.set("v.field", fieldInfo);
    this.fireFieldUpdate(component);
  },
  isValidValue: function(valueArray, valueToCheck, matchType) {
    if (matchType == "Not Null") {
      return !(valueToCheck == null || valueToCheck == undefined ||
        valueToCheck == "");
    } else {
      if (valueToCheck == null || valueToCheck == undefined) {
        return false;
      }
    }

    var vtc;

    if (typeof valueToCheck === "string") {
      vtc = valueToCheck.toLowerCase();
    } else {
      vtc = valueToCheck;
    }

    for (var i = 0; i < valueArray.length; i++) {
      if (matchType == "Contains") {
        if (vtc.indexOf(valueArray[i]) != -1) {
          return true;
        }
      } else if (matchType == "Equals") {
        if (valueArray[i] == vtc) {
          return true;
        }
      }
    }

    return false;
  }
})