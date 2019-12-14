package sg.model
{
	import laya.maths.MathUtil;
	import laya.utils.Handler;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.Vector2D;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.entitys.EntityBase;
	import sg.utils.Tools;
	import sg.fight.FightMain;
	import laya.ui.Button;
	import sg.map.view.TroopAnimation;
	import sg.utils.ObjectUtil;
	import sg.utils.StringUtil;

    public class ModelClimb extends ModelBase{
        public static const EVENT_CLIMB_FIGHT_END:String = "event_climb_fight_end";
        //
        public static const EVENT_CHAMPION_SIGN_OK:String = "event_champion_sign_ok";
        //
        public static const EVENT_PK_NPC_VIEW_UPDATE:String = "event_pk_npc_view_update";

        public static function getCfg():Object{
            return ConfigServer.climb;
        }
        /**
         * 获取 configure 配置
         */
        public static function getCfgConfigure():Object{
            return getCfg().configure;
        }   
        public function climb_fight(receiveData:Object):void{
            var fds:Number = ModelManager.instance.modelClimb.isClimbIng();
            if(fds>0){
                // receiveData.pk_data["reward"] = receiveData.;//ModelManager.instance.modelClimb.getMyClimbAward();
                receiveData.pk_data["skipTime"] = (receiveData.pk_result.time*Tools.oneMillis - fds)*0.001;
                // receiveData.pk_data["lastKillWave"] = ModelManager.instance.modelClimb.getMyKillNumMax() -  
                // trace(receiveData.pk_data.skipTime,receiveData.pk_result.time*Tools.oneMilliS,fds);         
            }
            //
			FightMain.startBattle(receiveData);
        }
        /**
         * 每日可购买的挑战次数
         */
        public function getBuyTimes():Number{
            return getCfgConfigure().buy;
        }
        public function getBuyTimesGet():Number{
            if(Tools.isNewDay(ModelManager.instance.modelUser.climb_records.buy_time)){
                return 0;
            }
            return ModelManager.instance.modelUser.climb_records.buy_times;
        }
        public function getMyClimbTimes():Number{
            if(Tools.isNewDay(ModelManager.instance.modelUser.climb_records.combat_time)){
                return this.getFightTimesByDay();
            }
            return ModelManager.instance.modelUser.climb_records["combat_times"];
        }
        public function getMyClimbAward():Object{
            var reward:Object = ModelManager.instance.modelUser.climb_records["reward"];
            return reward?reward:{};
        }
        public function isGetAward():Boolean
        {
            if(this.isClimbIng()<=0 && Tools.getDictLength(this.getMyClimbAward(),true)>0){
                return true;
            }
            return false;
        }
        public function getClimbAwardToMe(handler:Handler):void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CLIMB_REWARD,{},Handler.create(this,function(re:NetPackage):void{
                var reward:Object = ModelManager.instance.modelClimb.getMyClimbAward();
            
                ModelManager.instance.modelUser.updateData(re.receiveData);
                //
                ViewManager.instance.showRewardPanel(reward);
                //
                if(ModelManager.instance.modelGame.isInside){
                    ModelManager.instance.modelInside.getBuildingModel("building007").updateStatus(true);
                }                
                //
                if(handler){
                    handler.run();
                }
            }));
        }
        public function setClimbFightingToEnd():void
        {
            var des:Number = this.isClimbIng();
            Laya.timer.once(des+1000,this,function():void{
                // ModelManager.instance.modelClimb.event(ModelClimb.EVENT_CLIMB_FIGHT_END);
                if(ModelManager.instance.modelClimb.isGetAward() && ModelManager.instance.modelGame.isInside){
                    ModelManager.instance.modelInside.getBuildingModel("building007").updateStatus(true);
                }
            });
        }
        public function isClimbIng():Number{
            var etn:Number = 0;
            var et:Object = ModelManager.instance.modelUser.climb_records["end_time"];
            if(Tools.isNullObj(et)){
                etn = 0;
            }
            else{
                var ett:Number = Tools.getTimeStamp(et)+1000;
                var now:Number = ConfigServer.getServerTimer();
                etn = ett - now;
            }
            return etn;
        }
        /**
         * 每日的挑战次数
         */
        public function getFightTimesByDay():Number{
            var num:int = getCfgConfigure().frequency;
            //自己的数据 再处理
            return num;
        }
        /**
         * 初始的敌军等级
         */
        public function getPClv():Number{ 
            return ModelManager.instance.modelUser.world_lv;       
        }
        /**
         * 购买挑战消耗的黄金
         */
        public function getTimesBuyCoin():Number{
            return getCfgConfigure().consume;
        }
        /**
         * 奖池中
         */
        public function getAwardItems():Array{
            return getCfgConfigure().preview;
        }
        /**
         * 我的击杀数量
         */
        public function getMyKillNumMax():Number{
            var r1:int = ModelManager.instance.modelUser.climb_records.season_num%4;
            var pd1:Number = ModelManager.instance.modelUser.getGameDate()-1;
            var rr:int = getCfgConfigure().num_season;
            if((rr == r1) && (pd1>ModelManager.instance.modelUser.climb_records.season_num) && (ModelManager.instance.modelUser.getGameSeason() == rr)){
                return 0;
            }
            return ModelManager.instance.modelUser.climb_records.kill_wave;
        }
        public function getClimbRankAward(rank:Number):Object{
            var arr:Array = getCfgConfigure().num_reward;
            // for(var key:String in getCfgConfigure().num_reward)
            // {
            //     arr.push({index:key,award:getCfgConfigure().num_reward[key]});
                
            // }
            // //
            // arr.sort(MathUtil.sortByKey("index"));
            //
            var len:int = arr.length;
            // var a:Object;
            for(var i:int = 0; i < len-1; i++)
            {
                if(rank<= parseInt(arr[i][0])){
                    // a = arr[i][1].show;
                    break;
                }
                
            }
            var obj:Object = {};
            obj["show"] = arr[i][1].show;
            obj["reward"] = arr[i][1].reward;
            return obj;
        }
        public function getPKtimesMax():Number{
            return this.getPKtimesByDay()+this.getPKmyBuyTimes()*this.getPKtimesForBuyOne();
        }

        //
        /**
         * pk 每天默认 次数
         */
        public function getPKtimesByDay():Number{
            return ConfigServer.pk.pk_count[0];
        }
        /**
         * pk ,每次购买次数
         */
        public function getPKtimesForBuyOne():Number{
            return ConfigServer.pk.pk_count[1];
        } 
        /**
         * pk 购买次数 配置,len 是能买多少次
         */
        public function getPKbuyForIndex():Array{
            return ConfigServer.pk.pk_count[2];
        } 
        /**
         * pk 最好排名
         */
        public function getPKrankBest():Number{
            return ModelManager.instance.modelUser.pk_records["best_rank"];
        }
        /**
         * pk log
         */
        public function getPKlog():Array{
            return ModelManager.instance.modelUser.pk_records["log"];
        }
        /**
         * pk ,能上阵的英雄 个数
         */
        public static function getPKdeployMax():Number{
            var arr:Array = ConfigServer.pk["pk_hero"];
            var len:int = arr.length;
            var index:int = len;
            for(var i:int = 0; i < len; i++)
            {
                if(ModelManager.instance.modelUser.getLv()<arr[i]){
                    index = i;
                    break;
                }  
            }
            return index;
        }
        public function getPKawardByOnec():Array{
            return ConfigServer.pk.pk_once_award;
        }
        public function getPKmyTimes():Number{
            var cur:int = ModelManager.instance.modelUser.pk_records["pk_times"];
            if(Tools.isNewDay(ModelManager.instance.modelUser.pk_records["pk_time"])){
                var max:int = this.getPKtimesMax();
                if(cur<max) return max;
            }
            return cur;
        }
        public function getPKmyBuyTimes():Number{
            if(Tools.isNewDay(ModelManager.instance.modelUser.pk_records["buy_time"])){
                return 0;
            }            
            return ModelManager.instance.modelUser.pk_records["buy_times"];
        }
        public function getPKrankAward(rank:int):Array{
            var cfg:Array = ConfigServer.pk["pk_day_award"];
            var len:int = cfg.length;
            var min:Array;
            var max:Array;
            var award:Array;
            for(var i:int = 0; i < len; i++)
            {
                if(i<(len-1)){
                    min = cfg[i];
                    max = cfg[i+1];
                    if(rank >= min[0] && rank<max[0]){
                        if(rank == min[0]){
                            award = min.concat();
                        }
                        else{
                            award = max.concat();
                        }
                        break;
                    }
                }else{
                    max = cfg[i];
                    if(rank >= max[0]){
                        award = max.concat();
                        break;
                    }
                }
            }
            return award;
        }
        //-------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------
        public static function getChampionFightData(arr:Array):Object{
            var obj:Object = {};
            obj["mode"] = 3;
            obj["rnd"] = arr[3];
            obj["team"] = [arr[0], arr[1]];
			var re:Object = {pk_data:obj};
			if (arr[4]){
				re["time"] = arr[4];
			}
            return re;
        }
        /**
         * 第几 个赛季
         */
        public static function getChampionHowSeason():Number{
            return Math.ceil(ModelManager.instance.modelUser.getGameDate()/4);
        }
        public static function getChampionHowSeasonHeroNum():Number{
            var num:Number = getChampionHowSeason();
            if(ModelManager.instance.modelUser.getGameSeason()>ConfigServer.pk_yard.begin_time[0]){
                return num+1;
            }
            return num;
        }
        /**
         * 是否在秋天的 赛季中
         */
        public static function isChampionIng():Boolean{
            var b:Boolean = false;
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();
                var ems:Number = sms+ModelClimb.getChampionUseTimer()+Tools.oneMillis;
                if(now>=sms && now<ems){
                    b = true;
                }
            }
            return b;
        }
        /**
         * 是否能押注
         */
        public static function isChampionBet():Boolean{
            var b:Boolean = false;
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();  

                var arr:Array = ConfigServer.pk_yard.combat_time;
                var len:int = arr.length-1;
                var ms:Number = 0;
                for(var i:int = 0;i < len;i++){
                    for(var j:int = 0;j<arr[i].length;j++){
                        ms+=arr[i][j]*Tools.oneMinuteMilli;
                    }
                }
                var ems:Number = sms+ms;              
                var ems2:Number = ems+arr[len-1][0]*Tools.oneMinuteMilli;   
                if(now>ems && now<ems2){
                    b = true;
                }                           
            }
            return b;
        }
        /**
         * 赛季 比赛开始时间 已经过了多久
         */
        public static function getChampionIngTime():Number{
            var t:Number = -1;
            if(ModelClimb.isChampionStartSeason()){//秋天
                var nowNum:Number = ConfigServer.getServerTimer();
                var openMs:Number = ModelClimb.getChampionStartTimer();
                //
                t = nowNum - openMs;//在 秋天 的 开赛时间 后,都算 比赛中,过了秋天,就不能用一些功能了
            }
            return t;
        }
        public static function getChampionNextRoundTimr(curr:Number):Number
        {
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();
                var cfg:Array = ConfigServer.pk_yard.combat_time;
                var len:int = curr;
                for(var i:int = 0;i < len;i++){
                    for(var j:int = 0;j < cfg[i].length;j++){
                        sms+=cfg[i][j]*Tools.oneMinuteMilli;
                    }
                }
                return sms - now;
            }
            return -1;
        }
		/**
		 * 膜拜
		 */
		public static function isChampionWorship():Boolean{
			var timerNum:Number = 0;
			var b:Boolean = false;
			if(ModelManager.instance.modelUser.records.hasOwnProperty("worship_time")){
				if(!Tools.isNullObj(ModelManager.instance.modelUser.records["worship_time"])){
					timerNum = Tools.getTimeStamp(ModelManager.instance.modelUser.records["worship_time"])
					if(Tools.isNewDay(timerNum)){
						b = true;
					}
				}
				else{
					b = true;
				}
			}
			else{
				b = true;
			}
			return b;
		}        
        public static function getChampionRoundNextFightTimr():Number{
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();
                var cfg:Array = ConfigServer.pk_yard.combat_time;
                var len:int = cfg.length;
                var des:Number = -1;
                var newArr:Array = [];
                for(var i:int = 0;i < len;i++){
                    newArr = newArr.concat(cfg[i]);
                }
                len = newArr.length;
                for(i = 0;i < len;i++){
                    sms+=newArr[i]*Tools.oneMinuteMilli;
                    if(now<sms){
                        return sms - now;
                    }
                }
            }
            return -1;            
        }
        public static function getChampionRoundFightTime(curr:Number,index:Number):Array{
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();
                var cfg:Array = ConfigServer.pk_yard.combat_time;
                var len:int = curr-1;
                for(var i:int = 0;i < len;i++){
                    for(var j:int = 0;j < cfg[i].length;j++){
                        sms+=cfg[i][j]*Tools.oneMinuteMilli;
                    }
                }
                for(var k:int = 0;k < index;k++){
                    sms+=cfg[curr][k]*Tools.oneMinuteMilli;
                }
                var ems:Number = 0;
                if(index<cfg[curr].length){
                    ems = cfg[curr][index]*Tools.oneMinuteMilli;
                }
                else{
                    if(curr<(cfg[curr].length-1)){
                        ems = cfg[curr+1][0]*Tools.oneMinuteMilli;
                    }
                    else{
                        ems = cfg[cfg.length-1][2]*Tools.oneMinuteMilli;
                    }
                }
                var isOver:Boolean= now>(sms+ems)
                return [sms,ems,isOver];
                
            }
            return null;            
        }        
        /**
         * 开赛时间点,不分季节,ms
         */
        public static function getChampionStartTimer(start0ms:Number = -1):Number{
            return ((start0ms>-1)?start0ms:Tools.gameDay0hourMs(ConfigServer.getServerTimer()))+ConfigServer.pk_yard.begin_time[1]*Tools.oneMinuteMilli;
        }
        /**
         * 比武大会总 耗时ms
         */
        public static function getChampionUseTimer():Number{
            var arr:Array = ConfigServer.pk_yard.combat_time;
            var len:int = arr.length;
            var ms:Number = 0;
            for(var i:int = 0;i < len;i++){
                for(var j:int = 0;j<arr[i].length;j++){
                    ms+=arr[i][j]*Tools.oneMinuteMilli;
                }
            }
            return ms;
        }
        /**
         * 检查 ,轮次,是否符合
         */
        public static function checkChampionTimetableByIndex(index:int):Array{
            var arr:Array = ConfigServer.pk_yard.combat_time;
            var st:Number = ModelClimb.getChampionStartTimer();
            var now:Number = ConfigServer.getServerTimer();
            // var l:Number = arr[]
            var len:int = index;//arr.length;
            var rArr:Array;
            var ready:int = -1;//第几场
            var round:int = -1;//第几轮
            var dis:Number = 0;//时间差
            var i:int = 0;
            for(i = 0; i < len; i++)
            {
                rArr = arr[i];
                ready = -1;
                
                for(var j:int = 0;j<rArr.length;j++){

                    st+=rArr[j]*Tools.oneMinuteMilli;
                    if(now<st){
                        ready = j;
                        dis = st - now;
                        break;
                    }
                }
                
                if(ready>-1){
                    round = i;
                    break;
                }
            }
            
            return [round,ready,st,dis,i];
        }
        /**
         * 是否是比武大会,开始赛季
         */
        public static function isChampionStartSeason():Boolean{
            return (ModelManager.instance.modelUser.getGameSeason() == ConfigServer.pk_yard.begin_time[0])//秋天
        }
        /**
         * 可以上阵 英雄数量数量
         */
        public static function getChampionHeroNum():Number{
            var arr:Array = ConfigServer.pk_yard['hero_number_'+ModelManager.instance.modelUser.mergeNum];
            var len:int = arr.length;
            var lv:Number = ModelClimb.getChampionHowSeasonHeroNum();//ModelManager.instance.modelUser.getLv();
            var index:int = len;
            for(var i:int = 1; i < len; i++)
            {
                if(lv< arr[i][0]){
                    break;
                }
            }
            
            return arr[i-1][1];
        }
        public function getChampionUnlockLv(n:int):Number{
            //var arr:Array = ModelManager.instance.modelUser.isMerge ? ConfigServer.pk_yard.hero_number_merge : ConfigServer.pk_yard.hero_number;
            var arr:Array = ConfigServer.pk_yard["hero_number_"+ModelManager.instance.modelUser.mergeNum];
            var len:int = arr.length;
            var num:int = (n+1);
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                if(num<= arr[i][1]){
                    index = i;
                    break;
                }
            }
            if(index<0){
                index = (arr.length-1);
            }
            return arr[index][0];
        }
        /**
         * 
         */
        public static function getChampionHeroRecommend(len:int,ext:Array = null,filterAdjutant:Boolean = true):Array{
            var arr:Array = ModelManager.instance.modelUser.getMyHeroArr(true,"",ext,filterAdjutant);
            //
            if(arr.length > len){
                var arrHeros:Array = [];
                for(var i:int = 0;i<len;i++){
                    arrHeros.push(arr[i]);
                }
                return arrHeros;
            }
            else{
                return arr;
            }
        }      
        /**
         * 比赛开始时间点
         * alwaysNext == true 只有下赛季时间, == false, date<now 代表本赛季,否则下赛季
         */
        public static function getChampionStarTime(alwaysNext:Boolean = false,rulerS:Number = 0):Date{
            var gs:Number = ModelManager.instance.modelUser.getGameSeason();
            var now:Number = ConfigServer.getServerTimer();
            var i:int = 0;
            var gsTime:Number = Tools.gameDay0hourMs(now);
            // while((gs%4)!=rulerS)
            // {
            //     i+=1;
            //     gs+=1;
            // }
            if(gs>rulerS){
                i = (4 - (gs+1))+(rulerS+1);
            }
            else if(gs<rulerS){
                i = rulerS-gs;
            }
            // trace(gs,i);
            if(alwaysNext && i==0){
                i = 4;
            }
            
            var nextStart:Number = gsTime+i*Tools.oneDayMilli;
            var date:Date = new Date();
            date.setTime(nextStart);
            // trace(date.toLocaleString(),nextStart-now);
            //规定季节开始时间
            return date;
        }
        public function send_WS_SR_JOIN_PK_YARD(sd:*,cb:Handler):void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_JOIN_PK_YARD,{hids:sd},Handler.create(this,this.ws_sr_join_pk_yard),cb);
        }
        private function ws_sr_join_pk_yard(re:NetPackage):void{
            ViewManager.instance.showRewardPanel(re.receiveData["gift_dict"]);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            var cb:Handler = re.otherData;
            if(cb){
                cb.runWith(re);
            }
        }
        public function send_WS_SR_GET_MY_PK_YARD_HIDS(cb:Handler,btn:Button = null):void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_MY_PK_YARD_HIDS,{},Handler.create(this,this.ws_sr_get_my_pk_yard_hids),[cb,btn]);
        }
        private function ws_sr_get_my_pk_yard_hids(re:NetPackage):void{
            var btn:Button = re.otherData[1];
            var hids:Array = re.receiveData;
            var overB:Boolean = ModelClimb.isChampionStartSeason();
            var str:String = Tools.getMsgById("_climb54");//报名结束
            if(overB){
                str = Tools.getMsgById("_climb54");
            }
            var hadMe:Boolean = false;
            if(hids){
                if(hids.length>0){                   
                    hadMe = true;
                }
            }
            
            if(btn){
                btn.disabled = overB || hadMe;
                btn.label = hadMe?(overB?str:Tools.getMsgById("_climb13")):Tools.getMsgById("_climb21");
            }
            var cb:Handler = re.otherData[0];
            if(cb){
                cb.runWith(re);
            }            
        }
        //
        public static function formatChampionGroupReady(data:Object):Array{
            var arr:Array = data.log_list;
            var len:int = arr.length;
            var arrData:Object;
            for(var i:int = 0; i < len; i++)
            {
                arrData = arr[i];
                arrData["win"] = "0";
            }
            arr.sort(MathUtil.sortByKey("power",true));
            return arr;
        }
        public static function formatChampionGroupLog(data:Object):Array{
            var arr:Array = data.log_list;
            var pkArr:Array;
            var len:int = arr.length;
            var users:Object = {};
            var p0:Object;
            var p1:Object;
            var win0:int = 0;
            var win1:int = 0;
            //
            var arrData:Object;
            for(var i:int = 0; i < len; i++)
            {
                pkArr = arr[i];
                p0 = pkArr[0];
                p1 = pkArr[1];
                win0 = (pkArr[2] == 0)?1:0;
                win1 = (pkArr[2] == 1)?1:0;
                if(!users.hasOwnProperty(p0.uid)){
                    users[p0.uid] = p0;
                    users[p0.uid]["win"] = win0;
                    users[p0.uid]["winArr"] = [win0];
                }
                else{
                    arrData = users[p0.uid];
                    arrData["win"]= arrData["win"]+""+win0;
                    (arrData["winArr"] as Array).push(win0);
                    users[p0.uid] = arrData;
                }
                if(!users.hasOwnProperty(p1.uid)){
                    users[p1.uid] = p1;
                    users[p1.uid]["win"] = win1;
                    users[p1.uid]["winArr"] = [win1];
                }
                else{
                    arrData = users[p1.uid];
                    arrData["win"]= arrData["win"]+""+win1;
                    (arrData["winArr"] as Array).push(win1);
                    users[p1.uid] = arrData;                   
                }
            }
            var usersArr:Array = [];
            var winStr:String;
            var winArr:Array;
            for(var key:String in users)
            {
                arrData = users[key];
                winStr = arrData["win"];
                winArr = arrData["winArr"];
                if(winArr && winArr.length<3){
                    winStr=winStr+"0";
                    winArr.push(-1);
                }
                arrData["win"] = winStr;
                arrData["winArr"] = winArr;
                var n:int=parseInt(winStr);
                if(n==110){
                    n=3;
                }else if(n==101 || n==11){
                    n=2;
                }else if(n==1 || n==10 || n==100){
                    n=1;
                }
                arrData["sortWin"] = n;
                usersArr.push(arrData);
            }
            usersArr.sort(MathUtil.sortByKey("sortWin",true));
            return usersArr;
        }
        public static function formatRankAward(tid:String = ""):Array{
            var arr:Array = ConfigServer.pk_yard.reward;
            arr = ObjectUtil.clone(arr,true) as Array;
            arr = arr.reverse();
            var len:int = arr.length;
            var awardArr:Array;
            var award:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                awardArr = arr[i];
                awardArr = awardArr.reverse();
                for(var j:int = 0;j<awardArr.length;j++){
                    if(tid!=""){
                        if(awardArr[j][0].indexOf(tid)>-1){
                            return awardArr[j][0];
                        }
                    }
                    else{
                        award.push(awardArr[j]);
                    }
                }
            }
            return award;
        }
        //
        //--------------------------------------------------------
        //--------------------------------------------------------
        //
        public static const pk_npc_diff_name:Array = ["alien_easy","alien_normal","alien_trouble"];
        public static function pk_npc_get_hero_icon(country:int,diff:int):String{
            return ConfigServer.pk_npc.alien_figure[country+""][diff+""];
        }
        public static function alien_my():Object{
            if(ModelManager.instance.modelUser.pk_npc){
                if(ModelManager.instance.modelUser.pk_npc.hasOwnProperty("npc_dict")){
                    return ModelManager.instance.modelUser.pk_npc["npc_dict"];
                }
            }
            return {};
        }
		/**
		 * 得到异族入侵的推荐战力
		 */
		public static function getAlienPower(cid:String):int{
			var arr:Array = ModelClimb.alien_city(cid);
			if (arr.length > 4){
				var power:int = arr[4];
				power = ModelPrepare.getFormatPower(power, ConfigServer.pk_npc.alien_enemy_power);
				return power;
			}
            return -1;
        }
		/**
		 * 得到名将来袭的推荐战力
		 */
		public static function getCaptainPower():int{
			var arr:Array = ModelClimb.captain_curr();
			if (arr.length > 1){
				var power:int = arr[1];
				power = ModelPrepare.getFormatPower(power, ConfigServer.pk_npc.captain_enemy_power);
				return power;
			}
            return -1;
        }
		
        public static function alien_city(cid:String):Array{
            var data:Object = alien_my();
            if(data.hasOwnProperty(cid)){
                return data[cid];
            }
            return [];
        }
        public static function alien_city_reward(cid:String):Object{
            var arr:Array = ModelClimb.alien_city(cid);
            var rwd:Object = {};
            if(arr.length>0){
                rwd = arr[5];
            }
            return rwd;
        }
        public static function alien_check_is_end(cid:String):Boolean{
            var b:Boolean = false;
            var cityData:Array = alien_city(cid);
            if(cityData.length>0){
                b = (cityData[3]<=0);
            }
            return b;
        }
        public static function alien_check_fight_ing(cid:String):Boolean{
            var b:Boolean = false;
            var cityData:Array = alien_city(cid);
            if(cityData.length>0){
                if(cityData[6].length>0){
                    
                    var st:Number = Tools.getTimeStamp(cityData[6][2]);
                    // trace("异族入侵,战斗状态",cityData[6],st);
                    if(st>ConfigServer.getServerTimer()){
                        b = true;
                    }
                }
            }
            return b;
        } 
        public static function alien_check_fight_data(cid:String):Array{
            var cityData:Array = alien_city(cid);
            if(cityData.length>0){
                if(cityData[6].length>0){
                    return cityData[6];
                }
            }
            return [];
        }
        public static function alien_check_fight_ing_data(cid:String):Object{
            var receiveData:Object = {};
            var cityData:Array = alien_city(cid);
            if(cityData.length>0){
                if(cityData[6].length>0){
                    receiveData = {pk_data:cityData[6][0],pk_result:cityData[6][1]};
                    //
                    // data.reward = {"2":["item303",2]}
                    // data.skipTime = 21.4
                }
            }
            return receiveData;
        }               
        public static function alien_country_diff(cid:String):Array{
            if(ConfigServer.pk_npc.alien_diff.hasOwnProperty(ModelUser.getCountryID()+"")){
                var cityData:Array = alien_city(cid);
                if(cityData.length>0){
                    return ConfigServer.pk_npc.alien_diff[ModelUser.getCountryID()+""][cityData[0]];
                }
                else{
                    return [];
                }
            }
            return [];
        }
        public static function alien_curr_lv(cid:String):Number
        {
            var cityData:Array = alien_city(cid);
            if(cityData.length>7){
                return cityData[7];
            }
            return ModelManager.instance.modelUser.getLv();
        }
        public static function alien_army_max(cid:String):Number{
            var cityData:Array = alien_city(cid);
            if(cityData.length>0){
                
                var diff:Number = cityData[0];
                var ba:Number = ConfigServer.pk_npc.alien_army[diff];
                var bb:Array = ConfigServer.pk_npc.alien_armyadd[diff];
                var lv:Number = ModelClimb.alien_curr_lv(cid);
                var bLv:Number = ConfigServer.pk_npc.building_unlock_lv;
                return ba+Math.floor((lv-bLv)/bb[0])*bb[1];
            }
            return 0;
        }
        public static function alien_award(cid:String):Array{
            var arr:Array = [];
            var cityData:Array = alien_city(cid);
            //
            if(cityData.length>0){
                var bLv:Number = ConfigServer.pk_npc.building_unlock_lv;
                var lv:Number = ModelClimb.alien_curr_lv(cid);
                var ba:Array = ConfigServer.pk_npc.alien_mag[cityData[0]];
                var bb:Number = ConfigServer.pk_npc.alien_meritadd[cityData[0]];
                var bgold:Number = ConfigServer.pk_npc.alien_gold[cityData[0]];
                var merit:Number = ba[0]+(lv-bLv)*bb;
                arr.push(["merit",merit]);
                arr.push(["gold",ba[1]+(lv-bLv)*bgold]);
                //
                var oaward:Array = ConfigServer.pk_npc.alien_rewaddtrea;
                var len:int = oaward.length;
                var num:Number = 0;
                for(var i:int = 0;i < len;i++){
                    if(lv>=oaward[i][0]){
                        num = oaward[i][2][cityData[0]];
                        if(num>0){
                            arr.push([oaward[i][1],oaward[i][2][cityData[0]]]);
                        }
                    }
                }
            }
            //
            return arr;
        }
        public static function captain_my():Array{
            if(ModelManager.instance.modelUser.pk_npc){
                if(ModelManager.instance.modelUser.pk_npc.hasOwnProperty("captain")){
                    return ModelManager.instance.modelUser.pk_npc["captain"];
                }
            }
            return [];            
        }
        public static function captain_curr():Array{
            var myData:Array = captain_my();
            if(myData.length>0){
                return myData[0];
            }
            return [];
        }
        public static function captain_curr_reward():Object{//战斗掉 奖励
            var arr:Array = ModelClimb.captain_curr();
            var rwd:Object = {};
            if(arr.length>0){
                rwd = arr[6];
            }
            return rwd;
        }        
        public static function captain_curr_timer():Number{
            var curr:Array = captain_curr();
            if(curr.length>0){
                if(!Tools.isNullObj(curr[0])){
                    return Tools.getTimeStamp(curr[0]);
                }
            }
            return 0;
        }
        public static function captain_check_fight_ing():Boolean{//是否战斗中
            var b:Boolean = false;
            var cityData:Array = captain_curr();
            if(captain_curr_timer()>0 && cityData.length>0){
                if(cityData[7].length>0){
                    var st:Number = Tools.getTimeStamp(cityData[7][2]);
                    if(st>ConfigServer.getServerTimer()){
                        b = true;
                    }
                }
            }
            return b;            
        }
        public static function captain_check_fight_data():Array{//战斗结算和战斗用数据
            var cityData:Array = captain_curr();
            if(cityData.length>0){
                if(cityData[7].length>0){
                    return cityData[7];
                }
            }
            return [];
        }
        public static function captain_check_fight_ing_data():Object{//模拟 战斗结算和战斗用数据
            var receiveData:Object = {};
            var cityData:Array = captain_curr();
            if(cityData.length>0){
                if(cityData[7].length>0){
                    receiveData = {pk_data:cityData[7][0],pk_result:cityData[7][1]};
                }
            }
            return receiveData;
        }        
        public static function captain_award(bLv:int,otherArr:Array = null):Array{//通用奖励
            var arr:Array = [];
            var curr:Array = captain_curr();
            if(curr.length>0){
                var awards:Array = ConfigServer.pk_npc.captain_strike_open[bLv+""];
                var awardObj:Object = awards[1];
                for(var key:String in awardObj)
                {
                    arr.push([key,awardObj[key]]);
                }
                if(otherArr && otherArr.length>1){
                    arr.push([otherArr[1],otherArr[2]]);
                }
            }
            return arr;
        }
        //战斗 经过的时间差
        public static function pk_npc_fight_ing_pass(fightArr:Array):Number{
            var des:Number = 0;
            if(fightArr.length>0){
                var endMs:Number = Tools.getTimeStamp(fightArr[2]);
                var startMs:Number = endMs - Math.floor(fightArr[1].time*Tools.oneMillis);
                var now:Number = ConfigServer.getServerTimer();
                // trace(fightArr,endMs,startMs,now);
                des = (now - startMs)*0.001;
            }
            return des;
        }       
        public static function pk_npc_check_end(fightArr:Array,hids:Array,fighting:Boolean):void{
            if(fightArr.length>0){
                var ttm:Number = Math.ceil(fightArr[1].time*Tools.oneMillis);
                Laya.timer.clear(TroopAnimation,TroopAnimation.backTroop);
                if(!fighting){
                    Laya.timer.once(ttm,TroopAnimation,TroopAnimation.backTroop,[hids]);
                }
            }
        }
        public static function pk_npc_get_ing_records_hp(hid:String,fightArr:Array):Array{//战斗过程中的自己血量查询
            //
            var hp:Number = 0;
            var hpm:Number = 0;
            var army1:Number = 0;
            var army2:Number = 0;
            var isDead:Boolean = false;
            // var hero:String = "";
            if(fightArr.length>0){
                var pk_result:Object;
                var records:Array;
                var endMs:Number = 0;
                var startMs:Number = 0;
                var now:Number = ConfigServer.getServerTimer();
                var len:int = 0;
                var i:int = 0;
                var troops:Array;
                
                pk_result = fightArr[1];
                endMs = Tools.getTimeStamp(fightArr[2]);
                startMs = endMs - Math.floor(pk_result.time*Tools.oneMillis);
                records = pk_result.records;
                len = records.length;
                
                var tmd:ModelTroop = ModelManager.instance.modelTroopManager.troops[ModelManager.instance.modelUser.mUID+"&"+hid];
                if(tmd && tmd.army){
                    hp = tmd.army[0] + tmd.army[1];
					army1 = tmd.army[0];
					army2 = tmd.army[1];
                    hpm = tmd.getHpMax();
                }
                for(i = 0; i < len; i++)
                {
                    troops = records[i].troop;
                    startMs+= Math.floor(records[i].time*Tools.oneMillis);
                   if(now>=startMs){
                    // if(now<startMs){// && !isEnd) || isEnd
                        //这一波还没有战斗完
                        if(troops[0].hid == hid){
                            hp = troops[0].hp;
                            hpm = troops[0].hpm;
                        }
                   }
                }
				
				if (now >= endMs) {
					for(var key:String in pk_result.userTroop){
						if(key == hid){
							army1 = pk_result.userTroop[key][0];
							army2 = pk_result.userTroop[key][1];
							isDead = ((army1+army2)<=0);
							break;
						}
					}
				}
                
            }        
            // trace(fightArr.length,hp,hpm,army1,army2);
            if(!isDead){
                if(army1<=0){
                    army1 = 1;
                }
                if(army2<=0){
                    army2 = 1;
                }                
            }  
            else{
                trace(fightArr.length,hp,hpm,army1,army2,ModelHero.getHeroName(hid));
            }   
            return [hp,hpm,army1,army2,isDead];
        }
        public static function pk_npc_get_kill_len(cid:String,captainB:Boolean = false):Number{//战斗过程中敌人损失部队
            var fightArr:Array = [];
            if(!captainB){
                fightArr = ModelClimb.alien_check_fight_data(cid);
            }
            else{
                fightArr = ModelClimb.captain_check_fight_data();
            }
            var num:Number = 0;
            if(fightArr.length>0){
                var pk_result:Object;
                var records:Array;
                var endMs:Number = 0;
                var startMs:Number = 0;
                var now:Number = ConfigServer.getServerTimer();
                var len:int = 0;
                var i:int = 0;
                var troops:Array; 
                pk_result = fightArr[1];
                endMs = Tools.getTimeStamp(fightArr[2]);
                startMs = endMs - Math.floor(pk_result.time*Tools.oneMillis);
                records = pk_result.records;
                len = records.length;
                for(i = 0; i < len; i++)
                {
                    troops = records[i].troop;
                    startMs+= Math.floor(records[i].time*Tools.oneMillis);
                    if(now>=startMs){
                        num+=1;
                    }
                }                
            }
            return num;
        }

        //-------------------------------------------------
        //-------------------------------------------------
        //-------------------------------------------------
        //-------------------------------------------------
        //-------------------------------------------------
        public static var pk_npc_models:Object = {};
        public var pk_npc_id:String;
        public var pk_npc_fight_ing:Boolean = false;
        public var pk_npc_award:Boolean = false;//是否可以领奖
        private var pk_npc_status:int = -1;
        public var pk_npc_hids:Array;
		private var enemy_now_num:Number = 0;
        private var mKillWave:Number = 0;
		private var fightTimes:Number = 100;
        private var hpsTemp:Object;
		public function get icon():String {
            var istr:String = "";
            var arr:Array = [];
            if(this.isCaptain()){
                // arr = ModelClimb.captain_award(ModelClimb.captain_curr()[3]); 
                return ModelClimb.captain_curr()[5];//AssetsManager.getAssetsHero(ModelClimb.captain_curr()[5]+".png");
                // return AssetsManager.getAssetsHero(ModelClimb.captain_curr()[5],true);
            }
            else{
                arr = ModelClimb.alien_award(this.pk_npc_id);
            }
            var len:int = arr.length;
            var awardId:String;
            var itemB:Boolean = false;
            var gstr:String = "";
            for(var i:int = 0;i < len;i++){
                awardId = arr[i][0];
                if(awardId.indexOf("item")>-1){
                    itemB = true;
                    istr = ModelItem.getItemIcon(awardId);
                }
                else if(awardId.indexOf("gold")>-1){
                    gstr = ModelItem.getItemIcon(awardId,true);
                }
            }
            if(!itemB){
                istr = gstr;
            }          
            // trace(istr,istr,istr,istr,istr,istr,istr);  
			return AssetsManager.getAssetsICON(istr,!itemB);
		}
		
		 /**
         * 难度
         */
        public function pk_npc_diff():int
        {
            if(this.isCaptain()){
                return 2;
            }
            else{
                return ModelClimb.alien_city(this.pk_npc_id)[0];
            }
        }
        /**
         * 战斗进度
         */
        public function pk_npc_get_troop_fight_progress():Number{
            var arr:Array = this.pk_npc_check_hp();
            return arr[0]/arr[1];
        }
        public function pk_npc_check_hp():Array{
            var iscaptain:Boolean = this.isCaptain();
            var max:Number = 0;
            var num:Number = 0
            var fn:Number = 0;
            if(iscaptain){
                max = ConfigServer.pk_npc.captain_armyopnum;
                this.enemy_now_num = ModelClimb.captain_curr()[2];
            }
            else{
                max = ModelClimb.alien_army_max(this.pk_npc_id);
                this.enemy_now_num = ModelClimb.alien_city(this.pk_npc_id)[3];
            }            
            if(this.pk_npc_fight_ing){
                // max = iscaptain?ConfigServer.pk_npc.captain_armyopnum:ModelClimb.alien_army_max(this.pk_npc_id);
                fn = ModelClimb.pk_npc_get_kill_len(this.pk_npc_id,iscaptain);
                // trace("异族入侵,战斗胜利失败进度",this.pk_npc_id,fn,num,max);
                if(fn>=0){
                    num = this.enemy_now_num + this.mKillWave - fn;
                }
            }
            else{
                num = this.enemy_now_num;
            }
            num = (num<=0)?0:num;
            return [num,max]; 
        }
        /**
         * 名将来袭的 hid
         */
        public function captain_hero():String{
            var arr:Array = ModelClimb.captain_curr();
            var hid:String = "";
            if(arr.length>0){
                hid = arr[5];
            }
            return hid;
        }
        /**
         * 名将来袭的倒计时 毫秒
         */
        public function captain_time():Number{
            var des:Number = 0;
            var currEndTimer:Number = ModelClimb.captain_curr_timer();
            if(currEndTimer>0){
                des = currEndTimer - ConfigServer.getServerTimer();
            }
            return des;
        }
		public function get cityId():String {
            if(this.isCaptain()){
			    return ConfigServer.country.country[ModelUser.getCountryID()].capital+"";
            }
            else{
                return this.pk_npc_id;
            }
		}
        public function pk_npc_setData(id:String):void{
            this.pk_npc_id = id;
        }
        public static function getPKnpcModel(id:String):ModelClimb{
            if(pk_npc_models.hasOwnProperty(id)){
                return pk_npc_models[id];
            }
            return null;
        }
        /**
         * 刷新大地图上的异族入侵
         */
        public static function updateAllClip():void{
            for(var s:String in ModelClimb.pk_npc_models){
                var mcb:ModelClimb = ModelClimb.getPKnpcModel(s);
                if(mcb){
                    mcb.event(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE,2);
                }
            }
        }

        public function isCaptain():Boolean{
            return this.pk_npc_id == "captain";
        }
        public function pk_npc_init():void{
            this.pk_npc_clear();
            this.pk_npc_status = -1;
            var now:Number = ConfigServer.getServerTimer();
            var fd:Array = []
            if(this.isCaptain()){
                fd = ModelClimb.captain_check_fight_data();
            }
            else{
                fd = ModelClimb.alien_check_fight_data(this.pk_npc_id);
            }
            if(fd.length>0){
                if(fd[2] && Tools.getTimeStamp(fd[2])>now){
                    this.pk_npc_fight_start(fd[0],fd[1]);
                }
                else{
                    this.pk_npc_check_status();
                }
            }
            else{
                this.pk_npc_check_status();
            }       
        }
        private function pk_npc_clear():void{
            this.fightTimes = 100;
            Laya.timer.clear(this,this.pk_npc_timer);
        }
        private function pk_npc_timer():void{
            this.pk_npc_check_status();
        }        
        private function pk_npc_check_status():void{
            var isFighting:Boolean = false;
            var isEnd:Boolean = false;
            var status:int = -1;
            var evtStatus:int = 1;
            var award:Boolean = false;
            var isEndEvent:Boolean = false;
            if(this.isCaptain()){
                isFighting = ModelClimb.captain_check_fight_ing();
                isEnd = (ModelClimb.captain_curr_timer()>0 && ModelClimb.captain_curr()[2]<=0);
            }
            else{
                isFighting = ModelClimb.alien_check_fight_ing(this.pk_npc_id);
                isEnd = ModelClimb.alien_check_is_end(this.pk_npc_id);
            }
            award = (!isFighting && isEnd);
            //
            this.pk_npc_fight_ing = isFighting;
            //    
            if(isFighting){
                // this.fightTimes+=1;
                status = 1;
                Laya.timer.once(2000,this,this.pk_npc_timer);
            }
            else{
                this.fightTimes = 100;
                status = 0;
            }
            // //
            // if(this.fightTimes<2){
            //     return;
            // }            
            if((this.pk_npc_status != status) || status == 1){
                this.pk_npc_status = status;
                this.pk_npc_award = award;

                if(isFighting){
                    this.pk_npc_event_troop(EventConstant.EVENT_PK_NPC_STATUS_TROOP_FIGHT_ING,true);
                }
                else{
                    this.pk_npc_event_troop(EventConstant.EVENT_PK_NPC_STATUS_TROOP_FIGHT_READY,false);
                }
                this.event(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE,evtStatus);            
            }
        }
        private var mUserTroopToFight:Object;

        public function pk_npc_fight_start(pk_data:Object,pk_result:Object):void{
            this.hpsTemp = {};
            this.fightTimes = 0;
            this.mKillWave = pk_result.killWave;
            this.mUserTroopToFight = pk_result.userTroop;
            var troops:Array = pk_data.team[0].troop;
            var len:int = troops.length;
            this.pk_npc_hids = [];
            for(var i:int = 0;i < len;i++){
                this.pk_npc_hids.push(troops[i].hid);
            }
            this.pk_npc_timer(); 
        }
        private function pk_npc_event_troop(st:String,isFighting:Boolean):void{
            var sts:int = (st == EventConstant.EVENT_PK_NPC_STATUS_TROOP_FIGHT_ING)?ModelTroop.TROOP_STATE_MONSTER:ModelTroop.TROOP_STATE_IDLE;
            if(this.pk_npc_hids){
                var len:int = this.pk_npc_hids.length;
                var hps:Array;
                var data:Object;
                var hid:String;
                var temp:Number;
                var curr:Number;
                var hpUpdate:Boolean = false;
                for(var i:int = 0;i < len;i++){
                    data = {};
                    data["status"] = sts;      
                    hid = this.pk_npc_hids[i];  
                    hpUpdate = false;   
                    // ModelManager.instance.modelTroopManager.monster(st,this.pk_npc_hids[i],null);
                    if(this.mUserTroopToFight && this.mUserTroopToFight.hasOwnProperty(hid)){
                        hps = this.pk_npc_hero_hp(hid);
                        if(!this.pk_npc_award){
                            curr = Math.floor(hps[0]/hps[1]*1000);
                            if(this.hpsTemp.hasOwnProperty(hid)){
                                temp = Math.floor(this.hpsTemp[hid][0]/this.hpsTemp[hid][1]*1000);
                                if(temp!=curr){
                                    hpUpdate = true;
                                    this.hpsTemp[hid] = hps;
                                }
                            }
                            else{
                                this.hpsTemp[hid] = hps;
                                hpUpdate = true;
                            }
                        }
                        // trace("mUserTroopToFight--------",hid);
                        if(hpUpdate || !isFighting){
                            data["hp"] = [hps[0],hps[1]];
                            data["army"] = [hps[2], hps[3]];
							trace("----------------------------" + data["hp"]);
                            // data["monster"] = 1;
                            // trace("-------------pk_npc_event_troop----",hpUpdate,isFighting,data);
                            ModelManager.instance.modelTroopManager.setTroopData(EventConstant.TROOP_UPDATE,hid,data);
                        }
                    }
                }
            }
        }
        private function pk_npc_hero_hp(hid:String):Array
        {
            var hps:Array;//[0,0,-1];
            if(this.isCaptain()){
                hps = ModelClimb.pk_npc_get_ing_records_hp(hid,ModelClimb.captain_check_fight_data());
            }
            else{
                hps = ModelClimb.pk_npc_get_ing_records_hp(hid,ModelClimb.alien_check_fight_data(this.pk_npc_id));
            }
            return hps;
        }
        private function pk_npc_del_self():void{
            this.pk_npc_clear();
            delete ModelClimb.pk_npc_models[this.pk_npc_id];
            this.event(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE,0);
        }
        /**
         * 点击 调用 功能,包含领奖和派兵打仗
         */
        public function pk_npc_click(v:Vector2D):void
        {
            if(this.isCaptain()){
                if(ModelClimb.captain_curr_timer()>0){
                    var curr:Array = ModelClimb.captain_curr();
                    if(curr[2]<=0 && !this.pk_npc_fight_ing){
                        NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_NPC_CAPTAIN_REWARD,{},Handler.create(this,function(vo:NetPackage):void{
                            this.pk_npc_del_self();
                            ModelManager.instance.modelUser.updateData(vo.receiveData);
                            ViewManager.instance.showRewardPanel(vo.receiveData.gift_dict);
                            ModelManager.instance.modelGame.checkPKnpcCaptain(true);
                            
                        }));
                    }
                    else{
                        ViewManager.instance.showView(ConfigClass.VIEW_CAPTAIN_MAIN,[this.cityId,v]);
                    }
                }
                return;
            }
            var isEnd:Boolean = ModelClimb.alien_check_is_end(this.pk_npc_id);//entityCity.cityId
            if(isEnd  && !this.pk_npc_fight_ing){
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_NPC_REWARD,{city_id:this.pk_npc_id},Handler.create(this,function(vo:NetPackage):void{
                    this.pk_npc_del_self();
                    ModelManager.instance.modelUser.updateData(vo.receiveData);
                    ViewManager.instance.showRewardPanel(vo.receiveData.gift_dict);
                                 
                }));
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_NPC,{},Handler.create(this,function(vo:NetPackage):void{
                    ModelManager.instance.modelUser.updateData(vo.receiveData);
                    ViewManager.instance.showView(ConfigClass.VIEW_ALIEN_MAIN,[this.pk_npc_id,v]);
                }));                
            }
        }
        public static function checkClimbWill():Boolean
        {
            var cmd:ModelClimb = ModelManager.instance.modelClimb;
            var n:Number = cmd.getMyClimbTimes();
            // var m:Number = (cmd.getFightTimesByDay()+cmd.getBuyTimesGet());
            if(n>0){
                return true;
            }
            else if(cmd.isGetAward()){
                return true;
            }
            return false;
        }
        public static function checkPkWill():Boolean
        {
            var cmd:ModelClimb = ModelManager.instance.modelClimb;
            var n:Number = cmd.getPKmyTimes();
            // ModelManager.instance.modelClimb.getPKmyTimes()+"/"+ModelManager.instance.modelClimb.getPKtimesMax();
            if(n>0){
                return true;
            }
            return false;
        }        
		public static function checkChampionWill():Boolean
        {
            var b:Boolean = false;
            if(ModelClimb.isChampionStartSeason()){
                var now:Number = ConfigServer.getServerTimer();
                var sms:Number = ModelClimb.getChampionStartTimer();
                var ems:Number = sms+ModelClimb.getChampionUseTimer()+Tools.oneMillis;
                if(now>ems){
                    b = true;
                }
            }       
            else{
                b = true;
            }     
            if(ModelClimb.isChampionIng()){
                return true;
            }
            else if(b && ModelClimb.isChampionWorship()){
                return true;
            }
            return false;
        }
    }   
}