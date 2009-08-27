<%@ page contentType="text/html; charset=utf-8" language="java" %>
<%
	String serverName = request.getServerName();
	String msgOrigin = "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
	<title>Google Map</title>
	<% if( serverName.equals("localhost") ){ 
		msgOrigin = "http://localhost:8080";	%>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxTwM0brOpm-All5BF6PoaKBxRWWERSqjpfjjfkG4H9v-B4BS9p0qsqmDA"
    	    type="text/javascript" charset="utf-8"></script>
	<% }else if( serverName.equals("bw-inayoshi.appspot.com") ){ 
		msgOrigin = "http://bw-inayoshi.appspot.com";	%>
	    <script src="http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAQOl2RRcJsYdX8o3bAJnpvxQSDgvuLRL42az8R-TnHvBjlZ8zZBSlebLvFRVwlZFRmnPWCzwfIWtrJw"
    	    type="text/javascript" charset="utf-8"></script>
	<% } %>
	<script src="http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js"></script>
	<script type="text/javascript" src="../js/flickr-search.js"></script>
	<script type="text/javascript">
	<!--
		function errorHandler(msg,url,line)	{
			alert("エラーメッセージ: " + msg + "\n\n" + "エラーファイル(URL):" + url + "\n\n" + "エラー行:" + line + "\n")
			return true
		}
		window.onerror = errorHandler;

		var map;
		
	    var bound = null;
	    var isBoundEdit = false;
	    var boundClickListener = null;
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
			boundClickListener = GEvent.addListener(bound, "click", function(latlng){
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
			map.setCenter(new GLatLng(35.53222622770337,135.6973419189453),14);
			map.addControl(new GLargeMapControl());
			map.addControl(new GMapTypeControl());
			map.addControl(new GOverviewMapControl());
			map.setMapType(G_NORMAL_MAP);
			map.getInfoWindow();
		}
		
		function unload(){
	    	if(bound != null){
	    		map.removeOverlay(bound);
	    	}
		    clearMarker();
	    	
			GUnload();
		}

		// Flickr検索終了後のコールバック関数
		function jsonFlickrApi ( data ) {
		    // 現在の表示内容をクリアする
		    remove_children("photos_info");
		    remove_children("photos_page_prev");
		    remove_children("photos_page_next");
		    remove_children("photos_page");
		    remove_children( 'photos_here' );
		    clearMarker();

			if(data.stat != "ok"){
				alert("検索エラー");
				return;
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
		    
		    // 検索情報
		    setSearchInfo(photos, "photos_info");
		    // 前ページリンク表示
		    setPrevLink(photos, "photos_page_prev");
		    // 次ページリンク表示
		    setNextLink(photos, "photos_page_next");
	    	// ページリンク表示
	    	setPageLink(photos, "photos_page");
		
		    // 地図上のデータを収集
		    var amapphoto = new Array();
		    // 地図上に無いデータを表示
		    var div = document.getElementById( 'photos_here' );
		    var outnum = 0;
		    for( var i=0; i<list.length; i++ ) {
		        var photo = list[i];
		        
		        if(photo.latitude == 0 && photo.longitude == 0){
			        // 地図に載らない
			        if( outnum % 10 == 0 ){
			        	div.appendChild( document.createElement("br") );
			        }
			        
			        // img 要素の生成
			        var img = document.createElement( 'img' );
			        img.src = getSImgUrl(photo);
			        img.style.border = '0';
			        
			        // a 要素の生成
			        var atag = document.createElement( 'a' );
					atag.href = getFLinkUrl(photo);
			        atag.target = "_blank";
		
			        atag.appendChild( img );
			        div.appendChild( atag );
			        outnum++;
		        }else{
		       		amapphoto.push(photo);
		        }
		    }
		    
		    // マップ上のデータの初期設定
		    initMarker(amapphoto);
		    
		    // マップ表示領域を再設定
		    setMapZoom();
		}
		
		// 検索情報表示
		function setSearchInfo(photos, id){
		    var info = document.createElement("div");
		    info.style.textAlign = "right";
		    info.innerText = photos.total
		    			   + "件中 "
		    			   + ((photos.page-1) * photos.perpage + 1)
		    			   + " - "
		    			   + (photos.page==photos.pages ? (photos.total) : (photos.page * photos.perpage))
		    			   + " 件目";
		    document.getElementById(id).appendChild(info);
		}
		
		// 前へリンクを表示
		function setPrevLink(photos, id){
		    if( photos.page == 1 ){
			    var prevl = document.createElement("span");
		    	prevl.style.color = "gray";
		    	prevl.innerText = "＜前へ";
		    	document.getElementById(id).appendChild(prevl);
		    }else{
			    var prevl = document.createElement("a");
			    prevl.href = "javascript: search(" + (photos.page-1) + ");";
		    	prevl.innerText = "＜前へ";
		    	document.getElementById(id).appendChild(prevl);
		    }
		}
		
		// 次へリンクを表示
		function setNextLink(photos, id){
		    if( photos.page == photos.pages ){
			    var nextl = document.createElement("span");
		    	nextl.style.color = "gray";
		    	nextl.innerText = "次へ＞";
		    	document.getElementById(id).appendChild(nextl);
		    }else{
			    var nextl = document.createElement("a");
			    nextl.href = "javascript: search(" + (photos.page+1) + ");";
		    	nextl.innerText = "次へ＞";
		    	document.getElementById(id).appendChild(nextl);
		    }
		}
		
		// ページリンクを表示
		function setPageLink(photos, id){
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
	    	document.getElementById(id).appendChild(pagel);
		}
		
		// 全データを表示する位置とズームに調整
		function setMapZoom(){
		    if(amarker.length != 0){
			    // マップ表示領域を再設定
			    var markerBounds = new GLatLngBounds(amarker[0].getLatLng(), amarker[0].getLatLng());
			    
			    for(var i = 1; i < amarker.length; i++){
			    	markerBounds.extend( amarker[i].getLatLng() );
			    }
			    
			    var zoom = map.getBoundsZoomLevel(markerBounds);
			    if(zoom > 1){
			    	zoom--;
			    }
			    map.setCenter(markerBounds.getCenter(), zoom);
		    }
		}

		var amarker = new Array();
		var aphoto = new Array();
		var aimgnode = new Array();
		var ainbound = new Array();
		
		var markerManager = null;
		var agroupmarker = new Array();
		var aamarkerlink = new Array();
		
		function clearMarker(){
			if(markerManager != null){
				markerManager.clearMarkers();
			}
			amarker.length = 0;
			aphoto.length = 0;
			aimgnode.length = 0;
			ainbound.length = 0;
			
			markerManager = null;
			agroupmarker.length = 0;
			aamarkerlink.length = 0;
			
			map.closeInfoWindow();
		}
		
		// マーカーの初期設定
		function initMarker(photoList){
			// 並べ替える
			photoList.sort(function(a, b){
				return b.latitude - a.latitude;
			});
			
			// すべてのマーカー、データ、イメージを取得
			for(var i = 0; i < photoList.length; i++){
				var photo = photoList[i];
				
				// 領域内判定
				var isin = isInBound(photo);
				ainbound.push( isin );
				
	        	amarker.push( getSingleMarker(photo, isin) );
	        	aphoto.push(photo);
				aimgnode.push( makeImageNode(photo) );
			}
			
			// ズームレベル毎にまとめる
			markerManager = new MarkerManager(map, {maxZoom:19});
			var groupZoomSet = new Array();
			for(var i = 0; i <= 19; i++){
				// 検索リストにデータをコピー
				var photoList2 = new Array();
				for(var j = 0; j < photoList.length; j++){
					photoList2[j] = photoList[j];
				}
				
				for(var j = 0; j < photoList2.length; j++){
					var photo = photoList2[j];
					if( photo == null ){
						continue;
					}
					
					// 近くのデータを検索
					var anear = getNearData(i, photo, photoList2);
					if( anear.length == 1 && anear[0] == j ){
						// 近くのものが無い
						photoList[j] = null;
						photoList2[j] = null;
						markerManager.addMarker(amarker[j], i);
						continue;
					}
					
					// 周囲のデータを検索から除外
					for(var k = 0; k < anear.length; k++){
						photoList2[ anear[k] ] = null;
					}
					
					// 前のズームで同じグループになっているか
					var isnew = true;
					for(var k = 0; k < aamarkerlink.length; k++){
						if(aamarkerlink[k].length != anear.length){
							continue;
						}
						
						var eqg = true;
						for(var m = 0; m < aamarkerlink[k].length; m++){
							if(aamarkerlink[k][m] != anear[m]){
								eqg = false;
								break;
							}
						}
						if(eqg){
							// 最大ズーム設定を変更
							groupZoomSet[k].max = i;
							isnew = false;
							break;
						}
					}
					if(!isnew){
						continue;
					}
					
					// グループのマーカーを作成
					var gmarker = getGroupMarker(anear);
					agroupmarker.push(gmarker);
					aamarkerlink.push(anear);
					groupZoomSet.push({min:i, max:i});
				}
			}
			
			// グループマーカーを設定
			for(var i = 0; i < agroupmarker.length; i++){
				var minzoom = groupZoomSet[i].min;
				var maxzoom = groupZoomSet[i].max;
				markerManager.addMarker( agroupmarker[i], minzoom, maxzoom );
			}
			
			markerManager.refresh();
		}
		
		// イメージノードを作成
		function makeImageNode(photo){
	        // img 要素の生成
	        var img = document.createElement("img");
	        img.src = getSImgUrl(photo);
	        img.style.border = '0';
	        
	        // a 要素の生成
	        var atag = document.createElement("a");
	        atag.href = getFLinkUrl(photo);
	        atag.target = "_blank";
	        atag.appendChild(img);
			
			return atag;
		}

		// 単一表示のマーカーを作成		
		function getSingleMarker(photo, isin){
        	var pnt = new GLatLng(photo.latitude, photo.longitude, false);
			var icon = new GIcon(G_DEFAULT_ICON);
			if(isin){
				icon.image = "../icon/red-dot.png";
				icon.iconSize = new GSize(32, 32);
				icon.iconAnchor = new GPoint(16, 32);
				icon.shadow = "../icon/shadow.png";
				icon.shadowSize = new GSize(49, 32);
			}else{
				icon.image = "../icon/mm_20_red.png";
				icon.iconSize = new GSize(12, 20);
				icon.iconAnchor = new GPoint(6, 20);
				icon.shadow = "../icon/mm_20_shadow.png";
				icon.shadowSize = new GSize(22, 20);
			}
        	var marker = new GMarker(pnt, {icon:icon});

        	GEvent.addListener(marker, "click", function(latlng){
        		var photo = null;
				for(var i = 0; i < amarker.length; i++){
					if( amarker[i] == this ){
						photo = aphoto[i];
						break;
					}
				}
				if(photo == null){
					return;
				}
				
				var url = getFLinkUrl(photo);
				window.open(url, "_blank");
        	});
        	GEvent.addListener(marker, "mouseover", function(latlng){
        		var photo = null;
        		var imgnode = null;
        		var height = this.getIcon().iconSize.height;
        		
				for(var i = 0; i < amarker.length; i++){
					if( amarker[i] == this ){
						photo = aphoto[i];
						imgnode = aimgnode[i];
						break;
					}
				}
				if(photo == null){
					return;
				}
				
        		map.openInfoWindow(latlng, getSingleInfoNode(photo, imgnode), 
        			{maxWidth:200, pixelOffset:new GSize(0, -height)});
        	});
        	GEvent.addListener(marker, "mouseout", function(latlng){
        		map.closeInfoWindow();
        	});
        	
        	return marker;
		}
		
		function getSingleInfoNode(photo, img){
        	// 情報画面に表示する内容
        	var info = document.createElement("div");
        	info.style.textAlign = "center";
	        //info.style.border = '1px solid #FFFFFF';

        	var infotitle = document.createElement("div");
        	infotitle.innerText = photo.title;
        	infotitle.style.fontWeight = "bold";
        	infotitle.style.backgroundColor = "#D0D0D0";
        	infotitle.style.marginBottom = "5px"
        	info.appendChild(infotitle);

	        info.appendChild(img);
	        return info;
		}
		
		// グループ表示のマーカーを作成
		function getGroupMarker(anear){
			if(anear.length == 0){
				return null;
			}
			
			var title = anear.length + "件";

			// グループの中心に表示
			var sumlat = 0;
			var sumlng = 0;
			for(var i = 0; i < anear.length; i++){
				sumlat += amarker[ anear[i] ].getLatLng().lat();
				sumlng += amarker[ anear[i] ].getLatLng().lng();
			}
			var lat = sumlat / anear.length;
			var lng = sumlng / anear.length;
			var latlng = new GLatLng(lat, lng);
			var icon = new GIcon();
			
			// グループ内に範囲内があれば範囲内のマーカーを表示
			var isin = false;
			for(var i = 0; i < anear.length; i++){
				if(ainbound[ anear[i] ]){
					isin = true;
					break;
				}
			}
			if(isin){
				icon.image = "../icon/yellow-dot.png";
				icon.iconSize = new GSize(32, 32);
				icon.iconAnchor = new GPoint(16, 32);
				icon.shadow = "../icon/shadow.png";
				icon.shadowSize = new GSize(49, 32);
			}else{
				icon.image = "../icon/mm_20_yellow.png";
				icon.iconSize = new GSize(12, 20);
				icon.iconAnchor = new GPoint(6, 20);
				icon.shadow = "../icon/mm_20_shadow.png";
				icon.shadowSize = new GSize(22, 20);
			}
			
			var marker = new GMarker(latlng, {icon:icon, title:title});
			
			GEvent.addListener(marker, "click", function(latlng){
				var anear = null;
				for(var i = 0; i < agroupmarker.length; i++){
					if( agroupmarker[i] == this ){
						anear = aamarkerlink[i];
						break;
					}
				}
				if(anear == null){
					return;
				}
				
				var info = getGroupInfoNode(anear);
        		map.openInfoWindow(latlng, info);
			});
			
			return marker;
		}
		
		function getGroupInfoNode(near){
        	// 情報画面に表示する内容
        	var info = document.createElement("div");
        	info.style.textAlign = "center";
			
			for(var i = 0; i < near.length; i++){
				if(i != 0 && i % 5 == 0){
					var br = document.createElement("br");
					info.appendChild(br);
				}else if(i != 0){
					var sp = document.createElement("span");
					sp.innerText = " ";
					info.appendChild(sp);
				}
				var idx = near[i];
		        info.appendChild(aimgnode[idx]);
			}
			
	        return info;
		}
		
		function search(pagenum) {
			try{
				window.postMessage(pagenum, "<%= msgOrigin %>/");
			}catch(e){
				alert(e.description);
			}
		}
		
		window.addEventListener("message", function(event){
			var textvalue = form.search_save.value;
			form.search_text.value = textvalue;
			
			var param = new Object();
			param.per_page = 20;
			param.page = event.data;
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
		}, false);
		
		function newSearch(){
			form.search_save.value = form.search_text.value;
			if(bound != null){
				var llbounds = bound.getBounds();
				form.search_west.value = llbounds.getSouthWest().lng();
				form.search_south.value = llbounds.getSouthWest().lat();
				form.search_east.value = llbounds.getNorthEast().lng();
				form.search_north.value = llbounds.getNorthEast().lat();
				form.search_box.value = "1";

				// 領域クリックの操作を切り替え
				bound.disableEditing();
				GEvent.removeListener(boundClickListener);
				boundClickListener = GEvent.addListener(bound, "click", function(latlng){
					map.closeInfoWindow();
				});
				document.all.msg.innerText = "";
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
		<input type="text" name="search_text" size="60">
		<br>
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
	マップ上にはマーカーを表示するように変更<br>
	<br>
	赤のマーカーは単体<br>
	カーソルを合わせると画像を表示し、<br>
	クリックするとFlickrのページへリンクします。<br>
	<br>
	黄のマーカーはグループで近くのものをまとめています。<br>
	カーソルを合わせると件数を表示し、<br>
	クリックすると画像を表示します。<br>
	画像をクリックするとFlickrのページへリンクします。<br>
	<br>
	<br>
	領域の判定を追加<br>
	<br>
	入力した領域内のものは大きいマーカーで、<br>
	行域の外で検索されたものは小さいマーカーで表示します。<br>
	<br>
	検索の範囲は矩形でなければならず、<br>
	領域内のものだけ表示するとページごとの表示数が変わるため、<br>
	このような処理をすることにしました。<br>
	<br>
	<br>
	検索時の処理を非同期にしました。<br>
	<br>
	非同期処理にはクロスドキュメントメッセージングという機能を使っています。<br>
	これは元々ウィンドウ（フレーム）間でメッセージの送受信を行うものですが、<br>
	処理は非同期で行われるようなのでこれを使用しました。<br>
	<br>
</body>
</html>
