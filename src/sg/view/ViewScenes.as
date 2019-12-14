package sg.view
{
	import laya.display.Sprite;
	import sg.manager.AssetsManager;
	import laya.ui.Image;
	import ui.menu.scenesTitleUI;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import laya.maths.Rectangle;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ViewScenes extends ViewBase{
		private const HEIGHT_TOP:Number = 60;
		private const HEIGHT_TITLE_TOP:Number = 60;
		public static const TOP_HEIGHT:Number = 45;//28
		public var mBoxTitle:scenesTitleUI;
		
		public function ViewScenes(){

			
			if(ConfigApp.isPC){
				this.mBg.x = 0;
				this.mBg.height = Laya.stage.height;
				this.mBg.width = 640;
			}else{
				this.mBg.height = Laya.stage.height;
				this.mBg.width = Laya.stage.width;

			}
			
			this.test_clip_vis = false;
		}
		override protected function createView(uiView:Object):void {
			//
			this.mBg = new Image();
			this.mBg.name = "_$_bg_mask_$_";
			this.addChild(this.mBg);
			//
			super.createView(uiView);
			
			//
		}
		public function setTitle(str:String):void{
			if(this.mBoxTitle){
				this.mBoxTitle.sg_txt.text = str;
				Tools.textLayout2(this.mBoxTitle.sg_txt,this.mBoxTitle.sg_img);
			}
		}
		public function click_closeScenes():void{
			ViewManager.instance.closeScenes();
		}
		override public function checkBg(type:int):void{
			this.mBgType = type;
			//
			var a:Number = 0;
			var b:Number = 0;
			var c:Number = 0;
			if(type>0){
				if(!this.mBoxTitle){
					this.mBoxTitle = new scenesTitleUI();
				}
				this.mBoxTitle.sg_title.visible = true;
			}
			if(type == 1){
				a = -(HEIGHT_TOP+TOP_HEIGHT+ConfigApp.topVal);
				b = (HEIGHT_TOP+TOP_HEIGHT+ConfigApp.topVal);
				c = -(HEIGHT_TITLE_TOP);
				this.fLayer(a,b,c);	
			}
			else if(type == 2){
				a = -(TOP_HEIGHT+ConfigApp.topVal);
				b = (TOP_HEIGHT+ConfigApp.topVal);
				c = 0;
				this.fLayer(a,b,c);
				this.mBoxTitle.sg_title.visible = false;			
			}
			else{
				this.y = 0;
				this.height = Laya.stage.height;
			}
		}
		private function fLayer(by:Number,sy:Number,ty:Number,bSkin:String = "bg_20.png"):void{
			this.mBg.y = by;
			if(!Tools.isNullString(bSkin)){
				this.mBg.skin = AssetsManager.getAssetsUI(bSkin);
			}
			this.y = sy;
			this.mBoxTitle.y = ty;
			
			this.addChild(this.mBoxTitle);
			this.mBoxTitle.sg_btn_close.off(Event.CLICK,this,this.click_closeScenes);
			this.mBoxTitle.sg_btn_close.on(Event.CLICK,this,this.click_closeScenes);
			//
			this.height = Laya.stage.height-this.y;		
			this.hitArea = this.mRect = new Rectangle(this.x,ty,this.width,this.height+Math.abs(ty));		
		}
		override public function onAddedBase():void{
			//this.cacheAs = "normal";
			this.onAdded();
			this.test_clip_int(0);
		}
		override public function onRemovedBase():void{
			this.onRemoved();
			this.cacheAs = "none";
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
			if (name === 'btn_close')   return this.mBoxTitle.sg_btn_close;
            else return super.getSpriteByName(name);
		}
	}

}