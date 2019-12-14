package sg.model
{
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.maths.MathUtil;
    import sg.cfg.ConfigServer;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.map.utils.Vector2D;
    import ui.inside.starGetUI;

    public class ModelTask extends ModelBase
    {
        public static const EVENT_GTASK_UPDATE:String = "event_gtask_update";
        public function ModelTask()
        {
            
        }
// "gtask": {
//     "refresh_time":{
//         "$datetime":"2018-06-01 18:00:01"
//     },
//     "refresh_times":0,
//     "task":{
//         "gtask001":{
//             "city_id":"148",
//             "rate":0,
//             "reward_key":"item072",
//             "status":0
//         },
//         "gtask003":{
//             "city_id":"161",
//             "rate":0,
//             "reward_key":"item072",
//             "status":0
//         },
//         "gtask004":{
//             "city_id":"162",
//             "rate":0,
//             "reward_key":"item074",
//             "status":0
//         }
//     },
//     "task_times":0
// }
        public static const GTASK_TYPE_GTASK_BUILD:String = "gtask_build";//建设
        public static const GTASK_TYPE_GTASK_BUILD_RAN:String = "gtask_build_ran";//建设
        public static const GTASK_TYPE_GTASK_COLLECT:String = "gtask_collect";//打仗
        public static const GTASK_TYPE_GTASK_DONATE:String = "gtask_donate";//捐献
        //
        public static function gTask_name(tid:String,pa:Array):String{
            return Tools.getMsgById(tid+"_name",pa);
        }
        public static function gTask_info(tid:String,arr:Array,status:int = 0):String{
            return Tools.getMsgById(tid+(status!=0?"_info_re":"_info"),arr);
        }            
        public static function gTask_type(tid:String):String{
            return ConfigServer.gtask.government_task[tid].type;
        }
        public static function gTask_need_cfg(tid:String):Array{
            return ConfigServer.gtask.government_task[tid].need;
        }    
        public static function gTask_npc_name(tid:String):String{
            return ConfigServer.gtask.government_task[tid].npc_name;
        }                     
        public static function gTask_gtask_get_mon():int{
            return ConfigServer.gtask.gtask_get_mon;
        }
        public static function gTask_get_talk():String{
            var often_show:Array = ConfigServer.gtask.often_show;
            var office:Number = ModelManager.instance.modelUser.office;
            var len:int = often_show.length;
            for(var i:int = 0; i < len; i++)
            {
                if(office<=often_show[i][0]){
                    i+=1;
                    break;
                }
            }
            return Tools.getMsgById(often_show[i-1][1]);
        }
        public static function gTask_get_talk2():String{
            var timesNum:Number = ModelTask.gTask_self_task_times();
            var timesBuy:Number = ModelTask.gTask_self_buy_times();
            var timesDef:Number = ModelTask.gTask_gtask_intial_num_max();
            var timesMax:Number = (timesDef+timesBuy);
            //
            var complete_show:Array = ConfigServer.gtask.complete_show;
            var office:Number = timesMax-timesNum;
            var len:int = complete_show.length;
            for(var i:int = 0; i < len; i++)
            {
                if(office<=complete_show[i][0]){
                    i+=1;
                    break;
                }
            }
            return Tools.getMsgById(complete_show[i-1][1]);
        }        
        public static function gTask_need(tid:String,useCfg:Boolean = false):Array{
            var cfg:Object = ConfigServer.gtask.government_task[tid];
            var re:Array = [];
            var lv:int = gTask_self_take_building_lv(tid);//ModelManager.instance.modelUser.getLv();
            switch(cfg.type)
            {
                case GTASK_TYPE_GTASK_BUILD:
                case GTASK_TYPE_GTASK_BUILD_RAN:
                    var arr:Array = cfg.need;
                    var len:int = arr.length;
                    for(var i:int = 1; i < len; i++)
                    {
                       if(lv<arr[i][0]){   
                           break;
                       }
                    }
                    var num:Number = 0;
                    if(useCfg){
                        num = ConfigServer.gtask.reward_mulit[ConfigServer.gtask.reward_mulit.length-1][0]*ModelTask.gTask_gtask_exceed_need(tid)*arr[i-1][1];
                    }
                    else{
                        num = gTask_self_take_need(tid);
                    }
                    re = [num,num];//arr[index][1]];
                    break;
                case GTASK_TYPE_GTASK_COLLECT:
                    re = [cfg.need[1],cfg.need[2]];
                    break;  
                case GTASK_TYPE_GTASK_DONATE:
                    re = [cfg.need[1]+cfg.need[2]*(lv-cfg.need[3]),cfg.need[4]];
                    break;                               
                default:
                    break;
            }
            return re;
        }
        public static function gTask_getUnlockLv(tid:String):Number{
            var arr:Array = ConfigServer.gtask.gtask_unlockLV;
            var len:int = arr.length;
            var data:Array;
            for(var i:int = 0; i < len; i++)
            {
                data = arr[i][1];
                for(var j:int = 0; j < data.length; j++)
                {
                    if(data[j][0]==tid){
                        return arr[i][0];
                    }   
                }
            }
            return 0;
        }
        public static function gTask_gtask_brush():Array{
            return ConfigServer.gtask.gtask_brush;
        } 
        public static function gTask_gtask_exceed_need(tid:String):Number{
            return ConfigServer.gtask.government_task[tid].exceed_need;
        } 
        public static function gTask_exceed(obj:Object):Boolean{
            var need:Array = ModelTask.gTask_need(obj.id);
            var max:Number = ModelTask.gTask_gtask_exceed_need(obj.id);
            var score:Number = obj.rate/need[0]/max;
            return score>=max;
        }                
        public static function gTask_gtask_intial_num_max():int{
            return ConfigServer.gtask.gtask_intial_num+ModelOffice.func_gtaskcount();
        } 
        public static function gTask_gtask_buy():Array{
            return ConfigServer.gtask.gtask_buy;
        } 
        public static function gTask_self():Object{
            return ModelManager.instance.modelUser.gtask;
        }
        public static function gTask_self_take():Object{
            if(gTask_self() && gTask_self().hasOwnProperty("task")){
                return gTask_self().task;
            }
            return {};
        }
        public static function gTask_self_task_city(tid:String):String{
            return gTask_self_take()[tid]["city_id"]
        }
        /**
         * 查看已经接受政务中符合的city
         * if
         *      ModelTask.GTASK_TYPE_GTASK_DONATE//捐献
         *      ModelTask.GTASK_TYPE_GTASK_COLLECT//打仗
         * else
         *      
         * @return type == null没有符合的,否则 为 任意任务类型
         */
        public static function gTaskByCityGetType(cid:*):String{
            var task:Object = gTask_self_take();
            var type:String = null;
            for(var key:String in task){
                if(task[key].status>0 && task[key]["city_id"] == cid+''){
                    type = gTask_type(key);
                    break;
                }
            }
            return type;
        }
        public static function gTask_self_task_times():Number{
            if(gTask_self() && gTask_self().hasOwnProperty("task_times")){
                if(Tools.isNewDay(gTask_refresh_time())){// && gTask_self().task_times<=0
                    return gTask_gtask_intial_num_max(); 
                }                
                return gTask_self().task_times;
            }
            return 0;            
        }
        public static function gTask_self_buy_times():Number{
            if(gTask_self() && gTask_self().hasOwnProperty("buy_times")){
                if(Tools.isNewDay(gTask_refresh_time())){// && gTask_self().buy_times>=ModelTask.gTask_gtask_buy().length
                    return 0; 
                }
                return gTask_self().buy_times;
            }
            return 0;             
        }
        /**
         * 给大地图显示 npc用的
         */
        public static function gTask_by_lc():Object{   
            var obj:Object = gTask_self_take();
            var gType:String;
            var re:Object = {};
            for(var key:String in obj){
                obj[key]["id"] = key;
                gType = gTask_type(key);
                if(gType == ModelTask.GTASK_TYPE_GTASK_COLLECT && obj[key].status>0){
                    re[obj[key].city_id] = obj[key];
                }
            }
            return re;
        }   
        public static function gTask_self_take_arr():Array{
            var task:Object = gTask_self_take();
            var arr:Array = [];
            
            for(var key:String in task)
            {
                task[key]["id"] = key;
                task[key]["sortEnd"] = ((task[key].rate>=ModelTask.gTask_need(key)[0])?2000:1000)+task[key].status;
                arr.push(task[key]);
            }
            arr.sort(MathUtil.sortByKey("sortEnd",true));
            return arr;
        }                     
        public static function gTask_self_take_need(tid:String):Number{
            var num:Number = 0;
            var task:Object = gTask_self_take();
            if(task.hasOwnProperty(tid)){
                num = task[tid]["need"];
            }
            return isNaN(num)?0:num;
        }
        public static function gTask_refresh_time():Number{
            return Tools.getTimeStamp(gTask_self().refresh_time);
        } 
        public static function gTask_refresh_refresh_times():Number{
            return gTask_self().refresh_times;//
        } 
        public static function gTask_reward_mulit_arr(v:Number):Array{
            var arr:Array = ConfigServer.gtask.reward_mulit;
            var len:int = arr.length;
            var arrNum:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                if(v>=arr[i][0]){
                    arrNum.push(arr[i]);
                }
            }
            return arrNum;
        }
        public static function gTask_reward_mulit(v:Number):Array{
            var arr:Array = ConfigServer.gtask.reward_mulit;
            var len:int = arr.length;
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                if(v<arr[i][0]){
                    index = i;
                    break;
                }
            }     
			if(index>0){
				index = index-1;
			}
			else if(index<0){
				index = len-1;
			}                
            return [arr[index],index];         
        }
        public static function gTask_self_take_building_lv(tid:String):Number
        {
            var task:Object = gTask_self_take();
            if(task.hasOwnProperty(tid)){
                task = task[tid];
                if(task.hasOwnProperty("building_lv")){
                    return task["building_lv"];
                }
            }
            return ModelManager.instance.modelUser.getLv();
        }
        public static function gTask_reward_mer(tid:String):Array{
            var arr:Array = ConfigServer.gtask.reward_mer;
            var len:int = arr.length;
            var lv:int = gTask_self_take_building_lv(tid);
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                if(lv<arr[i][0]){
                    index = i;
                    break;
                }
            }      
			if(index>0){
				index = index-1;
			}
			else if(index<0){
				index = len-1;
			}              
            var re:Array = (arr[index] as Array).concat();
            re[1] = Math.ceil(re[1]*(1+ModelOffice.func_addmerit()+ModelScience.func_sum_type(ModelScience.more_merit,"gtask")));
            return re;
        }
        public static function gTask_click(cid:*,v:Vector2D):void{
            ViewManager.instance.showView(ConfigClass.VIEW_WORK_CONQUEST,[ModelTask.gTask_city_data(cid,ModelTask.GTASK_TYPE_GTASK_COLLECT),v]);
        }
        public static function gTask_city_data(id:*,type:String):Object{
            var data:Object = null;
            var cid:String = id+"";
            var task:Object = gTask_self_take();
            var gType:String;
            for(var key:String in task)
            {
                gType = gTask_type(key);
                if(gType == type){
                    if(gType == GTASK_TYPE_GTASK_BUILD_RAN){
                        task[key]["id"] = key;
                        data = task[key];
                        break;
                    }
                    else if(task[key].city_id == cid){
                        task[key]["id"] = key;
                        data = task[key];
                        break;
                    }
                }
            }
            return data;
        }
        public static function gTask_city_is(cid:*):Boolean{
            var gtask_build:Object = ModelTask.gTask_city_data(cid,ModelTask.GTASK_TYPE_GTASK_BUILD);
            if(gtask_build){
                return true;
            }
            else{
		        var gtask_build_ran:Object = ModelTask.gTask_city_data(cid,ModelTask.GTASK_TYPE_GTASK_BUILD_RAN);
                if(gtask_build_ran){
                    return true;
                }
            }
            return false;
        }
        public static function gTask_city_troop(cid:String):Array{
            var troop:ModelTroop;
            var cids:String;
            var arr:Array = [];
            for(var key:String in ModelManager.instance.modelTroopManager.troops)
            {
                troop = ModelManager.instance.modelTroopManager.troops[key];
                cids = troop.cityId+"";
                if(cids == cid){
                    arr.push(troop);
                }
            }
            
            return arr;
        }
        public static var npcInfoTempKeyDic:Object = {};
        public static var npcInfoStatus:Number = 0;
        //public static var npcInfo_pk_arr:Array = [];//异族入侵
        public static var npcInfo_thief_arr:Array = [];//黄巾军入侵
        public static var buffs_mayor_arr:Array = [];//所有国家令和太守令
        public static var fire_city_arr:Array = [];//点火中的国家
        public static var country_army_arr:Array = [];//所有护国军
        public static var bless_hero_arr:Array = [];//福将
        public static var fire_num:Number=0;//点火中国家个数(查看完斥候情报就清零)
        public static var buffs_num:Number=0;//各种令的个数(查看完斥候情报就清零)
        public static var thief_num:Number=0;//黄巾军的个数(查看完斥候情报就清零)
        public static var country_army_num:Number=0;//护国军的个数(查看完斥候情报就清零)
        public static var bless_hero_num:Number = 0;
        /**
         * 
         */
        public static function npcInfo_check():void{//不用了
            return;
            //pk_npc
            var temp:Object = {};
            var mid:String = "_pk";
            //npcInfo_pk_arr = [];
            var keyID:String = "";
            for(var key:String in ModelClimb.pk_npc_models){
                var cityData:Array = ModelClimb.alien_city(key);
                keyID = key+mid+"_"+Tools.getTimeStamp(cityData[2]);
                temp[keyID] = keyID;
                if(!npcInfoTempKeyDic.hasOwnProperty(keyID)){
                    npcInfoTempKeyDic[keyID] = [key,npcInfo_pk_status(ModelClimb.pk_npc_models[key])];
                    npcInfoStatus +=1;
                }
                //npcInfo_pk_arr.push({type:"pk_npc",data:ModelClimb.pk_npc_models[key],id:key});
            }
            for(var key2:String in npcInfoTempKeyDic){
                if(!temp.hasOwnProperty(key2)){
                    // npcInfoStatus +=1;
                    delete npcInfoTempKeyDic[key2];
                }
            }
        }
        public static function npcInfo_thief_check(thief:Array = null):void{
            var len:int = thief.length;
            var thiefData:Object;
            var temp:Object = {};
            var mid:String = "_thief";
            thief_num=0;
            npcInfo_thief_arr = [];
            var key:String;
            for(var i:int = 0;i < len;i++){
                thiefData = thief[i];
                key = thiefData.cid+mid+"_"+thiefData.start_time;
                if(ModelOfficial.checkCityIsMyCountry(thiefData.cid)){   
                    temp[key] = key;
                    var sort:Number=ConfigServer.npc_info[thiefData.type] ? ConfigServer.npc_info[thiefData.type].layer : 0;
                    npcInfo_thief_arr.push({"type":thiefData.type,
                                            "data":thiefData,
                                            "id":thiefData.cid,
                                            "layer":sort});                    
                    if(!npcInfoTempKeyDic.hasOwnProperty(key)){
                        npcInfoTempKeyDic[key] = [thiefData,npcInfo_thief_status(thiefData)];
                        npcInfoStatus +=1;
                    }      
                    thief_num+=1;          
                }
            }
            for(var key2:String in npcInfoTempKeyDic){
                if(!temp.hasOwnProperty(key2)){
                    npcInfoStatus +=1;
                    delete npcInfoTempKeyDic[key2];
                }
            }                     
            //ConfigServer.attack_city_npc
            ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
        }
        public static function npcInfo_pk_status(pmd:ModelClimb):Number
        {
            var status:Number = 0;
            if(pmd.pk_npc_award){
                status = 2;
            }
            else{
                status = 1;
            }      
            return status;      
        }
        public static function npcInfo_thief_status(thief:Object):Number
        {
            var thiefCfg:Object = ConfigServer.attack_city_npc[thief.type];
            if(Tools.isNullObj(thiefCfg)) return 0;
            
            var stms:Number = thief.start_time*Tools.oneMillis;
            
            var lms:Number = thiefCfg.speed*Tools.oneMillis;
            
            var fightMs:Number = stms+lms;
            var std:Date = new Date(fightMs);
            var now:Number = ConfigServer.getServerTimer();	  
            var status:Number = 0;
            if(now>=stms && now<fightMs){
                status = 1;
            }
            else{
                status = 2;
            } 
            return status;         
        }
        public static function npcInfo_checkByTimer():Boolean{
			var isNew:Boolean = false;
			if(ModelTask.npcInfoStatus>0){
				//有状态变化
				isNew = true;
			}
			else{
				var data:Array;
				var status:Number = 0;
				var pmd:ModelClimb;
				for(var key:String in ModelTask.npcInfoTempKeyDic){
					data = ModelTask.npcInfoTempKeyDic[key];
					if(key.indexOf("_thief")>-1){
						status = ModelTask.npcInfo_thief_status(data[0]);				
					}
					else{
						pmd = ModelClimb.pk_npc_models[data[0]];
						if(pmd){
							status = ModelTask.npcInfo_pk_status(pmd);
						}
						else{
							delete ModelTask.npcInfoTempKeyDic[key];
							status = 0;
						}
					}
					if(data[1] !=status){
						ModelTask.npcInfoTempKeyDic[key] = [data[0],status];
						// trace(key+"状态有变化",status);
						isNew = true;
						break;
					}					
				}
			}
            return isNew;
        }
        /**
         * 是否有政务 red 提示
         */
        public static function checkWorkWill():Boolean
        {
            var timesNum:Number = ModelTask.gTask_self_task_times();
            var timesBuy:Number = ModelTask.gTask_self_buy_times();
            var timesDef:Number = ModelTask.gTask_gtask_intial_num_max();
            var timesMax:Number = (timesDef+timesBuy);
            if(timesNum>0){
                return true;
            }            
            var take:Object = ModelTask.gTask_self_take();
            for(var key:String in take)
            {
                if(take[key].status>0){
                    return true;
                }
            }
            return false;
        }   

        /**
         * 获得当前所有国家令和太守令
         */
        public static function getBuffsAndMayor():Array{
            buffs_mayor_arr=[];
            buffs_num=0;
            var o1:Object=ModelOfficial.getMyCountryBuffs();
            var config:Object=ConfigServer.npc_info;
            var now:Number=ConfigServer.getServerTimer();
            var t1:Number;
            var t2:Number;
            if(o1){
                for(var s:String in o1){
                    if(s!=ModelOfficial.BUFF_5 && config.hasOwnProperty(s)){
                        t1=ConfigServer.country[s].time*Tools.oneMinuteMilli;
                        t2=Tools.getTimeStamp(o1[s][2]);
                        if(now - t2 < t1){
                            buffs_mayor_arr.push({"type":s, "id":o1[s][0], "data":o1[s], "sort":config[s].layer});
                            buffs_num+=1;
                        }
                    }
                }
            }
            var temp:Object=ModelOfficial.getAllMayorBuffs();
            var o2:Object=temp["corps"];
            for(var k:String in o2){
                if(config.hasOwnProperty("buff_corps")){
                    t1=ConfigServer.country["buff_corps"].time*Tools.oneMinuteMilli;
                    t2=Tools.getTimeStamp(o2[k][2]);
                    if(now - t2 < t1){
                        buffs_mayor_arr.push({"type":"buff_corps","id":k,"data":o2[k],"sort":config["buff_corps"].layer});
                        buffs_num+=1;
                    }
                }
            }
            var o3:Object=temp["country5"];
            for(var c:String in o3){
                if(config.hasOwnProperty(ModelOfficial.BUFF_5)){
                    t1=ConfigServer.country[ModelOfficial.BUFF_5].time*Tools.oneMinuteMilli;
                    t2=Tools.getTimeStamp(o3[c][2]);
                    if(now - t2 < t1){
                        buffs_mayor_arr.push({"type":ModelOfficial.BUFF_5,"id":c,"data":o3[c],"sort":config[ModelOfficial.BUFF_5].layer});
                        buffs_num+=1;
                    }
                }
            }
            buffs_mayor_arr.sort(MathUtil.sortByKey("sort",false,true));
            ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
            return buffs_mayor_arr;
        }   

        /**
         * 更新斥候情报里面的令的数据
         */
        public static function updateBuffsAndMayor():void{
            var arr:Array=ModelTask.buffs_mayor_arr;
            var t1:Number;
            var t2:Number;
            var now:Number=ConfigServer.getServerTimer();
            for(var i:int=0;i<arr.length;i++){
                var o:Object=arr[i];
                t1=ConfigServer.country[o.type].time*Tools.oneMinuteMilli;
                t2=Tools.getTimeStamp(o.data[2]);
                if(now-t2>t1){
                    arr.splice(i,1);
                }
            }
        }

        /**
         * 正在点火国家(只在斥候情报里使用)
         * type 0初始化  1增加  2删除
         */
        public static function checkFireCity(type:Number=0,re:*=null):Array{
            var config:Object=ConfigServer.npc_info;
            if(type==0){
                fire_city_arr=[];
                fire_num=0;
                var cities:Object=ModelOfficial.cities;
                for(var s:String in cities){
                    var b1:Boolean=cities[s].country==ModelManager.instance.modelUser.country;//我国正在挨打
                    if(b1 && cities[s].fight){
                        fire_city_arr.push({"type":"fire","id":s,"data":cities[s].fight.fireCountry, "layer":config["fire"].layer});
                        fire_num+=1;
                    }
                }
            }else if(type==1){
                fire_num+=1;
                if(re){
                    fire_city_arr.push({"type":"fire","id":re.city,"data":re.fire_country,"layer":config["fire"].layer});
                }
                ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
            }else if(type==2){
                fire_num = fire_num>0 ? fire_num-1 : 0;
                if(re){
                    for(var i:int=0;i<fire_city_arr.length;i++){
                        if(fire_city_arr[i].id==re.city.cid){
                            fire_city_arr.splice(i,1);
                            break;
                        }
                    }
                }
                //ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
            }

            return fire_city_arr;
        }

        public static var target_city_arr:Array=[];
        /**
         * 检查护国军军状态(斥候情报里用)
         * type 0初始化  1更新(每次战斗结束检查)
         */
        public static function checkCountryArmy(type:int,cid:String):Array{
            if(ModelUser.isHaveCountryArmy()==false){
                return [];
            }
            if(ModelOfficial.cities==null){
                return [];
            }

            var config:Object = ConfigServer.country_army;

            var configNpc:Object = ConfigServer.npc_info.country_army;
            if(configNpc==null){
                return [];
            }

            //目标城市对应的发兵时间点[h,m]
            var ot:Object = ModelUser.getCountryArmyAriseTime();
            if(ot == null){
                return [];
            }

            var o:Object   = ConfigServer.country_army[ModelManager.instance.modelUser.country];
            var now:Number = ConfigServer.getServerTimer();
            
            if(ModelTask.target_city_arr.length==0){
                for(var i:int=0;i<o.target_city.length;i++){
                    var c:String = o.target_city[i][o.target_city[i].length-1];
                    ModelTask.target_city_arr.push(c);
                }
            }

            if(type==0){
                country_army_arr = [];
                country_army_num = 0;
                if(o){
                    for(var j:int=0;j<ModelTask.target_city_arr.length;j++){
                        var city_id:String = ModelTask.target_city_arr[j];
                        var n:Number = ModelOfficial.cities[city_id].country;
                        if(n!=ModelManager.instance.modelUser.country){//非本国城市
                            country_army_arr.push({"type":"country_army","id":city_id,"data":"", "layer":configNpc.layer});
                            country_army_num+=1;
                        }
                    }
                }
            }else if(type==1){
                if(ModelTask.target_city_arr.indexOf(cid)!=-1){
                    var nn:Number = ModelOfficial.cities[cid].country;
                    //非我国城市
                    if(nn!=ModelManager.instance.modelUser.country){
                        country_army_arr.push({"type":"country_army","id":cid,"data":"", "layer":configNpc.layer});
                        ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
                    }else{
                        for(var k:int=0;k<country_army_arr.length;k++){
                            if(country_army_arr[k].id==cid){
                                //该城市变回我国城市 移除这个信息
                                if(nn==ModelManager.instance.modelUser.country){
                                    country_army_arr.splice(k,1);
                                    if(country_army_num>0) country_army_num-=1;
                                }
                                break;
                            }
                        }
                    }
                }

            }
            return country_army_arr;
        }


        public static function checkBlessHero():void{
            bless_hero_arr = [];
            bless_hero_num = 0;
            var config:Object = ConfigServer.npc_info.bless_hero;
            if(config==null){
                return;
            }

            var a:Array = ModelBlessHero.instance.infoData;
            for(var i:int=0;i<a.length;i++){
                bless_hero_arr.push({"type":"bless_hero","id":a[i][0],"data":a[i], "layer":config.layer});
                bless_hero_num+=a[i][2];
            }
        }
    }
}