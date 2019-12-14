package sg.festival.view
{
    import ui.festival.festival_luckshopUI;
    import laya.events.Event;
    import sg.festival.model.ModelFestival;
    import sg.utils.Tools;
    import sg.activities.view.RewardList;
    import sg.boundFor.GotoManager;
    import sg.festival.model.ModelFestivalLuckShop;
    import sg.utils.TimeHelper;
    import sg.manager.ViewManager;
    import laya.utils.Handler;

    public class FestivalLuckShop extends festival_luckshopUI
    {
        private var model:ModelFestivalLuckShop = ModelFestivalLuckShop.instance;
		private var cfg:Object;
		private var rewardList:RewardList;
        public function FestivalLuckShop()
        {
            
			list.itemRender = FestivalSaleBase;
            cfg = model.cfg;
			character.setHeroIcon(cfg.hero[0], false);
            character.pos(cfg.hero[1][0], cfg.hero[1][1]);
            txt_count_hint.text = Tools.getMsgById('_festival009');
            Tools.textLayout(txt_count_hint,txt_count,img_count,timerBox);

            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            btn_refresh.on(Event.CLICK, this, this._onClickRefresh);
            txt_times_hint.text = Tools.getMsgById('_festival010');
            Tools.textLayout(txt_times_hint,txt_remain_times,img_remain_times,box_hint);

            box_hint.visible = model.cfg.all_limit > 0;
        }
        
        private function _onDisplay():void { 
            this.refreshPanel();
            Laya.timer.loop(1000, this, this.refreshtime);
        }

        private function refreshtime():void {
            txt_count.text = TimeHelper.formatTime(model.refreshTimeCount);
            
        }

        private function refreshPanel():void {
            this.refreshtime();
            list.array = model.goodsData;
            var count:int = model.cfg.refresh_count[0];
            txt_refresh_times.text = String(count - model.refresh_times % count);
            txt_remain_times.text = [model.cfg.all_limit - model.buy_times, model.cfg.all_limit].join('/');
			// txt_pay.text = String(model.needPay * 10);
			// txt_progress.text = model.payMoney * 10 + '/' + model.needPay * 10;
            // rewardList.setArray(model.getRewardData());
            // rewardList.pos(btn_reward.x + (btn_reward.width - rewardList.width) * 0.5, img_reward_panel.y + img_reward_panel.height * 0.15);
            // btn_reward.disabled = !model.rewardActive;
            
            var costArr:Array = model.cfg.cost_refresh;
            var index:int = model.refresh_times >= costArr.length ? costArr.length - 1 : model.refresh_times;
            var cost:Array = costArr[index];
            if (cost[1]) {
                btn_img.visible = true;
                btn_txt.text = cost[1] + ' ' + Tools.getMsgById('_public78');
                btn_txt.x = btn_img.x + btn_img.width + 5;
            }
            else {
                btn_img.visible = false;
                btn_txt.text = Tools.getMsgById('_public77');
                btn_txt.x = (btn_refresh.width - btn_txt.width) * 0.5;
            }
            Tools.textFitFontSize(btn_txt);
            
        }

		public function _onClickRefresh():void  {
            var flag:Boolean = list.array.some(function(obj:Object):Boolean{ return obj.discount === 1 && obj.buyTimes < obj.limit; });
            if (flag) {
                ViewManager.instance.showHintPanel(
                    Tools.getMsgById('_jia0117'), // 内容
                    null,
                    [
                        {'name': Tools.getMsgById('_public183'), 'handler': Handler.create(model, model.refreshGoods)},
                        {'name': Tools.getMsgById('_shogun_text03'), 'handler': null},
                    ]
                );
            }
            else {
                model.refreshGoods();
            }
		}

		public function removeCostumeEvent():void  {
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshPanel);
		}
    }
}