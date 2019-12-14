package sg.model
{
    import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.map.model.MapModel;
    import sg.utils.Tools;
    import laya.maths.MathUtil;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.scene.constant.EventConstant;
    import sg.utils.StringUtil;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.guide.model.ModelGuide;
    import sg.boundFor.GotoManager;
    import sg.utils.SaveLocal;
    import sg.explore.model.ModelExplore;

    public class ModelOfficial extends ModelBase{

        public static const BUFF_3:String = "buff_country3";//攻城令
        public static const BUFF_4:String = "buff_country4";//守城令
        public static const BUFF_5:String = "buff_country5";//督尉令
        public static const BUFF_CORPS:String = "buff_corps";//太守令

        public static const EVENT_SET_OFFICER_IS_OK:String = "event_set_officer_is_ok";
        public static const EVENT_SET_MAYOR_IS_OK:String = "event_set_mayor_is_ok";
        public static const EVENT_UPDATE_COUNTRY_DATA:String = "event_update_country_data";
        public static const EVENT_UPDATE_ORDER:String = "event_update_order";
        public static const EVENT_UPDATE_ORDER_ICON:String = "event_update_order_icon";
        public static const EVENT_UPDATE_ALIEN_CD:String = "event_update_ALEIN_CD";//异邦来访CD
        public static const EVENT_UPDATE_IMPEACH:String = "event_update_impeach";//弹劾消息

        public static const EVENT_SHOW_GOLD_ESTATE:String = "event_show_gold_estate";//显示黄金矿 参数[[cid,index],[cid,index],[cid,index]]
        public static const EVENT_HIDE_GOLD_ESTATE:String = "event_hide_gold_estate";//隐藏黄金矿

        public static const EVENT_SHOW_XYZ:String = "event_show_xyz";//显示襄阳城按钮
        public static const EVENT_HIDE_XYZ:String = "event_hide_xyz";//隐藏襄阳城按钮
        public static const EVENT_PAY_RANK:String = "event_pay_rank"; // 消费榜数据
        
        //=============服务器数据
        public static var countries:Object;//全部国家
        public static var cities:Object;//全部城市PP
        public static var troops:Object;//全部部队
        public static var visit:Object;//拜访数据
        public static var xyz_victor_country:*;//襄阳城占领国家
        public static var xyz_estate_add:Array;//黄金矿
        

        //=============前端用的数据
        public static var city_order:Object = {}; //城市上面的令 主要是给大地图用的
        public static var city_mayor:Object = {}; //城市太守{"cid":uid} 我国城市太守uid列表  战斗结束和封太守的时候更新一下

        public function ModelOfficial(){
			this.init();
		}
        public function init():void{
            NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_TO,this,this.event_socket_receive_to);
        }
        private function event_socket_receive_to(re:Object,isMe:Boolean):void
        {
            var method:String = re.method;
            var receiveData:Object = re.data;
            if(Tools.isNullObj(receiveData)){
                return;
            }
            if(receiveData.hasOwnProperty("msg")){
                return;
            }
            // trace("===ModelOfficial==",method,receiveData);
            switch(method)
            {
                case NetMethodCfg.WS_SR_GET_INFO:
                    ModelOfficial.countries          = receiveData.countries;
                    ModelOfficial.cities             = receiveData.cities;                    
                    ModelOfficial.troops             = receiveData.troops;   
                    ModelOfficial.xyz_victor_country = receiveData.xyz_victor_country;
                    ModelOfficial.xyz_estate_add     = receiveData.xyz_estate_add;
                    if (!MapModel.instance.reloading) {
						ModelManager.instance.modelGame.initEstate();//初始化产业
						ModelManager.instance.modelGame.initFtask();//初始化民情  
						ModelTask.checkFireCity();//点火城市初始化（用在斥候情报）
						ModelTask.getBuffsAndMayor();//所有的令（用在斥候情报）   
						ModelTask.checkCountryArmy(0,"");
						ModelOfficial.updateCityMayor(0,receiveData);      
						ModelOfficial.initCityOrder();//初始化大地图上要显示的令   
						
						// 初始化探险（需要等待ModelOfficial.cities数据，所以放在这里）
						ModelExplore.instance.initModel();
						ModelManager.instance.modelCountryPvp.updateXYZ(receiveData);
						if(xyz_estate_add && xyz_estate_add.length!=0){
							this.event(ModelOfficial.EVENT_SHOW_GOLD_ESTATE,xyz_estate_add);
						}

						if(receiveData.xyz==null || receiveData.xyz.status==0){
							this.event(ModelOfficial.EVENT_SHOW_XYZ);
						}
						this.event(ModelOfficial.EVENT_PAY_RANK, receiveData.pay_rank);
					}
                    
                    break;
                case NetMethodCfg.WS_SR_SET_OFFICIAL:
        /**
         * 官员更改,更新国家数据
         */
                    ModelOfficial.updateSetOfficer(receiveData);
                    ModelManager.instance.modelOfficel.event(EVENT_SET_OFFICER_IS_OK,isMe);               
                    break;
                case NetMethodCfg.WS_SR_SET_MAYOR:
        /**
         * 太守更改,更新国家数据
         */                
                    ModelOfficial.updateSetMayor(receiveData);
                    ModelManager.instance.modelOfficel.event(EVENT_SET_MAYOR_IS_OK,isMe);                 
                    break;
                case NetMethodCfg.WS_SR_CREATE_BUFF:
        /**
         * 官员下令,更新国家数据
         */         
                    ModelManager.instance.modelUser.updateData(receiveData);
                    
                    delete receiveData["user"];
                    for(var key:String in receiveData)
                    {
                        if(key == "buff_corps" || key == ModelOfficial.BUFF_5){
                            ModelOfficial.updateOrderCity(key,receiveData[key]);
                        }
                        else{
                            ModelOfficial.updateOrderCountries(key,receiveData[key]);
                        }
                        ModelManager.instance.modelGame.event(EVENT_UPDATE_ORDER,[receiveData,isMe]);

                    }   
                    ModelManager.instance.modelGame.event(EVENT_UPDATE_ORDER_ICON);
                    ModelTask.getBuffsAndMayor();//(斥候情报里面用的数据)
                    break;
                case EventConstant.FIGHT_END:        
         /**
         * 国战,结束,通知,更改数据
         */                
                    // ModelOfficial.updateFightEnd(receiveData);  

                    break;
                case "impeach_over_push"://弹劾结束推送
                    updateCountryData(receiveData.country);
                    //trace("=====弹劾结束");
                    this.event(ModelOfficial.EVENT_UPDATE_IMPEACH);
                    break; 
                case "start_vote_push"://有人投票
                    updateImpeach(receiveData);
                    //trace("=====有人投票");
                    this.event(ModelOfficial.EVENT_UPDATE_IMPEACH);
                    break; 
                case "start_impeach_push"://发起弹劾
                    updateImpeach(receiveData);
                    //trace("=====发起弹劾");
                    this.event(ModelOfficial.EVENT_UPDATE_IMPEACH);
                    break; 
                case "w.xyz_over"://襄阳战结束
					xyzOver(receiveData);
					/*********************城池归属************************/
                    var xyzCitys:Array = [ -1, -2, -3, -4, -5];
					for (var i:int = 0, len:int = xyzCitys.length; i < len; i++) {
                        var n:Number=(receiveData.victor_country is Number) ? receiveData.victor_country : receiveData.victor_country.tid;
						if(cities[xyzCitys[i]]){
                            cities[xyzCitys[i]].country=n;
                        }
                        MapModel.instance.onFightEndHandler({city:{cid:xyzCitys[i], country:n}}, false);
                    }    

                    
					//*******************清理部队*************************/
					ModelManager.instance.modelTroopManager.deleteXYZTroop();
					/*****************************************************/
					
					
                    if(xyz_estate_add && xyz_estate_add.length!=0){
                        this.event(ModelOfficial.EVENT_SHOW_GOLD_ESTATE,xyz_estate_add);
                    }else{
                        this.event(ModelOfficial.EVENT_HIDE_GOLD_ESTATE);
                    }

                    //this.event(ModelOfficial.EVENT_SHOW_XYZ);

					break;	
                case "w.country_army_dead"://(护国军战死)
                    //trace("========= country_army_dead",receiveData);
                    //deleteTroops(receiveData);
                    break; 
                case "w.troop_move_push"://创建行军（这里就是处理一下护国军的）
                    //ModelOfficial.updateTroops(receiveData); 
                    break; 
                                                                                                 
                default:
                    break;
            }
        }

        /**
         * 更新get_info接口上的troops
         */
        public static function updateTroops(obj:Object):void{
            //护国军
            if(obj.xtype && obj.xtype=="country_army"){
                //trace("troops里添加护国军数据");
                var s:String = obj.hid;
                var o:Object={};
                o[s]=obj;
                troops[obj.uid]=o;
            }
        }
        
        /**
         * 删除troops里的护国军
         * obj = {"uid":"","hid":""}
         */
        public static function deleteTroops(obj:Object):void{
            if(obj.uid && troops.hasOwnProperty(obj.uid)){
                if(obj.hid && troops[obj.uid].hasOwnProperty(obj.hid)){
                    delete troops[obj.uid][obj.hid];
                }    
            }
        }

        /**
         * 襄阳战结束
         */
        public static function xyzOver(receiveData:Object):void{
            if(!ModelOfficial.countries || !ModelOfficial.cities){
                return;
            } 
            //victor_country 黄巾军是数字  魏蜀吴是国家对象
            ModelOfficial.xyz_victor_country = receiveData.victor_country is Number ? receiveData.victor_country : receiveData.victor_country.tid;//战胜国
            ModelOfficial.xyz_estate_add     = receiveData.estate_add;
            
            //本国数据
            if(receiveData.country) ModelOfficial.countries[receiveData.country.tid] = receiveData.country;
            //战胜国数据
            if([0,1,2].indexOf(ModelOfficial.xyz_victor_country)!=-1 && receiveData.country.tid != receiveData.victor_country.tid)
                ModelOfficial.countries[receiveData.victor_country.tid] = receiveData.victor_country;


        }

        public static function updateFightEnd(receiveData:Object):void
        {
            if(!ModelOfficial.countries || !ModelOfficial.cities){
                return;
            }             
            var oldInv:Number = ModelOfficial.getInvade();
            var cid:Number = receiveData.city.cid;
            var oldCountry:Number = ModelOfficial.cities[receiveData.city.cid].country;
            var newCountry:Number = receiveData.city.country;
            var myCountry:Number = ModelUser.getCountryID();

            ModelOfficial.cities[receiveData.city.cid] = receiveData.city;
            ModelOfficial.updateCityMayor(2,receiveData);
            //
            var newInv:Number = ModelOfficial.getInvade();
            oldInv !== newInv && ModelManager.instance.modelGame.event(ModelGame.EVENT_INVADE_CHANGE, newInv);
            // oldInv !== newInv && trace("战斗结束  天下大势变化 ",oldInv,newInv);
            //
            if(receiveData.country && ModelManager.instance.modelCountryPvp.xyz==null){
                ModelOfficial.countries[receiveData.country.tid] = receiveData.country;
                if(receiveData.country.tid == myCountry){
                    var arr:Array=ModelOfficial.checkCountryKingStatus(receiveData.country,oldInv!=newInv);
                    if(arr){
                        if(ModelGuide.forceGuide()){
                            return;
                        }
                        ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_KING_TIPS,arr);
                    };
                }                 
            }

            if(oldCountry != newCountry){//城市变更
                //deleteCountryBuffs(oldCountry,"buff_country4",cid);
                //deleteCountryBuffs(newCountry,"buff_country3",cid);                    
                //deleteCountryBuffs(oldCountry,"buff_country2",cid);
                if(oldCountry==ModelUser.getCountryID()){
                    //被攻占 清除守城令
                    if(ModelOfficial.countries[oldCountry]){
                        var buffs:Object=ModelOfficial.countries[oldCountry].buffs;
                        if(buffs && buffs.hasOwnProperty(ModelOfficial.BUFF_4)){
                            if(buffs[ModelOfficial.BUFF_4][0]==cid+""){
                                delete buffs[ModelOfficial.BUFF_4];
                            }
                        }
                    }

                    //被攻占  清除太守令
                    if(ModelOfficial.city_order["buff_corps_"+cid]){
                        (ModelOfficial.city_order["buff_corps_"+cid] as cityOrder).timerEnd();
                    }
                }
                
                deleteCountryBuffs("","buff_country3","");
                deleteCountryBuffs("","buff_country4","");
            }
            
            ModelManager.instance.modelGame.event(EVENT_UPDATE_ORDER_ICON);
            //
            ModelManager.instance.modelUser.updateData(receiveData);
            ModelTask.getBuffsAndMayor();
        }
        public static function deleteCountryBuffs(country:*,buff:String,cid:*):void{
            /*
            if(ModelOfficial.countries[country]){
                if(ModelOfficial.countries[country]["buffs"] && ModelOfficial.countries[country]["buffs"][buff]){
                    if(ModelOfficial.countries[country]["buffs"][buff][0] && ModelOfficial.countries[country]["buffs"][buff][0] == cid){
                        delete ModelOfficial.countries[country]["buffs"][buff];
                        if(ModelOfficial.city_order[buff] && country == ModelUser.getCountryID()){
                            (ModelOfficial.city_order[buff] as cityOrder).timerEnd();
                        }
                    }
                }
            }*/

            var myCountry:Number=ModelUser.getCountryID();
            if(ModelOfficial.countries[myCountry] && ModelOfficial.countries[myCountry]["buffs"]){
                var new_buffs:Object=ModelOfficial.countries[myCountry]["buffs"];
                var old_buffs:Object=ModelOfficial.city_order;
                if(!new_buffs[buff]){
                    if(ModelOfficial.city_order[buff]){
                        (ModelOfficial.city_order[buff] as cityOrder).timerEnd();
                    }else{
                        //trace(buff,"error");
                    }
                }
            }
        }



        public static function checkCountryKingStatus(country:Object,inv:Boolean = false):Array{
            var key:String = ModelManager.instance.modelUser.mUID+SaveLocal.KEY_COUNTRY_KING;
            var b:Boolean = false;
            var uname:String = "";
            var cc:Number = -1;
            if(country && country.official && country.official[0]){    
                var old:Object = SaveLocal.getValue(key,true);
                if(inv){
                    b = true;
                }
                else{
                    if(old && old.official && old.official[0]){
                        if(old.official[0][0]!=country.official[0][0]){
                            b = true;
                        }
                    }else{
                        b = true;
                    }
                }
                if(b){
                    uname = country.official[0][1];
                    cc = country.tid;     
                    SaveLocal.save(key,country,true);
                    if(ModelGuide.forceGuide()){
                        return null;
                    }
                    //ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_KING_TIPS,[uname,cc]);
                }          
            }
            return b ? [uname,cc] : null;   
        }
        public static function checkCountryKingTips():Array{
            var key:String = ModelManager.instance.modelUser.mUID+SaveLocal.KEY_COUNTRY_KING_EVERY_TIPS;
            var str:* = SaveLocal.getValue(key,true);
            var old:Number = Number(str?str:0);
            var now:Number = ConfigServer.getServerTimer();
            var arr:Array=null;
            if(!str || (str  && Tools.isNewDay(old))){
                SaveLocal.save(ModelManager.instance.modelUser.mUID+SaveLocal.KEY_COUNTRY_KING,ModelOfficial.countries[ModelUser.getCountryID()],true);
                arr=ModelOfficial.checkCountryKingStatus(ModelOfficial.countries[ModelUser.getCountryID()],true);
                SaveLocal.save(key,now+"",true);
            }
            return arr;

        }
        /**
         * 更新国家,各种下令后的数据
         */
        public static function updateOrderCountries(key:String,data:Array):void{
            if(!ModelOfficial.countries){
                return;
            }            
            var country:Object = ModelOfficial.getMyCountryCfg();
            if(!ModelGuide.forceGuide()){
                GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_TIPS_ORDER,"",[key,data,ModelUser.getCountryID(),2]);
            }
            //
            var cityChange:Boolean = false;
            var old:Array;
            if(country.hasOwnProperty("buffs")){
                old = country["buffs"][key];
                if(old && old[0] && data[0]){
                    cityChange = (old[0]!=data[0]);
                }
                country["buffs"][key] = data;
            }
            else{
                country["buffs"] = {};
                country["buffs"][key] = data;
            }
            if(key == ModelOfficial.BUFF_3 || key == ModelOfficial.BUFF_4){
                if(ModelOfficial.city_order[key]){
                    if(cityChange){
                        (ModelOfficial.city_order[key] as cityOrder).timerEnd();
                        ModelOfficial.city_order[key] = new cityOrder(key,data);
                    }
                    else{
                        (ModelOfficial.city_order[key] as cityOrder).update(key,data);
                    }
                }
                else{
                    ModelOfficial.city_order[key] = new cityOrder(key,data);
                }
            }
        }
        /**
         * 官员下令,更新城市数据
         */        
        public static function updateOrderCity(key:String,data:Array):void{
            if(!ModelOfficial.cities){
                return;
            }            
            if(!Tools.isNullObj(data[0])){
                if(key==ModelOfficial.BUFF_5){
                    if(data[5]==ModelManager.instance.modelUser.country){//我国发出的buff5才弹提示
                        if(!ModelGuide.forceGuide()){
                            GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_TIPS_ORDER,"",[key,data,ModelUser.getCountryID(),2])    
                        }
                        
                    }
                }else{
                    if(!ModelGuide.forceGuide()){
                        GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_TIPS_ORDER,"",[key,data,ModelUser.getCountryID(),2])
                    }
                }
                var city:Object = cities[data[0]+""];
                if(city.hasOwnProperty("buffs")){
                    city["buffs"][key] = data;
                }
                else{
                    city["buffs"] = {};
                    city["buffs"][key] = data;
                } 

                if(key == ModelOfficial.BUFF_5 || key == ModelOfficial.BUFF_CORPS){
                    var s:String=key+"_"+city.cid;
                    var b:Boolean=true;
                    if(key == ModelOfficial.BUFF_CORPS){
                        if(city.country!=ModelManager.instance.modelUser.country) 
                            b=false;
                    }
                    if(b){
                        if(ModelOfficial.city_order[s]){
                            (ModelOfficial.city_order[s] as cityOrder).update(key,data);
                        }
                        else{
                            ModelOfficial.city_order[s] = new cityOrder(key,data);
                        }
                    }

                    if(key == ModelOfficial.BUFF_5){
                        var country:Object = ModelOfficial.getMyCountryCfg();
                        if(country.hasOwnProperty("buffs")){
                            country["buffs"][key] = data;
                        }else{
                            country["buffs"] = {};
                            country["buffs"][key] = data;
                        }
                    }
                }
            }
        }

        /**
         * 获取 本国 所有 官职
         */
        public static function getOfficers(countryID:* = ""):Array{
            return ModelOfficial.getMyCountryCfg(countryID)["official"];
        }

        /**
         * 获得某国的指定uid的官职
         */
        public static function getOfficersByID(countryID:* = "",uid:String = ""):Number{
            var n:Number=-100;
            var arr:Array=getOfficers(countryID);
            for(var i:int=0;i<arr.length;i++){
                if(arr[i] && arr[i][0]==uid){
                    n=i;
                    break;
                }
            }
            return n;
        }

        /**
         * 我的国家配置
         */
        public static function getMyCountryCfg(countryID:* = ""):Object{
            return countries[ModelUser.getCountryID(countryID)];
        }
        /**
         * 我的国家弹劾数据
         */
        public static function get impeach():Object{
            var o:Object=getMyCountryCfg();
            return o.impeach?o.impeach:null;
        }

        public static function get impeach_fail_time():Number{
            var o:Object=getMyCountryCfg();
            return o.impeach_fail_time?Tools.getTimeStamp(o.impeach_fail_time):0;
        }

        public static function get king_time():Number{
            var o:Object=getMyCountryCfg();
            return o.king_time?Tools.getTimeStamp(o.king_time):0;
        }

        /**
         * 更新弹劾数据
         */
        public static function updateImpeach(re:Object):void{
            if(re && re.impeach){
                var o:Object=getMyCountryCfg();
                o["impeach"]=re.impeach;
            }   
        }


        /**
         * 国家数据完整更新
         */
        public static function updateCountryData(re:Object,countryID:* = ""):void
        {
            countries[ModelUser.getCountryID(countryID)] = re;
        }

        /**
         * 城市上面的建筑数据
         */
        public static function updateCityBuild(re:Object):void{
            if(re.hasOwnProperty("city_build") && ModelOfficial.cities && ModelOfficial.cities[re.cid]){
                ModelOfficial.cities[re.cid]["build"]=re["city_build"];
            }
        }
        /**
         * 获得 user 的官职 ,-1 没有,>= 0 看配置
         */
        public static function getUserOfficer(uid:String,sp:Boolean = false):int{
            
            var all:Array = ModelOfficial.getOfficers();
            var oid:int = sp?-100:-1;
            var len:int = all.length;
            for(var i:int = 0; i < len; i++)
            {
                if(!Tools.isNullObj(all[i])){
                    if(all[i][0] == parseInt(uid)){
                        oid = i;
                        break;
                    }
                }
            }
            return oid;
        }
        public static function isKingKing(uid:String,country:* = ""):Boolean{//
            if(((!Tools.isNullString(uid) && isKing(uid)>-1) || Tools.isNullString(uid)) && cities["-1"].country == ModelUser.getCountryID(country)){
                return true;
            }
            return false;
        }
        /**
         * 国王
         */
        public static function isKing(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 0)?oid:-1;
        }
        /**
         * 军师
         */
        public static function isAdviser(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 5)?oid:-1;
        }        
        /**
         * 相国(可分配除世子外所有官职)
         */        
        public static function isPremier(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 9)?oid:-1;            
        }
        /**
         * 郡丞(分配太守)
         */         
        public static function isGovernor(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 6)?oid:-1;            
        } 
        /**
         * 祭酒(训练)
         */          
        public static function isTrain(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 7)?oid:-1;        
        } 
        /**
         * 主簿(建设令)
         */         
        public static function isBuilder(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 10)?oid:-1;        
        } 
        /**
         * 都尉(都尉令)//禁止补兵令
         */         
        public static function isBeefedUp(uid:String):int{//
            var oid:int = getUserOfficer(uid);
            return (oid == 12)?oid:-1;        
        }          
        /**
         * 获取,官员,命令,加成值
         * type == 命令ID
         * cid == 城市ID
         */
        public static function get_order_buff(type:String,cid:String = "",isCity:Boolean = false):Array{
            var data:Object = (!isCity)?ModelOfficial.getMyCountryCfg():cities[cid];
            var cfg:Object = ConfigServer.country[type];
            var buffs:Object;
            if(data.hasOwnProperty("buffs")){
                buffs = data["buffs"];
            }
            if(buffs){
                if(buffs.hasOwnProperty(type)){
                    var tt:Number = Tools.getTimeStamp(buffs[type][2]);
                    var et:Number = tt+cfg.time*Tools.oneMinuteMilli;
                    if(ConfigServer.getServerTimer()<et){
                        return cfg[buffs[type][1]?"effect_gratis":"effect_consume"];
                    }
                }         
            }   
            return null;
        }
        /**
         * 太守令和建设令 对城市建造的增益
         * @param cid: 城市id
         * @param type: 0 太守令  1 建设令
         */
        public static function cityBuildAdd(cid:String = "",type:Number=0):Number{
            if(type==0){
                var buff_corps:Array = get_order_buff("buff_corps",cid,true);
                if(buff_corps){
                    var mayor:Array = getCityMayor(cid);
                    if(mayor){
                        //if(ModelManager.instance.modelGuild.u_dict.hasOwnProperty(mayor[0])){
                            return buff_corps[1][1];
                        //}
                    }
                }
            }else{
                var buff_country2:Array = get_order_buff("buff_country2",cid);
                if(buff_country2){
                    return buff_country2[0][1];
                }
            }
            return 0;
            
        }
        public static function getArmyMakeBuff():Number
        {
            var buff:Array = get_order_buff("buff_country1");
            if(buff){
                return buff[0][1];
            }
            return 0;
        }
        /**
         * order 是否超时
         */
        public static function orderIsNewDay(buff:Array,type:String):Boolean
        {
            if(buff){
                var cfg:Object = ConfigServer.country[type];
                var tt:Number = Tools.getTimeStamp(buff[2]);
                var et:Number = tt+cfg.time*Tools.oneMinuteMilli; 
                return Tools.isNewDay(et);           
            }
            return false;
        }
        /**
         * 检查国家是否有buff
         */
        public static function get_country_order_data(oid:String,country:*=""):Array
        {
            var cobj:Object = getMyCountryCfg(country);
            var buffs:Object;
            if(cobj.hasOwnProperty("buffs")){
                buffs = cobj["buffs"];
            }
            if(buffs){
                if(buffs.hasOwnProperty(oid)){
                    return buffs[oid];
                }
            }
            return null;
        }
        /**
         * 检查城市是否有buff
         */        
        public static function get_city_order_data(oid:String,city:*):Array
        {
            var cobj:Object = cities[city];
            var buffs:Object;
            if(cobj.hasOwnProperty("buffs")){
                buffs = cobj["buffs"];
            }
            if(buffs){
                if(buffs.hasOwnProperty(oid)){
                    return buffs[oid];
                }
            }
            return null;
        }  

        /**
         * 根据id获得buff倒计时
         */
        public static function getBuffTimeById(id:String):Number{
            var cobj:Object = getMyCountryCfg();
            var now:Number = ConfigServer.getServerTimer();
            
            if(id == "country_army"){//护国军
                var o:Object = ModelTask.country_army_arr.length > 0 ? ModelUser.getCountryArmyAriseTime() : {};
                var a:Array = [];
                for(var s:String in o){
                    var n:Number = Tools.getToDayHourMill(o[s]) - now;
                    if(n<0) return 0;
                    if(n>0) a.push(n);
                }
                if(a.length!=0){
                    return a[0];
                }
            }else if(id == "task_buff"){//国战任务
                
            }else if(cobj.hasOwnProperty("buffs") && cobj["buffs"] && cobj["buffs"][id]){//国家令
                //var arr:Array=ModelOfficial.get_country_order_data(id);
			    //var n1:Number = arr ? Tools.getTimeStamp(arr[2]) : 0;//开始时间
                //var n2:Number = ConfigServer.country[id].time * Tools.oneMinuteMilli;//持续时间
                return 0;//(n1 + n2) - now; 
            }

            return 0;
        }      
        /**
         * 更新 官职
         */
        public static function updateSetOfficer(re:Object):void
        {
            if(!ModelOfficial.countries){
                return;
            }
            if(!Tools.isNullObj(re)){       
                ModelOfficial.countries[re.country.tid] = re.country;
                //
                // re.o1,re.o2,re.country.tid;
                //
                if(re.country.tid == ModelUser.getCountryID() && re.o1!=null && re.o2!=null){//o1 旧官职  o2 新官职
                    if(re.o2==0 && re.o1==re.o2){//当选国王
                        var _name:String=re.country.official[0][1];
                        var _country:Number=re.country.tid;
                        if(ModelGuide.forceGuide()){
                            return;
                        }
                        ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_KING_TIPS,[_name,_country]);
                    }else{
                        if(ModelGuide.forceGuide()){
                            return;
                        }
                        GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_OFFICER_TIPS,"",[re.o1,re.o2,re.country.tid,1]);
                    }
                    
                }
            }
        }
        /**
         * 更新 太守
         */
        public static function updateSetMayor(re:Object):void{
            if(!ModelOfficial.cities){
                return;
            }
            if(!Tools.isNullObj(re)){
                cities[re.cid]["mayor"] = re.data;
                cities[re.cid]["mayor_cd"] = re.mayor_cd;
                if(!Tools.isNullObj(re.cid2)){
                    cities[re.cid2]["mayor"] = null;
                }
                // 0,1,2,3
                //任命了新人
                var country:Number=cities[re.cid].country;
                if(ModelManager.instance.modelUser.country==country){
                    if(!ModelGuide.forceGuide()){
                        GotoManager.boundForPanel(GotoManager.VIEW_COUNTRY_OFFICER_TIPS,"",[re.data[4],re.cid,country,2,re.data[1]]);
                    }
                    ModelOfficial.updateCityMayor(1,re);
                }
            }
        }     
        /**
         * 检查,城市,是否是我国的
         */
        public static function checkCityIsMyCountry(cid:*):Boolean{
            if(cities && cities.hasOwnProperty(cid+"")){
                if(cities[cid+""].country == ModelUser.getCountryID()){
                    return true;
                }
            }
            return false;
        }   
        /**
         * 获得 国家 内 所有归属城市,祖国全部城市
         */
        public static function getMyCities(country:*,ctd:Array=null,mayor:String = ""):Array{//
            var cityType:Array = [0,1,2,3,4,5,9];
            cityType = Tools.isNullObj(ctd)?cityType:ctd;
            var city:Object;
            var arr:Array = [];
            var cfg:Object;
            for(var key:String in cities)
            {
                city = cities[key];
                if(city.country == country){
                    if(cityType){
                        cfg = ConfigServer.city[city.cid];
                        if(cityType.indexOf(parseInt(cfg.cityType))>-1){
                            if(mayor!=""){
                                if(city.mayor){
                                    if(city.mayor[0] == mayor){
                                        arr.push(city);
                                        break;
                                    }
                                }
                            }
                            else{
                                arr.push(city);
                            }
                        }
                    }
                    else{
                        arr.push(city);
                    }
                }
            }
            return arr;
        }
        /**
         * 是否是太守,返回 城市 cid
         */
        public static function isCityMayor(uid:String,country:int):String{
            var city:Object;
            var arr:Array = [];
            var cid:String = "";
            for(var key:String in cities)
            {
                city = cities[key];
                if(city.country == country){
                    if(!Tools.isNullObj(city.mayor)){
                        if(city.mayor[0] == parseInt(uid)){
                            cid = city.cid;
                            break;
                        }
                    }
                }
            }
            return cid;
        }
        /**
         * 城市名称
         */
        public static function getCityName(cid:String):String{//
            if(Tools.isNullString(cid))
                return "";
            
			if (cid == 'captain')
				cid = ModelUser.getCaptainID(ModelUser.getCountryID()).toString();
            return Tools.getMsgById(getCityCfg(cid).name);
        }
        /**
         * 城市类型名称
         */        
        public static function getCityType(cid:String):String{//
            return Tools.getMsgById("cityType"+getCityCfg(cid).cityType);
        }        
        /**
         * 城市配置
         */
        public static function getCityCfg(cid:*):Object{//
            return ConfigServer.city[cid+""];
        }
        /**
         * [信仰过,驻军,鼓舞等级,加速等级]
         */
        public static function getCityFaith(cid:*):Array{//
            return getCityCfg(cid)["faith"];
        }        
        /**
         * 太守
         */
        public static function getCityMayor(cid:*):Array{//
            return cities[cid]["mayor"];
        }        
        /**
         * 城市 转到 国家的资源
         */
        public static function getCityStoreToCountry(cid:String):Array{
            var cfg:Object = getCityCfg(cid);
            var ctcfg:Object = ConfigServer.world.cityType[cfg.cityType];
            var sArr:Array = ["coin","gold","food"];
            var index:int = -1;
            var pArr:Array = [0,0,0];
            for(var key:String in ctcfg)
            {
                index = sArr.indexOf(key);
                if(index>-1){
                    pArr[index] = ctcfg[key][0]+ModelCityBuild.getResouceByCity(cid,key);//+ctcfg[key][0]*0;
                }
            }
            return pArr;
        }
        /**
         * 国库 到下一个秋天的 收获
         */
        public static function getStoreToSeason(arr:Array):Array{
            var len:int = arr.length;
            
            var passTime:Number = Math.floor((ModelClimb.getChampionStarTime(true).getTime()- ConfigServer.getServerTimer())*0.001/60/60);
            for(var i:int = 0; i < len; i++)
            {
                arr[i] = arr[i]*passTime;
            }
            return arr;
        }
        private static const country_store_types:Array = ["coin","gold","food"];
        /**
         * 国库 类型的 封赏时间
         */
        public static function getStoreTimes(type:String):Array{
            var index:int = country_store_types.indexOf(type);
            var arr:Array = countries[ModelUser.getCountryID()]["grant_number"];
            var len:int = arr.length;
            var da:Array;
            for(var i:int = 0; i < len; i++)
            {
                if(index == i){
                    da = arr[i];
                    break;
                }
            }
            var preTime:Number = Tools.isNullObj(da[0])?0:Tools.getTimeStamp(da[0]);
            var isNewD:Boolean = false;
            if(preTime>0){
                isNewD = Tools.isNewDay(preTime);
            } 
            else{
                isNewD = true;
            }           
            var max:Number = ConfigServer.country.warehouse.grant_second;
            var curr:Number = (isNewD)?0:da[1];
            return [da[0],curr];
        }
        /**
         * 国库,类型数量
         */ 
        public static function getStoreNum(type:String):Array{
            var index:int = country_store_types.indexOf(type);
            var arr:Array = ConfigServer.country.warehouse["grant_number"];
            var len:int = arr.length;
            var da:Array;
            for(var i:int = 0; i < len; i++)
            {
                if(index == i){
                    da = arr[i];
                    break;
                }
            }
            return da;
        }        
        /**
         * 官职 名称
         * otherInvade = 当前天下大势
         * countryID = 国家ID
         */ 
        public static function getOfficerName(id:*, otherInvade:int = -1, country:* = ""):String{
            if(id === -100){
                return "";
            }
			else if (id < 0){
				return Tools.getMsgById('troopOfficial' + id);
			}
            var cid:int = ModelUser.getCountryID(country);
            var cfg:Object = getOfficerCfg(id);
            var arr:Array = cfg["name"];
            var str:String = "";
            var invade:int = (otherInvade>-1)?otherInvade:getInvade(cid);//getInvadeAwardMax();
            //
            if(invade>0 && arr[invade-1]){
                str = Tools.getMsgById(arr[invade-1][1],[ModelUser.country_name[cid]]);
            }
            else{
                str = Tools.getMsgById(arr[0][1],[ModelUser.country_name[cid]]);
            }
            return str;
        }
		 /**
         * 官职 颜色等级
         * countryID = 国家ID
         * otherInvade = 当前天下大势
         */ 
        public static function getOfficerColorLevel(id:*, otherInvade:int = -1):int{
			var level:int = 0;
			if (id == -1){
				level = 1;
			}
			else if (id == -2){
				level = 2;
			}
			else{
				var cfg:Object = ModelOfficial.getOfficerCfg(id);
				if(cfg){
					level = Math.floor(cfg.level / 25);
					otherInvade = (otherInvade>-1)?otherInvade:getInvade();//getInvadeAwardMax();
					if (otherInvade >= 5){
						level += 1;
					}
				}
			}
            return level;
        }
        /**
         * 官职 信息
         */          
        public static function getOfficerInfo(id:*):String{
            var cfg:Object = getOfficerCfg(id);
            var str:String = cfg["info"]
            return  Tools.getMsgById(str);
        } 
        /**
         * 官职 条件   0任何人，1只有军团长，2拿下第一座都城后
         */        
        public static function getOfficerCondition(id:*):String{
            var cfg:Object = getOfficerCfg(id);
            var arr:Array = cfg["tenure_condition"];
            var str:String = Tools.getMsgById(arr[1]);
            return str;
        }                
        /**
         * 官职 解锁
         */
        public static function checkOfficerIsOpen(id:*):Boolean{
            var cfg:Object = getOfficerCfg(id);
            var invade:int = getInvadeAwardMax();
            return (invade >= parseInt(cfg["Unlock"]));
        }
        /**
         * 官职 解锁 大势阶段
         */
        public static function getOfficerInvade(id:int):int{
            var cfg:Object = getOfficerCfg(id);
            return cfg["Unlock"];
        }   
        /**
         * 所有官职 排序
         */             
        public static function getOfficerAll():Array{
            var arr:Array = [];
            var obj:Object;
            var ni:int = -1;
            for(var key:String in ConfigServer.country.Official)
            {
                ni = key.indexOf("minister");
                if(ni>-1){
                    obj = ConfigServer.country.Official[key];
                    obj["sortIndex"] = parseInt(key.substring(ni,key.length));
                    arr.push(obj);
                }
                
            }
            arr.sort(MathUtil.sortByKey("sortIndex"));
            return arr;
        }
        /**
         * 某个 官职 配置
         */
        public static function getOfficerCfg(id:*):Object{
            return ConfigServer.country.Official["minister"+id];
        }

        /**
         * 返回某个uid的官职名称
         */
        public static function getOfficerNameByID(uid:*):String{
            var arr:Array=getMyCountryCfg()["official"];
            for(var i:int=0;i<arr.length;i++){
                if(arr[i] && uid+""==arr[i][0]+""){
                    return getOfficerName(i);
                }
            }
            return "";
        }

        /**
         * 返回我自己的官职ID
         */
        public static function getMyOfficerId():Number{
            var arr:Array=getMyCountryCfg()["official"];
            for(var i:int=0;i<arr.length;i++){
                if(arr[i] && ModelManager.instance.modelUser.mUID==arr[i][0]+""){
                    return i;
                }
            }
            return -100;
        }

        //----------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------
        /**
         * 天下大势 Invade 的进度
         */
        public static function getInvade(countryID:* = ""):int{
			if (!ModelOfficial.cities){
				return -1;
            }
            var myCountry:int = ModelUser.getCountryID(countryID);
            var cfg:Object = ConfigServer.country.milepost[myCountry];

            var arr:Array = [];
            for(var key:String in cfg)
            {
                cfg[key]["index"] = key;
                arr.push(cfg[key]);
            }
            arr.sort(MathUtil.sortByKey("index",true));
            //
            var len:int = arr.length;
            var cCfg:Object;
            var tar:Array;
            var and:Boolean;
            var cid:String;
            
            var num:Number = -1;
            var max:Number = 0;
            var searchIndex:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                cCfg = getInvadeCfg(arr[i]["index"],myCountry);
                and = false;
                if(cCfg.hasOwnProperty("target_and")){
                    and = true;
                    if(cCfg["target_and"] is Array){
                        tar = cCfg["target_and"];
                    }
                    else{
                        tar = [cCfg["target_and"]];
                    }
                }
                else{
                    if(cCfg["target_or"] is Array){
                        tar = cCfg["target_or"];
                    }
                    else{
                        tar = [cCfg["target_or"]];
                    }                    
                }
                
                
                if(and){
                    num = 0;
                    max = tar.length;
                }
                else{
                    num = 0;
                    max = 1;
                }
                for(var j:int = 0; j < tar.length; j++)
                {
                    cid = tar[j];
                    if(!Tools.isNullString(cid)){
                        cid = cid.replace("c_","");
                        if(cid=="-1"){
                            var md:ModelCountryPvp=ModelManager.instance.modelCountryPvp;
                            if(ModelOfficial.xyz_victor_country!=null && ModelOfficial.xyz_victor_country==myCountry){
                                return parseInt(arr[i]["index"]);
                            }
                        }else{
                            if(cities.hasOwnProperty(cid)){
                                if(cities[cid].country == myCountry){
                                    num+=1;
                                }
                            }
                        }
                        
                    }
                    if(num>=max){
                        searchIndex = i;
                        break;
                    }
                }
                if(searchIndex>-1){
                    break;
                }
            }
            var re:int = (searchIndex>-1)?parseInt(arr[searchIndex]["index"]):0;
            return re;
        }
        /**
         * 国家大势 配置
         */
        public static function getInvadeCfg(id:*,countryID:*=""):Object{
            var cfg:Object = ConfigServer.country.milepost[ModelUser.getCountryID(countryID)];
            return cfg[id+""];
        }
        /**
         * 国家大势 最高进度
         */
        public static function getInvadeAwardMax():int{
			if (!countries || !ModelManager.instance.modelUser){
				return 1;
			}
            return ModelOfficial.getMyCountryCfg()["max_milepost"];
        }
        /**
         * 国家大势 解锁 , 说明 或 cid (id=1到5)
         */
        public static function getInvadeUnlock(id:*,getCid:Boolean = false):Array{
            var cfg:Object = getInvadeCfg(id);
            var and:Boolean = cfg.hasOwnProperty("target_and");
            var arr:Array;
            var i:int = 0;
            var len:int = 0;
            var str:String = "";
            var key:String = and?"target_and":"target_or";
            var cityArr:Array = [];
            if(cfg[key] is Array){
                arr = cfg[key];
                len = arr.length;
                for(i = 0; i < len; i++)
                {
                    str +=Tools.getMsgById(arr[i]) + (i<(len-1)?(and?Tools.getMsgById("_public181"):Tools.getMsgById("_public182")):"")// (i<(len-1)?(and?" 和 ":" 或 "):"");   
                    if(arr[i]!=""){
                        cityArr.push(arr[i]);
                    }
                }
            }
            else{
                str = Tools.getMsgById(cfg[key]);
                if(cfg[key]!=""){
                    cityArr.push(cfg[key]);
                }
            }
            return [str,cityArr];
        }
        public static var buffs_dic:Object = {};
        public static var buffs_check_open:Boolean = false;
        /**
         * 检查 命令 buff 的状态
         */
        public static function checkOrderBuffs():Boolean{
            if(!buffs_check_open){
                return false;
            }
            var reData:Object = {};
            var cobj:Object = getMyCountryCfg(ModelUser.getCountryID());
            var buffs:Object;
            var key:String;
            var status:Number = 0;
            //
            if(cobj.hasOwnProperty("buffs")){
                buffs = cobj["buffs"];
                if(buffs){
                    if(checkOrderBuffsStatus(buffs)){
                        status+=1;
                    }
                }
            }

            var countryArmy:Array = ModelTask.country_army_arr;
            if(countryArmy.length != 0){
                if(!buffs_dic["country_army"]){
                    status+=1;
                    buffs_dic["country_army"]=1;
                }
            }else{
                if(buffs_dic["country_army"]){
                    status+=1;
                    delete buffs_dic[key];
                }
            }

            var b:Boolean = ModelFightTask.instance.buff.length != 0;
            if(b && !buffs_dic["task_buff"]){
                status+=1;
                buffs_dic["task_buff"]=1;
            }else{
                if(buffs_dic["task_buff"]){
                    status+=1;
                    delete buffs_dic[key];
                }
            }
            /*
            var guild:String = ModelManager.instance.modelUser.guild_id;
            // "buff_corps",
            if(guild){
                var user:Array;
                var isHadMayor:String = "";
                for(key in ModelManager.instance.modelGuild.u_dict){
                    user = ModelManager.instance.modelGuild.u_dict[key];
                    if(user[4]==1){
                        isHadMayor = key;
                        break;
                    }
                }
                if(isHadMayor){
                    var myCitys:Array = getMyCities(ModelUser.getCountryID(),null,isHadMayor);
                    if(myCitys.length>0){
                        var cityData:Object = myCitys[0];
                        buffs = cityData["buffs"];
                        if(buffs){
                            if(checkOrderBuffsStatus(buffs)){
                                status+=1;
                            }                        
                        }
                    }
                }
            }*/
            return status>0;
        }
        public static function checkOrderBuffsStatus(buffs:Object):Boolean{
            var key:String;       
            var buff:Object;
            var now:Number = ConfigServer.getServerTimer();
            var isChange:Boolean = false;
            for(key in buffs){
                buff = buffs[key];
                if(buff){

                     //如果是buff5 且非我国  就跳过
                    if(key==ModelOfficial.BUFF_5 && buff[5]!=ModelManager.instance.modelUser.country){                
                        continue;
                    }
                    var st:Number = Tools.getTimeStamp(buff[2]);
                    var cfg:Object = ConfigServer.country[key];
                    var ent:Number = st+cfg.time*Tools.oneMinuteMilli;
                    if(buffs_dic[key]){
                        if(now>=ent){
                            isChange = true;
                            delete buffs_dic[key];
                        }else{
                            isChange = true;
                            buffs_dic[key] = buff;
                        }
                    }
                    else{
                        isChange = true;
                        if(now<ent){
                            buffs_dic[key] = buff;
                        }
                    }
                }
            } 

            //增加的补丁  主要是为了移除攻城令
            for(key in buffs_dic){
                buff = buffs_dic[key];
                if(buff){
                    if(!buffs[key]){
                        isChange = true;
                        delete buffs_dic[key];
                    }
                }
            }
            return isChange;           
        }
        public static function checkInvadeWill():Boolean{
            var len:int = getInvadeAwardMax();
            
            for(var i:int = 1; i <= len; i++)
            {
                var cfg:Object = getInvadeCfg(i);
                if(cfg.reward && cfg.reward.length>0 && (ModelManager.instance.modelUser.milepost_reward.indexOf(i) === -1)){
                    return true;
                }
            }
            return false;
        }
        /**
         * 检查一个城市是否有,攻城 / 守城 令
         * @return status == 0 =没有,1=攻城,2=守城
         */
        /*
        public static function checkBuffStatus(cid:*):Number{
            var status:Number = 0;
            if(ModelOfficial.countries){
                var country:Object = ModelOfficial.countries[ModelUser.getCountryID()];
                if(country.buffs){
                    for(var key:String in country.buffs)
                    {
                        if(key == "buff_country3" || key == "buff_country4"){
                            var st:Number = Tools.getTimeStamp(country.buffs[key][2]);
                            var cfg:Object = ConfigServer.country[key];
                            var ent:Number = st+cfg.time*Tools.oneMinuteMilli;  
                            var now:Number = ConfigServer.getServerTimer(); 
                            if(now<ent && Number(cid) == Number(country.buffs[key][0])){
                                if(key == "buff_country3"){
                                    status = 1;
                                }
                                else{
                                    status = 2;
                                }
                            }
                            break;
                        }
                    }
                }
            }
            return status;
        }*/

        /**
         * 检查有没有攻城令和守城令（给大地图用的）
         */
        public static function checkBuffStatus2(oid:String):String
        {
			if (oid.indexOf("buff_fight_task_") == 0) {
				return ModelFightTask.instance.cids_map[parseInt(oid.replace("buff_fight_task_", "")) - 1];
			}
			
            var arr:Array = get_country_order_data(oid,ModelUser.getCountryID());
            if(arr && arr[0]){
                var st:Number = Tools.getTimeStamp(arr[2]);
                var cfg:Object = ConfigServer.country[oid];
                var ent:Number = st+cfg.time*Tools.oneMinuteMilli;  
                var now:Number = ConfigServer.getServerTimer();    
                if(now<ent){              
                    return arr[0]+"";
                }
                else{
                    return null;
                }
            }
            return null;
        }

        /**
         * 国家今日的黄金收入
         */
        public static function getDayCoin():Number{
            var o:Object=ModelOfficial.getMyCountryCfg().day_coin;
            if(o && !Tools.isNewDay(o.time)){
                return o.num;
            }
            return 0;
        }

        /**
         * 
         */
        public static function getMayorCD(cid:String):Number{
            var o:*=ModelOfficial.cities[cid].mayor_cd;
            if(o){
                return Tools.getTimeStamp(o);
            }
            return 0;
        }
        /**
         * 获得召集CD
         */
        public function getCallCD(lv:Number):Number{
            var o:*=ModelOfficial.countries[Number(ModelManager.instance.modelUser.country)].call_cd;
            if(o && o[lv]){
                return Tools.getTimeStamp(o[lv]);
            }
            return 0;
        }

        /**
         * 更新召集CD
         */
        public function setCallCD(o:*):void{
            if(o){
                if(ModelOfficial.countries){
                    var oo:Object=ModelOfficial.countries[Number(ModelManager.instance.modelUser.country)];
                    if(oo){
                        oo.call_cd=o;
                        this.event(ModelOfficial.EVENT_UPDATE_ALIEN_CD);
                    }
                }
            }
        }
        
        /**
         * 获得我国所有的buff
         */
        public static function getMyCountryBuffs():Object{
            var o:Object=countries[ModelManager.instance.modelUser.country];
            if(o){
                return o.buffs;
            }
            return null;
        }

        /**
         * 获得本国所有太守令 和 都尉令 //这些都记在城市身上
         */
        public static function getAllMayorBuffs():Object{
            var o:Object={};
            o["country5"]={};
            o["corps"]={};
            for(var cid:String in ModelOfficial.cities){
                var obj:Object=ModelOfficial.cities[cid];
                if(obj.country == ModelManager.instance.modelUser.country && obj.buffs && obj.buffs.hasOwnProperty("buff_corps")){
                    o["corps"][cid]=obj.buffs.buff_corps;
                }
                if(obj.buffs && obj.buffs.hasOwnProperty(ModelOfficial.BUFF_5)){
                    if(obj.buffs[ModelOfficial.BUFF_5][5]==ModelManager.instance.modelUser.country){
                        o["country5"][cid]=obj.buffs.buff_country5;
                    }
                }
            } 
            return o;
        }
        /**
         * 查询该城市有没有国家令
         */
        public static function getBuffByCid(cid:String,bid:String):Array{
            var o:Object=ModelOfficial.cities[cid];
            if(o && o.buffs && o.buffs.hasOwnProperty(bid)){
                var a:Array=o.buffs[bid];
                var n:Number=Tools.getTimeStamp(a[2]) + ConfigServer.country[bid].time*Tools.oneMinuteMilli - ConfigServer.getServerTimer();
                if(n>0){
                    return a;
                }
            }
            return null;
        }

        /**
         * 返回有buff5的城市
         */
        public static function getBuff5Arr(_bid:String="buff_country5"):Array{
            var bid:String=_bid;//"buff_country5";//buff_corps
            var arr:Array=[];
            for(var s:String in ModelOfficial.cities){
                var o:Object=ModelOfficial.cities[s];
                if(o && o.buffs && o.buffs.hasOwnProperty(bid)){
                    var a:Array=o.buffs[bid];
                    var n:Number=0;//Tools.getTimeStamp(a[2]) + ConfigServer.country.buff_country5.time*Tools.oneMinuteMilli - ConfigServer.getServerTimer();
                    n=Tools.getTimeStamp(a[2]) + ConfigServer.country[_bid].time*Tools.oneMinuteMilli - ConfigServer.getServerTimer();
                    if(_bid==ModelOfficial.BUFF_CORPS){
                        if(o.country==ModelManager.instance.modelUser.country){
                            if(n>0) arr.push(s);
                        }
                    }else{
                        if(n>0) arr.push(s);
                            
                    }
                    
                }
            }
            //trace("========getBuff5Arr",bid,arr);
            return arr;
        }
        



        /**
         * 
         * 处理 city_mayor数据 
         * type 0初始化  1增加  2删除
         */
        public static function updateCityMayor(type:int, data:*):void{
			
            if(type==0){
                city_mayor={};
                var o:Object=ModelOfficial.cities;
                for(var s:String in o){
                    if(o[s].country==ModelUser.getCountryID() && o[s].mayor){
                        city_mayor[s]=o[s].mayor[0];
                    }
                }
            }else if(type==1){
                city_mayor[data.cid] = data.data[0];
				
				if(data.cid) ModelManager.instance.modelGame.event(ModelGame.EVENT_MAYOR_UDPATE, [data.cid]);				
				if(data.cid2) ModelManager.instance.modelGame.event(ModelGame.EVENT_MAYOR_UDPATE, [data.cid2]);
            }else if(type==2){
                if(city_mayor.hasOwnProperty(data.city.cid)){
                    if(data.city.country!=ModelUser.getCountryID()){
                        delete city_mayor[data.city.cid];
                        //trace("城市被攻占，移除这个城市的太守");
						ModelManager.instance.modelGame.event(ModelGame.EVENT_MAYOR_UDPATE, [data.city.cid]);
                    }
                }
            }
			
        }

        /**
         * 通过uid查太守cid
         */
        public static function getMayorByUID(uid:*):String{
            for(var s:String in ModelOfficial.city_mayor){
                if(ModelOfficial.city_mayor[s]+"" == uid+""){
                    return s;
                }
            }
            return "";
        }

        /**
         * 是否太守或者官员（国家栋梁）
         */
        public static function isMayorOrOfficer(uid:String):Boolean{
            if(ModelOfficial.getMayorByUID(uid)!=""){
                return true;
            }
            if(ModelOfficial.getUserOfficer(uid)>=0){
                return true;
            }
            return false;
        }

        /**
         * 初始化cityOrder
         */
        public static function initCityOrder():void{
            for(var s:String in ModelOfficial.cities){
                var arrBuff5:Array = ModelOfficial.getBuffByCid(s,ModelOfficial.BUFF_5);
                if(arrBuff5){
                    ModelOfficial.city_order[ModelOfficial.BUFF_5+"_"+s] = new cityOrder(ModelOfficial.BUFF_5,arrBuff5);
                }

                var arrBuffCorps:Array = ModelOfficial.getBuffByCid(s,ModelOfficial.BUFF_CORPS);
                if(arrBuffCorps){
                    ModelOfficial.city_order[ModelOfficial.BUFF_CORPS+"_"+s] = new cityOrder(ModelOfficial.BUFF_CORPS,arrBuffCorps);
                }
            }

            var buffs:Object=getMyCountryBuffs();
            for(var ss:String in buffs){
                if(ss==ModelOfficial.BUFF_3 || ss==ModelOfficial.BUFF_4){
                    ModelOfficial.city_order[ss] = new cityOrder(ss,buffs[ss]);
                }
            }

            //trace("=======================",ModelOfficial.city_order);
        }

        /**
         * 弹劾状态
         */
        public static function getImpeachStatus():Number{
            var _status:Number=0;//0 可弹劾  1 可投票  2 已投票  3 可查看  4 国王保护期  5 失败cd   6 个人cd
            var now:Number=ConfigServer.getServerTimer();
            var cfg:Object=ConfigServer.country.impeach;
            var imp:Object=impeach;
            var kt:Number=king_time;
            
            if(kt!=0 && kt+cfg.cd1*Tools.oneMinuteMilli>now){//国王保护期内
                _status=4;
            }else{
                if(imp){
                    var st:Number=Tools.getTimeStamp(imp.start);
                    var b:Boolean=false;
                    if(now-st<cfg.continued*Tools.oneMinuteMilli){//投票有效期内
                        if(imp.is_over){
                            //_status=0;
                            b=true;
                        }else{
                            if(imp.vote_users.hasOwnProperty(ModelManager.instance.modelUser.mUID)){
                                if(imp.vote_users[ModelManager.instance.modelUser.mUID]){
                                    _status=2;
                                }else{
                                    _status=1;
                                }
                            }else{
                                _status=3;
                            }
                        }
                        
                    }else{
                        b=true;
                    }
                    if(b){
                        var ut:Number=Tools.getTimeStamp(ModelManager.instance.modelUser.impeach_time);
                        //个人cd
                        if(now-ut<cfg.cd3*Tools.oneMinuteMilli){
                            _status=6;
                        }else{
                            var ft:Number=impeach_fail_time;
                            //弹劾失败之后的cd2时间内无法再弹劾
                            if(ft!=0 && now-ft<cfg.cd2*Tools.oneMinuteMilli){
                                _status=5;
                            }else{
                                _status=0;        
                            }
                        }
                    }
                }else{
                    _status=0;
                }
            }

            return _status;
        }

        /**
         * 获得城市开战时间字符串
         */
        //public static function getFightTimeStr(ct:Number):String{
            //if(ConfigServer.world.cityType[ct]){
                //var cfg:*=ConfigServer.world.cityType[ct].fightTime;
                //if(cfg==0){//不可攻打
                    //return Tools.getMsgById("_city_fighttime3");
                //}else if(cfg==-1){//襄阳战期间才能打
                    //return Tools.getMsgById("_city_fighttime4");
                //}else if(cfg==1){//任意时间可以打
                    //return Tools.getMsgById("_city_fighttime2");
                //}else{
                    //var arr:Array=cfg as Array;
                    //var s:String="";
                    //for(var i:int=0;i<arr.length;i++){
                        //var a:Array=arr[i];
                        //var ss:String=i==arr.length-1?"":"  ";
                        //s+=a[0]+":"+(a[1]<9 ? "0"+a[1] : a[1])+"~"+a[2]+":"+(a[3]<9 ? "0"+a[3] : a[3])+ss;
                    //}
                    //return Tools.getMsgById("_city_fighttime1",[s]);
                //}
            //}
            //return "";
