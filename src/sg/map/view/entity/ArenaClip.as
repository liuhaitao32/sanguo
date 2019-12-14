package sg.map.view.entity {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.entitys.EntityArena;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.model.ModelArena;
	import sg.model.ModelGame;
	import sg.scene.SceneMain;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.Tools;
	import sg.view.init.ViewUnlock;
	import ui.com.country_flag1UI;
	import ui.mapScene.ArenaInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ArenaClip extends EntityClip {
		
		private var _arenaEntity:EntityArena;
		
		private var _noScale:NoScaleUI = new NoScaleUI();
		
		private var _ui:ArenaInfoUI = new ArenaInfoUI();
		
		public function ArenaClip(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			this._arenaEntity = this._entity as EntityArena;
			super.init();
			this._arenaEntity.on(Event.CHANGE, this, this.changeHandler);
			this.on(Event.CLICK, this, onClick);
			
			this.hitArea = new Rectangle(-45, -120, 90, 170);
			
			//this.graphics.drawRect( -35, -120, 70, 120, "#FF0000");
			
			this._clip.addChild(EffectManager.loadAnimation("statue0" + (this._arenaEntity.index + 1), '', 0, null, "map"));
			//var v:Vector2D = this._arenaEntity.mapGrid.toScreenPos();
			
			//this.x += this._entity.x - v.x;
			//this.y += this._entity.y - v.y;
			//
			MapViewMain.instance.mapLayer.arenaLayer.addChild(this);
			this.x = this._entity.x;
			this.y = this._entity.y;
			
			this.addChild(this._noScale);
			this._noScale.initScene(this._scene);
			this._noScale.minLost = true;
			this._noScale.addChild(this._ui);
			this._scene.bubbles.push(this._noScale);
			//this._ui.y = 35;
			this._ui.y = 25;
			this._noScale.resize();
			this.changeHandler();
			this.visible = true;
		}
		
		private function changeHandler():void {
			this._ui.icon_img.destroyChildren();
			
			
			this._ui.arena_name_txt.text = Tools.getMsgById("arena_statue0" + (this._arenaEntity.index + 1));
			
			//this._ui.city_name_txt.fontSize = 32;
			var txtWidth:Number = 75;
			if (this._arenaEntity._data != null) {				
				
				//擂主名
				this._ui.city_name_txt.text = this._arenaEntity.getParamConfig("uname");
				//this._ui.city_name_txt.text = Math.random()>0.5?'WWWWW D MMMMM':'小白';
				this._ui.city_name_txt.color = '#FFFFAA';
				
				//适配字号
				txtWidth = Tools.textFitFontSize(this._ui.city_name_txt, null, txtWidth);
				
				this._ui.icon_img.x = -txtWidth / 2 - 3;				
				this._ui.icon_img.visible = true;
				
				this._ui.city_name_txt.x = this._ui.icon_img.x + 15;
				
				//this._ui.arena_name_txt.x = this._ui.icon_img.x - 15;
				
				//this._ui.bg_img.x = this._ui.arena_name_txt.x;
				this._ui.bg_img.width = txtWidth + 50;
				
				var flag:country_flag1UI = new country_flag1UI();
				flag.setCountryFlag(this._arenaEntity.getParamConfig("country"));
				this._ui.icon_img.addChild(flag);
				
				
			} else {
				//虚位以待
				this._ui.city_name_txt.text = Tools.getMsgById("arena_clip_0");
				this._ui.city_name_txt.color = '#CCCCCC';
				
				txtWidth = Tools.textFitFontSize(this._ui.city_name_txt, null, txtWidth);
				this._ui.city_name_txt.x = -txtWidth / 2;
				
				this._ui.icon_img.visible = false;
				//this._ui.arena_name_txt.x = -this._ui.arena_name_txt.textField.textWidth / 2 * this._ui.arena_name_txt.scaleX - 2;
				this._ui.bg_img.width = txtWidth + 20;
				//this._ui.bg_img.x = this._ui.arena_name_txt.x - 10;
			}
		}
		
		override public function onClick():void {
			//super.onClick();
			ModelArena.showView(this._arenaEntity.index + 1);
			if(this._entity) MapCamera.lookAtDisplay(this, 500);	
		}
		
		override public function set visible(value:Boolean):void {
			if (value) {
				super.visible = ModelArena.instance.getLight();
			} else {
				super.visible = value;
			}
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

		override public function destroy(destroyChild:Boolean = true):void{
			super.destroy(destroyChild);
			this._arenaEntity.off(Event.CHANGE, this, this.changeHandler);
		}
	}

}