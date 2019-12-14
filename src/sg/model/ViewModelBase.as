package sg.model
{
	import laya.events.EventDispatcher;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.view.hero.ViewAwakenHero;

	public class ViewModelBase extends EventDispatcher {

        protected var haveConfig:Boolean = false;
		public var mIsTestClose:Boolean = false;//测试

        public function ViewModelBase() {
			this.initData();
        }

		/**
		 * 初始化数据
		 */
        protected function initData():void {}
         
		/**
		 * 刷新数据
		 */
		public function refreshData(data:*):void {}

        /**
         * @param 方法
         * @param 数据
         */
        public function sendMethod(method:String, data:Object = null, handler:Handler = null, otherData:* = null):void {
            data || (data = {});
            NetSocket.instance.send(method, data, handler || Handler.create(this, this.sendCB), otherData);
        }
        
		/**
		 * @param	re
		 */
		private function sendCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;
			var gift_dict:* = receiveData && receiveData.gift_dict;
            ViewAwakenHero.checkGiftDict(gift_dict);
			ModelManager.instance.modelUser.updateData(receiveData);
			gift_dict && ViewManager.instance.showRewardPanel(gift_dict);
		}

		/**
		 * 是否激活
		 */
		public function get active():Boolean {
			return false;
		}

		/**
		 * 是否需要显示红点
		 */
		public function get redPoint():Boolean {
			return false;
		}
    }
}