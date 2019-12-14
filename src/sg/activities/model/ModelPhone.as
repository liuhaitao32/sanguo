package sg.activities.model
{
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.cfg.ConfigApp;
	import sg.utils.Tools;
	import sg.model.ModelPlayer;
	import sg.model.ViewModelBase;
	import sg.zmPlatform.ConstantZM;
	import sg.zmPlatform.ModelVerify;

	/**
	 * ...
	 * @author
	 */
	public class ModelPhone extends ViewModelBase{

		private static var sModel:ModelPhone = null;
		public var bindSupported:Boolean = false;
		private var _binded:int = 0;
		public static function get instance():ModelPhone
		{
			return sModel ||= new ModelPhone();
		}
		public function ModelPhone(){
		}
		public function isSpecialPf():Boolean{
			var b:Boolean = false;
			if(ConfigApp.pf == ConfigApp.PF_and_google || ConfigApp.pf == ConfigApp.PF_ios_meng52_tw){
				b = true;
			}
			return b;
		}
		
		override public function get active():Boolean {
			if(this.isSpecialPf()){
				var isBind:Boolean = ModelPhone.isBindingFBorGG(ModelPlayer.instance.getName());
				return ConfigServer.system_simple.phone_pf.indexOf(ConfigApp.pf)!=-1 && !isBind;//
			} else if(ConfigApp.pf === ConfigApp.PF_360_3_h5) {
				bindSupported = Platform.h5_sdk_obj.isSupportMethod('bindPhone') && binded === 0;
				return bindSupported;
			} else {
            	return ConfigServer.system_simple.phone_pf.indexOf(ConfigApp.pf)!=-1 && Tools.isNullString(ModelManager.instance.modelUser.tel);
			}
        }
		
		/**
		 * 红点
		 */
		override public function get redPoint():Boolean {
			return true;
		}

		public function isOpenView():Boolean{
			if(this.isSpecialPf()){
				return false;
			}
			if(ConfigServer.system_simple.phone_pf.indexOf(ConfigApp.pf)!=-1){
				if(ModelPlayer.instance.mTel==""){
					return true;
				}
			}
			return false;
		}
		public static function isBindingFBorGG(str:String):Boolean{
			var b:Boolean = false;
			if(str && str.indexOf("|")>-1 && (str.indexOf(ConfigApp.PF_and_google)>-1 || str.indexOf(ConfigApp.PF_ios_meng52_tw)>-1)){
				b = true;
			}
			return b;
		}

		/**
		 * 调用平台的绑定手机接口
		 */
		public static function bindPhone():void {
			Platform.h5_sdk_obj.bindPhone(bindPhoneCB);
		}

		public static function bindPhoneCB(data:Object):void {
			if (parseInt(data.retcode) === 0 ) {
				ModelPhone.instance.binded = 1;
			}
		}

		public function get binded():int {
			return _binded;
		}

		public function set binded(v:int):void {
			if (v === 1 && _binded === 0) {
				_binded = 1;
				ModelVerify.instance.checkReward();
			}
			_binded = v;
		}
	}

}