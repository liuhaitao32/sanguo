package sg.activities.view
{
    import laya.events.Event;

    import sg.activities.model.ModelActivities;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;

    import ui.activities.actRewardListBaseUI;
    public class PayListBase extends actRewardListBaseUI
    {
        private var ploy_key:String;
        private var reward_key:int;
        private var _rewardData:Array;
		private var rewardList:RewardList;
        public function PayListBase()
        {
            this.rewardList = new RewardList();
            this.rewardList.scale(0.65, 0.65);
            this.rewardList.pos(165, 15);
            this.addChild(this.rewardList);
            this.on(Event.DISPLAY, this, this._onDisplay);
        }

        private function set rewardData(data:Array):void
        {
            this._rewardData = data;
            this.rewardList.setArray(data);
        }
        
        private function _onDisplay():void
        {
            _rewardData && this.rewardList.setArray(_rewardData);
        }

        override public function set dataSource(value:*):void {
            if (!value) return;
			this._dataSource = value;
            this.setData(value.alreadyPay, value.needMoney, value.reward, value.flag, value.imgUrl);
            this.setRewardData(value.id, value.needMoney);
        }

        /**
         * @param 已支付
         * @param 需支付
         * @param 奖励数据
         */
        private function setData(currentNum:int, needNum:int, rewardData:Object, flag:int, imgUrl:String):void {
            this.needPayTxt.text = String(needNum * 10);
            currentNum = Math.min(needNum, currentNum);
            this.progressTxt.text = currentNum * 10 + '/' + needNum * 10;
            this.pBar.value = currentNum / needNum;
            this.rewardData = ModelManager.instance.modelProp.getRewardProp(rewardData); 
            this.btn_get.label = Tools.getMsgById(flag === 1 ? '_public103' : '_public105');
            this.img_description.skin = AssetsManager.getAssetsUI(imgUrl);
            this.progressMc.visible = flag === 0;
            this.btn_get.visible = flag === 1;
            this.alreadyGet.visible = flag === 2;
            this.btn_get.off(Event.CLICK, this, this._getReward);
            flag === 1 && this.btn_get.on(Event.CLICK, this, this._getReward);
        }

        private function setRewardData(ploy_key:String, reward_key:int):void
        {
            this.ploy_key = ploy_key;
            this.reward_key = reward_key;
        }

        private function _getReward(event:Event):void {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_PAY_PLOY_REWARD, {ploy_key:this.ploy_key, reward_key:this.reward_key});
        }
    }
}