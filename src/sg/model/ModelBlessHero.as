package sg.model
{
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.fight.FightMain;
    import sg.net.NetPackage;
    import laya.utils.Handler;
    import sg.net.NetMethodCfg;
    import sg.boundFor.GotoManager;
    import sg.utils.ObjectUtil;

    public class ModelBlessHero extends ViewModelBase
    {
        public static const UPDATE_DATA:String      = 'update_data';        // 数据更新

		public static const TYPE_MAIN:String = 'main';	
		public static const TYPE_SECONDARY:String = 'secondary';	
		// 单例
		private static var sModel:ModelBlessHero = null;		
		public static function get instance():ModelBlessHero {
			return sModel ||= new ModelBlessHero();
		}
		public var cfg:Object = null;
		public var cfg_main:Object = null;
		public var cfg_secondary:Object = null;
        public var show_num:int = 100;
		public var teamData:Object = {};
        public function ModelBlessHero()
        {
        }

        override protected function initData():void {
            var user:ModelUser = ModelManager.instance.modelUser;
            cfg = ConfigServer.bless_hero;
            cfg_main = cfg['main_' + user.mergeNum];
            cfg_secondary = cfg.secondary;
            
            this.lookup();
			this.refreshData(ModelManager.instance.modelUser.bless_hero);
        }

        override public function refreshData(bless_hero:*):void {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var gameDate:int = modelUser.getGameDate();
            for(var key:String in bless_hero) {
                var obj:Object = teamData[key];
                var data:Object = bless_hero[key];
                var starData:Array = data.data;
                if (obj && data.season_num === gameDate - 1) {
                    obj.star_num = starData[0] || 0;
                    obj.reward_num = starData[1] || 0;
                    data.num && (obj.remain_times = cfg.num - data.num);
                }
            }
            this.event(UPDATE_DATA);
        }

        private function lookup():void {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var gameDate:int = modelUser.getGameDate();
            var country:int = modelUser.country;
            var position:Array = cfg.position[country];
            teamData[TYPE_MAIN] = teamData[TYPE_SECONDARY] = {};
            var data_cfg:Object = null;
            var effect:Array = null;

            // 查找主线
            for(var ateam:String in cfg_main) {
                data_cfg = cfg_main[ateam];
                effect = data_cfg.effect || ['', 0, 1];
                if (gameDate === data_cfg.day) {
                    teamData[TYPE_MAIN] = {
                        cid: position[0],
                        team_id: ateam,
                        effectId: effect[0],
                        awaken: Boolean(effect[1]),
                        scale: effect[2],
                        npc_id: data_cfg.npc_id[country],
                        hid: data_cfg.hero[country],
                        reward: data_cfg.reward,
                        reward_num: 0,  // 领奖进度
                        star_num: 0,
                        remain_times: cfg.num,// 剩余挑战次数
                        begin_time: 0,  // 开始时间
                        end_time: 0     // 结束时间
                    };
                    break;
                }
            }

            // 查找支线
            for(var bteam:String in cfg_secondary) {
                data_cfg = cfg_secondary[bteam];
                effect = data_cfg.effect || ['', 0, 1];
                var day:int = modelUser.getGameDate(Tools.getTimeStamp(data_cfg.start_time) + ConfigServer.system_simple.deviation * Tools.oneMinuteMilli + 1);
                if (gameDate >= data_cfg.open_day && gameDate === day) {
                    teamData[TYPE_SECONDARY] = {
                        cid: position[1],
                        team_id: bteam,
                        effectId: effect[0],
                        awaken: Boolean(effect[1]),
                        scale: effect[2],
                        npc_id: data_cfg.npc_id,
                        hid: data_cfg.hero,
                        reward: data_cfg.reward,
                        reward_num: 0, // 领奖进度
                        star_num: 0,
                        remain_times: cfg.num,
                        begin_time: 0,
                        end_time: 0
                    };
                    break;
                }
            }

            this.refreshTime(); // 刷新时间（发布配置也会刷新）
        }

        public function getEnemyDataByType(type:String, secondary_lv:Array):Array {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var data:Object = teamData[type];
            var npc_id:String = data.npc_id;
            var arr:Array = ConfigServer.bless_hero_npc[npc_id] || ConfigServer.bless_hero_npc['default'];
            return arr.map(function(data:Object, index:int):Object { 
                if (type === TYPE_SECONDARY) {
                    data = ObjectUtil.clone(data);
                    data.lv += secondary_lv[index] || 0;
                }
                return {index: index, data: data};
             }, this);
        }
        
        public function refreshTime():void {
            var currentTime:int = ConfigServer.getServerTimer();
            Laya.timer.clear(this, this.event);
            for(var key:String in teamData) { 
                var data:Object = teamData[key];
                if (data.team_id) {
                    var obj:Object = key === TYPE_MAIN ? cfg_main : cfg_secondary;
                    var cfg_s:Object = obj[data.team_id];
                    data.begin_time = Tools.getTodayMillWithHourAndMinute(cfg_s.open_time[0]);
                    data.end_time = Tools.getTodayMillWithHourAndMinute(cfg_s.open_time[1]);
                    if (currentTime < data.begin_time) {
                        Laya.timer.once(data.begin_time - currentTime, this, this.event, [UPDATE_DATA], false);
                        Laya.timer.once(data.end_time - currentTime, this, this.event, [UPDATE_DATA], false);
                    }
                }
            }
            this.event(UPDATE_DATA);
        }

        public function getTime(type:String):int {
            var currentTime:int = ConfigServer.getServerTimer();
            var data:Object = teamData[type];
            return data.end_time - currentTime;
        }

        /**
         * 战斗
         */
        public function fight(type:String, team_id:String, hids:Array):void {

            this.sendMethod(NetMethodCfg.WS_SR_PK_BLESS, {type: type, team_id: team_id, hids: hids}, Handler.create(this, this._fightCB), type);
        }

        /**
         * 战斗的回掉
         */
        private function _fightCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;
			var type:String = re.otherData;
			ModelManager.instance.modelUser.updateData(receiveData);
            FightMain.startBattle(receiveData, this, this._outFight, [type, receiveData.star_num]);
        }

        /**
         * 战斗结束
         */
        private function _outFight(type:String, star_num:int):void {
            var data:Object = teamData[type];
            if (star_num > data.old_star) {
                data.new_star = star_num;
            }
            GotoManager.boundForPanel(GotoManager.VIEW_BLESS_HERO, '', [type, true]);
        }

        /**
         * 领奖
         */
        public function getReward(type:String, team_id:String):void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_BLESS_GIFT, {type: type, team_id: team_id});
        }

        public function getClipData(cid:int):Object {
            for(var key:String in teamData) { 
                var data:Object = teamData[key];
                if (data.team_id && data.cid === cid) {
                    return this.checkActive(key) ? data : null;
                }
            }
			return null;
        }

        public function get cids():Array {
            return cfg.position[ModelManager.instance.modelUser.country]
        }

        public function checkActive(type:String):Boolean {
            if(ModelGame.unlock('',"bless_hero").stop) {
                return false;
            }
            var currentTime:int = ConfigServer.getServerTimer();
            var data:Object = teamData[type];
            if (data && data.team_id) {
                return currentTime > data.begin_time && currentTime < data.end_time;
            }
            return false;
        }

        public function onClickCity(cid:int):void {
            var task_type:String = teamData[TYPE_MAIN].cid === cid ? TYPE_MAIN : TYPE_SECONDARY;
            GotoManager.boundForPanel(GotoManager.VIEW_BLESS_HERO, '', [task_type, false]);
        }

        public function get infoData():Array {
            var arr:Array = [];
            for(var key:String in teamData) { 
                var data:Object = teamData[key];
                this.checkActive(key) && arr.push([data.cid, data.hid, data.remain_times]);
            }
            return arr;
        }

        override public function get active():Boolean {
            return (checkActive(TYPE_MAIN) || checkActive(TYPE_SECONDARY));
        }

        override public function get redPoint():Boolean {
            return active && false;
        }
    }
}