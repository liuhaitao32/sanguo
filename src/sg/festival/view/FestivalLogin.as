package sg.festival.view
{
    import laya.events.Event;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import ui.festival.festivalLoginUI;
    import sg.activities.view.RewardList;
    import laya.display.Node;
    import sg.festival.model.ModelFestivalLogin;
    import laya.utils.Handler;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.maths.Point;
    import laya.display.Sprite;
    import sg.festival.model.ModelFestival;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class FestivalLogin extends festivalLoginUI
    {
        private var model:ModelFestivalLogin = ModelFestivalLogin.instance;
		private var cfg:Object;
		private var rewardList:RewardList;
		private var currentIndex:int;
        public function FestivalLogin() {
            cfg = model.cfg;
            btn_reward.label = Tools.getMsgById('_public103');
            txt_hint.text = Tools.getMsgById('_festival000');
            Tools.textFitFontSize(txt_hint)
            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
			character.setHeroIcon(cfg.hero[0], false);
            character.pos(cfg.hero[1][0], cfg.hero[1][1]);
            rewardList = new RewardList();
            rewardListPanel.parent.addChild(rewardList as Node);

            list_days.itemRender = FestivalLoginDayBase;
            list_days.selectEnable = true;
            list_days.selectHandler = new Handler(this, this.tab_select);
            list_days.spaceX = 8;

            currentIndex = model.loginDay;
            btn_reward.on(Event.CLICK, this, this.getReward);

        }

        private function _onDisplay():void {
            LoadeManager.loadTemp(img_bg, AssetsManager.getAssetsAD(cfg.picture));
            this.refreshPanel();
        }

        private function tab_select(index:int):void {
            this.setReward(index);
            list_days.array.forEach(function(item:Object, i:int):void{item.selected = i === index;}, this);
            currentIndex = index;
            btn_reward.disabled = model.rewardData[index].state !== ModelFestivalLogin.TYPE_VALID;
        }

        private function refreshPanel():void {
            list_days.array = model.rewardData;
            Laya.timer.once(50, this, this.tab_select, [currentIndex]);
        }

        private function setReward(index:int):void {
            if (!cfg.reward[index]) return;
            rewardList.setArray(ModelManager.instance.modelProp.getCfgPropArr(cfg.reward[index]));
            rewardList.x = rewardListPanel.x + (rewardListPanel.width - rewardList.width) * 0.5;
            rewardList.y = rewardListPanel.y + (rewardListPanel.height - rewardList.height) * 0.5 - 3;
        }

        public function getReward():void {
            model.getReward(currentIndex);
        }

		public function removeCostumeEvent():void  {
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshPanel);
		}
    }
}