package sg.festival.view
{
    import laya.events.Event;
    import sg.festival.model.ModelFestival;
    import sg.utils.Tools;
    import sg.activities.view.RewardList;
    import sg.boundFor.GotoManager;
    import sg.utils.TimeHelper;
    import ui.festival.festival_exchangeUI;
    import sg.festival.model.ModelFestivalExchange;

    public class FestivalExchange extends festival_exchangeUI
    {
        private var model:ModelFestivalExchange = ModelFestivalExchange.instance;
		private var cfg:Object;
		private var rewardList:RewardList;
        public function FestivalExchange()
        {
            
			list.itemRender = FestivalExchangeBase;
            list.scrollBar.hide = true;
            cfg = model.cfg;
			character.setHeroIcon(cfg.hero[0], false);
            character.pos(cfg.hero[1][0], cfg.hero[1][1]);
            txt_count_hint.text = Tools.getMsgById('_festival009');
            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
        }
        
        private function _onDisplay():void { 
            this.refreshPanel();
            this.refreshtime();
            Laya.timer.loop(1000, this, this.refreshtime);
        }

        private function refreshtime():void {
            txt_count.text = TimeHelper.formatTime(model.refreshTimeCount);
            Tools.textLayout(txt_count_hint,txt_count,img_hint,timerBox);
        }

        private function refreshPanel():void {
            list.array = model.goodsData;
        }

		public function removeCostumeEvent():void  {
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshPanel);
		}
    }
}