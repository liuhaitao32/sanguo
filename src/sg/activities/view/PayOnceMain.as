package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelPayOnce;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.payOnce.payOnceUI;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.manager.ViewManager;

    public class PayOnceMain extends payOnceUI
    {
        private var model:ModelPayOnce = ModelPayOnce.instance;
        private var id:String;
        private var rewardData:Object;
        private var pay_list:Array;
        private var reward_list:Array;
        public function PayOnceMain(type:String)
        {
            this.id = model.getIdByType(type);
            this.showList.scrollBar.hide = true;
			this.showList.itemRender = ActRewardListBase;
            this.model.on(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
            this.on(Event.DISPLAY, this, this._onDisplay);
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
            this.tipsTxt.text = Tools.getMsgById(cfg['tips']);
			this.character.setHeroIcon(cfg['character']);
            
            btn_suit.visible = false;
            if (cfg['show']) {
                btn_suit.visible = true;
                var suitName:String = Tools.getMsgById(cfg['name']);
                btn_suit.label = Tools.getMsgById('_jia0088', [suitName]);
                btn_suit.on(Event.CLICK, ViewManager.instance, ViewManager.instance.showView, [["ViewEmboitement",ViewEmboitement],[cfg['show'], cfg['info'], suitName]]);
            }
           
            var keys:Array = model.getKeysById(this.id);
            var dataArr:Array = [];
            for (var i:int = 0, len:int = keys.length; i < len; ++i) {
                var needMoney:int = keys[i];
                var flag:int = 0;
                this.pay_list.indexOf(needMoney) !== -1 && (flag = 1);
                this.reward_list.indexOf(needMoney) !== -1 && (flag = 2);
                var reward:Object = this.rewardData[needMoney];
                var alreadyPay:int = flag ? needMoney : 0;
                dataArr.push({
                    'view':this,
                    'currentNum':alreadyPay * 10,
                    'needNum':needMoney * 10,
                    'reward':reward,
                    'flag':flag,
                    'imgUrl':'actPay3_10.png'
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