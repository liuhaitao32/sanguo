package sg.view.map
{
    import ui.map.fight_task_baseUI;
    import sg.map.model.MapModel;
    import sg.map.model.entitys.EntityCity;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import laya.utils.Tween;
    import laya.utils.Ease;
    import sg.utils.Tools;
    import sg.scene.constant.ConfigConstant;
    import sg.utils.StringUtil;
    import sg.model.ModelOfficial;

    public class FightTaskBase extends fight_task_baseUI
    {
        private var entity:EntityCity = null;
        private var ani:Animation = null;
        private var ani2:Animation = null;
        public function FightTaskBase() {
            img_complete.visible = false;
            box_hint.on(Event.CLICK, this, this._onClickCity);
        }

        public function initCity(data:Object):void {
            var citys:Array = MapModel.instance.citys;
            entity = EntityCity(citys[data.cid]);
			var res:String = entity.getParamConfig("res").split("_")[0];
			ani = EffectManager.loadAnimation(res);
            ani.pos(box_hint.x + box_hint.width * 0.5, box_hint.y + box_hint.height * 0.5);
            var ratio:Number = box_ani.width * 0.5 / entity.width;
            ani.scale(ratio, ratio);
            box_ani.addChild(ani);

            
			// 添加流光特效
			ani2 = EffectManager.loadAnimation("glow037");
            ani2.pos(box_ani2.width * 0.5, box_ani2.height * 0.5);
            ani2.scale(0.7, 1.5);
            box_ani2.addChild(ani2);


            txt_title.text = Tools.getMsgById('fight_task05', [entity.name]);
            txt_tips.text = Tools.getMsgById('fight_task06');
            var buff:Array = data.cfg.task_buff;
            var args:Array = [
                StringUtil.numberToPercent(buff[0]),
                StringUtil.numberToPercent(buff[0]),
                StringUtil.numberToPercent(buff[1]),
                Math.floor(buff[2] / 60)
            ];
            txt_buff.text = Tools.getMsgById('fight_task07', args);
            Tools.textFitFontSize2(txt_buff);
            txt_tips.color = txt_buff.color = ['#fffa87', '#a3f173', '#cecece'][data.state];
            
			var isMyCity:Boolean = ModelOfficial.checkCityIsMyCountry(data.cid);
            box_ani2.visible = img_complete.visible = data.state === 1;
            img_failed.visible = data.state === -1;
            box_hint.visible = data.state === 0;
            if (data.state === 0) {
                box_hint.alpha = 1;
                Tween.clearAll(box_hint);
                EffectManager.tweenLoop(box_hint, {alpha: 0.3}, 600, Ease.sineIn);
            }
        }

        override public function clear():void {
            Tween.clearAll(box_hint);
            ani && ani.removeSelf();
            ani2 && ani2.removeSelf();
            ani = ani2 = null;
        }

        private function _onClickCity():void {
            GotoManager.instance.boundForMap(entity.cityId, 0, '', null, 500);
        }
    }
}