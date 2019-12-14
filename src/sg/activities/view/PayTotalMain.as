package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelPayTotal;
    import sg.boundFor.GotoManager;
    import sg.manager.ViewManager;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.payTotal.payTotalUI;
    import sg.manager.AssetsManager;
    import sg.utils.TimeHelper;

    public class PayTotalMain extends payTotalUI
    {
        private var model:ModelPayTotal = ModelPayTotal.instance;
        private var id:String;
        private var rewardData:Object;
        private var pay_list:Array;
        private var reward_list:Array;
        private var totalPay:int;
        public function PayTotalMain(type:String)
        {
            this.id = model.getIdByType(type);
            this.showList.scrollBar.hide = true;
			this.showList.itemRender = ActRewardListBase;
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            // this.payHintTxt.text = Tools.getMsgById('_jia0014', [Tools.getMsgById('502051')]);
            this.on(Event.DISPLAY, this, this._onDisplay);
            this.btn_pay.label = Tools.getMsgById('_public104');
            this.btn_pay.on(Event.CLICK, this, GotoManager.boundForPanel, [GotoManager.VIEW_PAY_TEST]);
        }

        private function _onDisplay():void
        {
            this.refreshPanel();
            this.refreshtime();
            Laya.timer.loop(1000, this, this.refreshtime);
        }

        private function refreshtime():void
        {
            this.timeTxt.text = TimeHelper.formatTime(this.model.getRemainingTime(this.id)) + Tools.getMsgById('_public107');
        }

        private function refreshPanel():void {
            // 获取配置
            var cfg:Object = this.model.getConfigByID(this.id);
            this.rewardData = this.model.getConfigByID(this.id)['reward'];
            var data:Object = this.model.getDataByID(this.id);
            if (!data)  return;
            this.pay_list = data['pay_list'];
            this.reward_list = data['reward_list'];
            this.totalPay = 0;
            var len:int = this.pay_list.length;
            for(var i:int = 0; i < len; i++)
            {
                this.totalPay += this.pay_list[i];
            }
            this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), this.totalPay * 10);
			this.character.setHeroIcon(cfg['character']);

            btn_suit.visible = false;
            if (cfg['show']) {
                btn_suit.visible = true;
                var suitName:String = Tools.getMsgById(cfg['name']);
                btn_suit.label = Tools.getMsgById('_jia0088', [suitName]);
                btn_suit.on(Event.CLICK, ViewManager.instance, ViewManager.instance.showView, [["ViewEmboitement",ViewEmboitement],[cfg['show'], cfg['info'], suitName]]);
            }
            
            var keys:Array = ObjectUtil.keys(cfg['reward']);
            var dataArr:Array = [];
            for (i = 0, len = keys.length; i < len; ++i) {
                var key:String = keys[i];
                var reward:Object = this.rewardData[key];
                var flag:int = 0;
                var needMoney:int = parseInt(key);
                this.totalPay >= needMoney && (flag = 1);
                this.reward_list.indexOf(needMoney) !== -1 && (flag = 2);
                var alreadyPay:int = flag ? needMoney : 0;
                var canShow:Boolean = true;
                if (cfg.reward_show && cfg.reward_show[key]) {
                    canShow = totalPay >= cfg.reward_show[key];
                }
                canShow && dataArr.push({
                    'view':this,
                    'currentNum':this.totalPay * 10,
                    'needNum':needMoney * 10,
                    'reward':reward,
                    'flag':flag,
                    'imgUrl':'actPay3_15.png'
                });
            }
            dataArr.sort(function (a:Object, b:Object):Number { return a.needNum - b.needNum; });
            var tempArr1:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 1; });
            var tempArr2:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 0; });
            var tempArr3:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 2; });
            this.showList.array = tempArr1.concat(tempArr2, tempArr3);
        }

        public function getReward(key:int):void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_PAY_PLOY_REWARD, {ploy_key:this.id, reward_key:Math.round(key / 10)});
        }

		public function removeCostumeEvent():void 
		{
            Laya.timer.clear(this, this.refreshtime);
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}
    }
}