package sg.festival.view
{
    import ui.festival.festival_onceUI;
    import sg.festival.model.ModelFestivalOnce;
    import laya.events.Event;
    import sg.festival.model.ModelFestival;
    import sg.utils.Tools;
    import sg.activities.view.RewardList;
    import sg.boundFor.GotoManager;
    import laya.maths.Point;
    import sg.cfg.ConfigServer;
    import sg.manager.ViewManager;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.utils.ObjectUtil;
    import sg.activities.view.ViewEmboitement;
    import sg.manager.ModelManager;

    public class FestivalOnce extends festival_onceUI
    {
        private var model:ModelFestivalOnce = ModelFestivalOnce.instance;
		private var cfg:Object;
        private var pay_list:Array;
        private var reward_list:Array;
        public function FestivalOnce() {

            // 获取配置
            cfg = model.cfg;
            list.scrollBar.hide = true;
			list.itemRender = FestivalOnceBase;
            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
        }
        
        private function _onDisplay():void { 
            this.refreshPanel();
            txt_info.text = Tools.getMsgById(model.cfg.info);
            Tools.textFitFontSize2(txt_info);
            var heroData:Array = model.cfg.hero;
            character.setHeroIcon(heroData[0]);
            character.pos(heroData[1][0], heroData[1][1]);
        }

        private function refreshPanel():void {
            btn_suit.visible = false;
            if (cfg.show) {
                btn_suit.visible = true;
                var suitName:String = Tools.getMsgById(cfg.name);
                btn_suit.label = Tools.getMsgById('_jia0088', [suitName]);
                Tools.textFitFontSize(btn_suit);
                btn_suit.on(Event.CLICK, ViewManager.instance, ViewManager.instance.showView, [["ViewEmboitement",ViewEmboitement],[cfg.show, cfg.info, suitName]]);
            }
            var dataArr:Array = ObjectUtil.values(model.data);
            dataArr.sort(function (a:Object, b:Object):Number { return a.need_num - b.need_num; });
            var tempArr1:Array = dataArr.filter(function (a:Object):Boolean { return !a.complete && a.can_get_num > 0; });
            var tempArr2:Array = dataArr.filter(function (a:Object):Boolean { return !a.complete && a.can_get_num === 0; });
            var tempArr3:Array = dataArr.filter(function (a:Object):Boolean { return a.complete; });
            list.array = tempArr1.concat(tempArr2, tempArr3);
        }

		public function removeCostumeEvent():void  {
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
		}
    }
}