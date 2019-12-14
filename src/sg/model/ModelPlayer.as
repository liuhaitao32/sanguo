package sg.model
{
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.cfg.ConfigApp;
    import laya.maths.MathUtil;
    import sg.manager.ModelManager;
    import sg.map.utils.ArrayUtils;
    import laya.utils.Handler;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;

    public class ModelPlayer extends ModelBase
    {
        public static const EVENT_LOGIN_OK:String = "event_login_ok";
        public static const TEMP_UID_KEY_VALUE:String = "ready";
        private static var mModelPlayer:ModelPlayer;
        public var mPlayer:Object;
        public var mPlayerList:Object;
        public var isTempPlayer:Boolean;
        public var mCurrZone:String = "";
        public var mTel:String = "";
        public var loginName:String = "";
        public var loginPwd:String = "";
        public static var recommendServer:String = "";
        public static var userData:Object;
        public static var userListData:Object;
        public function ModelPlayer()
        {
            
        }
        public  static function get instance():ModelPlayer{
			return mModelPlayer ||= new ModelPlayer();
		}
        public function updateAll(isInit:Boolean = false):void{
            //
            this.mPlayer = SaveLocal.getValue(SaveLocal.KEY_USER);
            this.mPlayerList = SaveLocal.getValue(SaveLocal.KEY_USER_LIST);
            this.isTempPlayer = true;
            if(Tools.isNullObj(this.mPlayer)){
                if(ModelPlayer.userData){
                    this.mPlayer = ModelPlayer.userData;
                }
                else{
                    this.mPlayer = {};
                    this.isTempPlayer =false;
                }
            }
            else{
                if(ConfigApp.isTest){
                    if(Tools.isNullString(this.getUID())){
                        this.isTempPlayer =false;
                    }
                }
                else{
                    //自己的登录,没有用户名和密码
                    if(ConfigApp.useMyLogin() && (Tools.isNullString(this.getName()) || Tools.isNullString(this.getPWD()))){
                        this.isTempPlayer =false;//不存在缓存
                    }                    
                }
            }
            if(Tools.isNullObj(this.mPlayerList)){
                if(ModelPlayer.userListData){
                    this.mPlayerList = ModelPlayer.userListData;
                }else{
                    this.mPlayerList = {};
                }
                
            }
            //
            if(isInit){
                this.clearReadyTemp();
            }
        }
        public function clearReadyTemp():void{
            if(this.mPlayerList && this.mPlayerList.hasOwnProperty(ModelPlayer.TEMP_UID_KEY_VALUE)){
                delete this.mPlayerList[ModelPlayer.TEMP_UID_KEY_VALUE];
            }
            if(this.mPlayerList && this.mPlayer["uid"] && this.mPlayer["uid"] == ModelPlayer.TEMP_UID_KEY_VALUE){
                this.mPlayer = {};
            }
        }
        public function clearUser():void{
            this.savePlayerAll();
        }
        private function changeAll():void{
            this.savePlayerAll();
            this.updateAll();
            // trace(this.mPlayer,this.mPlayerList);
        }
        public function savePlayerAll():void{
            SaveLocal.save(SaveLocal.KEY_USER,this.mPlayer);
            SaveLocal.save(SaveLocal.KEY_USER_LIST,this.mPlayerList);
            //
            Platform.setUserDataForIos({"player":this.mPlayer,"list":this.mPlayerList});
        }
        public function getAutoLogin():Boolean{
            var obj:Object = SaveLocal.getValue("sg_auto_login");
            var sg_auto_login:String = Tools.isNullObj(obj)?"":(obj+"");
            sg_auto_login = (sg_auto_login=="")?"1":sg_auto_login;
            return (sg_auto_login == "1");
        } 
        public function isNullAutoLogin():Boolean{
            var obj:Object = SaveLocal.getValue("sg_auto_login");
            return Tools.isNullObj(obj);
        }
        public function setAutoLogin(b:Boolean):void{
            SaveLocal.save("sg_auto_login",b?"1":"0");
        }               
        public function getPlayer():Object{
            return this.mPlayer;
        }
        //
        public function setUID(uid:String):void{
            if(!this.mPlayerList.hasOwnProperty(uid)){
                if(this.mPlayerList.hasOwnProperty(ModelPlayer.TEMP_UID_KEY_VALUE)){
                    this.mPlayer = this.mPlayerList[ModelPlayer.TEMP_UID_KEY_VALUE];
                }
                else{
                    this.mPlayer = {};
                }
            }
            else{
                this.mPlayer = this.mPlayerList[uid];
            }
            this.mPlayer["uid"] = uid;
            //
            this.changeAll();
        }
        public function getUID():String{
            return this.mPlayer.hasOwnProperty("uid")?this.mPlayer["uid"]:"";
        }
        //  
        public function setServerZones(szs:String):void{
            if(szs.charAt(0) == "|"){
                szs = szs.substr(1,szs.length);
            }
            this.mPlayer["szs"] = szs;
            this.changeAll();
        } 
        public function getServerZones():String{
            return this.mPlayer.hasOwnProperty("szs")?this.mPlayer["szs"]:"";
        }     
        // 
        public function setSessionid(sid:String):void{
            this.mPlayer["sessionid"] = sid;
            this.changeAll();
        }                
        public function getSessionid():String{
            return this.mPlayer.hasOwnProperty("sessionid")?this.mPlayer["sessionid"]:"";
        }  
        //  
        public function setName(un:String):void{
            this.mPlayer["name"] = un;
            this.changeAll();
        }                 

        public function getName():String{
            return this.mPlayer.hasOwnProperty("name")?this.mPlayer["name"]:"";
        }
        //  
        public function setPhone(un:String):void{
            this.mPlayer["phone"] = un;
            this.changeAll();
        }
        public function getPhone():String{
            return this.mPlayer.hasOwnProperty("phone")?this.mPlayer["phone"]:"";
        }
        public function setPhoneCode(un:String):void{
            this.mPlayer["phoneCode"] = un;
            this.changeAll();
        }
        public function getPhoneCode():String{
            return this.mPlayer.hasOwnProperty("phoneCode")?this.mPlayer["phoneCode"]:"";
        }
        public function setPWD(pwd:String):void{
            this.mPlayer["pwd"] = pwd;
            this.changeAll();
        }  
        public function setPWDs(pwds:String):void{
            this.mPlayer["pwd_s"] = pwds;
            this.changeAll();
        } 
        public function getPWD():String{
            if(this.mPlayer["pwd"]){
                return this.mPlayer["pwd"];
            }
            else if(this.mPlayer["pwd_s"]){
                return this.mPlayer["pwd_s"];
            }
            else{
                return "";
            }
            // return this.mPlayer.hasOwnProperty("pwd")?(this.mPlayer["pwd"]?this.mPlayer["pwd"]:(this.mPlayer.hasOwnProperty("pwd_s")?this.mPlayer["pwd_s"]:"")):"";
        } 
        //  
        public function setZone(z:String):void{
            this.mPlayer["z"] = z;
            this.changeAll();
        }                    
        public function getZone():String{
            return this.mPlayer.hasOwnProperty("z")?this.mPlayer["z"]:"";
        } 
        //
        public function getZoneList():Object{
            return this.mPlayer.hasOwnProperty("zs")?this.mPlayer["zs"]:{};
        } 
        public function setZoneList():void{
            var myZones:Object = this.getZoneList();
            //
            if(myZones.hasOwnProperty(this.getCurrZone())){
                myZones[this.getCurrZone()] += 1;
            }
            else{
                myZones[this.getCurrZone()] = 1;
            }
            this.mPlayer["zs"] = myZones;
            this.changeAll();           
        }  
        public function setPlayerList():void{
            this.mPlayer["times"] = ConfigServer.getServerTimer();
            this.mPlayerList[this.getUID()] = this.mPlayer;
            this.changeAll();
        } 
        public function setPlayerCardID(cid:String):void{
            this.mPlayer["ucid"] = cid;
            this.changeAll();
        }  
        public function getPlayerCardID():String{
            return this.mPlayer.hasOwnProperty("ucid")?this.mPlayer["ucid"]:"";
        }           
        //      
        public function setCurrZone(zone:*):void{
            this.mCurrZone = zone+"";
            this.setZone(this.mCurrZone);
        }
        public function getCurrZone():String{
            if(Tools.isNullString(this.mCurrZone)){
                var zs:String = this.getZone();
                if(zs!=""){
                    if(ConfigServer.zone.hasOwnProperty(zs) && ConfigServer.checkZonePfIsOK(zs)){
                        return zs;
                    }
                }
                //下面是推荐服务器,根据规则
                var zArrAll:Array = [];
                var zcfg:Array;
                var now:Number = ConfigServer.getServerTimer();
                var su:Number = 0;
                var index:String = "";
                var ms:Number = 0;
                var registEndTime:Number = -1;
                var registB:Number = 0;
                var sortVal:Number = 0;
                var opend:Number = 1;
                var zoneNumCfg:Object = ModelManager.instance.modelUser.zones_user_num;
                var zoneNums:Number = -999999;
                for(var key:String in ConfigServer.zone)
                {
                    if(!ConfigServer.checkZonePfIsOK(key)){
                        continue;
                    }
                    zcfg = ConfigServer.zone[key];
                    if(zcfg[5]!=0){
                        continue;
                    }
                    ms = Tools.getTimeStamp(zcfg[2]);
                    opend = 0;
                    sortVal = 0;
                    registB = 0;
                    registEndTime = -1;
                    zoneNums = -999999;
                    if(zcfg[3] == 1){
                        if(zcfg[7]!=""){
                            registB = 0;
                        }
                        else{
                            registB = 1;
                        }
                    }
                    else{
                        registEndTime = Tools.getTimeStamp(zcfg[2])+ConfigServer.getForbidNewTime();
                        if(now<registEndTime){
                            if(zcfg[7]!=""){
                                registB = 0;
                            }
                            else{
                                registB = 1;
                            }
                        }
                        else{
                            registB = 0;
                        }
                    }
                    if(now>=ms){
                        opend = 2;
                    }
                    if(registB==1){
                        sortVal = Number(opend +"" +zcfg[6]+""+ ms);
                    }
                    if(zoneNumCfg && zoneNumCfg[key] && zoneNumCfg[key]>-1){
                        zoneNums = Math.abs(Number(zoneNumCfg[key]))*-1;
                    }
                    zArrAll.push({nums:zoneNums,sortIndex:sortVal,id:key,tms:ms,regist:registB,force:zcfg[6]});
                }
                // zArrAll.sort(MathUtil.sortByKey("sortIndex",true));
                if(zArrAll && zArrAll.length>0){
                    ArrayUtils.sortOn(["nums","sortIndex"],zArrAll,true);
                    index = zArrAll[0].id;
                    //推荐出来的服务器id
                    return index;
                }
                else{
                    return "";
                }
            }
            return this.mCurrZone;
        }    

        public function set tel(data:*):void{
            mTel=data+""
        }
        public function get tel():String{
            return mTel;
        }
        public function getVisitorData(apf:String,callback:Handler):void{
            var temp:Object = SaveLocal.getValue(SaveLocal.KEY_VISITOR_USER_DATA);
            if(temp){
                if(callback){
                    callback.runWith([0,temp]);
                }
            }
            else{
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER_FAST,{pf:apf},Handler.create(null,function(re:*):void{
                    temp = {uid:re.username,token:re.pwd,login_type:Platform.TAG_LOGIN_TYPE_MENG52};
                    Trackingio.postReport(3,re);
                    SaveLocal.save(SaveLocal.KEY_VISITOR_USER_DATA,temp);
                    if(callback){
                        callback.runWith([0,temp]);
                    }
                }));
            }
        }
        public function getVisitorDataTemp(apf:String,callback:Handler):void{
            var temp:Object = {uid:ModelPlayer.instance.loginName,token:ModelPlayer.instance.loginPwd,login_type:Platform.TAG_LOGIN_TYPE_TUP};
            if(callback){
                callback.runWith([0,temp]);
            }
        }
    }
}