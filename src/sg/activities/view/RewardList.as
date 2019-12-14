package sg.activities.view
{
    import laya.display.Sprite;
    import laya.display.Node;

    public class RewardList extends Sprite
    {
        private var double:Boolean = false;
        public function RewardList()
        {
            this.autoSize = true;
        }

        public function setArray(arr:Array, double: Boolean = false):void
        {
            this.destroyChildren();
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				var source:Array = arr[i];
				var rewardItem:RewardItem = new RewardItem();
				this.addChild(rewardItem as Node);
                rewardItem.x = (rewardItem.width + 0) * i;
				rewardItem.setReward(source, double);
			}
        }

    }
}