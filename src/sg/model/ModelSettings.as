package sg.model
{
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import sg.utils.MusicManager;
    import laya.events.EventDispatcher;
    import laya.utils.Browser;
    import sg.cfg.ConfigApp;

    public class ModelSettings extends EventDispatcher
    {
		public static const TYPE_MUSIC:String = "music";	// 音乐
		public static const TYPE_SOUND:String = "sound";	// 音效
		public static const TYPE_MODEL:String = "teamModel";// 友军行军模型
		public static const TYPE_NOTIFY:String = "notify";	// 行军到达等弹板通知
		public static const CHANGE_MODEL:String = "change_model";

		// 单例
		public static var sModel:ModelSettings = null;
		
		public static function get instance():ModelSettings
		{
			return sModel ||= new ModelSettings();
		}
        
        private var settingsData:Object;
        public function ModelSettings()
        {
            this._initModel();
        }

        private function _initModel():void
        {
            // 读取本地设置
            settingsData = SaveLocal.getValue(SaveLocal.KEY_SETTINGS);
            if (!settingsData) {
                settingsData = {};
                settingsData[TYPE_MUSIC] = true;//!Browser.onMiniGame;
                settingsData[TYPE_SOUND] = true;//!Browser.onMiniGame;
                settingsData[TYPE_MODEL] = true;
                settingsData[TYPE_NOTIFY] = true;
            }
            // 初始化设置
            this.musicActive = settingsData[TYPE_MUSIC];
            this.soundActive = settingsData[TYPE_SOUND];
            this.modelActive = settingsData[TYPE_MODEL];
            this.notifyActive = settingsData[TYPE_NOTIFY];
			
			if (ConfigApp.pf === ConfigApp.PF_360_3_h5) {
				Browser.window.pauseAudio = function():void {
					ModelSettings.instance.musicActive = ModelSettings.instance.soundActive = false;
				}
				Browser.window.resumeAudio = function():void {
					ModelSettings.instance.musicActive = ModelSettings.instance.soundActive = true;
				}
			}
        }

        public function getListData():Array
        {
            return [
                {'type': TYPE_MUSIC, 'name': Tools.getMsgById('_settings003'), 'value': this.musicActive},
                {'type': TYPE_SOUND, 'name': Tools.getMsgById('_settings004'), 'value': this.soundActive},
                //{'type': TYPE_MODEL, 'name': Tools.getMsgById('_settings005'), 'value': this.modelActive},
                //{'type': TYPE_NOTIFY,'name': Tools.getMsgById('_settings006'), 'value': this.notifyActive},
            ];
        }

        /**
         * 获取音乐开关状态
         */
        public function get musicActive():Boolean{
            return settingsData[TYPE_MUSIC];
        }

        /**
         * 设置音乐开关状态
         */
        public function set musicActive(value: Boolean):void
        {
            settingsData[TYPE_MUSIC] = value;
            MusicManager.musicMuted = !value;
        }

        /**
         * 获取音效开关状态
         */
        public function get soundActive():Boolean {
            return settingsData[TYPE_SOUND];
        }

        /**
         * 设置音效开关状态
         */
        public function set soundActive(value: Boolean):void
        {
            settingsData[TYPE_SOUND] = value;
            MusicManager.soundMuted = !value;
        }

        /**
         * 获取友军行军模型状态
         */
        public function get modelActive():Boolean {
            return settingsData[TYPE_MODEL];
        }

        /**
         * 设置友军行军模型状态
         */
        public function set modelActive(value: Boolean):void
        {
            settingsData[TYPE_MODEL] = value;
            this.event(CHANGE_MODEL);
        }

        /**
         * 获取行军到达等弹板通知状态
         */
        public function get notifyActive():Boolean {
            return settingsData[TYPE_NOTIFY];
        }

        /**
         * 设置行军到达等弹板通知状态
         */
        public function set notifyActive(value: Boolean):void
        {
            settingsData[TYPE_NOTIFY] = value;
        }

        /**
         * 保存设置
         */
        public function saveSettings():void
        {
            SaveLocal.save(SaveLocal.KEY_SETTINGS, settingsData);
        }
    }
}