//
        //}

        /**
         * 获得进贡的数额
         */
        public static function getTributeNum(key:String):Number{
            var n:Number=0;
            if(key == "food" || key == "gold"){
                if(xyz_victor_country==ModelManager.instance.modelUser.country){
                    for(var i:int=0;i<3;i++){
                        if(countries[i].tid!=ModelManager.instance.modelUser.country){
                            n+=countries[i][key]*ConfigServer.country.warehouse.tribute[2];
                        }
                    }
                }
            }
            return n;
        }
    }   
}

import sg.utils.Tools;
import sg.cfg.ConfigServer;
import sg.model.ModelOfficial;
import sg.manager.ModelManager;
import sg.model.ModelGame;

class cityOrder//给大地图用的数据
{
    private var mKey:String;
    private var mData:Array;
    private var mCid:*;
    public function cityOrder(key:String,data:Array)
    {
        this.update(key,data);
        //
        this.notice();
    }
    public function timerEnd():void{
        var s:String=this.mKey;
        if(this.mKey==ModelOfficial.BUFF_5 || this.mKey==ModelOfficial.BUFF_CORPS){
            s=s+"_"+this.mCid;
        }
        if(ModelOfficial.city_order[s]){
            delete ModelOfficial.city_order[s];
            this.notice();
        }
        // trace("===timeEnd",s);
        this.clear();
    }
    private function notice():void{
        // trace("===notice",this.mKey);
        if(this.mKey==ModelOfficial.BUFF_5){
            if(this.mCid){
                //ModelOfficial.getBuff5Arr();
                ModelManager.instance.modelGame.event(ModelGame.EVENT_BUFFS_ORDER_5_CHANGE);
            }
        }else if(this.mKey=="buff_corps"){
            if(this.mCid){
                //ModelOfficial.getBuff5Arr("buff_corps");
                ModelManager.instance.modelGame.event(ModelGame.EVENT_BUFFS_ORDER_CORPS_CHANGE);
            }
        }else{
            if(this.mCid){
                ModelManager.instance.modelGame.event(ModelGame.EVENT_BUFFS_ORDER_3_4_CHANGE,this.mCid);
            } 
        }
    }
    private function clear():void
    {
        Laya.timer.clear(this,this.timerEnd);
        this.mKey = "";
        this.mData = null;
        this.mCid = null;
    }
    public function update(key:String,data:Array):void{
        this.clear();
        this.mKey = key;
        this.mData = data;
        //
        if(data && data[0]){
            var st:Number = Tools.getTimeStamp(data[2]);
            var cfg:Object = ConfigServer.country[key];
            var ent:Number = st+cfg.time*Tools.oneMinuteMilli;  
            var now:Number = ConfigServer.getServerTimer();  
            var des:Number = ent-now;     
            this.mCid = data[0];
            if(des>=0){
                Laya.timer.once(des,this,this.timerEnd);
            }
            else{
                this.timerEnd();
            }
        }
    }
}