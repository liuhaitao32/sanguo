package sg.festival.view
{
    import laya.events.Event;
    import sg.manager.AssetsManager;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.activities.view.RewardList;
    import ui.festival.fes_reward_list_baseUI;
    public class FestivalRewardListBase extends fes_reward_list_baseUI
    {
        private var _id:int;
        private var _view:Object;
        private var _rewardData:Array;
		private var rewardList:RewardList;
        public function FestivalRewardListBase()
        {
            this.rewardList = new RewardList();
            this.rewardList.scale(0.75, 0.75);
            this.rewardList.pos(150, 10);
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

        private function set dataSource(value:Object):void
        {
            if (!value) return;
			this._dataSource = value;
            _id = value.id;
            _view = value.view;
            this.setData(value.currentNum, value.needNum, value.reward, value.flag, value.imgUrl);
        }

        /**
         * @param 已支付
         * @param 需支付
         * @param 奖励数据
         */
        private function setData(currentNum:int, needNum:int, rewardData:Object, flag:int, imgUrl:String):void {
            this.needPayTxt.text = String(needNum);
            currentNum = Math.min(needNum, currentNum);
            this.progressTxt.text = currentNum + '/' + needNum;
            this.pBar.value = currentNum / needNum;
            this.rewardData = ModelManager.instance.modelProp.getRewardProp(rewardData); 
            this.btn_get.label = Tools.getMsgById(flag === 1 ? '_public103' : '_public105');
            this.img_description.skin = AssetsManager.getAssetLater(imgUrl);
            this.progressMc.visible = flag === 0;
            this.btn_get.visible = flag === 1;
            this.alreadyGet.visible = flag === 2;
            this.btn_get.off(Event.CLICK, this, this._getReward);
            flag === 1 && this.btn_get.on(Event.CLICK, this, this._getReward);
        }

        private function _getReward(event:Event):void {
            _view.getReward(_id);
        }
    }
}