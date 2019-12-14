package sg.activities.view
{
    import laya.display.Node;
    import laya.events.Event;

    import sg.manager.ViewManager;

    import ui.activities.rewardItemUI;

    public class RewardItem extends rewardItemUI
    {
        public var rewardID:String;
        public var rewardNum:int;
        public function RewardItem()
        {
            extraIcon.visible = false;
        }

        private function set dataSource(source:Array):void {
            if (source is Array) {
                _dataSource = source;
                this.setReward(source);
            }
        }

        public function setReward(data:Array, double: Boolean = false):void{
            rewardID = data[0];
            rewardNum = data[1];
            itemIcon.setData(rewardID, rewardNum, -1);
            extraIcon.visible = double;
        }

        public function setSelected(flag:Boolean):void {
            itemIcon.setSelection(flag);
        }

        public function showConfirmEffect():void {
            this.itemIcon.playEffect();
        }

        private function reset():void {
            this.pos(0, 0);
            this.scale(1, 1);
            this.visible = false;
            this.itemIcon.clearCom();
            this.offAll();
            // 移入对象池
            RewardItemPool.returnItem(this);
        }

        public function set canClick(b:Boolean):void {
            itemIcon.mCanClick = b;
        }

        override public function destroy(destroyChild:Boolean = true):void {
            this.parent && this.parent.removeChild(this);
        }

        override public function set parent(value:Node):void {
            super.parent = value;
            value || this.reset();
        }
    }
}