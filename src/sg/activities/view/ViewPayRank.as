package sg.activities.view
{
    import ui.activities.payRank.payRankUI;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import avmplus.finish;
    import laya.events.Event;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import laya.utils.Handler;
    import sg.boundFor.GotoManager;
    import sg.activities.model.ModelPayRank;
    import laya.ui.Label;
    import laya.ui.ProgressBar;
    import sg.activities.model.ModelActivities;
    import sg.view.com.ComPayType;
    import sg.utils.TimeHelper;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import laya.ui.Box;
    import laya.ui.Image;
    import laya.ui.Panel;
    import sg.utils.ObjectUtil;

    public class ViewPayRank extends payRankUI
    {
        public var model:ModelPayRank = ModelPayRank.instance;
        public var box_head:Box = null;
        public function ViewPayRank() {
            txt_time_end_hint.text = Tools.getMsgById('_jia0052');
            txt_rank_hint.text = Tools.getMsgById('_jia0014', [Tools.getMsgById('_public214')]);
            txt_title_rank.text = Tools.getMsgById('pay_rank10');
            txt_points_hint.text = Tools.getMsgById('_jia0014', [Tools.getMsgById('pay_rank3')]);
            txt_none.text = Tools.getMsgById('pay_rank8');
            btn_help.on(Event.CLICK, this, this._onClickHelp);
            list_hero.itemRender = PayRankBase;
            list_hero.scrollBar.hide = true;
            list_reward.renderHandler = new Handler(this, _updateRewardItem);

            Tools.textLayout(txt_time_end_hint,txt_time_end,time_end_panel,timeBox);
        }

        override public function initData():void {
            var hids:Array = model.round_dict.heroIds || [];
            box_zero.visible = box_one.visible = box_two.visible = false;
            box_head = box_zero;
            if (hids.length) {
                box_head = hids.length === 2 ? box_two : box_one;
            }
            box_head.visible = true;
            // 广告图
            var img_ad:Image = box_head.getChildByName('img_ad') as Image;
            var img_src:String = model.round_dict.bg_image is Array ? model.round_dict.bg_image[0] || '' : ''
            img_ad && LoadeManager.loadTemp(img_ad, AssetsManager.getAssetsAD(img_src));
            // 排名奖励
            var box_reward:Box = box_head.getChildByName('box_reward') as Box;
            var icon_reward:ComPayType = box_reward.getChildByName('icon_reward') as ComPayType;
            var txt_reward_hint:Label = box_reward.getChildByName('txt_reward_hint') as Label;
            icon_reward.off(Event.CLICK, this, this._onClickReward);
            icon_reward.on(Event.CLICK, this, this._onClickReward);
            txt_reward_hint.text = Tools.getMsgById('pay_rank2');

            // 本期登场英雄 文字提示
            var txt_hero_name_hint:Label = box_head.getChildByName('txt_hero_name_hint') as Label;
            txt_hero_name_hint && (txt_hero_name_hint.text = Tools.getMsgById('pay_rank1'));

            // 英雄Icon
            var iconPanel:Panel = box_head.getChildByName('iconPanel') as Panel;
            var txt_hero_name:Label = box_head.getChildByName('txt_hero_name') as Label;
            var txt_hero_name2:Label = box_head.getChildByName('txt_hero_name2') as Label;
            if (iconPanel) {
                var heroIcon:ComPayType = iconPanel.getChildByName('heroIcon') as ComPayType;
                var heroIcon2:ComPayType = iconPanel.getChildByName('heroIcon2') as ComPayType;
            }
            var modelHero:ModelHero = null;
            if (hids[0]) {
                var hid:String = hids[0];
                heroIcon && heroIcon.setHeroIcon(hid, false);
                modelHero = ModelManager.instance.modelGame.getModelHero(hid);
                txt_hero_name && (txt_hero_name.text = modelHero.getAwakenName());
                if (heroIcon) {
                    heroIcon.off(Event.CLICK, this, this._onClickAwaken);
                    heroIcon.on(Event.CLICK, this, this._onClickAwaken, [hid]);
                }
            }
            if (hids[1]) {
                hid = hids[1];
                heroIcon2 && heroIcon2.setHeroIcon(hid, false);
                modelHero = ModelManager.instance.modelGame.getModelHero(hid);
                txt_hero_name2 && (txt_hero_name2.text = modelHero.getAwakenName());
                if (heroIcon2) {
                    heroIcon2.off(Event.CLICK, this, this._onClickAwaken);
                    heroIcon2.on(Event.CLICK, this, this._onClickAwaken, [hid]);
                }
            }

        }

        override public function onAdded():void {
            this.setTitle(Tools.getMsgById('pay_rank0'));
            model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            model.on(ModelPayRank.CLOSE_PANEL, this, this.closePanel);
            Laya.timer.loop(model.cfg.fresh_interval * Tools.oneMillis, model, model.getPayInfo);
            model.getPayInfo();
        }

        public function refreshPanel():void {
            if (!model.active) {
                return;
            }
            txt_rank.text = model.rank ? String(model.rank) : Tools.getMsgById('_public101');
            txt_points.text = String(model.point);
            var split_arr:Array = model.cfg.split_arr;
            list_hero.array = model.rankDataArr.slice(0, split_arr[split_arr.length - 1]);
            box_hint.visible = !Boolean(list_hero.array.length);
            list_reward.array = model.pointRewardData;
            this._refreshTime();
            Laya.timer.loop(Tools.oneMillis, this, this._refreshTime);
            var box_reward:Box = box_head.getChildByName('box_reward') as Box;
            var icon_reward:ComPayType = box_reward.getChildByName('icon_reward') as ComPayType;
            if (model.rank_reward) {
                icon_reward.setRewardBox(2);
            }
            else {
                icon_reward.setRewardBox(model.haveRankReward() ? 1:0);
            }
        }

		private function _onClickAwaken(hid:String):void {
			var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
			var data:Object = ObjectUtil.clone(md.getMyData());
			if (!data) data = {};
			data.id = hid;
			data.name = md.name;
			data.awaken = 1;
			
			var hmd:ModelHero = new ModelHero(true);
            hmd.setData(data);
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO,hmd);
        }

        private function _refreshTime():void {
            if (model.getTime() is Number) {
                txt_time_end.text = TimeHelper.formatTime(model.getTime());
            }
            else {
                Laya.timer.clear(this, this._refreshTime);
                txt_time_end_hint.visible = time_end_panel.visible = false;
                txt_time_end.text = Tools.getMsgById('happy_tips07');
            }
        }

        private function _updateRewardItem(item:Object, index:int):void {
            var source:Object = item.dataSource;
			var icon:ComPayType = item.getChildByName('icon');
			var txt_goal:Label = item.getChildByName('txt_goal');
			var bar:ProgressBar = item.getChildByName('bar');
            txt_goal.text = source.goal;
            if (model.point < source.start) {
                bar.value = 0;
                icon.setRewardBox(0);
            }
            else if (model.point >= source.goal) {
                bar.value = 1;
                icon.setRewardBox(model.point_reward.indexOf(String(source.goal)) === -1 ? 1 : 2);
            }
            else {
                bar.value = (model.point - source.start) / (source.goal - source.start);
                icon.setRewardBox(0);
            }
            icon.off(Event.CLICK, this, this._onClickRewardIcon);
            icon.on(Event.CLICK, this, this._onClickRewardIcon, [icon['boxType'], source.goal]);
        }

        override public function onRemoved():void {
            model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this._refreshTime);
            Laya.timer.clear(model, model.getPayInfo);
        }

        private function _onClickRewardIcon(state:int, goal:int):void {
            if (state === 2)    return;
            state === 0 && GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', model.round_dict.point_reward[goal]);
            state === 1 && model.getPointReward(goal);
        }

        private function _onClickHelp():void { 
            ViewManager.instance.showTipsPanel(Tools.getMsgById('pay_rank6'));
        }

        private function _onClickReward():void {
            if (model.haveRankReward()) {
                model.getRankReward();
            }
            else {
                ViewManager.instance.showView(ConfigClass.VIEW_PAY_RANK_REWARD);
            }
        }

        private function closePanel():void {
            ViewManager.instance.showTipsTxt(Tools.getMsgById('pay_rank0') + Tools.getMsgById('happy_tips07'));
            this.click_closeScenes();
        }
    }
}
