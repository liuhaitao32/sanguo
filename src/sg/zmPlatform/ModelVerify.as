package sg.zmPlatform
{
	import sg.model.ViewModelBase;
	import sg.manager.ModelManager;
	import sg.net.NetMethodCfg;
	import sg.activities.model.ModelActivities;
	import sg.activities.model.ModelPhone;

	/**
	 * ...
	 * @author
	 */
	public class ModelVerify extends ViewModelBase{

		private static var sModel:ModelVerify = null;
		private var _verified:int = 0;
		public static function get instance():ModelVerify
		{
			return sModel ||= new ModelVerify();
		}
		public function ModelVerify() {
		}

		/**
		 * 实名认证
		 */
		public function nameVerify():void {
			switch(ConstantZM.platform) { // 速易平台实名认证
				case ConstantZM.PLAT_IWEIYOU:
					ConstantZM.sdk.verify(function(data:Object):void {
						if (data && data.error === 0) {
							ModelVerify.instance.verified = 1;
						}
					});
					break;
				case ConstantZM.PLAT_CRAZY:
					ConstantZM.sdk.realnameAuthentication(function(origin:String, data:Object):void {
						if (data && data.errCode === 0) {
							ModelVerify.instance.verified = 1;
						}
            		});
					break;
			}
		}

		public function get verified():int {
			return _verified;
		}

		public function set verified(v:int):void {
			if (v === 1 && _verified === 0) {
				_verified = 1;
				ModelVerify.instance.checkReward();
			}
			_verified = v;
		}

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
			var data:Array = ModelManager.instance.modelUser.records_360 || [];
			return [ConstantZM.PLAT_CRAZY, ConstantZM.PLAT_IWEIYOU].indexOf(ConstantZM.platform) !== -1 && data.indexOf('verify') === -1 && verified === 0; // 没领奖且可以认证
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return active && true;
		}

		/**
		 * 平台相关领奖
		 * 为了省事儿  认证等领奖也在这里判断
		 */
		public function checkReward():void {
			var records_360:Array = ModelManager.instance.modelUser.records_360 || [];
			var rkey_list:Array = [];
			records_360.indexOf('focus') === -1 && ModelFocus.instance.focused && rkey_list.push('focus');
			records_360.indexOf('verify') === -1 && ModelVerify.instance.verified && rkey_list.push('verify');
			records_360.indexOf('bind') === -1 && ModelPhone.instance.binded && rkey_list.push('bind');
			rkey_list.length && this.sendMethod(NetMethodCfg.WS_SR_GET_360_REWARD, {rkey_list: rkey_list});
			ModelActivities.instance.refreshLeftList();
		}
	}

}