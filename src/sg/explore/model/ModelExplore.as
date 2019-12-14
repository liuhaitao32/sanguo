package sg.explore.model
{
    import sg.model.ViewModelBase;
    import sg.model.ModelUser;
    import sg.model.ModelGame;
    import sg.manager.ModelManager;

    public class ModelExplore extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelExplore = null;
		public static function get instance():ModelExplore
		{
			return sModel ||= new ModelExplore();
		}
        public function ModelExplore()
        {
            super();
        }

        override protected function initData():void {
        }

        /**
         * 初始化各个探险模型
         */
        public function initModel():void {
            ModelTreasureHunting.instance;
            
            // 刷新数据
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            this.refreshData(modelUser);
        }

        override public function refreshData(data:*):void {
            data.mining && ModelTreasureHunting.instance.refreshData(data.mining);
        }

        override public function get active():Boolean {
            return ModelGame.unlock(null, "mining").visible;
        }

        override public function get redPoint():Boolean {
            return this.active && ModelTreasureHunting.instance.redPoint;
        }
    }
}