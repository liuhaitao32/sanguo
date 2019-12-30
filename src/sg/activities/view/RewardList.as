package sg.activities.view
{
    import laya.display.Sprite;
    import laya.display.Node;

    public class RewardList extends Sprite
    {
        public static const ALIGN_LEFT:Number   = 0;
        public static const ALIGN_CENTER:Number = -0.5;
        public static const ALIGN_RIGHT:Number  = -1;
        private var double:Boolean = false;
        private var _align:Number = ALIGN_LEFT;
        public function RewardList() {
            this.autoSize = true;
        }

        public function set align(value:int):void {
            _align = value;
        }

        public function refreshPos():void {
            var len:int = this.numChildren;
            if (len === 0) return;
            var spaceX:int = 0;
            var offsetX:int = (this.getChildAt(0) as RewardItem).width + spaceX;
            var listWidth:int = offsetX * len - spaceX;
            var startX:int = listWidth * _align;
			for(var i:int = 0; i < len; i++) {
				var item:RewardItem = this.getChildByName('item' + i) as RewardItem;
                item.x = offsetX * i + startX;
            }
        }

        public function setArray(arr:Array, double:Boolean = false):void {
            this.destroyChildren();
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++) {
				var source:Array = arr[i];
				var item:RewardItem = new RewardItem();
                item.name = 'item' + i;
				this.addChild(item as Node);
				item.setReward(source, double);
			}
            this.refreshPos();
        }

    }
}