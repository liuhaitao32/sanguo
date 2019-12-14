package sg.activities.view
{


    public class RewardItemPool
    {
		
		// 单例
		private static var pool:RewardItemPool = null;
		public  static function get instance():RewardItemPool{
			return pool ||= new RewardItemPool();
		}
		
        private var itemArr:Array = [];
        public function RewardItemPool()
        {
            this._addItem();
            this._addItem();
            this._addItem();
        }

        private function _addItem():void
        {
            for (var i:int = 0; i < 5; ++i) {
                itemArr.push(new RewardItem());
            }
            // TestButton.log('pool size: ' + itemArr.length, 2);
        }

        private function _borrowItem():RewardItem
        {
            itemArr.length || this._addItem();
            var item:RewardItem = itemArr.shift();
            item.visible = true;
            return item;
        }

        private function _returnItem(item:RewardItem):void
        {
            itemArr.push(item);
        }

        public static function borrowItem():RewardItem
        {
            return instance._borrowItem();            
        }

        public static function returnItem(item:RewardItem):void
        {
            return instance._returnItem(item);            
        }
    }
}