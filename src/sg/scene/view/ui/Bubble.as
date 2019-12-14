package sg.scene.view.ui {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.manager.EffectManager;
	import sg.map.utils.ArrayUtils;
	import sg.scene.SceneMain;
	import sg.scene.interfaces.IResizeUI;
	import sg.scene.view.InputManager;
	import sg.scene.view.entity.EntityClip;
	import sg.view.com.ComPayType;
	import sg.map.view.MapViewMain;
	import sg.scene.constant.EventConstant;
	
	/**
	 * ...
	 * @author light
	 */
	public class Bubble extends NoScaleUI {
		
		
		private var _clip:EntityClip;
		
		public function Bubble(clip:EntityClip = null) {
			super();
			if (clip) {
				this.initScene(clip.scene);
				this._clip = clip;			
				ArrayUtils.push(this, this.sceneMain.bubbles);	
				this.sceneMain.mapLayer.bubbleLayer.addChild(this);	
				this.on(Event.CLICK, this, function():void{
					MapViewMain.instance.event(EventConstant.CLICK_BUBBLE, this)
				});	// 引导中使用	
			}
			EffectManager.tweenShake(this, {rotation:5}, 100, Ease.sineInOut, null, Math.random() * 2000 + 300, -1, 2000);
			this.scale(1, 1);
		}
		
		public function birthEffect():void {	
			var scaleY:Number = this.scaleY;
			this.scaleY = 0;
			Tween.to(this, {scaleY:scaleY}, Math.random() * 200 + 200, Ease.backOut);
			
		}
		
		override public function event(type:String, data:* = null):Boolean {
			var isClick:Boolean = (type == Event.CLICK);
			if (isClick) {
				if (!InputManager.instance.canClick) return true;
				if (data is Event) {
					Event(data).stopPropagation();
				}
			}
			return super.event(type, data);
		}
		
		override public function scale(scaleX:Number, scaleY:Number, speedMode:Boolean = false):Sprite {
			scaleX *= 0.8;
			scaleY *= 0.8;
			return super.scale(scaleX, scaleY, speedMode);
		}
		
		public function setData(bData:Object):ComPayType {		
			if (bData == null) {
				this.visible = false;
				return null;
			} else {
				if(!bData.ui){
					this.visible = false;
					return null;
				}
				var icon:ComPayType = new bData.ui();
				switch(bData.type) {
					case 0:
						icon.setBuildingTipsIcon3(bData.heroId, bData.flagText, bData.flagBg);								
						break;
					case 1:
						icon.setBuildingTipsIcon(bData.icon, bData.num == null ? "" : bData.num.toString(), bData.bg, bData.flagText, bData.flagBg);								
						break;
					default:
						icon.setBuildingTipsIcon(bData.icon, bData.num == null ? "" : bData.num.toString(), bData.bg, bData.flagText, bData.flagBg);
						break;
				}
				
				if ("gray" in bData) icon.gray = bData.gray;
				
				if ("handlerValue" in bData) {
					for (var name:String in bData["handlerValue"]) {
						bData["handlerValue"][name](icon[name]);
					}
				}
				
				this.removeChildren();
				this.hitArea = new Rectangle(-icon.width / 2, -icon.height, icon.width, icon.height);
				this.visible = true;
				this.addChild(icon);
				icon.name = "icon";
				this.resize();
				return icon;
				
			}
		}
		
		override public function destroy(destroyChild:Boolean = true):void {			
			Tween.clearAll(this);
			super.destroy(destroyChild);
		}
		
	}

}