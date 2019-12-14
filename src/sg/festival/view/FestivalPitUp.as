package sg.festival.view
{
    import ui.festival.festival_pitupUI;
    import laya.events.Event;
    import sg.festival.model.ModelFestival;
    import sg.utils.Tools;
    import sg.activities.view.RewardList;
    import sg.boundFor.GotoManager;
    import sg.festival.model.ModelFestivalPitUp;

    public class FestivalPitUp extends festival_pitupUI
    {
        private var model:ModelFestivalPitUp = ModelFestivalPitUp.instance;
		private var cfg:Object;
		private var rewardList:RewardList;
        public function FestivalPitUp()
        {
            rewardList = new RewardList();
            img_reward_panel.parent.addChild(rewardList);

            txt_hint.text = Tools.getMsgById('_festival006');
            Tools.textFitFontSize(txt_hint);
            btn_reward.label = Tools.getMsgById('_public103');
            Tools.textFitFontSize(btn_reward);
            cfg = model.cfg;
			character.setHeroIcon(cfg.hero[0], false);
            character.pos(cfg.hero[1][0], cfg.hero[1][1]);
            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            btn_reward.on(Event.CLICK, model, model.getReward);
        }
        
        private function _onDisplay():void { 
            this.refreshPanel();
        }

        private function refreshPanel():void {
			txt_pay.text = String(model.needPay * 10);
			txt_progress.text = model.payMoney * 10 + '/' + model.needPay * 10;
            rewardList.setArray(model.getRewardData());
            rewardList.pos(btn_reward.x + (btn_reward.width - rewardList.width) * 0.5, img_reward_panel.y + img_reward_panel.height * 0.15);
            btn_reward.disabled = !model.rewardActive;
            if (model.rewardAllReceived) {
                btn_reward.label = Tools.getMsgById('_view_timer12');
            }
        }

		public function removeCostumeEvent():void  {
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshPanel);
		}
    }
}