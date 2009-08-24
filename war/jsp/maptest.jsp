<%@ page contentType="text/html; charset=utf-8" language="java" %>
<%
	String serverName = request.getServerName();
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Google Map</title>
	<% if( serverName.equals("localhost") ){ %>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxTwM0brOpm-All5BF6PoaKBxRWWERSqjpfjjfkG4H9v-B4BS9p0qsqmDA"
    	    type="text/javascript" charset="utf-8"></script>
	<% }else if( serverName.equals("bw-inayoshi.appspot.com") ){ %>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxQSDgvuLRL42az8R-TnHvBjlZ8zZBSlebLvFRVwlZFRmnPWCzwfIWtrJw"
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
	
		var sizecheck = null;
		
		function onLoad() {
			map = new GMap2(document.getElementById("map"));
			map.setCenter(new GLatLng(35.53222622770337,139.6973419189453),14);
			map.addControl(new GLargeMapControl());
			map.addControl(new GMapTypeControl());
			map.addControl(new GOverviewMapControl());
			map.setMapType(G_NORMAL_MAP);
			
			GEvent.addListener(map, "zoomend", function(oldLevel, newLevel){
				var size = map.getSize();
				var bounds = map.getBounds();
				var west = bounds.getSouthWest().lng();
				var south = bounds.getSouthWest().lat();
				var east = bounds.getNorthEast().lng();
				var north = bounds.getNorthEast().lat();
				var lat = north - south;
				var lng = east - west;
				var msg = "Zoom:" + newLevel + "  "
						+ "X:" + (lng/size.width) + "  "
						+ "Y:" + (lat/size.height);
				
				document.getElementById("lengthmsg").innerText = msg;
				
				if(sizecheck != null){
		    		map.removeOverlay(sizecheck);
				}
				var west = bounds.getSouthWest().lng();
				var south = bounds.getSouthWest().lat();
				var east = bounds.getNorthEast().lng();
				var north = bounds.getNorthEast().lat();
				points = new Array();
				points[0] = new GLatLng(south, west);
				points[1] = new GLatLng(south, east);
				points[2] = new GLatLng(north, east);
				points[3] = new GLatLng(north, west);
				points[4] = new GLatLng(south, west);
				sizecheck = new GPolyline(points, "#FF0000", 2);
				map.addOverlay(sizecheck);
			});
		}
		
		function unload(){
	    	if(bound != null){
	    		map.removeOverlay(bound);
	    	}
	    	if(sizecheck != null){
	    		map.removeOverlay(sizecheck);
	    	}
	    	
			GUnload();
		}
	//-->
	</script>
</head>
<body onload="onLoad()" onunload="unload()">
	<input type="button" value="範囲入力" id="btnMap" onclick="seqBound()" style="width: 100px">
	<span id="msg"></span>
	<br>
	<div id="map" style="width:800px; height:500px;"></div>
	<br>
	<span id="lengthmsg"></span>
	<br>
	<br>
	グーグルマップの表示です。<br>
	<br>
	領域の入力もできるようにしています。<br>
	最初、選択した領域内で検索できるようになればと思ったのですが、<br>
	ある位置が領域内に含まれるかどうかを調べる関数がありませんでした。<br>
	<br>
	矩形範囲なら問題ないのですが、矩形領域を入力するものがありません。<br>
	<br>
	FlickrAppで緯度経度の矩形範囲内を検索できそうなので、<br>
	矩形範囲選択の方法を考えてみます。<br>
	<br>
</body>
</html>
