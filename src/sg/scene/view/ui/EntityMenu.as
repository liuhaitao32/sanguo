package sg.scene.view.ui {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.ui.View;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.home.view.entity.BuildClip;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.utils.Vector2D;
	import sg.map.view.CityBar;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.CityClip;
	import sg.model.ModelOfficial;
	import sg.scene.SceneMain;
	import sg.scene.view.InputManager;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.ArrayUtil;
	import ui.home.HomeMenuItemUI;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class EntityMenu extends Sprite {
		private var _opened:Boolean = false;
		
		public var entityClip:EntityClip;		
		
		public var menus:Array = [];
		
		public var menuContainer:Sprite = new Sprite();
		
		public var scene:SceneMain;
		
		public var cityBar:CityBar;
		
		public function EntityMenu(scene:SceneMain) {
			this.scene = scene;
			this.addChild(this.menuContainer);			
		}
		
		public function showMenu(entityClip:EntityClip, datas:Array, radius:Number, offset:Point = null):void {
			offset ||= Point.EMPTY;
			datas = datas.filter(function(o:Object, index:int, arr:Array):Boolean {
				return o.visible;
			});
			if (datas.length == 0) return;
			radius = this.scene.tMap.scale * radius;
			this.hide();			
			this.menuContainer.removeChildren();
			this.entityClip = entityClip;
			Point.TEMP.setTo(0, 0);
			var p:Point = this.entityClip.localToGlobal(Point.TEMP);
			
			p = this.scene.mapLayer.menuLayer.globalToLocal(p);
			this.show();
			
			this.x = p.x + offset.x;
			this.y = p.y + offset.y;
			this.menus = [];
			var sc:Number = 1 / this.scene.tMap.scale;
			this.menuContainer.scale(sc, sc);		
			this.addChild(this.menuContainer);	
			if (this.cityBar) {
				this.addChild(this.cityBar);
				this.cityBar.scale(sc, sc);
			}
			
			var interval:Number = 70;
			var offsetY:Number = 250;
			radius += offsetY;
			
			var len:int = datas.length;
			var dui:Number = (interval / 2);
			var xie:Number = Math.sqrt(dui * dui + radius * radius);
			
			var ua:Number = Math.asin(dui / xie) * 2 / Math.PI * 180;
			var leftA:Number = ((len - 1) * ua ) / 2 + 90;
			var v:Vector2D = Vector2D.createVector(0, radius);
			var v2:Vector2D = Vector2D.createVector(0, v.length / 1.2);
			for (var i:int = 0; i < len; i++) {
				var item:HomeMenuItemUI = this.createMenu(datas[i], i);
				v2.angle = v.angle = (leftA - ua * i) / 180 * Math.PI;				
				item.x = v2.x;
				item.y = v2.y - offsetY;
				Tween.to(item, {x:v.x, y:v.y - offsetY, alpha:1}, 300);
			}		
			if (!ModelManager.instance.modelGame.isInside && MapViewMain.instance && ModelOfficial.get_order_buff("buff_country2")) {
				//临时写一下建设令的。
				var menuItem:Sprite = ArrayUtil.find(this.menus, function(item:Sprite):Boolean{return item.name == "3";});
				if (menuItem) {
					var ani:Animation = EffectManager.loadAnimation("glow047");
					ani.pos(33, 33);
					menuItem.addChild(ani);
				}
			}
			
			
		}
		
		public function show():void {
			this._opened = true;
			this.scene.mapLayer.menuLayer.addChild(this);
		}
		
		public function hide():void {
			if (!this._opened) return;
			this._opened = false;
			while (this.menus.length) {
				HomeMenuItemUI(this.menus.shift()).clear();
			}
			this.removeSelf();
		}
		
		private function createMenu(o:*, i:int):HomeMenuItemUI {
			var item:HomeMenuItemUI = new HomeMenuItemUI();
			item.init();
			item.name_txt.text = o.label;
			Tools.textFitFontSize(item.name_txt);
			
			item.name = o.type.toString();
			if (o['name2'] is Number)	item.name = o['name2'].toString();
			else	item.name = o.type.toString();
			item.icon_img.skin = o.icon;
			item.gray=o.gray;
			InputManager.pierceEvent(item.item_btn);
			item.item_btn.clickHandler = Handler.create(this, this.clickHandler, [o], false);
			
			this.menuContainer.addChild(item);			
			item.alpha = 0;
			this.menus.push(item);
			if(item["imgWork"]){
				item["imgWork"].visible = false;
				if(o["work"]){
					item["imgWork"].visible = o["work"];
				}
			}
			return item;
		}
		
		private function clickHandler(o:*):void {
			if(o.gray && o.text){
				ViewManager.instance.showTipsTxt(o.text);
				return;
			}
			if (o.handler) {
				Handler(o.handler).run();
			} else if (ModelManager.instance.modelGame.isInside) {
				ModelManager.instance.modelInside.checkBuildingFunc(BuildClip(this.entityClip).entityBuild.model, o.type);
			}else {
				MapViewMain.instance.checkMenu(CityClip(this.entityClip).entityCity, o.type);
			}
			this.hide();
		}
		
	}

}