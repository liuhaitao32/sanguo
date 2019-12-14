package sg.view.effect
{
    import sg.view.ViewBase;
    import laya.events.Event;
    import laya.display.Node;
    import laya.ui.Image;
    import laya.maths.Rectangle;
    import laya.utils.Handler;

    public class EffectUIBase extends ViewBase{
		public var mCallback:Handler;
		private var mThrough:Boolean = false;
		public function EffectUIBase(alpha:Number = 0.5,callback:Handler = null,through:Boolean = false){
			this.mCallback = callback;
			this.mThrough = through;
			this.mouseEnabled = true;
            this.mBg = new Image();
			this.mBg.name = "_$_bg_mask_$_";
			this.mBg.graphics.drawRect(0,0,Laya.stage.width,Laya.stage.height,"#000000");
			this.mBg.alpha = alpha;
            this.addChild(this.mBg);
            //
			if(!through){
				this.hitArea = new Rectangle(0,0,Laya.stage.width,Laya.stage.height);
				
			}
			this.mouseThrough = through;
		}   
		override public function onAddedBase():void{
			// this.cacheAs = "bitmap";
			// trace("EffectUIBase -- ",this.width,this.height);
			// if(!this.mThrough){
				this.once(Event.CLICK,this,this.onClick_bg);
			// }
		}
		override public function onRemovedBase():void{
			this.clearEvent();
			this.off(Event.CLICK,this,this.onClick_bg);
            this.destroyChildren();
            this.destroy();
			// this.cacheAs = "none";
			if(this.mCallback){
				this.mCallback.run();
			}
			this.mCallback = null;			
		}  
        private function onClick_bg(e:Event):void{
			if((e.target as Node).name == "btn_close" || e.target == this){
				this.removeSelf();
			}
		}           
    }   
}