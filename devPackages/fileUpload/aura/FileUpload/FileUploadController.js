({  
  handleFileChange: function(component, event, helper){
    var fileInput = component.find("file").getElement();
    if(fileInput.files.length){
      component.set("v.fileReady", true);
    } else {
      component.set("v.fileReady", false);
    }
  },
  save : function(component, event, helper) {
    helper.save(component);
  }
})