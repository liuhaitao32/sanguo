package sg.activities.view
{
    import ui.activities.surpriseGift.surpriseGiftUI;
    import sg.activities.model.ModelSurpriseGift;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import sg.activities.model.ModelActivities;
    import sg.utils.TimeHelper;
    import sg.utils.SaveLocal;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.cfg.ConfigServer;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.utils.StringUtil;
    import laya.display.Animation;
    import sg.manager.EffectManager;

    public class ViewSurpriseGift extends surpriseGiftUI
    {
        private var model:ModelSurpriseGift = ModelSurpriseGift.instance;
        private var aniExp:Animation = null;
        public function ViewSurpriseGift()
        {
            list.itemRender = SurpriseGiftBase;
            list.scrollBar.hide = true;
            txt_tips.text = Tools.getMsgById('surprise_02');
            txt_tips2.text = Tools.getMsgById('surprise_03', [model.cfg.active_time.map(function(arr:Array):String {
                return arr.map(function(num:int):String {
                    return StringUtil.padding(String(num), 2, '0', false);
                }).join(':');
            }, this).join('-')]);
            btn_help.on(Event.CLICK, this, this._onClickHelp);
        }

        override public function onAdded():void {
            this.refreshPanel();
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);

            this._refreshTime();
            this.timer.loop(Tools.oneMillis, this, this._refreshTime);
            SaveLocal.save(ModelSurpriseGift.RED_KEY, {day: ModelManager.instance.modelUser.getGameDate()}, true);
            ModelActivities.instance.refreshLeftList();
            
			// 添加流光特效
			aniExp = EffectManager.loadAnimation("glow_surprise_blow");
            aniExp.pos(box_tips.width * 0.5, box_tips.height * 0.5);
            aniExp.blendMode = 'lighter';
            box_tips.addChild(aniExp);
        }

        /**
         * 刷新界面
         */
        private function refreshPanel():void {
            list.array = model.goodsData;
        }

        private function _refreshTime():void {
            txt_time.text = TimeHelper.formatTime(model.getTime());
            txt_time_hint.text = model.timeHintTxt;
            list.refresh();
        }

        override public function onRemoved():void {
            model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.timer.clear(this, this._refreshTime);
            aniExp && aniExp.removeSelf();
            aniExp = null;
        }

        private function _onClickHelp():void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById('surprise_04'));
        }
    }
}