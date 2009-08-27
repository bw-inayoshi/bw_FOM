function InputControl(){
	this.text = "test";
}
InputControl.text;

InputControl.prototype = new GControl();

InputControl.prototype.initialize = function(map){
	var container = document.createElement("div");
	
	var testdiv = document.createElement("div");
	testdiv.style.backgroundColor = "white";
	testdiv.style.padding = "2px";
	testdiv.style.textAlign = "center";
	testdiv.style.cursor = "pointer";
	container.appendChild(testdiv);

	var inputtext = document.createElement("input");
	inputtext.type = "text";
	testdiv.appendChild( inputtext );
	var inputsubmit = document.createElement("input");
	inputsubmit.type = "button";
	inputsubmit.value = "検索";
	inputsubmit.onclick = this.testclick;
	testdiv.appendChild( inputsubmit );
	
	map.getContainer().appendChild(container);
	
	return container;
}

InputControl.prototype.getDefaultPosition = function(){
	return new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(7, 30));
}

InputControl.prototype.testclick = function(){
	alert(InputControl.text);
}
