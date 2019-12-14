package sg.altar.legend.model
{
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ViewModelBase;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.utils.StringUtil;
    import sg.utils.ObjectUtil;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.fight.FightMain;
    import sg.manager.ViewManager;
    import sg.altar.legend.view.ViewLegendKillNum;
    import sg.altar.legend.view.ViewLegendKillRate;
    import sg.net.NetSocket;

    public class ModelLegend extends ViewModelBase
    {
        public static var TYPE_ROAD:String = 'road';
        public static var TYPE_EXPERIENCE:String = 'experience';
        public static const UPDATE_DATA:String = 'update_data';         // 根据数据刷新界面

		// 单例
		private static var sModel:ModelLegend = null;
		public static function get instance():ModelLegend {
			return sModel ||= new ModelLegend();
		}
		public var cfg:Object = null;
		public var hero_dict:Object = null;
		public var cfg_heros:Object = null;
		public var buyTimes:int = 0;
		public var remainTimes:int = 0;
		public var sortIds:Array = null; // 排序
        public function ModelLegend() {
            cfg = ConfigServer.legend;
            cfg_heros = cfg['heros_' + ModelManager.instance.modelUser.mergeNum];
            sortIds = ObjectUtil.keys(cfg_heros);
            sortIds.sort(function(a, b):int {
                var data_a:Object = cfg_heros[a];
                var data_b:Object = cfg_heros[b];
                // trace(data_a.index - data_b.index)
                return data_a.index - data_b.index;
            });
        }

        override protected function initData():void {
        }

        override public function refreshData(legend:*):void {
            legend = legend || ModelManager.instance.modelUser.legend;
            buyTimes = legend.buy_times;
            remainTimes = legend.combat_times;
            hero_dict = legend.hero_dict || {};
            this.event(UPDATE_DATA);
        }

        public function get listData():Array {
            var hids:Array = ObjectUtil.clone(sortIds) as Array;
            var gameDate:int = ModelManager.instance.modelUser.getGameDate();
            hids = hids.filter(function(hid:String):Boolean { return cfg_heros[hid].road.open_date <= gameDate; });
            hids.push(null);
            return hids.map(this._getLegendData, this);
        }
        
        private function _getLegendData(hid:String):Object {
            var heroName:String = '???';
            var info:String = '';
            var type:String = TYPE_ROAD;
            var progress:int = 0;
            var reward:Boolean = false;
            if (hid) {
                var md:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
                heroName = Tools.getMsgById(md.name);
                var data_road:Object = hero_dict[hid];
                if (data_road) {
                    progress = data_road[0] / cfg_heros[hid].road.need_kill;
                    progress = progress > 1 ? 1: progress;
                    data_road[1] === 1 && (type = TYPE_EXPERIENCE);
                }
                reward = this.haveRewardWithHid(hid);
                info = Tools.getMsgById('_jia0119') + StringUtil.numberToPercent(progress, 1);
            }
            
            return {
                type: type,
                hid: hid,
                name: heroName,
                info: info,
                reward: reward,
                value: progress
            };
        }

        public function challenge(legend_hid:String, hids:Array, handler:Handler):void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_LEGEND_COMBAT, {legend_hid: legend_hid, hids: hids}, Handler.create(this, this._challengeCB), handler);
        }

        /**
         * 挑战的回掉
         */
        private function _challengeCB(re:NetPackage):void {
			var receiveData:* = re.receiveData;	
			var otherData:* = re.otherData;	
			ModelManager.instance.modelUser.updateData(receiveData);
            FightMain.startBattle(receiveData, this, this._outFight, [receiveData, otherData]);
        }

        /**
         * 战斗结束
         */
        private function _outFight(receiveData:*, handler:Handler):void {
            handler.runWith(receiveData);
        }
        
        public function buyChallengeTimes(type:int):void { // 确定 => (type == 0)
            type || this.sendMethod(NetMethodCfg.WS_SR_GET_LEGEND_BUY_TIMES);
        }

        public function getKillNum(hid:String):int {
            if (!hero_dict[hid]) return 0;
            return hero_dict[hid][0];
        }

        /**
         * 传奇之路奖励状态
         */
        public function getRoadRewardState(hid:String):int {
            var needKill:int = cfg_heros[hid].road.need_kill;
            if (!hero_dict[hid] || hero_dict[hid][0] < needKill) return 0;
            return hero_dict[hid][1] + 1;
        }

        /**
         * 传奇之路击杀数量
         */
        public function getRoadReward(hid:String):void {
            this.sendMethod(NetMethodCfg.WS_SR_GET_LEGEND_REWARD, {legend_hid: hid});
        }

        /**
         * 剩余挑战次数
         */
        public function get remainTimesTxt():String {
            return remainTimes + '/' + totalTimes;
        }

        /**
         * 总挑战次数
         */
        public function get totalTimes():int {
            return cfg.initial_times + buyTimes;
        }

        /**
         * 购买价格
         */
        public function get buyPrice():int {
            return cfg.coin_buy[buyTimes];
        }

        /**
         * 某个英雄有奖励可领
         */
        public function haveRewardWithHid(hid:String):Boolean {
            return this.getRoadRewardState(hid) === 1;
        }

        /**
         * 有奖励可领
         */
        public function get haveReward():Boolean {
            return sortIds.some(this.haveRewardWithHid, this);
        }

        /**
         * 通过配置控制见证传奇面板和祭坛建筑是否显示（合服相关）
         */
        public function get canShow():Boolean {
            var isMerge:Boolean = ModelManager.instance.modelUser.isMerge;
            return (isMerge === false && cfg.merge === 0) || (isMerge && cfg.merge === 1);
        }

        override public function get active():Boolean {
            return !ModelGame.unlock('',"legend").stop && canShow && this.alterLvEnough;
        }

        override public function get redPoint():Boolean {
            return active && (haveReward || remainTimes > 0);
        }

        /**
         * 检查祭坛等级是否满足条件
         */
         public function get alterLvEnough():Boolean {
            return ModelManager.instance.modelInside.getBuildingModel(cfg.need_building[0]).lv >= cfg.need_building[1];
        }
        
        /**
         * 是否可以预告
         */
         public function get forshow():Boolean {
            var obj:Object = ModelGame.unlock('',"legend");
            // 官邸等级 => 置灰 或者 祭坛等级不足 
            return obj.visible && canShow &&  (obj.gray || !this.alterLvEnough);
        }

         public function get openWords():String {
             var need:Array = cfg.need_building;
            var str:String = Tools.getMsgById("190008",[ModelManager.instance.modelInside.getBuildingModel(need[0]).getName(), need[1]]);
            return str;
        }
    }
}