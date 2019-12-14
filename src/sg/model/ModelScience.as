package sg.model
{
    import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.map.utils.TestUtils;
    import sg.utils.Tools;
    import sg.manager.ModelManager;

    public class ModelScience extends ModelBase
    {
        public static var modelSciences:Object = {};
        public static const TYPE_PASSIVE:String = "passive";//战斗
        public static const TYPE_INTERIOR:String = "interior";//内政
        public static const TYPE_DAY_GET:String = "day_get";
        //
        public static const type_ui:Object = {
            passive:"bg_technology01.png",
            interior:"bg_technology02.png",
            day_get:"bg_technology03.png"
        };
        public static const type_ui_mask:Object = {
            passive:"bg_technology04.png",
            interior:"bg_technology05.png",
            day_get:"bg_technology06.png"
        };        
        //
        public static function getConfig(key:String):Object{
            return ConfigServer.science[key];
        }
        public var id:String;
		public var name:String;
		public var info:String;
		public var icon:String
		public var type:String;
		public var color:int;
		public var rim:int;
		public var effect:String;
		public var coordinate:Array;//坐标
		public var upper_level:Array;//父
		public var lower_level:Array;//子
        public var deviation:Array;//偏移
		public var limit:Number;
		public var lock1:Array;
		public var lock2:Array;
		public var max_level:int;
		public var cost:Object;
		public var time:Array;
		public var passive:Object;
		public var interior:Array;    
		public var day_get:Array;    
        public function ModelScience()
        {
            
        }
        public function initData(key:String, obj:Object):void{
            this.id = key;
			for(var m:String in obj)
			{
				if(this.hasOwnProperty(m)){
					this[m] = obj[m];
				}
			}
        }
        public function getName(canTest:Boolean = false):String{
			var name:String = Tools.getMsgById(this.name);
			if (canTest && TestUtils.isTestShow){
				name += ' id:'+this.id;
			}
            return name;
        }
        public function getInfo():String
        {
            return Tools.getMsgById(this.info);
        }  
        /**
         * 内政科技
         */
        public function isInterior():Boolean
        {
            return this.type == TYPE_INTERIOR;
        }     
        public function isDay_get():Boolean
        {
            return this.type == TYPE_DAY_GET;
        }
        public function checkUpdateArmyBuilding():void{
            if(this.isInterior()){
                if(this.interior){
                    if(this.interior[0]==army_stock){
                        ModelManager.instance.modelInside.getBuildingModel(this.interior[1][0]).updateStatus();
                    }
                }
            }
        }
        /**
         * 战斗科技
         */        
        public function isPassive():Boolean
        {
            return this.type == TYPE_PASSIVE;
        }               
        public function isMine():Boolean
        {
            if(ModelManager.instance.modelUser.science.hasOwnProperty(this.type))//TYPE_PASSIVE
            {
                return ModelManager.instance.modelUser.science[this.type].hasOwnProperty(this.id);
            }
            return false;
        }
        public function getAtt():Array{
            var isArr:Array = null;
			var attName:String;
			var attValue:Number;
			var attType:int;	//0显示整数 1显示百分数
			
            if(this.isInterior()){
                isArr = this.interior[1];
				attName = this.getInfo();//getAttInfoCfg(this.interior[0],(isArr.length>1)?this.interior[1][0]:"");
				attValue = (isArr.length>1)?this.interior[1][1]:this.interior[1][0];
				attType = attValue<1?1:0;
            }
            else if (this.isDay_get()){
				attName = this.getInfo()+ModelItem.getItemName(this.day_get[0]);
				attValue = this.day_get[1];
				attType = attValue<1?1:0;
            }
            else if(this.passive && this.passive.rslt){
				var rslt:Object = this.passive.rslt;
				var condStr:String = PassiveStrUtils.translateCondStr(this.passive);
				attName = PassiveStrUtils.translateRsltInfo(condStr, rslt, false, false, false);
				for (var k:String in rslt){
					if(k.indexOf('power') == -1){
						attValue = rslt[k];
						break;
					}
				}
				var arr:Array = PassiveStrUtils.getAttFormat(attName,attValue);
				attName = arr[0];
				attValue = arr[1];
				attType = arr[2];
				if (arr[1] > 0){
					attName = attName + Tools.getMsgById("_science6");//"增加";
				}
				else{
					attName = attName + Tools.getMsgById("_science8");//"减少";
					attValue = -attValue;
				}
            }
			else{
				attName = Tools.getMsgById("_science7");//"未知属性";
				attValue = 1;
				attType = 0;
			}
            return [attName,attValue,attType];
        }
        /**
         * 前置 num
         */        
        public function parentNum():int
        {
            return this.upper_level.length;
        }
        /**
         * 子 num
         */         
        public function childNum():int
        {
            return this.lower_level.length;
        }
        /**
         * 解锁条件 1
         */
        public function checkLock1():Boolean{
            var b:Boolean = false;
            var smd:ModelScience;
            var max:Number = this.lock1[0];
            var tt:int = this.lock1[1][0];
            var typeNum:Number = this.lock1[1][1];
            var lvNum:Number = 0;
            var lvTypeNum:Number = 0;
            for(var t:String in ModelManager.instance.modelUser.science)
            {
                for(var key:String in ModelManager.instance.modelUser.science[t])
                {
                    smd = ModelManager.instance.modelGame.getModelScience(key);
                    if(smd.isMine()){
                        lvNum+=smd.getLv();
                        if(smd.color == tt){
                            lvTypeNum+=smd.getLv();
                        }
                        if(lvNum>=max && lvTypeNum>=typeNum){
                            b = true;
                            break;
                        }
                    }
                }
            }
 
            return b;
        }
        /**
         * 解锁条件 2
         * [是否,[条件key,v]]
         */
        public function checkLock2():Array{
            var b:Boolean = false;
            var arr:Array = [];
            if(this.lock2 && this.lock2.length>0){
                var len:int = this.lock2.length;
                var key:String;
                var val:int;
                if(this.lock2[0] is Array){
                    for(var i:int = 0; i < len; i++)
                    {
                        key = this.lock2[i][0];
                        val = this.lock2[i][1];
                        if(ModelManager.instance.modelGame.getModelScience(key).getLv()>=val){
                            b = true;
                        }
                        else{
                            arr.push([key,val]);
                        }
                    }
                }
                else{
                    key = this.lock2[0];
                    val = this.lock2[1];
                    if(ModelManager.instance.modelGame.getModelScience(key).getLv()>=val){
                        b = true;
                    }
                    else{
                        arr.push([key,val]);
                    }
                }
            }
            else{
                if(this.lock2 && this.lock2.length==0){
                    b = true;
                }
            }
            return [b,arr];
        }
        public function getId():int{
            return parseInt(this.id);
        }      
        public function getLv():Number{
            var lv:Number = 0;
            if(this.isMine()){
                lv = ModelManager.instance.modelUser.science[this.type][this.id];
            }
            return lv;
        } 
        /**
         * 返回秒
         */
        public function getLvCD(lv:int):Number{//

			return this.getCD(lv)*60;
		}
        private function getCD(lv:int):Number{
            var arr:Array;
            for(var i:Number = 1;i<this.time.length;i++){
                if(lv<this.time[i][0]){
                    break;
                }
            }
            arr = this.time[i-1];
            var a:Number = arr[1];
            var b:Number = arr[2];
			var m:Number = Math.ceil(Math.floor(a*lv+b)/(1+ModelOffice.func_sectionspeed()+ModelScience.func_sum_type(ModelScience.ology_time)));
            return m;
        }
        /**
         * 返回coin
         */
        public function getLvCDcoin(lv:int):Number{//
			return ModelBuiding.getCostByCD(this.getCD(lv),2);
		}                        
        /**
         * 升级材料
         */
        public function getLvUpItems(lv:int):Array{
            var arr:Array = [];
            var pay:Array;
            for(var key:String in this.cost)
            {
                pay = this.cost[key];
                for(var i:Number = 1;i<pay.length;i++){
                    if(lv<pay[i][0]){
                        break;
                    }
                }
                var num:Number = pay[i-1][1]*lv+pay[i-1][2];
                if(num>0){
                    arr.push([key,num]);
                }
                // arr.push([key,pay[0]*lv+pay[1]]);
            }
            return arr;
        }
        /**
         * 是否在升级队列
         */
        public function isInQueue():Boolean{
            var b:Boolean = false;
            if(ModelManager.instance.modelUser.records.hasOwnProperty("science_cd")){
                var arr:Array = ModelManager.instance.modelUser.records["science_cd"];
                if(arr.length>0){
                    if(arr[0] == this.id){
                        b = true;
                    }
                }
            }
            return b;
        }  
        /**
         * 是否在升级中
         */              
        public function isUpgradeIng():int{
            var type:int = -1;
            var b:Boolean = this.isInQueue();
            if(b){
                type = 1;
            }
            return type;
        }
        public function upgradeIng():void{
            var endB:Boolean = false;
			if(this.isUpgradeIng()>-1){
                if(this.getLastCDtimer()>0){
				    ModelManager.instance.modelInside.event(ModelInside.SCIENCE_UPDATE_CD,this);
                }
                else{
                    endB = true;
                }
			}
			else{
				//升级CD完成
                endB = true;
			}
            if(endB){
                this.upgradeEnd(1);
            }
		}
        public function upgradeEnd(type:int):void{
			ModelManager.instance.modelInside.event(ModelInside.SCIENCE_UPDATE_REMOVE,this);
			ModelManager.instance.modelInside.event(ModelInside.SCIENCE_UPDATE_GET,this);
            ModelManager.instance.modelInside.getBuilding003().updateStatus(true);
        }
        /**
         * 升级剩余时间,毫秒
         */        
        public function getLastCDtimer():Number{
			var now:Number = ConfigServer.getServerTimer();
            var cd:Number = 0;
            if(ModelManager.instance.modelUser.records.hasOwnProperty("science_cd")){
                var arr:Array = ModelManager.instance.modelUser.records["science_cd"];
                if(arr.length>0){
                    cd = Tools.getTimeStamp(arr[1]);
                }
            }
            return cd - now;
		}
        public function getLastCDtimerStyle(type:Number = 2):String{
			return Tools.getTimeStyle(this.getLastCDtimer(),type);
		}        
        /**
         * 正在 cd 的科技
         */
        public static function getCDingModel():ModelScience{
            var smd:ModelScience;
            if(ModelManager.instance.modelUser.records.hasOwnProperty("science_cd")){
                var arr:Array = ModelManager.instance.modelUser.records["science_cd"];
                if(arr.length>0){
                    smd = ModelManager.instance.modelGame.getModelScience(arr[0]);
                }
            }
            return smd;
        }
        
        public static const equip_ma_time:String = "equip_ma_time";//减少宝物制作时间+++
        public static const equip_up_chance:String = "equip_up_chance";//xx突破成功率增加++++
        public static const equip_up_consume:String = "equip_up_consume";//减少宝物突破xx +++++
        public static const equip_up_time:String = "equip_up_time";//减少宝物突破时间+++++++
        public static const equip_wa_consume:String = "equip_wa_consume";//减少宝物洗炼消耗精粹
        public static const estate_active:String = "estate_active";//征税收益增加
        public static const estate_produce:String = "estate_produce";//增加港口产量
        public static const fief_produce:String = "fief_produce";//增加封地产物
        public static const hero_resolve:String = "hero_resolve";//增加问道获得将魂数量
        public static const more_item:String = "more_item";//增加贡品所得军团币
        public static const more_merit:String = "more_merit";//增加政务功勋奖励
        public static const more_number:String = "more_number";//增加小酌英雄碎片数量
        public static const ology_consume:String = "ology_consume";//减少科技研究粮草消耗++++++
        public static const ology_time:String = "ology_time";//减少科技研究时间++++++
        public static const tribute_time:String = "tribute_time";//缩短贡品开启时间
        //
        public static const army_atk:String = "army_atk";//提升部队攻击
        public static const army_consume:String = "army_consume";//减少训练所耗资源
        public static const army_def:String = "army_def";//提升部队防御
        public static const army_go:String = "army_go";//增加部队行进速度
        public static const army_hpm:String = "army_hpm";//提升部队兵力
        public static const army_rate:String = "army_rate";//减少部队训练时间
        public static const army_resist:String = "army_resist";//减少步兵受到英雄伤害
        public static const catch_apart:String = "catch_apart";//增加切磋获得技能碎片
        public static const catch_times:String = "catch_times";//增加每日切磋免费次数
        public static const hero_atk:String = "hero_atk";//xx伤害加成
        public static const hero_combat:String = "hero_combat";//减少文官受到xx攻击
        public static const hero_def:String = "hero_def";//英雄xx防御
        public static const pve_get:String = "pve_get";//增加沙盘演义军械产量
        public static const pve_combat_times:String = "pve_combat_times";//增加沙盘演义免费次数
        public static const rarity_hpm:String = "rarity_hpm";//增加xx英雄前后军兵力
        public static const sex_skills:String = "sex_skills";//增加xx英雄主动技能位
        public static const star_atk:String = "star_atk";//增加xx色以上英雄攻击
        public static const star_def:String = "star_def";//增加xx色以上英雄防御
        public static const stranger:String = "stranger";//减少异族入侵所耗粮草
        // 
        public static const day_gat:String = "day_gat";//增加每日获得试炼令               
        public static const army_stock:String = "army_stock";//是增加兵营的存量的，这个存量显示在兵营上，科技领取后，要立即更新兵营的存量上限              
        public static const army_add:String = "army_add";//是增加兵营单次训练量的，显示在练兵的面板上，科技领取后，要立即更新练兵是的单次上限              
        public static const army_food:String = "army_food";//行军耗粮             
        /**
         * 科技 buff ,数值计算 +和, fid == 功能配置key,type == 另一种类型匹配
         */
        public static function func_sum_type(fid:String,type:String = "",type_func:String = ""):Number{        
            var arr:Object = ConfigServer.science_type[Tools.isNullString(type_func)?TYPE_INTERIOR:type_func][fid];
            var smd:ModelScience;
            // var len:int = arr.length;
            var num:Number = 0;
            var cArr:Array;
            var sid:String
            var argStr:String;
            for(var key:String in arr)
            // for(var i:int = 0; i < len; i++)
            {
                
                smd = ModelManager.instance.modelGame.getModelScience(key);
                if(smd && smd.isMine()){
                    if(smd.isInterior() && smd.interior.length>0){
                        if(smd.interior[1] is Array){
                            cArr = smd.interior[1];
                            if(Tools.isNullString(type)){
                                num+=(cArr[cArr.length-1]*smd.getLv());
                            }
                            else{
                                argStr = cArr[0]+"";
                                if(argStr == type){
                                    num+=(cArr[cArr.length-1]*smd.getLv());
                                }
                            }
                        }
                        else{
                            num+=(smd.interior[1]*smd.getLv());
                        }
                    }
                    else if(smd.isDay_get()){
                        if(smd.day_get[1] is Array){
                            cArr = smd.day_get[1];
                            if(Tools.isNullString(type)){
                                num+=(cArr[cArr.length-1]*smd.getLv());
                            }
                            else{
                                argStr = cArr[0]+"";
                                if(argStr == type){
                                    num+=(cArr[cArr.length-1]*smd.getLv());
                                }
                            }
                        }
                        else{
                            num+=(smd.day_get[1]*smd.getLv());
                        }                        
                    }
                }
            }
            return num;
        }
        /**
         * 检测,是否有 收获 科技 类 物品
         */
        public static function check_science_day_get():Boolean{
            var b:Boolean = false;
            var isNewDay:Boolean = false;
            if(ModelManager.instance.modelUser.records.hasOwnProperty("science_day_get_time")){
                if(!Tools.isNullObj(ModelManager.instance.modelUser.records["science_day_get_time"])){
                    var gt:Number = Tools.getTimeStamp(ModelManager.instance.modelUser.records["science_day_get_time"]);
                    if(Tools.isNewDay(gt)){
                        isNewDay = true;
                    }
                }
                else{
                    isNewDay = true;
                }
            }
            else{
                isNewDay = true;
            }
            if(isNewDay){
                var num:Number = func_sum_type(TYPE_DAY_GET,"",TYPE_DAY_GET);
                if(num>0){
                    b = true;
                }
            }
            else{
                if(ModelManager.instance.modelUser.records.hasOwnProperty("science_day_get_ids")){
                    var hasArr:Array = ModelManager.instance.modelUser.records.science_day_get_ids;
                    var day_get:Object = ConfigServer.science_type[TYPE_DAY_GET];
                    var smd:ModelScience;
                    for(var key:String in day_get){
                        smd = ModelManager.instance.modelGame.getModelScience(key);
                        if(smd && smd.isMine()){
                            if(hasArr.indexOf(smd.id)<0){
                                b = true;
                                break;
                            }
                        }
                    }
                }
            }
            return b;
        }
        /**
         * 是否有能升级的 科技
         */
        public static function checkHaveUp():Boolean
        {
            var smd:ModelScience;
            var b:Boolean = false;
            for(var key:String in ConfigServer.science){
                if(key!="science_type"){
                    //science_type
                    smd = ModelManager.instance.modelGame.getModelScience(key);
                    if(smd){
                        if(smd.isMine()){
                            if(smd.getLv()<smd.max_level){
                                b = true;
                                break;
                            }
                        }
                        else{
                            if(smd.checkLock2()){
                                b = true;
                                break;
                            }
                        }
                    }
                }
            }
            return b;
        }
    }
}