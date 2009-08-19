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
	<script type="text/javascript" src="../js/flickr-search.js"></script>
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
		    clearMarker();
	    	
			GUnload();
		}
		
		var amarker = new Array();
		var ainfo = new Array();
		function clearMarker(){
			for(var i = 0; i < amarker.length; i++){
				map.removeOverlay(amarker[i]);
			}
			amarker.length = 0;
			ainfo.length = 0;
			
			map.closeInfoWindow();
		}
		
		// Flickr検索終了後のコールバック関数
		function jsonFlickrApi ( data ) {
			if(data.stat != "ok"){
				alert("検索エラー");
			}
			
		    // データが取得できているかチェック
		    if ( ! data || ! data.photos ){
		    	alert("検索数0件");
		    	return;
		    }
		    var photos = data.photos;
		    if ( ! photos ){
		    	alert("検索数0件");
		    	return;
		    }
		    var list = data.photos.photo;
		    if ( ! list || ! list.length ){
		    	alert("検索数0件");
		    	return;
		    }
		
		    // 現在の表示内容をクリアする
		    remove_children("photos_info");
		    remove_children("photos_page_prev");
		    remove_children("photos_page_next");
		    remove_children("photos_page");
		    remove_children( 'photos_here' );
		    clearMarker();
		    
		    // 検索情報
		    var info = document.createElement("div");
		    info.style.textAlign = "right";
		    info.innerText = photos.total
		    			   + "件中 "
		    			   + ((photos.page-1) * photos.perpage + 1)
		    			   + " - "
		    			   + (photos.page==photos.pages ? (photos.total) : (photos.page * photos.perpage))
		    			   + " 件目";
		    document.getElementById("photos_info").appendChild(info);
		    
		    // 前ページリンク表示
		    if( photos.page == 1 ){
			    var prevl = document.createElement("span");
		    	prevl.style.color = "gray";
		    	prevl.innerText = "＜前へ";
		    	document.getElementById("photos_page_prev").appendChild(prevl);
		    }else{
			    var prevl = document.createElement("a");
			    prevl.href = "javascript: search(" + (photos.page-1) + ");";
		    	prevl.innerText = "＜前へ";
		    	document.getElementById("photos_page_prev").appendChild(prevl);
		    }

		    // 次ページリンク表示
		    if( photos.page == photos.pages ){
			    var nextl = document.createElement("span");
		    	nextl.style.color = "gray";
		    	nextl.innerText = "次へ＞";
		    	document.getElementById("photos_page_next").appendChild(nextl);
		    }else{
			    var nextl = document.createElement("a");
			    nextl.href = "javascript: search(" + (photos.page+1) + ");";
		    	nextl.innerText = "次へ＞";
		    	document.getElementById("photos_page_next").appendChild(nextl);
		    }
	    	
	    	// ページリンク表示
	    	var pagel = document.createElement("span");
	    	var pageltop = photos.page - 9;
	    	if( pageltop < 1 ){
	    		pageltop = 1;
	    	}
	    	var pagelnum = (photos.page - pageltop) + 10;
	    	
	    	for(var i = 0; i < pagelnum; i++){
	    		if( pageltop + i > photos.pages ){
	    			break;
	    		}
	    		
	    		var pagela = null;
	    		if( pageltop + i == photos.page ){
	    			pagela = document.createElement("span");
	    			pagela.style.color = "gray";
	    		}else{
	    			pagela = document.createElement("a");
	    			pagela.href = "javascript: search(" + (pageltop+i) + ");";
	    		}
	    		pagela.innerText = (pageltop+i) + " ";
	    		pagel.appendChild(pagela);
	    	}
	    	document.getElementById("photos_page").appendChild(pagel);
	    	
		
		    // 各画像を表示する
		    var div = document.getElementById( 'photos_here' );
		    var outnum = 0;
		    for( var i=0; i<list.length; i++ ) {
		        var photo = list[i];
		        
		        var simg = 'http://static.flickr.com/'+photo.server
		                 + '/'+photo.id+'_'+photo.secret+'_s.jpg';
		        var limg = 'http://static.flickr.com/'+photo.server
		                 + '/'+photo.id+'_'+photo.secret+'.jpg';
		        var ilnk = 'http://www.flickr.com/photos/'
		        		 + photo.owner+'/'+photo.id+'/';
		        
		        if(photo.latitude == 0 && photo.longitude == 0){
			        // 地図に載らない
			        if( outnum % 10 == 0 ){
			        	div.appendChild( document.createElement("br") );
			        }
			        
			        // img 要素の生成
			        var img = document.createElement( 'img' );
			        img.src = simg;
			        img.style.border = '0';
			        
			        // a 要素の生成
			        var atag = document.createElement( 'a' );
					atag.href = limg;
			        atag.target = "_blank";
		
			        atag.appendChild( img );
			        div.appendChild( atag );
			        outnum++;
		        }else{
		        	// 地図に載せる
		        	var pnt = new GLatLng(photo.latitude, photo.longitude, false);
		        	var icon = new GIcon();
		        	icon.image = simg;
		        	icon.iconSize = new GSize(75, 75);
		        	icon.iconAnchor = new GPoint(38, 75);
		        	
		        	var marker = new GMarker(pnt, {icon: icon});
		        	map.addOverlay(marker);
		        	amarker.push(marker);
		        	
		        	// 情報画面に表示する内容
		        	var info = document.createElement("span");
		        	
		        	var infotitle = document.createElement("div");
		        	infotitle.innerText = photo.title;
		        	infotitle.style.textAlign = "center";
		        	infotitle.style.fontWeight = "bold";
		        	infotitle.style.fontSize = "1.25em";
		        	info.appendChild(infotitle);

			        // img 要素の生成
			        var img = document.createElement( 'img' );
			        img.src = limg;
			        img.style.border = '0';
			        info.appendChild(img);
			        info.appendChild(document.createElement("br"));
			        
			        // Flickrへのリンク
			        var atag = document.createElement("a");
			        atag.innerText = ilnk;
			        atag.href = ilnk;
			        atag.target = "_blank";
			        info.appendChild(atag);
			        
		        	ainfo.push(info);
		        	
		        	GEvent.addListener(marker, "click", function(latlng){
		        		var infoimg = null;
		        		
						for(var i = 0; i < amarker.length; i++){
							if( amarker[i].getLatLng().equals(latlng) ){
								infoimg = ainfo[i];
								break;
							}
						}
						if(infoimg == null){
							return;
						}
						
		        		map.openInfoWindow(latlng, infoimg);
		        	});
		        	
		        }
		    }
		    
		    if(amarker.length != 0){
			    // マップ表示領域を再設定
			    var markerBounds = new GLatLngBounds(amarker[0].getLatLng(), amarker[0].getLatLng());
			    
			    for(var i = 1; i < amarker.length; i++){
			    	markerBounds.extend( amarker[i].getLatLng() );
			    }
			    
			    var zoom = map.getBoundsZoomLevel(markerBounds);
			    map.setCenter(markerBounds.getCenter(), zoom);
		    }
		}

		function search(pagenum) {
			var textvalue = form.search_save.value;
			form.search_text.value = textvalue;
			
			var param = new Object();
			param.per_page = 20;
			param.page = pagenum;
			param.extras = "geo";
			if(textvalue != ""){
				param.text = textvalue;
			}
			if(form.search_box.value == "1"){
				param.bbox = form.search_west.value
						   + ","
						   + form.search_south.value
						   + ","
						   + form.search_east.value
						   + ","
						   + form.search_north.value;
			}
			
			photo_search(param, "jsonFlickrApi");
		}
		
		function newSearch(){
			form.search_save.value = form.search_text.value;
			if(bound != null){
				var llbounds = bound.getBounds();
				form.search_west.value = llbounds.getSouthWest().lng();
				form.search_south.value = llbounds.getSouthWest().lat();
				form.search_east.value = llbounds.getNorthEast().lng();
				form.search_north.value = llbounds.getNorthEast().lat();
				form.search_box.value = "1";
			}else{
				form.search_box.value = "0";
			}
			
			search(1);
			return false;
		}
	//-->
	</script>
