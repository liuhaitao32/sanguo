package sg.guide.model
{
	
import sg.utils.Tools

    import laya.events.EventDispatcher;
    import laya.utils.Handler;

    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.map.model.MapModel;
    import sg.map.model.entitys.EntityHeroCatch;
    import sg.model.ModelEquip;
    import sg.model.ModelUser;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.task.TaskHelper;
    import sg.utils.ObjectUtil;
    import sg.utils.SaveLocal;
    import sg.activities.view.ActIconList;
    import sg.utils.ArrayUtil;
    import sg.cfg.ConfigClass;

    public class GuideChecker extends EventDispatcher
    {
        public static const TYPE_MAIN:String = 'main'; // 新手引导
        public static const TYPE_OFFICE:String = 'office_guide'; // 爵位引导
        public static const TYPE_HEROSLV:String = 'heroslv_guide'; // 英雄兵阶引导(兵阶功能开启后，第一次进入英雄属性界面)
        public static const TYPE_HERO_CATCH:String = 'catchhero_guide'; // 名将切磋引导
        public static const TYPE_COUNTRY:String = 'country_guide'; // 国家引导
        public static const TYPE_GUILD:String = 'guild_guide'; // 军团引导
        public static const TYPE_PK:String = 'pk_guide'; // 群雄逐鹿引导
        public static const TYPE_RESOLVE:String = 'resolve_guide'; // 问道引导
        public static const TYPE_ESTATE:String = 'estate_guide'; // 产业引导
        public static const TYPE_EQUIP:String = 'equip_guide'; // 宝物引导

        public static const DO_GUIDE:String = 'do_guide'; // 进行引导
        public static const ALL_OVER:String = 'all_over'; // 引导结束

        private var guideConfig:Object = null;
        private var _guideType:String = null;
        public var _guideID:String = null;  // 引导ID
		public var _guideIndex:int = 0;    // 引导小步骤
        private var _lastID:String = null;  // 上一步引导ID
        private var _lastIndex:int = 0;     // 上一步引导索引
		private var _gData:Array;		// 当前步骤的引导数据
		private var _buildArray:Array;		// 补偿数组
		private var _force:Boolean = false;	// 强制引导标识
		private var _canGuide:Boolean = false;	// 强制引导标识
		public var _buildMode:Boolean = false;	// 补偿模式
		private var _needSave:Boolean = false;   // 需要其它接口进行保存
		private var _checkOverTime:Boolean = false;   // 检测超时
		private var _tempProgress:Object = null;   // 自动保存的新手引导进度
        private var _sendMethod:String = '';
        private var _skip_key:String; // 跳过引导使用的key
        
        private var _guideLocalKey:String = SaveLocal.KEY_GUIDE + '_' + ModelManager.instance.modelUser.zone + '_' + ModelManager.instance.modelUser.mUID;
        private var _localData:Object = null;
        
		
		// 单例
		public static var sModel:GuideChecker = null;
		
		public static function get instance():GuideChecker
		{
			return sModel ||= new GuideChecker();
		}
		public static function clear():void{
            sModel.clearEvents();
            sModel = null;
        }        
        public function GuideChecker()
        {
            this.guideConfig = ObjectUtil.clone(ConfigServer.guide, true); // 引导配置
            // this._canGuide = false;
            this._canGuide = Boolean(ConfigServer.system_simple.is_guide);
            var uid:int = parseInt(ModelManager.instance.modelUser.mUID);
            var baseNum:int = Math.pow(10, 9);
            uid = uid % baseNum
            _skip_key = uid + 'skip_guide';
        }

        private function _getLocalData():void
        {
            this._localData = SaveLocal.getValue(this._guideLocalKey);
            this._localData || (this._localData = {});
        }

        public function initGuide():void
        {
            if (!this._canGuide) return;
            this._refreshMaxLV();
            this._getLocalData();
            this.getNewPlayerGuideID(); // 检查新手引导
            this._guideID || this.getConditionGuideID(); // 检查条件引导
            if (this._guideID) {
                NetSocket.instance.on(NetSocket.EVENT_SOCKET_OPENED, this, this.socketOpened); // 处理网络链接问题   
                NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_TO, this, this.onSocketReceived); // 接收网络返回
            }
        }

        public function startGuide():void
        {
            // 检测跳过弹板
            if (this.checkSkip()) {
                ViewManager.instance.showView(ConfigClass.VIEW_GUIDE_SKIP);
                return;
            }

            if (this._guideID) {

                // 处理做民情没编队的情况
                var troops:Object = ModelManager.instance.modelTroopManager.troops;
                var progress:int = parseInt(_guideID.match(/\d+/)[0]);
                if( progress > 2 && progress < 8 && ObjectUtil.keys(troops).length === 0) {
                    ModelManager.instance.modelTroopManager.sendCreateTroops('hero701');
                }

                this._initData();
            }
			this.getCurrentGuideData() && this.event(DO_GUIDE);
        }

        private function socketOpened():void
        {
            this._force && this._guideType === TYPE_MAIN && this.getCurrentGuideData() && this.event(DO_GUIDE);
            // console.info('%c 服务器重连， 继续当前步骤','color:red;font-size:16px');
        }

        private function onSocketReceived(re:Object, isMe:Boolean):void
        {
            var code:int = re['code'];
            var method:String = re['method'];
            var records:Object = ModelManager.instance.modelUser.records;
            if (this._tempProgress && this._sendMethod === method && this._guideType === TYPE_MAIN) {
                if (code === 0) {
                    records.guide = this._tempProgress;
                    this._tempProgress = null;
                    this._sendMethod = '';
                }
                var guideData:Array
                this.refreshGuide(records.guide[0], records.guide[1]);
            }
        }

        /**
         * 初始化以引导数据
         */
        public function _initData():void
        {
            if (this._guideType && this._guideID) {
                this._gData = this.getData(this._guideType, this._guideID); // 获取引导数据
                this._gData && this.checkEqualize();
            }
        }

        /**
         * 获取引导数据
         */
        private function getData(type:String, id:String):Array
        {
            var data:Array = null;
            if (type === TYPE_MAIN) {
                data = this.guideConfig.new_install[id];
            }
            else {
                data = this.guideConfig[type] && this.guideConfig[type][id];
            }
            return data;
        }
        
		/**
		 * 检测补偿，并开始引导
		 */
		private function checkEqualize():void {
			if (this._gData[0] is Array) { // 检测是否存在补偿数据
				var scene:Object = ViewManager.instance.getCurrentScene();
				var panel:Object = ViewManager.instance.getCurrentPanel();
				var inside:Boolean = ModelManager.instance.modelGame.isInside;
				if (scene || panel || inside) {	// 不需要开启补偿模式
					this._gData.shift();
				}
				else {
					// console.info('补偿模式开启');
					this._buildMode = true;
					this._buildArray = this._gData[0];
				}
			}
			this._guideIndex = 0;
        }

        /**
         * 获取当前引导数据（小步骤）
         */
        public function getCurrentGuideData():Object
        {
            if (!this._guideType || !this._gData)   return null;
            if (this._buildMode) {
                return this._buildArray[this._guideIndex];
            }
            else {
                return this._gData[this._guideIndex];
            }
        }

        public function continueGuide():void
        {
            // 缓存当前数据
            this._lastID = this._guideID;
            this._lastIndex = this._guideIndex;
            this._guideIndex++;
            if (this._buildMode) {
                if (this._guideIndex === this._buildArray.length) {
                    this._buildMode = false;
                    this._buildArray = null;
                    this._guideIndex = 0;
                    this._gData.shift();
                }
                this.event(DO_GUIDE);
            }
            else {
                if (this._guideIndex === this._gData.length) {
                    this._guideID = this.getNextID();
                    this._guideIndex = 0;
                    this._initData();
                    if (!this._gData) {
                        // 引导结束
                        this.event(ALL_OVER);
                        if (this._guideType === TYPE_MAIN) {
                            this.guideOver();
                            this.event(ActIconList.SHOW_ICONS);
                            TaskHelper.instance.refreshMainTask();
                        }
                        else this.guideOver();
                    }
                }
                // 保存数据
                this.recordGuide();
            }
            
        }

        /**
         * 获取新手引导ID
         */
        private function getNewPlayerGuideID():void
        {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
			var guideData:Array = modelUser.records.guide;
            var gid:String = guideData[0];
            var index:int = guideData[1];
            if (modelUser.getLv() < 3) {
                if(!guideData.length) {
                    gid = 'g001';
                    if (ObjectUtil.keys(modelUser.hero).length > 0) { // 自己人 已经有英雄了 不用走引导
                        return;
                    }
                }
                this._guideType = TYPE_MAIN;
                this._force = true;
            }
            this._guideID = gid;
            this.checkNewPlayerGuideIndex(gid, index) && (this._guideID = this.getNextID());
            if (!this.getData(this._guideType, this._guideID) || modelUser.isMerge) {
                this._guideID = null;
                this._guideType = null;
                this._force = false;
                // console.info('新手引导已完成');
            }
        }

        private function checkNewPlayerGuideIndex(id:String, index:int):Boolean
        {
            var data:Array = this.guideConfig.new_install[id];
            if (!data is Array)  return false;

            // 检查需要保存的位置
            var pos:int = ArrayUtil.findIndex(data, function(item:*):Boolean{return item['save'] != null}); // save的上一步数据改变
            if (data[0] is Array)   pos -= 1; // 减去补偿占的位置
            if (pos === -1) {
                pos = data.length - 1;
            }
            return index >= pos;
        }

        /**
         * 检测有无可执行的条件引导
         */
        private function getConditionGuideID(key:String = ''):void
        {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var lv:int = modelUser.getLv();
            var type:String = this.guideConfig['lv_guide_start'][lv];
            var tempLv:int = 0;
            var tempIndex:int = 0; // 临时储存引导步骤
            switch(lv) {
                case 3: // office_guide
                    tempLv = modelUser.office;
                    tempLv === 0 && (tempIndex = 1);
                    tempLv === 1 && modelUser.office_right.length === 0 && (tempIndex = 2);
                    break;
                case 4: //catchhero_guide
                    // 判断首都是否存在名将切磋
					var heroCatch:EntityHeroCatch = ArrayUtil.find(MapModel.instance.heroCatch, function(item:EntityHeroCatch):Boolean{
                        return item.city['cityId'] == MapModel.instance.getCapital(ModelUser.getCountryID()).cityId;
                    });
                    heroCatch && (tempIndex = 1);
                    break;
                case 5: //guild_guide
                    if (this.isGuideAlreadyExecute('country_guide')) return;
                    tempIndex = 1;
                    break;
                case 6: //pk_guide
                    tempLv =  modelUser.home['building008']['lv'];
                    tempLv === 0 && (tempIndex = 1);
                    tempLv === 1 && modelUser.task['common']['task088'][1] === 0 && (tempIndex = 2);
                    break;
                case 8: // resolve_guide
                    tempLv =  modelUser.home['building006']['lv'];
                    tempLv === 0 && (tempIndex = 1);
                    break;
                case 9: // estate_guide
                    // 判断产业数量为0
                    modelUser.estate.length === 0 && (tempIndex = 1);
                    break;
                case 10: // equip_guide
                    tempLv =  modelUser.home['building002']['lv'];
                    tempLv === 0 && (tempIndex = 1);
                    tempLv === 1 && ObjectUtil.keys(modelUser.equip).length === 0 && !ModelEquip.getCDingModel() && (tempIndex = 2);               
                    break;
                case 11: // science_guide
                    tempLv =  modelUser.home['building003']['lv'];
                    tempLv === 0 && (tempIndex = 1);
                    break;
                case 12: // shogun_guide
                    ModelUser.isShogunHasHero() || (tempIndex = 1);
                    break;
                case 15: //lookstar_guide
                    var itemName:String = ArrayUtil.find(ObjectUtil.keys(modelUser.property), function(item:String):Boolean{
                        return (/item6/).test(item); // 检测是否存在星辰碎片
                    });
                    // 检测是否存在星辰和星辰碎片
                    ObjectUtil.keys(modelUser.star).length === 0 && !itemName && (tempIndex = 1);
                    break;
            }
            if (key && type !== key) { //说明不是通过官邸等级触发
                type = key;
                tempIndex = 1;
            }
            tempIndex && (this._guideID = type.replace('guide', ('g00' + tempIndex)));
            if (this._guideID && !this.isGuideAlreadyExecute(type)) {
                this._guideType = type;
                this._force = true;
            }
            else {
                this._guideType = null;
                this._guideID = null;
                this._force = false;
            }
        }

        private function isGuideOver(type:String, id:String, index:int):Boolean
        {
            var gData:Array = this.getData(type, id); // 获取引导数据
            if (!gData) return true;
            return false;
        }

        /**
         * 检测条件引导是否已经执行过
         */
        private function isGuideAlreadyExecute(type:String):Boolean
        {
            var data:Array = this.checkGuideDataWithKey(type);
            if(data && type !== 'legend_guide') {
                var gid:String = data[0];
                var index:int = data[1];
                return this.isGuideOver(type, gid, index);
            }
            return false;
        }

        public function checkGuideDataWithKey(type:String):Array
        {
            return this._localData[type];
        }

        public function initConditionGuide(key:String = ''):void
        {
            this.getConditionGuideID(key);
            this._initData();
            if (this.getCurrentGuideData()) {
                this.event(DO_GUIDE);
                // console.info('开始条件引导1'); 
            }
        }

        /**
         * 打点成功之后刷新引导
         */
        public function refreshGuide(gid:String, gIndex:int):void
        {
            if (!this._canGuide || this.guideType !== TYPE_MAIN) return;
            this._checkOverTime = false;

            // 刷新进度、派发引导
            this._guideID = gid;
            this._guideIndex = gIndex;
            this.getCurrentGuideData() && this.event(DO_GUIDE);
        }

        /**
         * 保存引导进度
         */
        public function recordGuide():void
        {
            switch(this._guideType)
            {
                case TYPE_MAIN:
                    this.recordNewPlayerGuide()
                    break;            
                default:
                    this.recordConditionGuide()
                    break;
            }
        }

		/**
		 * 获取下一个引导ID
		 */
		private function getNextID():String
		{
			var result:Array = this._guideID.match(/(.*?)g(\d+)/);
			return result[1] + (parseInt(result[2]) + 1001).toString().replace('1', 'g');
		}

		/**
		 * 保存新手引导进度
		 */
		private function recordNewPlayerGuide():void
		{
            // 检测下一步是否是save，是的话本步骤不保存
            if (this._gData) {
                var nextData:* = this._gData[this._guideIndex];
                var lastData:* = this._gData[this._guideIndex - 1];
            }
            if (nextData && nextData['save'] && this._guideID !== 'g001' && this._guideID !== 'g028' && this._guideID !== 'g042') {
                if (
                    _guideID === 'g028' ||
                    _guideID === 'g042'
                ) {
                    var progressData:Object = {guide_type: this._guideID, guide_num: this._guideIndex};
                    progressData && NetSocket.instance.send(NetMethodCfg.WS_SR_DO_GUIDE, progressData, Handler.create(this, this.recordCB));
			        // progressData && // console.info('%c 保存进度','color:green;font-size:16px', progressData);
                    this.addOverTimeEvent();
                } else {
                    this._needSave = true;
                    // console.info('=========================      开启自动保存     =============================');
                    return;
                }
            } else {
                progressData = {guide_type: this._guideID, guide_num: this._guideIndex};
                progressData && NetSocket.instance.send(NetMethodCfg.WS_SR_DO_GUIDE, progressData, Handler.create(this, this.recordCB));
                // progressData && // console.info('%c 保存进度','color:green;font-size:16px', progressData);
                this.addOverTimeEvent();

                // 下次更
                // this.refreshGuide(_guideID, _guideIndex);
            }
		}

        /**
         * 将条件引导的进度保存到本地
         */
        private function recordConditionGuide():void {
            if (!this._guideType) {
                return;
            }
            this._localData[this._guideType] = [this._guideID, this._guideIndex];
            SaveLocal.save(this._guideLocalKey, this._localData);

            this.getCurrentGuideData() && this.event(DO_GUIDE);
        }

		private function recordCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;
			ModelManager.instance.modelUser.updateData(receiveData);
            var guideData:Array = ModelManager.instance.modelUser.records.guide;
            this.refreshGuide(guideData[0], guideData[1]);
		}

        /**
         * 获取当前引导类型
         */
        public function get guideType():String
        {
            return this._guideType;
        }

        /**
         * 获取当前引导ID
         */
        public function get guideID():String
        {
            return this._guideID;
        }

        /**
         * 是否为强制引导
         */
        public function get force():Boolean
        {
            return this._force;
        }

        /**
         * 是否为强制引导
         */
        public function get canGuide():Boolean
        {
            return this._canGuide;
        }

        public function guideOver():void
        {
            this.recordGuide();
            this._force = false;
            this._guideType = null;
            this._guideID = null;
            this._guideIndex = 0;
        }

		/**
		 * 检查新手引导, 用于向服务器保存数据
		 */
		public function checkNewPlayerData(method:String):Object
		{
            if (this._guideType === TYPE_MAIN && this._needSave) {
                this._tempProgress = [this._guideID, this._guideIndex];
                this._needSave = false;
                this._sendMethod = method;
                // console.info('=========================      自动保存引导进度     =============================' + this._guideIndex);
                this.addOverTimeEvent(); // 添加连接超时的处理逻辑
                return {guide_type: this._guideID, guide_num: this._guideIndex};
            }
            return null;
		}

        private function addOverTimeEvent():void
        {
            this._checkOverTime = true;
            Laya.timer.once(NetSocket.timeOutTimer, this, this._overTime);
        }

        /**
         * 处理自动保存超时
         */
        private function _overTime():void
        {
            if (this._checkOverTime && this._guideType === TYPE_MAIN) {
                this._checkOverTime = false;
                console.warn(Tools.getMsgById("msg_GuideChecker_0") + this._guideID + ' ' + this._guideIndex);
                // this.getCurrentGuideData() && this.event(DO_GUIDE); // 继续引导

                ModelGuide.instance.guideOver();
                this._force = false;
                ViewManager.instance.showWarnAlert(Tools.getMsgById("_lht59"),Handler.create(Platform, Platform.restart));
            }
        }

        /**
         * 检测是否跳过先手引导
         */
        public function checkSkip():Boolean {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var limitLV:int = ConfigServer.guide.jump_guide.user_lv;
            var maxLV:int = SaveLocal.getValue(_skip_key) as Number;
            
            return maxLV && maxLV > limitLV && modelUser.records.guide.length === 0;
        }

        private function _refreshMaxLV():void {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var limitLV:int = ConfigServer.guide.jump_guide.user_lv;
            var maxLV:int = SaveLocal.getValue(_skip_key) as Number;
            maxLV = maxLV ? Math.max(maxLV, modelUser.getLv()) : modelUser.getLv();
            
            maxLV >= limitLV && SaveLocal.save(_skip_key, maxLV);
        }

        public function skipGuide():void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_JUMP_GUIDE, {}, Handler.create(this, this._skipGuideCB));
        }

        private function _skipGuideCB(re:NetPackage):void {
			var gift_dict:* = re.receiveData['gift_dict'];
			ModelManager.instance.modelUser.updateData(re.receiveData);
			gift_dict && ViewManager.instance.showRewardPanel(gift_dict);
            ModelManager.instance.modelGame.checkFtask();//检查民情
            this.event(ALL_OVER);
            this._force = false;
            this._guideType = null;
            this._guideID = null;
            this._guideIndex = 0;
            this.event(ActIconList.SHOW_ICONS);
            TaskHelper.instance.refreshMainTask();
        }
    }
}