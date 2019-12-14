package sg.zmPlatform
{
	import sg.model.ViewModelBase;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ModelFocus extends ViewModelBase{

		private static var sModel:ModelFocus = null;
		private var _focused:int = 0;
		public static function get instance():ModelFocus
		{
			return sModel ||= new ModelFocus();
		}
		public function ModelFocus() {
		}

		public function focusOnPublicAccount():void {
			if (!active)	return;
			if (Platform.h5_sdk) {
				Platform.h5_sdk.focus();
			} else {
				Platform.h5_sdk_obj.showQRCode();
			}
		}

		public function get focused():int {
			return _focused;
		}

		public function set focused(v:int):void {
			if (v === 1 && _focused === 0) {
				_focused = 1;
				ModelVerify.instance.checkReward();
			}
			_focused = v;
		}

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
			var data:Object = ModelManager.instance.modelUser.records_360 || [];
			if (Platform.h5_sdk) {
				return Platform.h5_sdk.focusSupport && Platform.h5_sdk.focused === false;
			} else if (ConfigApp.pf === ConfigApp.PF_360_3_h5) {
				return data.indexOf('focus') === -1 && Platform.h5_sdk_obj.isSupportMethod('showQRCode') && focused === 0; // 没领奖且可以关注
			}
			return false;
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return active && true;
		}
	}

}