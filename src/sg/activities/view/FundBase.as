package sg.activities.view
{
    import laya.events.Event;

    import sg.manager.ModelManager;
    import sg.utils.Tools;

    import ui.activities.fund.fundBaseUI;

    public class FundBase extends fundBaseUI
    {
        private var rewardItemArr:Array = [];
        private var _index:int = 0;
        private var _model:Object;
        public function FundBase() {
            this.btn_get.label = Tools.getMsgById('_public103');
            this.btn_get.on(Event.CLICK, this, this.getReward);
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            this._model = source.model;
            this.setReward(source.reward);
            this.btn_get.gray = source.state !== 1;//0: 未达成， 1：未领奖， 2：已领取
            this.btn_get.visible = source.state !== 2;
            this.gold_skin.visible = source.state === 1;
            this.alreadyGet.visible = source.state === 2;
            this.dayTxt.text = source.name;
            this.dayTxt.color = source.state !== 1 ? '#ffffff' :'#ffd74f';
            this._index = source.index;
        }
        
		private function setReward(reward:Object):void
		{
			var props:Object = ModelManager.instance.modelProp.getRewardProp(reward);
			var len:int = props.length;
            this._removeRewardItems();
            var oriX:Number = 200;
            var oriY:Number = 12;
			for(var i:int = 0; i < len; i++)
			{
				var source:Array=props[i];
				var rewardItem:RewardItem = RewardItemPool.borrowItem();
				rewardItemArr.push(rewardItem);
				rewardItem.setReward(source);
                rewardItemArr.push(rewardItem);
			    rewardItem.scale(0.85, 0.85);
				this.addChild(rewardItem);
                rewardItem.pos(oriX + (rewardItem.width + 2) * i, oriY);
			}
		}

        private function _removeRewardItems():void {
            for(var index:int = 0, len:int = rewardItemArr.length; index < len; index++)
            {
                var item:RewardItem = rewardItemArr[index];
                item.destroy();
            }
            rewardItemArr = [];
        }

        private function getReward():void {
            this.btn_get.gray || _model.getReward(this._index);
        }
    }
}