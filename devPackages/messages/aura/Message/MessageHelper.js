({
	parseFieldErrors: function(component) {
    var errors = component.get("v.messageErrors");

    if (!errors) {
      return;
    }

    var fieldErrors = [];

    for (var i = 0; i < errors.length; i++) {
      var e = errors[i];

      if (!e.fieldErrors) {
        continue;
      }

      for (var fn in e.fieldErrors) {
        var feList = e.fieldErrors[fn];

        for (var j = 0; j < feList.length; j++) {
          fieldErrors.push(feList[j]);
        }
      }
    }

    component.set("v.fieldErrors", fieldErrors);
	}
})