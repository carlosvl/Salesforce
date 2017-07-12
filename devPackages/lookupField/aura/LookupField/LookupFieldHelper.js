({
	getReferenceObject: function(component) {
    var referenceId = component.get("v.referenceObjectId");
    var action = component.get("c.getReferenceObject");

    action.setParams({
      referenceId: referenceId
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        component.set("v.selectedReference", a.getReturnValue());
      }
    });

    $A.enqueueAction(action);
	},

  showResults: function(component) {
    $A.util.addClass(component.find("lookupDiv"), "slds-is-open");
  },

  hideResults: function(component) {
    $A.util.removeClass(component.find("lookupDiv"), "slds-is-open");
  },

  performSearch: function(component) {
    var searchTerm = component.get("v.searchTerm");
    var referenceObjectName = component.get("v.referenceObjectName");
    var action = component.get("c.getLookupSearchResults");

    action.setParams({
      searchTerm: searchTerm,
      objectType: referenceObjectName
    });

    action.setCallback(this, function(a) {
      var state = a.getState();

      if (state === "SUCCESS") {
        var results = a.getReturnValue();

        var showResults = results && results.length > 0;

        if (showResults) {
          this.showResults(component);
        } else {
          this.hideResults(component);
        }

        if (!results) {
          component.set("v.resultComponents", null);
          return;
        }

        console.log(component.get("v.showResults"));

        var componentsToMake = [];

        for (var i = 0; i < results.length; i++) {
          var cc = ["c:LookupSearchResult", {
            currentObject: results[i]
          }];

          componentsToMake.push(cc);
        }

         $A.createComponents(componentsToMake,
           function(components,status,statusMessagesList){
             component.set("v.resultComponents", components);
         });
      }
    });

    $A.enqueueAction(action);
  }
})