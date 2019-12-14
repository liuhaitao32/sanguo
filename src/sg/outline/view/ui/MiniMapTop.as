package sg.outline.view.ui {
	import laya.maths.Point;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.outline.view.OutlineViewMain;
	import sg.utils.ObjectSingle;
	import sg.utils.Tools;
	import ui.mapScene.MiniMapTopUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class MiniMapTop extends MiniMapTopUI {		
		
		private var _outline:OutlineViewMain;
		
		private var _isOpenBtn:Boolean = false;
		
		private var btns:Array = [];
		
		public function MiniMapTop() {
			
		}
		
		
		override public function init():void {
			super.init();
			this._outline = new OutlineViewMain(this);			
			this.scene_container.addChild(this._outline);
			this.setTitle(Tools.getMsgById("MiniMapTop_3"));
			Label(this.filter_btn.getChildByName("label")).text = Tools.getMsgById("_star_text20");
			
			var intervalY:Number = 7;
			var btnH:Number = 36;
			var maxH:Number = (intervalY + btnH) * (this.btnContainer.numChildren - 1) + intervalY;
			var labels:Array = ["_view_timer04", "msg_FtaskClip_0", "MiniMapTop_1", "_hero_chatch_text02", "lvup06_3_name", "_visit_text01", "MiniMapTop_2"];
			//ConfigServer.system_simple["mmp"]=[1,2,2,4,6,9,1]
			for (var j:int = 0, len2:int = ConfigServer.system_simple["mmp"].length; j < len2; j++) {
				var btn:Button = Button(this.btnContainer.getChildByName("btn_" + (j + 1)));
				if (ModelManager.instance.modelInside.getBase().lv < ConfigServer.system_simple["mmp"][j]) {
					btn.destroy();
				} else {
					this.btns.push(btn);
					Label( btn.getChildByName("label")).text = Tools.getMsgById(labels[j]);
				}
			}
			this.btns_bg_img.height = intervalY * (this.btns.length + 1) + btnH * (this.btns.length);
			this.btns_bg_img.y = maxH - this.btns_bg_img.height;
			
			for (var i:int = 0, len:int = this.btns.length; i < len; i++) {
				btn = this.btns[i]
				var n:String = btn.name;
				var index:int = parseInt(n.replace("btn_", "")) - 1;
				Button(btn).clickHandler = new Handler(this, this.onChangeHandler, [index]);
				btn.visible = false;
				btn.y = intervalY + this.btns_bg_img.y + (i) * (btnH + intervalY) ;
			}
			
			this.btns_bg_img.visible = false;
			this.onChangeHandler(OutlineViewMain.BU_DUI);
			this.filter_btn.clickHandler = new Handler(this, function():void {								
				this.showBtnsHandler(!_isOpenBtn);
			});
			this.bottomContainer.y = this._outline.y + this._outline.tMap.height - this.bottomContainer.height;
			this.bottomContainer.x = Laya.stage.width - this.bottomContainer.width;
		}
		
		private function showBtnsHandler(open:Boolean):void 
		{
			this._isOpenBtn = open;
			var offY:Number = -50;
			var time:Number = 100;
			if (this._isOpenBtn) {
				this.btns_bg_img.visible = true;
				for (var i:int = 0, len:int = this.btnContainer.numChildren; i < len; i++) {
					var btn:Button = Button(this.btnContainer.getChildByName("btn_" + (i + 1)));
					if (btn) {
						btn.visible = true;
						Tween.to(btn, {alpha:1, pivotY:0}, time, null, null, (this.btnContainer.numChildren - i - 1) * 30, true);
					}
					
				}
				
				Tween.to(this.btns_bg_img, {alpha:1, pivotY:0}, time, null, null, 0, true);
			} else {
				for (i = 0, len = this.btnContainer.numChildren; i < len; i++) {
					btn = Button(this.btnContainer.getChildByName("btn_" + (i + 1)));
					if (btn) {
						Tween.to(btn, {alpha:0, pivotY:offY}, time * 2, null, new Handler(this, function(b:Button):void{
							b.visible = false;
						}, [btn]), (this.btnContainer.numChildren - i - 1) * 0, true);
					}
					
				}
				
				Tween.to(this.btns_bg_img, {alpha:0, pivotY:offY}, time * 2, null, new Handler(this, function(b:Image):void{
					b.visible = false;
				}, [btns_bg_img]), 0, true);
			}
			
		}
		
		private function onChangeHandler(index:int):void {			
			var btn:Button = Button(this.btnContainer.getChildByName("btn_" + (index + 1)));
			var img:Image = this.select_img.getChildByName("icon") as Image;
			var imgBtn:Image = btn.getChildByName("icon") as Image;
			var label:Label = this.select_img.getChildByName("label") as Label;
			var labelBtn:Label = btn.getChildByName("label") as Label;
			if (img && imgBtn){
				img.skin = imgBtn.skin;
			}
			if (label && labelBtn){
				label.text = labelBtn.text;
			}
			//Image(this.select_img.getChildByName("icon")).skin = Image(btn.getChildByName("icon")).skin;
			//Label(this.select_img.getChildByName("label")).text = Label(btn.getChildByName("label")).text;
			this._outline.showType(index);
			this.showBtnsHandler(false);
		}
		
		override public function onAdded():void {
			super.onAdded();
			this._outline.resize();
		}
		
		
		override public function click_closeScenes():void {
			Tools.destroy(this._outline);
			super.click_closeScenes();
			delete ObjectSingle.sDic[ConfigClass.MINI_MAPTOP[0]];
			this.destroy(true);
		}
	}

}