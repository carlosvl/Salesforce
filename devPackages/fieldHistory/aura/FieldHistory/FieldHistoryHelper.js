({
	getHistoryData: function(component) {
    var action = component.get("c.getHistoryForId");

    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        component.set("v.historyData", a.getReturnValue());
        component.set("v.numberOfHistories", a.getReturnValue().length);
      }
    });

    $A.enqueueAction(action);
	},

  clearHistoryData: function(component) {
    component.set("v.historyData", []);
  }
})