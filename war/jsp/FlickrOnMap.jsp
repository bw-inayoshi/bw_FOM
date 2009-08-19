<%@ page contentType="text/html; charset=utf-8" language="java" %>
<%
	String url = request.getRequestURL().toString();
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Google Map</title>
	<% if( url.matches("^http://localhost:8080/.*") ){ %>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxRp67i8GUh0z_nWFZZ8r-U_rNelWBRa60guAIvm9la59GHuhzNmdiq_hg"
    	    type="text/javascript" charset="utf-8"></script>
	<% }else if( url.matches("^http://bw-inayoshi.appspot.com/.*") ){ %>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxRMBrWNm8_1BAOulVvCNRwJGt-CYBRVL1-c40EnI3sk4ZSbSJbqXpfTWg"
    	    type="text/javascript" charset="utf-8"></script>
	<% } %>
	<script type="text/javascript">
	<!--
		var map;
		
	    var bound = null;
	    var isBoundEdit = false;
	    function seqBound(){
	    	var btn = document.all.btnMap;
	    	var msg = document.all.msg;
	
			if( bound != null ){
				map.removeOverlay(bound);
				bound = null;
				btn.value = "範囲入力";
				msg.innerText = "";
			    isBoundEdit = false;
				return;
			}
	
			bound = new GPolygon(new Array(), "#0000FF", 2, 1, "#0000FF", 0.2);
			GEvent.addListener(bound, "endline", function(){
				btn.disabled = false;
				btn.value = "範囲削除";
				msg.innerText = "範囲内をクリックすると範囲を編集することができます。";
			});
			GEvent.addListener(bound, "cancelline", function(){
				map.removeOverlay(bound);
				bound = null;
				btn.value = "範囲入力";
				msg.innerText = "";
				btn.disabled = false;
			});
			GEvent.addListener(bound, "click", function(latlng){
				if( isBoundEdit == false ){
					bound.enableEditing();
					isBoundEdit = true;
				}else{
					bound.disableEditing();
					isBoundEdit = false;
				}
			});
	
			map.addOverlay(bound);
			bound.enableDrawing();
			btn.disabled = true;
			msg.innerText = "選択を終了するにはダブルクリックか始点をクリックしてください。";
	    }
	
		function onLoad() {
			map = new GMap2(document.getElementById("map"));
			map.setCenter(new GLatLng(35.53222622770337,139.6973419189453),14);
			map.addControl(new GLargeMapControl());
			map.addControl(new GMapTypeControl());
			map.addControl(new GOverviewMapControl());
			map.setMapType(G_NORMAL_MAP);
		}
		
		function unload(){
	    	if(bound != null){
	    		map.removeOverlay(bound);
	    	}
	    	
			GUnload();
		}
		
		
	//-->
	</script>
</head>
<body onload="onLoad()" onunload="unload()">
	<form name="form" action="#" onsubmit="return newSearch();">
		<input type="text" name="search_text">
		<input type="hidden" name="search_save">
		<input type="submit" name="submit" value="検索"><br>
	</form>
	<input type="button" value="範囲入力" id="btnMap" onclick="seqBound()" style="width: 100px">
	<span id="msg"></span>
	<br>
	<div id="map" style="width:800px; height:500px;"></div>
	<br>
</body>
</html>
