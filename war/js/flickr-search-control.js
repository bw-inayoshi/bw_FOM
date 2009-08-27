// 検索用コントロール
function FlickrSearchControl(){}
FlickrSearchControl.prototype = new GControl();

// GControl 初期化
FlickrSearchControl.prototype.initialize = function(map){
	var container = document.createElement("div");

	// 表示作成	
	container.appendChild( this.getInputFormElement() );
	container.appendChild( this.getPageElement() );
	
	map.getContainer().appendChild(container);
	return container;
}

// GControl 表示位置設定
FlickrSearchControl.prototype.getDefaultPosition = function(){
	return new GControlPosition(G_ANCHOR_TOP_RIGHT, new GSize(250, 7));
}

FlickrSearchControl.prototype.btn_bound;

FlickrSearchControl.prototype.search;
FlickrSearchControl.prototype.save;
FlickrSearchControl.prototype.box;
FlickrSearchControl.prototype.west;
FlickrSearchControl.prototype.south;
FlickrSearchControl.prototype.east;
FlickrSearchControl.prototype.north;

FlickrSearchControl.prototype.info;
FlickrSearchControl.prototype.page;
FlickrSearchControl.prototype.page_prev;
FlickrSearchControl.prototype.page_next;

// 入力フォーム作成
FlickrSearchControl.prototype.getInputFormElement = function(){
	var basediv = document.createElement("div");
	basediv.style.backgroundColor = "white";
	basediv.style.padding = "2px";
	basediv.style.textAlign = "right";
	basediv.style.cursor = "default";
	
	// フォーム
	var form = document.createElement("form");
	form.name = "flicker_search_form";
	form.action = "#";
	form.onsubmit = function(){
		return newSearch();
	};
	basediv.appendChild(form);
	
	// 範囲入力ボタン
	this.btn_bound = document.createElement("input");
	this.btn_bound.type = "button";
	this.btn_bound.value = "範囲入力";
	this.btn_bound.onclick = seqBound;
	form.appendChild( this.btn_bound );
	
	// 検索テキストボックス
	this.search = document.createElement("input");
	this.search.type = "text";
	this.search.name = "search_text";
	form.appendChild( this.search );
	
	// 検索ボタン
	var submit = document.createElement("input");
	submit.type = "submit";
	submit.value = "検索";
	form.appendChild( submit );
	
	// 保存テキストデータ
	this.save = document.createElement("input");
	this.save.type = "hidden";
	this.save.name = "search_save";
	form.appendChild( this.save );

	// 範囲選択判定
	this.box = document.createElement("input");
	this.box.type = "hidden";
	this.box.name = "search_box";
	this.box.value = "0";
	form.appendChild( this.box );
	
	// 保存範囲データ
	this.west = document.createElement("input");
	this.west.type = "hidden";
	this.west.name = "search_west";
	form.appendChild( this.west );
	this.south = document.createElement("input");
	this.south.type = "hidden";
	this.south.name = "search_south";
	form.appendChild( this.south );
	this.east = document.createElement("input");
	this.east.type = "hidden";
	this.east.name = "search_east";
	form.appendChild( this.east );
	this.north = document.createElement("input");
	this.north.type = "hidden";
	this.north.name = "search_north";
	form.appendChild( this.north );
	
	return basediv;
}

// ページ情報表示作成
FlickrSearchControl.prototype.getPageElement = function(){
	var basediv = document.createElement("div");
	basediv.style.backgroundColor = "white";
	basediv.style.padding = "2px";
	basediv.style.textAlign = "center";
	basediv.style.cursor = "default";

	this.info = document.createElement("div");
	this.info.style.textAlign = "right";
	this.page = document.createElement("span");
	this.page_prev = document.createElement("span");
	this.page_next = document.createElement("span");
	basediv.appendChild( this.info );
	basediv.appendChild( this.page_prev );
	basediv.appendChild( this.page );
	basediv.appendChild( this.page_next );
	
	return basediv;
}

// ページ情報クリア
FlickrSearchControl.prototype.clearPage = function(){
	this.remove_children( this.info );
	this.remove_children( this.page );
	this.remove_children( this.page_prev );
	this.remove_children( this.page_next );
}

// 現在の表示内容をクリアする
FlickrSearchControl.prototype.remove_children = function( div ) {
    while ( div.firstChild ) { 
        div.removeChild( div.lastChild );
    }
};
