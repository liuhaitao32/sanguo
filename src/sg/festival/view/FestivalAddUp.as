package sg.festival.view
{
    import ui.festival.festival_addupUI;
    import sg.festival.model.ModelFestivalAddUp;
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

    public class FestivalAddUp extends festival_addupUI
    {
        private var model:ModelFestivalAddUp = ModelFestivalAddUp.instance;
		private var cfg:Object;
		private var loopRewardList:RewardList;
        private var aniExp:Animation = null;
        public function FestivalAddUp()
        {
            loopRewardList = new RewardList();
            loopRewardList.scale(0.85, 0.85);
            loopRewardList.pos(img_loop_panel.x + img_loop_panel.width + 10, img_loop_panel.y);
            img_loop_panel.parent.addChild(loopRewardList);
            loopRewardList.setArray(model.getLoopRewardData());

            // 获取配置
            cfg = model.cfg;
            txt_progress_hint.text = Tools.getMsgById('_festival005');
            Tools.textFitFontSize(txt_progress_hint);
            txt_time_hint.text = Tools.getMsgById('_festival002');
            Tools.textFitFontSize(txt_time_hint);
            txt_pay_hint.text = Tools.getMsgById('_festival003');
            Tools.textFitFontSize(txt_pay_hint);
            txt_big_need.text = String(cfg.big_reward.pay * 10);
            Tools.textFitFontSize(txt_big_need);
            txt_loop_hint.text = Tools.getMsgById('_festival004', [cfg.loop_reward.pay * 10]);
            Tools.textFitFontSize2(txt_loop_hint);
            btn_loop_reward.label = Tools.getMsgById('_public103');
            Tools.textFitFontSize(btn_loop_reward);
            this.showList.scrollBar.hide = true;
			this.showList.itemRender = FestivalRewardListBase;
            this.on(Event.DISPLAY, this, this._onDisplay);
            ModelFestival.instance.on(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            btn_loop_reward.on(Event.MOUSE_DOWN, this, this.startGetLoopReward);
            btn_loop_reward.on(Event.MOUSE_OUT, this, this.stopGetLoopReward);
            Laya.stage.on(Event.MOUSE_UP, this, this.stopGetLoopReward);
            comBox.on(Event.CLICK, this, this.getBigReward);
            btn_help.on(Event.CLICK, this, this.click_help);
            
            
			// 添加流光特效
			aniExp = EffectManager.loadAnimation("glow050");
            aniExp.pos(comBox.x + comBox.width * 0.4, comBox.y + comBox.height * 0.6);
            // aniExp.scale(1.3, 1.3);
            this.addChild(aniExp);
            comBox.zOrder = aniExp.zOrder + 1;
        }
        
        private function _onDisplay():void { 
            this.refreshPanel();
        }

        private function click_help(e:Event):void {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(model.cfg.info));
        }

        private function refreshPanel():void {

            var currentTime:int = ConfigServer.getServerTimer();
            var remainTime:int = model.off_time - currentTime;
            if (remainTime > 0) {
                var on_date:Date = new Date(model.on_time);
                var off_date:Date = new Date(model.off_time);
                var on_date_str:String = Tools.getMsgById("msg_Tools_1", [on_date.getFullYear(), (on_date.getMonth()+1), on_date.getDate()]);
                var off_date_str:String = Tools.getMsgById("msg_Tools_1", [off_date.getFullYear(), (off_date.getMonth()+1), off_date.getDate()]);
                txt_time.text = on_date_str + '- ' + off_date_str;
                Laya.timer.once(remainTime, this, this.refreshPanel);
            }
            else {
                txt_time.text = Tools.getMsgById('happy_tips07');
            }
            //Tools.textFitFontSize(txt_time);
            txt_time_hint.width = txt_time_hint.textField.width;
            txt_time.x = txt_time_hint.x + txt_time_hint.width + 2;

			txt_pay.text = String(model.payMoney * 10);
            var rewardCfg:Array = cfg.reward;
            var dataArr:Array = [];
            for (var i:int = 0, len:int = rewardCfg.length; i < len; ++i) {
                var tempData:Array = rewardCfg[i];
                var needMoney:int = tempData[0];
                var flag:int = 0;
                flag = model.payMoney >= needMoney ? 1 : 0;
                flag = model.rewardList.indexOf(i) !== -1 ? 2 : flag;
                var reward:Object = tempData[1];
                var alreadyPay:int = flag ? needMoney : model.payMoney;
                dataArr.push({
                    'id':i,
                    'view':this,
                    'currentNum':alreadyPay * 10,
                    'needNum':needMoney * 10,
                    'reward':reward,
                    'flag':flag,
                    'imgUrl':'actPay3_11.png'
                });
            }
            dataArr.sort(function (a:Object, b:Object):Number { return a.needNum - b.needNum; });
            var tempArr1:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 1; });
            var tempArr2:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 0; });
            var tempArr3:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 2; });
            this.showList.array = tempArr1.concat(tempArr2, tempArr3);
            txt_loop_reward.text = Tools.getMsgById('_jia0006') + ':' + model.loopRewardData.join('/');
            Tools.textFitFontSize(txt_loop_reward);

            var loopRewardNeed:int = cfg.loop_reward.pay;
            var tempValue:int = model.loopRewardData[0] > 0 ? loopRewardNeed : (model.payMoney - model.loopReward * loopRewardNeed);
            txt_progress.text = [tempValue * 10, loopRewardNeed * 10].join('/');
            bar_loop.value = tempValue / loopRewardNeed;
            btn_loop_reward.disabled = !model.loopRewardActive // 不可领取循环奖励
            comBox.setRewardBox(model.bigRewardState);
            comBox.getChildByName("box")['gray'] = model.bigRewardState === 2;
            aniExp.visible = model.bigRewardState !== 2;
        }

        public function getBigReward():void {
            if (model.bigRewardState === 1) { // 可领取大奖
                model.getReward(ModelFestivalAddUp.TYPE_BIG);
            } else { // 预览大奖
                GotoManager.boundForPanel(GotoManager.VIEW_REWARD_PREVIEW, '', cfg.big_reward.reward);
            }
        }

        public function getReward(id):void {
            model.getReward(ModelFestivalAddUp.TYPE_REWARD, id)
        }

        /**
         * 开始领取循环奖励
         */
        public function startGetLoopReward():void {
            var pos:Point = new Point(350, 900);
            model.getLoopReward(pos);
            Laya.timer.frameLoop(10, model, model.getLoopReward, [pos]);
        }

        /**
         * 停止领取循环奖励
         */
        public function stopGetLoopReward():void {
            Laya.timer.clear(model, model.getLoopReward);
        }

		public function removeCostumeEvent():void  {
            this.stopGetLoopReward();
            ModelFestival.instance.off(ModelFestival.UPDATE_DATA, this, this.refreshPanel);
            Laya.timer.clear(this, this.refreshPanel);
		}
    }
}