</head>
<body onload="onLoad()" onunload="unload()">
	<form name="form" action="#" onsubmit="return newSearch();">
		<input type="hidden" name="search_save">
		<input type="hidden" name="search_box" value="0">
		<input type="hidden" name="search_west">
		<input type="hidden" name="search_south">
		<input type="hidden" name="search_east">
		<input type="hidden" name="search_north">
		<input type="text" name="search_text" size="100"><br>
		<input type="button" value="範囲入力" id="btnMap" onclick="seqBound()" style="width: 100px">
		<span id="msg"></span><br>
		<input type="submit" name="submit" value="検索" style="width: 100px"><br>
	</form>
	<div id="photos_info"></div>
	<table width="100%" summary="">
		<tr>
			<td align="left" id="photos_page_prev"></td>
			<td align="center" id="photos_page"></td>
			<td align="right" id="photos_page_next"></td>
		</tr>
	</table>
	<div id="map" style="width:800px; height:600px;"></div>
	<br>
	地図上に表示できない画像<br>
	<div id="photos_here"></div>
	<br>
	<br>
	とりあえず地図の上にFlickrの画像を表示するものを作りました。<br>
	<br>
	問題点としては、<br>
	領域外も検索されている。（領域を囲む矩形範囲で検索されている）<br>
	一箇所に画像が集中する場合に下の画像を選択できない。<br>
	大きい画像を地図上に表示させているが、見づらい。<br>
	といったとこでしょうか。<br>
	<br>
</body>
</html>
