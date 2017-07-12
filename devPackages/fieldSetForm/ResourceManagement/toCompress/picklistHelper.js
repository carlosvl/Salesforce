/**
 * getDependentPicklistOptions
 * by Benj Kamm, 2012
 * (inspired by http://iwritecrappycode.wordpress.com/2012/02/23/dependent-picklists-in-salesforce-without-metadata-api-or-visualforce/)
 * CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/us/)
 *
 * Build an Object in which keys are valid options for the controlling field
 * and values are lists of valid options for the dependent field.
 *
 * Method: dependent PickListEntry.validFor provides a base64 encoded
 * string. After decoding, each of the bits (reading L to R)
 * corresponds to the picklist values for the controlling field.
 */

window.getDependentOptions = function(objName, ctrlFieldName, depFieldName, objDesc) {
	// Isolate the Describe info for the relevant fields

	var ctrlFieldDesc, depFieldDesc;
	var found = 0;
	for (var i=0; i<objDesc.fields.length; i++) {
		var f = objDesc.fields[i];
		if (f.name == ctrlFieldName) {
			ctrlFieldDesc = f;
			found++;
		} else if (f.name == depFieldName) {
			depFieldDesc = f;
			found++;
		}
		if (found==2) break;
	}

	// Set up return object
	var dependentOptions = {};
	var ctrlValues = ctrlFieldDesc.picklistValues;
	for (var i=0; i<ctrlValues.length; i++) {
		dependentOptions[ctrlValues[i].label] = [];
	}

	var base64 = new sforce.Base64Binary("");
	function testBit (validFor, pos) {
		var byteToCheck = Math.floor(pos/8);
		var bit = 7 - (pos % 8);
		return ((Math.pow(2, bit) & validFor.charCodeAt(byteToCheck)) >> bit) == 1;
	}

	// For each dependent value, check whether it is valid for each controlling value
	var depValues = depFieldDesc.picklistValues;
	for (var i=0; i<depValues.length; i++) {
		var thisOption = depValues[i];
		var validForDec = base64.decode(thisOption.validFor);
		for (var ctrlValue=0; ctrlValue<ctrlValues.length; ctrlValue++) {
			if (testBit(validForDec, ctrlValue)) {
				var newObj = {};
				newObj.value = thisOption.value;
				newObj.label = thisOption.label;
				dependentOptions[ctrlValues[ctrlValue].label].push(newObj);
			}
		}
	}

	return dependentOptions;
}
