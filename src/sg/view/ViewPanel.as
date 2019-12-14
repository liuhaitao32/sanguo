package sg.view
{
	import sg.view.ViewBase;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import laya.maths.Rectangle;
	import laya.ui.Button;
	import laya.display.Sprite;
	import laya.display.Node;
	import laya.ui.Image;
	import sg.view.com.ItemBase;
	import laya.ui.Box;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ViewPanel extends ViewBase{
		public var isAutoClose:Boolean=true;
		public var btnCloseFun:Boolean = false;
		public function ViewPanel(){
			if(ConfigApp.isPC && !this['noAlignByPC']){
				this.width = Laya.stage.width;
				this.height = Laya.stage.height;
			}
			this.mBg.graphics.drawRect(0,0,Laya.stage.width,Laya.stage.height,"#000000");
			this.mBg.alpha = 0.7;
		}
		override protected function createView(uiView:Object):void {
			//
			this.mBg = new Image();
			this.mBg.name = "_$_bg_mask_$_";
			this.mBg.visible = false;
			this.addChild(this.mBg);
			//
			super.createView(uiView);
		}
		override public function checkBg(type:int):void{
			this.mBg.visible = (type>0);
			this.height = Laya.stage.height;
			//
		}
		override public function onAddedBase():void{
			//Laya.scaleTimer.frameOnce(100, this, function(){this.cacheAs = "bitmap"});
			//this.cacheAs = "bitmap";
			this.on(Event.CLICK,this,this.onClick_bg);
			this.onAdded();
			this.test_clip_int(1);
		}
		override public function onRemovedBase():void{
			this.off(Event.CLICK,this,this.onClick_bg);
			this.onRemoved();
			this.cacheAs = "none";
		}
		public function onChange(data:* = null):void{
			
		}
		private function onClick_bg(e:Event):void{
			if(((e.target as Node).name == "btn_close" || e.target == this) && !this.btnCloseFun){
				this.closeSelf();
			}
			else if(this.btnCloseFun && (e.target as Node).name == "btn_close"){
				this.btnClickClose();
			}
		}
		public function btnClickClose():void{

		}
		public function onlyCloseByBtn(b:Boolean):void
		{
			this.btnCloseFun = b;
		}
		public function closeSelf(onlySelf:Boolean = true):void{
			if(!this.isAutoClose){
				return;
			}
			ViewManager.instance.closePanel(onlySelf?this:null);
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
			if (name === 'btn_close') {
				return this['sg_btn_close'];
			}
            return super.getSpriteByName(name);
		}
	}

}