package sg.outline.view
{
    import ui.mapScene.OutlineCommonUI;
	import laya.events.Event;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import laya.display.Sprite;
	import sg.manager.AssetsManager;
	import laya.maths.Rectangle;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.scene.view.ui.Bubble;
	import sg.scene.constant.ConfigConstant;
	import sg.manager.ViewManager;
	import sg.boundFor.GotoManager;
	import sg.scene.view.InputManager;

    public class OutlineViewCommon extends OutlineCommonUI
    {
        private var _outline:OutlineViewMain;
        public function OutlineViewCommon() {
        }

        public function initCitys(cIds:Array):void{
            // return;
			_outline = new OutlineViewMain(this,false);			
			scene_container.addChild(_outline);
            scene_container.scale(0.40, 0.34);
            _outline.mapLayer.menuLayer.visible = false;
            scene_container.mouseThrough = false;
            _outline.tMap.moveViewPort(0, 0);
			_outline.fireCotnent.visible = false;
			rect_img.visible = false;
            _outline.scene.visible = true;
            _outline.citySprite.destroyChildren();

            var citys:Array = MapModel.instance.citys;
            cIds.forEach(function(cityId:int):void {
				var entity:EntityCity = EntityCity(citys[cityId]);
                var sp:Sprite = new Sprite();
                var bubble:Bubble = new Bubble();
                var ani:Animation = EffectManager.loadAnimation("glow012");
                bubble.scaleY = 0.9;
                bubble.texture = Laya.loader.getRes(AssetsManager.getAssetsUI('icon_map3.png'));
                switch(entity.cityType) {
                    case ConfigConstant.CITY_TYPE_DEST:
                        ani.scale(3, 3);
                        bubble.x = 63;
                        bubble.y = -0;

                        sp.texture = Laya.loader.getRes(AssetsManager.getAssetsUI('icon_map1.png'));
						sp.pivotX = sp.texture.sourceWidth / 2;
						sp.pivotY = sp.texture.sourceHeight / 2;
                        break;
                    default:
                        ani.scale(1.6, 1.8);
                        bubble.x = 36;
                        bubble.y = -2;

                        sp.texture = Laya.loader.getRes(AssetsManager.getAssetsUI('icon_map2.png'));
                        sp.pivotX = sp.texture.sourceWidth / 2 + 5;
                        sp.pivotY = sp.texture.sourceHeight / 2 + 5;
                        break;
                }
                bubble.pivotX = sp.texture.sourceWidth / 2;
                bubble.pivotY = sp.texture.sourceHeight;
                sp.hitArea = new Rectangle(-20, -50, sp.texture.sourceWidth + 40, sp.texture.sourceHeight + 50);
                sp.addChild(bubble);
                sp.scale(2, 2);
                sp.once(Event.CLICK, this, function(e:EntityCity):void{
                    GotoManager.instance.boundForMap(e.cityId, 0, '', null, 500);
                }, [entity]);
                _outline.citySprite.addChild(ani);			
                _outline.setGridPos(EntityCity(MapModel.instance.citys[cityId]).mapGrid, ani);

				_outline.citySprite.addChild(sp);
                _outline.setGridPos(EntityCity(MapModel.instance.citys[cityId]).mapGrid, sp);
            }, this);
            this.mouseThrough = false;
            img_bg.off(Event.CLICK, this, this._onClickBg);
            img_bg.on(Event.CLICK, this, this._onClickBg);
            
			InputManager.instance.enaled = false;
        }
        
        override public function clear():void{
			InputManager.instance.enaled = true;
            rect_img && rect_img.removeSelf();
            if (_outline) {
                _outline.destroy();
                _outline = null;
            }
        }
        
        private function _onClickBg():void{
        }
    }
}