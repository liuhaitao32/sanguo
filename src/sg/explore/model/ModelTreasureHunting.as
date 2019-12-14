package sg.explore.model
{
    import laya.events.EventDispatcher;
    import sg.cfg.ConfigServer;
    import sg.model.ViewModelBase;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.model.ModelGame;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import laya.utils.Handler;
    import sg.net.NetMethodCfg;
    import sg.utils.Tools;
    import sg.cfg.ConfigClass;
    import sg.model.ModelOfficial;
    import sg.fight.FightMain;
    import sg.utils.TimeHelper;
    import sg.explore.view.ViewTreasureHunting;
    import sg.utils.StringUtil;
    import sg.map.model.MapModel;
    import sg.scene.constant.EventConstant;

    public class ModelTreasureHunting extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelTreasureHunting = null;
        public static const RESOURCE_ID:String = 'item162';
        public static const PRAY_TOOL_ID:String = 'item163';

        public static const REFRESH_PLACE:String = 'refresh_place';       // 事件 刷新资源点
        public static const REFRESH_DETAIL:String = 'refresh_detail';     // 事件 刷新详情
        public static const FIGHT_END:String    = 'fight_end';      // 事件 抢夺战斗结束
        
        public static const STATE_LOCK:String   = 'state_lock';     // 状态 尚未解锁
        public static const STATE_BEFORE:String = 'state_before';   // 状态 尚未开始
        public static const STATE_MINING:String = 'state_mining';   // 状态 正在寻宝
        public static const STATE_REWARD:String = 'state_reward';   // 状态 寻宝结束
        public static const STATE_LOSE:String   = 'state_lose';     // 状态 资源点丢失（可以收获）
        
		public static function get instance():ModelTreasureHunting
		{
			return sModel ||= new ModelTreasureHunting();
		}
		public var cfg:Object = null;
		public var treasureData:Array = [];
		public var res:Array = [];          // 3个资源点数据
		public var free_magic_num:int;      // 免费卜卦次数
		public var last_magic_time:Object;  // 上次卜卦时间
		public var magic_id:String;         // 卦象ID
		public var grab_num:int = 0;        // 抢夺次数
		public var last_grab_time:Object = null;    // 上次抢夺时间
		public var enemyData:Object;        // 当前刷出来的对手的数据
        public var reportArr:Array;
		public var newReportId:int = 0;     // 最新战报的id
        public function ModelTreasureHunting() {
        }

        override protected function initData():void {
            cfg = ConfigServer.mining;
            var grab_safe:Array = cfg.grab_safe;
            for(var i:int = 0, len:int = grab_safe.length; i < len; i++) {
                treasureData.push({
                    index: i,
                    totalNum: cfg.work_reward[i],
                    saveNum: grab_safe[i],
                    enemy: false,
                    heros: [],
                    magic: null,
                    grabbed_num: 0,
                    loseTime: 0,
                    grabbedArr: null, //防守成功与失败的次数
                    state: '',
                    endTime: 0
                });
            }
			MapModel.instance.on(EventConstant.CITY_COUNTRY_CHANGE, this, function():void{this.refreshData(null)});
        }

        override public function refreshData(data:*):void {
            var user:ModelUser = ModelManager.instance.modelUser;
            data = data || user.mining;

            // 刷新寻宝数据
            for(var key:String in data) { this.hasOwnProperty(key) && (this[key] = data[key]); }

            // 抢夺的用户
            enemyData = data.next_grab_user;

            //跨天重置数据
            if (Tools.isNewDay(last_magic_time))    last_magic_time = null, free_magic_num = 0, magic_id = '';
            if (Tools.isNewDay(last_grab_time))     last_grab_time = null,  grab_num = 0;

            for(var i:int = 0, len:int = res.length; i < len; i++) {
                var resData:Array = res[i];
                var sData:Object = treasureData[i];
                if (resData) {
                    sData.endTime = Tools.getTimeStamp(resData[0]) + cfg.work_time * Tools.oneMinuteMilli;
                    sData.heros = resData[1];
                    sData.magic = resData[2];
                    sData.grabbed_num = resData[3];
                    sData.loseTime = Tools.getTimeStamp(resData[4]);
                    sData.grabbedArr = resData.slice(5, 5+2).reverse(); // 后端反了  所以要反一下
                }
                else {
                    sData.endTime = 0;
                    sData.heros = [];
                    sData.magic = magic_id;
                    sData.grabbed_num = 0;
                    sData.loseTime = 0;
                    sData.grabbedArr = [0, 0];
                }
                sData.state = this.getState(sData, user.country);
            }
            this.event(ModelTreasureHunting.REFRESH_PLACE);
            this.event(ModelTreasureHunting.REFRESH_DETAIL);
        }

        /**
         * 检测新战报
         */
        public function checkNewReport(handler:Handler):void {
            
            var tempReportId:int = newReportId;
            if (tempReportId === 0) {
                tempReportId = Number.MAX_VALUE;
            }
            ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_GET_GRAB_LOG, null, Handler.create(this, function(re:NetPackage):void{
                var reportData:Array = re.receiveData;
                var normalReportArr:Array = reportData[0].filter(this.isLogInvalid, this);
                var garbedReportArr:Array = reportData[1].filter(this.isLogInvalid, this);
                reportArr = [normalReportArr, garbedReportArr];
                handler.runWith(newReportId > tempReportId);
            }));
        }

        private function isLogInvalid(item:Object):Boolean {
            var logId:int = item.id;
            if (logId > newReportId) {
                newReportId = logId;
            }
            return !Tools.isNewDay(logId);
        }

        public function getState(sData:Object, country:int):String {
            var grab_city:Array = cfg.grab_city[country];
            grab_city = grab_city.filter(function(cId:String):Boolean { 
                return  ModelOfficial.cities[cId].country === country;
            }, this)
            var cityNum:int = grab_city.length;

            if (sData.loseTime)   return STATE_LOSE;
            if (sData.endTime === 0 && cityNum < sData.index)   return STATE_LOCK; // 服务器觉得资源点没丢就是没丢
            if (sData.heros.length === 0)       return STATE_BEFORE;
            if (this.getRemainTime(sData) === 0)    return STATE_REWARD;
            return STATE_MINING;
        }

        /**
         * 创建编队
         */
        public function createTroop(index:int):void {
            
            if (!magic_id) {
                ViewManager.instance.showHintPanel(
                    Tools.getMsgById('_explore044'), // 内容
                    null,
                    [
                        {'name': Tools.getMsgById('_explore017'), 'handler': Handler.create(ViewManager.instance, ViewManager.instance.showView, [ConfigClass.VIEW_HUNT_PRAY_PANEL])},
                        {'name': Tools.getMsgById('_explore045'), 'handler': Handler.create(this,this.createTroopReal, [index])},
                    ]
                );
            }
            else this.createTroopReal(index);
        }
        
        private function createTroopReal(index:int):void {
            var self:ModelTreasureHunting = this;
            ViewManager.instance.showView(ConfigClass.VIEW_EXPLORE_TROOP, {
                mMaxTroop: 3,
                filterHeros: this.getFilterHeros(),
                handler: Handler.create(this, function(hids:Array):void {
                    // 开始采集 
                    ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_START_MININE, {resId: index, hids: hids});
                })
            });
        }

        /**
         * 获取需要过滤掉的英雄
         */
        public function getFilterHeros():Array {
            var filterHeros:Array = [];
            for(var i:int = 0, len:int = res.length; i < len; i++) {
                var element:Array = res[i];
                if (element) filterHeros = filterHeros.concat(element[1]);
            }
            return filterHeros;
        }

        /**
         * 获取对应资源点的剩余采集时间
         */
        public function getRemainTime(sData:Object):int {
            var remainTime:int = sData.endTime - ConfigServer.getServerTimer();
            remainTime = remainTime > 0 ? remainTime: 0;
            return remainTime;
        }

        /**
         * 卜卦
         */
        public function getMagic():void {
            ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_GET_MAGIC);
        }

        /**
         * 收获
         */
        public function harvMining(id: int):void {
            ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_HARV_MININEE, {resId: id});
        }

        /**
         * 获取被抢夺用户数据
         */
        public function getGarbUserData(refresh:Boolean = false, handler:Handler = null):void {
            if (false === refresh && enemyData) {
                if (enemyData.timeout && this.checkOverdue(enemyData.timeout)) { // 检查是否过期
                    ViewTreasureHunting.refreshUI(true, enemyData);
                    return;
                }
            }
            ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_GET_GRAB_USER, {refresh: refresh}, Handler.create(this, this._getGarbUserDataCB));
        }

        private function _getGarbUserDataCB(re:NetPackage):void {
			ModelManager.instance.modelUser.updateData(re.receiveData);
            ViewTreasureHunting.refreshUI(true, enemyData);
		}

        /**
         * 检查是否过期
         * 过期 返回 0 否则返回剩余时间
         */
        public function checkOverdue(timeout:Object):int {
            var outTime:int = Tools.getTimeStamp(timeout);
            var currentTime:int = ConfigServer.getServerTimer();
            if (outTime > currentTime) {
                return outTime - currentTime;
            }
            return 0;
        }

        /**
         * 抢夺
         */
        public function garbUser(hids:Array, resId:int, logId:int = null):void {
            ModelExplore.instance.sendMethod(NetMethodCfg.WS_SR_GET_GRAB_MINING, {hids: hids, resId: resId, logId: logId}, Handler.create(this, this._garbUserCB));
        }

        /**
         * 抢夺的回掉
         */
        private function _garbUserCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;	
			ModelManager.instance.modelUser.updateData(receiveData);
            FightMain.startBattle(receiveData, this, this._outFight, [receiveData]);
        }

        /**
         * 战斗结束
         */
        private function _outFight(receiveData:*):void {
            this.event(FIGHT_END);
        }

        /**
         * 检测卜卦
         */
        public function get isPray():Boolean {
            return magic_id !== '';
        }

        /**
         * 检测收获
         */
        public function checkHarvest():Boolean {
            return treasureData.some(function(element:*, index:int):Boolean { return element.loseTime || (element.endTime && element.endTime < ConfigServer.getServerTimer()); }, this);
        }

        /**
         * 检测收获
         */
        public function get canGarb():Boolean {
            return grab_num < cfg.grab_num;
        }

        /**
         * 检测收获
         */
        public function get canHunt():Boolean {
            return treasureData.some(function(item:Object):Boolean { return item.state === STATE_BEFORE; }, this);
        }

        override public function get active():Boolean {
            return !ModelGame.unlock('',"mining").stop && openDaysEnough;
        }

        override public function get redPoint():Boolean {
            return active && (!isPray || checkHarvest() || canHunt || canGarb);
        }
        
        public function get openDays():int {
            var user:ModelUser = ModelManager.instance.modelUser;
            return cfg.begin_time[user.isMerge ? 1 : 0];
        }
        
        public function get openDaysEnough():Boolean {
            var user:ModelUser = ModelManager.instance.modelUser;
            return user.getGameDate() >= openDays;
        }
        
        public function get openWords():String {
            var year:int = Math.floor((openDays - 1) / 4) + 1;
            var season:int = (openDays - 1) % 4;
            var seasonNames:Array = [
                Tools.getMsgById("510052"), 
                Tools.getMsgById("510067"), 
                Tools.getMsgById("510068"), 
                Tools.getMsgById("510069")
            ];
            return Tools.getMsgById('_explore046', [StringUtil.numberToChinese(year), seasonNames[season]]);
        }
    }
}