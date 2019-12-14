package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.activities.model.ModelConsumeTotal;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.consumeTotal.consumeTotalUI;
    import sg.manager.AssetsManager;

    public class ConsumeTotalMain extends consumeTotalUI
    {
        private var model:ModelConsumeTotal = ModelConsumeTotal.instance;
        private var rewardData:Object;
        private var reward_list:Array;
        public function ConsumeTotalMain()
        {
            this.showList.scrollBar.hide = true;
			this.showList.itemRender = ActRewardListBase;
            // this.payHintTxt.text = Tools.getMsgById('_jia0014', [Tools.getMsgById('502054')]);
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
            this.timeTxt.text = model.getTimeString() + Tools.getMsgById('_public107');
        }

        private function refreshPanel():void {
            // 获取配置
            var cfg:Object = model.getConfig();
            rewardData = cfg['reward'];
			this.character.setHeroIcon(cfg['character']);
            var keys:Array = ObjectUtil.keys(rewardData);
            var dataArr:Array = [];
            var currentNum:int = flag ? needNum : model.use_coin;
            this.payIcon.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), currentNum);
            for (var i:int = 0, len:int = keys.length; i < len; ++i) {
                var needNum:int = parseInt(keys[i]);
                var reward:Object = rewardData[needNum];
                var flag:int = 0;
                currentNum >= needNum && (flag = 1);
                model.receive_list.indexOf(needNum) !== -1 && (flag = 2);
                dataArr.push({
                    'view':this,
                    'currentNum':currentNum,
                    'needNum':needNum,
                    'reward':reward,
                    'flag':flag,
                    'imgUrl':'actPay3_9.png'
                });
            }
            dataArr.sort(function (a:Object, b:Object):Number { return a.needNum - b.needNum; });
            var tempArr1:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 1; });
            var tempArr2:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 0; });
            var tempArr3:Array = dataArr.filter(function (a:Object):Boolean { return a.flag === 2; });
            this.showList.array = tempArr1.concat(tempArr2, tempArr3);
        }

        public function getReward(key:String):void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_CONSUME_REWARD, {coin_id:parseInt(key)});
        }

		public function removeCostumeEvent():void 
		{
			this.model.off(ModelActivities.UPDATE_DATA, this, this.refreshPanel);
		}
    }
}