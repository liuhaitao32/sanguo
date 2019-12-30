package sg.model
{
    import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.map.utils.TestUtils;
    import ui.inside.pubItemUI;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.maths.MathUtil;
    import sg.cfg.ConfigColor;
    import sg.utils.StringUtil;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;
    import laya.utils.Browser;

    public class ModelEquip extends ModelBase{

        public var id:String;
        public var name:String;
        public var info:String;
        public var index:Number;
        public var type:int;//安装类型
        public var make_time:Number;
        public var icon:String;
        public var upgrade:Object;
        public var make_item:Object;
        public var lvMax:Number = -1;
        public var special:String="";
        public var back:String="";
        public function get wash():Array{
            if(this.isMine()){
                return ModelManager.instance.modelUser.equip[this.id].wash;
            }
            return [];
        };

        public function get wash_reset():Object{
            if(this.isMine()){
                return ModelManager.instance.modelUser.equip[this.id].wash_reset;
            }
            return {};
        };

        public function get wash_temp():Array{
            if(this.isMine()){
                return ModelManager.instance.modelUser.equip[this.id].wash_temp;
            }
            return [];
        };


        public static const equip_type_name:Array = [
            Tools.getMsgById("_public154"),Tools.getMsgById("_public155"),Tools.getMsgById("_public156"),
            Tools.getMsgById("_public157"),Tools.getMsgById("_public158"),Tools.getMsgById("_public159")];
        public static const equip_type_name_tab:Array = [
            Tools.getMsgById("_public154"),Tools.getMsgById("_public155"),Tools.getMsgById("_public157"),
            Tools.getMsgById("_public156"),Tools.getMsgById("_public158"),Tools.getMsgById("_public159")];    

        //珍宝阁的tab
        public static const equipDataArr:Array = [
                        {"type":0,"icon0":"icon_smithing1.png","icon1":"icon_smithing1_1.png","text":Tools.getMsgById("_public154")},
                        {"type":1,"icon0":"icon_smithing2.png","icon1":"icon_smithing1_2.png","text":Tools.getMsgById("_public155")},
                        {"type":3,"icon0":"icon_smithing3.png","icon1":"icon_smithing1_3.png","text":Tools.getMsgById("_public157")},
                        {"type":2,"icon0":"icon_smithing4.png","icon1":"icon_smithing1_4.png","text":Tools.getMsgById("_public156")},
                        {"type":4,"icon0":"icon_smithing5.png","icon1":"icon_smithing1_5.png","text":Tools.getMsgById("_public158")},
                        {"type":5,"icon0":"icon_smithing6.png","icon1":"icon_smithing1_6.png","text":Tools.getMsgById("_public159")}];
               
        //
        public static var equipModels:Object = {};
        //
        public function ModelEquip():void{
            this.mClassType = 2;
        }
        public function initData(key:String,obj:Object):void{
            this.id = key;
			for(var m:String in obj)
			{
				if(this.hasOwnProperty(m)){
					this[m] = obj[m];
				}
			}
        }
        public static function getConfig(key:String):Object{
            return ConfigServer.equip[key];
        }
        //
        public function isUpgradeIng():int{
            var type:int = -1;
            var b:Boolean = this.isInQueue();
            if(b){
                if(this.isMine()){
                    type = 1;//升级
                }else{
                    type = 0;//锻造
                }
            }
            return type;
        }
        public function getName(canTest:Boolean = false):String{
			var name:String = Tools.getMsgById(this.name);
            name += this.getEnhanceLv()==0 ? "" : "+"+this.getEnhanceLv();
			if (canTest && TestUtils.isTestShow){
				//name += ' ' +this.getLvInfo(0) + ' ';
                name += this.id;
                
			}
            return name;
        }
        
        public function getTypeName():String{
            return equip_type_name[this.type];
        }
		public function getGroup():String{
			var cfg:Object = getConfig(this.id);
            return cfg?cfg.group:'';
        }
		public function getGroupName():String{
            return getGroupEquipName(this.getGroup());
        }
		static public function getGroupEquipName(group:String):String{
            return Tools.getMsgById('group'+group);
        }
		static public function getGroupEquipName2(group:String):String{
            return Tools.getMsgById('_equip37',[Tools.getMsgById('group'+group)]);
        }
		
		/**
         * 得到某级别的属性描述
         */
		public function getLvInfo(lv:int):String{
			var str:String = Tools.getMsgById("_public160");//'无属性';
			if (this.upgrade && this.upgrade[lv])
			{
				var lvObj:Object = this.upgrade[lv];
				str = '';
				if (lvObj.army_go){
					//移动速度
					str += Tools.getMsgById('army_go',[Tools.percentFormat(lvObj.army_go)]);
				}
				if (lvObj.passive){
					//战斗数值
					var temp:String = PassiveStrUtils.translatePassiveInfo(lvObj.passive, false, false, 1);
					if (temp){
						if (str){
							str += Tools.getMsgById('rslt_connect0');
						}
						str += temp;
					}
				}
			}
            return str;
        }
		
		
        public function getInfo():String{
            return Tools.getMsgById(this.info);
        }      
        /**
         * 属性,文字信息
         */
        public function getAttrInfo(clv:*):String
        {
            //if(this.upgrade.hasOwnProperty(clv+"")){
                //var str:String = this.getLvInfo(clv);
                ////var str1:String = "属性宝物属性宝物属性宝物属性";
                //return str;
            //}
            return this.getLvInfo(clv);
        }          
        public function isMine():Boolean{
            var b:Boolean = false;
            if(ModelManager.instance.modelUser.equip.hasOwnProperty(this.id)){
                b = true;
            }
            return b;
        }
        public function isSpecial():Boolean
        {
            if(ConfigServer.equip_make_special && ConfigServer.equip_make_special.length>1){
                return ConfigServer.equip_make_special[1].indexOf(this.id)>-1;
            }
            return false;
        }
        public function getLv():Number{
            var lv:Number = 0;
            if(this.isMine()){
                lv = ModelManager.instance.modelUser.equip[this.id].lv;
            }
            return lv;
        }
        


        public function getBack():String{
            var str:String = AssetsManager.getAssetsUI("icon_zhenbao00.png");

            if(!Tools.isNullString(this.back)){
                str = AssetsManager.getAssetsICON(this.back+".png");
            }
            
            return str;
        }        
        /**
         * 是否在 cd 队列 中
         */
        public function isInQueue():Boolean{
            var b:Boolean = false;
            if(ModelManager.instance.modelUser.equip_cd.length>0){
                if(ModelManager.instance.modelUser.equip_cd[2] == this.id){
                    b = true;
                }
            }
            return b;
        }
        public function getLastCDtimer():Number{
			var now:Number = ConfigServer.getServerTimer();
            var cd:Number = Tools.getTimeStamp(ModelManager.instance.modelUser.equip_cd[1]);
            return cd - now;
		}
        public function upgradeIng():void{
            var endB:Boolean = false;
			if(this.isUpgradeIng()>-1){
                if(this.getLastCDtimer()>0){
				    ModelManager.instance.modelInside.event(ModelInside.EQUIP_UPDATE_CD,this);
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
			ModelManager.instance.modelInside.event(ModelInside.EQUIP_UPDATE_REMOVE,this);
			ModelManager.instance.modelInside.event(ModelInside.EQUIP_UPDATE_GET,this);
            ModelManager.instance.modelInside.getBuilding002().updateStatus(true);
        }
        public function getMyHero():ModelHero{
            return searchHero(this.id);
        }
        public function getUpgradeCfgByLv(lv:int):Object{
            return this.upgrade[lv];
        }
        public function getMaxLv():Number
        {
            if(this.lvMax<0){
                this.lvMax = Tools.getDictLength(this.upgrade) - 1;
            }
            return this.lvMax;
        }
        public function getLvCD(lv:int):Number{//返回秒
            
			var lvobj:Object = this.getUpgradeCfgByLv(lv);
			var m:Number = -1;
            //如果还不是我的  那cd就是制造时间  否则就用升级时间
			if(this.isMine()==false){
                m=this.make_time;
            }else{
                if(lvobj.hasOwnProperty("upgrade_time"))
                {
                    m = lvobj["upgrade_time"];
                }
            }
			return Math.floor(m*60*(1-ModelScience.func_sum_type(ModelScience.equip_ma_time)));
		}
        public function getLastCDtimerStyle():String{
			return Tools.getTimeStyle(this.getLastCDtimer());
		}
        public static function getCDingModel():ModelEquip{
            var emd:ModelEquip;
            if(ModelManager.instance.modelUser.equip_cd.length>0){
                emd = ModelManager.instance.modelGame.getModelEquip(ModelManager.instance.modelUser.equip_cd[2]);
            }
            return emd;
        }
        public static function getIcon(eid:String):String{
			var obj:* = ModelEquip.getConfig(eid);
			if (obj && obj.icon){
				 return obj.icon + ".png";
			}
            return eid + ".png";
        }
        /**
         * 是否在 英雄身上
         */
        public static function searchHero(eid:String):ModelHero{
            var hero:ModelHero;
            for(var key:String in ModelManager.instance.modelUser.hero)
            {
                hero = ModelManager.instance.modelGame.getModelHero(key);
                if(hero.getEquip().indexOf(eid)>-1){
                    return hero;
                }
            }
            return null;
        }
        /**
         * 获取类型 宝物,宝物只有一个
         */
        public static function getTypeNums(equipType:int,checkHero:Boolean = true):Number{
            var obj:Object = ModelManager.instance.modelUser.equip;
            var md:ModelEquip;
            var num:Number = 0;
            for(var key:String in obj)
            {
                md = ModelManager.instance.modelGame.getModelEquip(key);
                if(md.type == equipType){
                    if(checkHero){
                        if(!md.getMyHero()){
                            num+=1;
                            break;
                        }
                    }else{
                        num+=1;
                        break;
                    }
                }
            }
            return num;
        }
        public static function checkBuildLvCanUp(type:int):int{
            return (type<5)?ConfigServer.system_simple.equip_make_list[type+""][0]:ConfigServer.equip_make_special[0];
        }
        public static function getHaveEquipTypes():Array{
            var cfg:Object = ConfigServer.system_simple.equip_make_list;
            var obj:Object;// = type<5?cfg[type]:ConfigServer.equip_make_special;
            //
            var eArr:Array;// = obj[1];
            //
            var myEquips:Object = ModelManager.instance.modelUser.equip;
            var arr:Array = [];
            // var num:int = 0;
            cfg["5"] = ConfigServer.equip_make_special;
            for(var i:String in cfg){
                obj = cfg[i];
                eArr = obj[1];
                for(var key:String in myEquips)
                {
                    if(eArr && eArr.indexOf(key)>-1){
                        arr.push(i);
                        break;
                    }
                } 
            }  
            arr.sort();
            return arr;
        }

        public function getWashInfoHtml(hasSign:Boolean = false):String
        {
            var arr:Array = this.getWashArr();
            var len:int = arr.length;
            var str:String = "";
			var washInfo:String;
            for (var i:int = 0; i < len; i++){
				washInfo = ModelEquip.getWashInfo(arr[i].id);
				if (hasSign){
					washInfo = Tools.getMsgById('_equip26') + washInfo;
				}
                str += StringUtil.htmlFontColor(washInfo,arr[i].color);
                if(i<len-1){
                    str+="<br/>";
                }
            }    
            return str;      
        }

        public function getEnhanceInfoHtml(hasSign:Boolean = false):String
        {
            var lv:Number       = this.getEnhanceLv();
            if(lv==0) return "";
            var str:String = "";
            var s:String = "";
            var baseInfo:String = this.getEnhanceLvBaseInfo(lv);
            s = baseInfo;
            if(hasSign) s = Tools.getMsgById('_equip26') + s;
            str += StringUtil.htmlFontColor(s,ConfigColor.FONT_COLORS[1]) + "<br/>";

            var highArr0:Array  = this.getEnhanceLvHighArr(0);
			var highArr1:Array  = this.getEnhanceLvHighArr(1);
			var highArr2:Array  = this.getEnhanceLvHighArr(2);
            var arr:Array = [highArr0,highArr1,highArr2];
            for(var i:int=0;i<arr.length;i++){
                if(arr[i][0]<=lv){
                    s = arr[i][1];
                    if(hasSign) s = Tools.getMsgById('_equip26') + s;
                    str += StringUtil.htmlFontColor(s,ConfigColor.FONT_COLORS[i+3]);
                }else{
                    break;
                }
                if(i<arr.length-1){
                    str+="<br/>";
                }
            }
            return str;      
        }
        /**
         * 获得宝物上的洗炼属性
         */
        public function getWashArr():Array{
            var a:Array=[];
            if(ModelManager.instance.modelUser.equip[this.id]){
                var wash:Array=ModelManager.instance.modelUser.equip[this.id].wash;
                if(wash.length==0){
                    return a;
                }else{
                    for(var i:int=0;i<wash.length;i++){
                        var o:Object=getWashData(wash[i]);
                        if(o){
                            a.push(o);
                        }else{
                            //error wash
                        }
                    }
                }
            }
            return a;
        }

        /**
         * 获得某个洗炼属性
         */
        public static function getWashData(id:String):Object{
            var d:Object=ConfigServer.equip_wash;
            if(d.hasOwnProperty(id)){
                var o:Object={};
                o["id"]=id;
                for(var s:String in d[id]){
                    o[s]=d[id][s];
                }
                o["color"]=ConfigColor.FONT_COLORS[o["rarity"]];
                return o;
            }
            return null;
        }
		/**
         * 单条洗炼 属性 中文显示
         */
        public static function getWashInfo(wid:String):String
        {
			var washCfg:Object = ConfigServer.equip_wash[wid];
			if (washCfg){
				var str:String = '';

				if (washCfg.estate_active){
					//产业挂机加成
					var estate_active:Array = washCfg.estate_active;
					var key:String = 'rslt_estate_active_' + estate_active[0];
					str += Tools.getMsgById(key,[Tools.percentFormat(estate_active[2])]);
				}
				if (washCfg.army_go){
					//行军加速
					if(str != '')
						str += Tools.getMsgById('rslt_connect0');
					str += Tools.getMsgById('army_go',[Tools.percentFormat(washCfg.army_go)]);
				}
				if (washCfg.passive){
					//战斗属性
					var temp:String = PassiveStrUtils.translatePassiveInfo(washCfg.passive, false);
					if (temp){
						if (str){
							str += Tools.getMsgById('rslt_connect0');
						}
						str += temp;
					}
				}
				
				if (str == ''){
					str = Tools.getMsgById("msg_ModelEquip_0");
				}
				if (TestUtils.isTestShow){
					str += ' '+wid;
				}
				return str;
			}
            return wid;
        }

        public static function getPrepareObj(hmd:ModelHero):Array{
            var arr:Array = hmd.getEquip();
            var len:int = arr.length;
            var myEquip:Object;
            var re:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                if(ModelManager.instance.modelUser.equip.hasOwnProperty(arr[i])){
                    myEquip = ModelManager.instance.modelUser.equip[arr[i]];
                    re.push([arr[i],myEquip.lv,myEquip.wash,(myEquip.enhance ? myEquip.enhance : 0)]);
                }
            }
            return re;
        }

        /**
         * 获得产业洗炼id
         */
        public static function getEstateWashId(aid:String,eid:String):Array{
            var wash:Object=ConfigServer.equip_wash;
            var arr:Array=[];
            for(var s:String in wash){
                var o:Object=wash[s];
                if(o.estate_active){
                    if(o.estate_active[0]==aid && o.estate_active[1].indexOf(eid)!=-1){
                        arr.push(s);
                    }
                }
            }
            return arr;
        }

        /**
         * 使用中的英雄
         */
        public function useHid():String{
            var heros:Object=ModelManager.instance.modelUser.hero;
            for(var s:String in heros){
                var arr:Array=heros[s].equip;
                for(var i:int=0;i<arr.length;i++){
                    if(arr[i]==this.id){
                        return ModelHero.getHeroName(s);
                    }
                }
            }
            return Tools.getMsgById("_guild_text10");
        }

        public static function getName(eid:String,elv:int):String{
            if(ConfigServer.equip.hasOwnProperty(eid)){
                var s:String = Tools.getMsgById(ConfigServer.equip[eid].name);
                return elv == 0 ? s : s+"+"+elv;
            }
            return "";
        }


        /**
         * 获得需要的指定道具数量(从当前状态到满级所需的数量)
         * 给“回收材料”时使用
         */
        public function getNeedNumById(item_id:String):Number{
            var _lv:Number=this.getLv();
            var n:Number=0;
            for(var s:String in this.upgrade){
                if(_lv < Number(s)){
                    if(this.upgrade[s].cost.hasOwnProperty(item_id)){
                        n+=this.upgrade[s].cost[item_id];
                    }
                }
            }
            if(!isMine()){
                n += (this.make_item && this.make_item[item_id]) ? this.make_item[item_id] : 0;
            }
            
            //制作或者突破当中  其实已经消耗掉了道具
            var cd:Array = ModelManager.instance.modelUser.equip_cd;
            if(cd.length > 0){
                if(this.id == cd[2]){
                    if(!isMine()){
                        n -= (this.make_item && this.make_item[item_id]) ? this.make_item[item_id] : 0;
                    }else{
                        if(this.upgrade[_lv+1]){
                            if(this.upgrade[_lv+1].cost.hasOwnProperty(item_id)){
                                n -= this.upgrade[_lv+1].cost[item_id];
                            }
                        }
                    }
                }
            }
            return n;
        } 

        /**
         * 指定道具制作或升级时需要的数量
         */
        public function nextLvNeedItemNum(item_id:String):Number{
            var n:Number = 0;
            if(!isMine()){
                if(this.make_item && this.make_item[item_id]){
                    n = this.make_item[item_id];
                }else{
                    if(this.upgrade[1] && this.upgrade[1].cost.hasOwnProperty(item_id)){
                        n = this.upgrade[1].cost[item_id];
                    }
                }
            }else{
                var _lv:Number=this.getLv();
                var _max:Number = this.getMaxLv();
                if(_lv == _max){
                    n = 0;
                }else{
                    if(this.upgrade[_lv+1] && this.upgrade[_lv+1].cost.hasOwnProperty(item_id)){
                        n = this.upgrade[_lv+1].cost[item_id];
                    }
                }
            }
            return n;
        }
        /**
         * 到满级还需要多少碎片
         */
        public static function canBuyEquipItem(item_id:String,tips:Boolean = false):Boolean{
            var b:Boolean = false;
            var pmd:ModelItem = ModelManager.instance.modelProp.getItemProp(item_id);
            if(pmd && pmd.equip_info){
                var n1:Number = 0;
                var n2:Number = pmd.num;
                var arr:Array = pmd.equip_info;
                for(var i:int=0;i<arr.length;i++){
                    var emd:ModelEquip = ModelManager.instance.modelGame.getModelEquip(arr[i]);
                    n1 += emd.getNeedNumById(item_id);
                }
                b = n1>n2;
            }else{
                b = true;
            }
            if(b==false && tips){
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0142'));
            }
            return b;
        }

        /**
         * 获得特殊道具列表(制作)
         */
        public function getSpecialMaterials():Array{
            var arr:Array=[];
            if(this.make_item){
                for(var s:String in this.make_item){
                    if(["food","wood","gold","iron"].indexOf(s)==-1 && ConfigServer.system_simple.equip_make_normal.indexOf(s)==-1){
                        arr.push([s,this.make_item[s]]);
                    }
                }
            }
            return arr;
        }

        /**
         * 判断是否有特殊材料
         */
        public function hasSpecialMaterial():Boolean{
            var arr:Array=getSpecialMaterials();
            if(arr.length==0) return false;
            for(var i:int=0;i<arr.length;i++){
                if(ModelItem.getMyItemNum(arr[i][0])>0){
                    return true;
                }
            }
            return false;
        }

        /**
         * 获得珍宝阁的类型列表
         */
        public static function getEquipTabArr(type:int=0):Array{
            var arr:Array = [];
            var emd:ModelEquip;
            if(type==0){//制作 直接返回 (包含特殊)
                var b:Boolean = false;
                var obj:Object = ConfigServer.equip_make_special;
                if(obj && obj[1]){
                    for(var j:int = 0; j <obj[1].length; j++){
                        emd = ModelManager.instance.modelGame.getModelEquip(obj[1][j]);
                        if(emd.isMine() || emd.hasSpecialMaterial()){
                            b = true;
                            break;
                        }
                    }
                }
                var lock:Object = ModelGame.unlock(null,"equip_special");
                var n:Number=(b && lock.visible) ? 5 : 4;
                for(var k:int=0;k<=n;k++){
                    arr.push(ModelEquip.equipDataArr[k]);
                }
                return arr;
            } 
            
            //突破 洗练 强化  返回已有宝物的类型 (不包含特殊)
            var typeArr:Array = [];
            var all:Object = ModelManager.instance.modelUser.equip;
            for(var i:int=0;i<ModelEquip.equipDataArr.length;i++){
                for(var key:String in all){
                    emd = ModelManager.instance.modelGame.getModelEquip(key);
                    if(emd.type == ModelEquip.equipDataArr[i].type){
                        arr.push(ModelEquip.equipDataArr[i]);
                        break;
                    }
                }
            }
            
            return arr;
        }

        /**
         * 材料是否满足可制造 且还未制造
         */
        public function isCanMake():Boolean{
            var b:Boolean = true;
            var emd:ModelEquip=this;//ModelManager.instance.modelGame.getModelEquip(eid);
            if(emd && !emd.isMine() && emd.make_item){
                var pay:Object = emd.make_item;
                var payArr:Array = Tools.getPayItemArr(pay);
                var len:int = payArr.length;
                var payItem:Object;
                var itemNo:Number = 0;
                for(var i:Number = 0; i < len; i++){
                    payItem = payArr[i];
                    if(payItem.id.indexOf("item")>-1){
                        if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                            b = false;
                            break;
                        }
                    }else{
                        if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                            b = false;
                            break;
                        }
                    }
                }
            }
            if(emd && emd.isMine()){
                b = false;
            }
            return b;
        }

        /**
         * 材料是否满足可突破
         */
        public function isCanUpgrade():Boolean{
            var emd:ModelEquip=this;
            var b:Boolean = false;
            if(emd.isMine() && emd.upgrade){
                var _lv:Number = emd.getLv();
                if(_lv<emd.getMaxLv()){
                    b = true;
                    var pay:Object = emd.upgrade[_lv+1].cost;
                    var payArr:Array = Tools.getPayItemArr(pay);
                    var len:int = payArr.length;
                    var payItem:Object;
                    var itemNo:Number = 0;
                    for(var i:Number = 0; i < len; i++){
                        payItem = payArr[i];
                        if(payItem.id.indexOf("item")>-1){
                            if(ModelItem.getMyItemNum(payItem.id)<payItem.data){
                                b = false;
                                break;
                            }
                        }else{
                            if(!ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                                b = false;
                                break;
                            }
                        }
                    }
                }
            }

            return b;
        }



        //====================宝物强化相关=================

        /**
         * 强化等级(从0开始)
         */
        public function getEnhanceLv():Number{
            if(ModelManager.instance.modelUser.equip[this.id] && ModelManager.instance.modelUser.equip[this.id].enhance)
                return ModelManager.instance.modelUser.equip[this.id].enhance;
            return 0;
        }

        /**
         * 失败次数
         */
        public function getEnhanceTimes():Number{
            if(ModelManager.instance.modelUser.equip[this.id] && ModelManager.instance.modelUser.equip[this.id].enhance_times)
                return ModelManager.instance.modelUser.equip[this.id].enhance_times;
            return 0;
        }

        /**
         * 强化最高等级
         */
        public function getEnhanceLvMax():Number{
            var equip_enhance_level:Array = ConfigServer.system_simple.equip_enhance_level;
			var n:Number = ConfigServer.system_simple.equip_enhance_cost.length;
            if(equip_enhance_level){
                n = 0;
                for(var i:int=0;i<equip_enhance_level.length;i++){
                    var a:Array = equip_enhance_level[i];
                    if(a[0] == 'merge'){
                        if(ModelManager.instance.modelUser.mergeNum >= a[1]){
                            n += a[2];
                        }
                    }else if(a[0] == 'science'){
                        n +=  (ModelManager.instance.modelGame.getModelScience(a[1]).getLv()*a[2]);
                    }
                }
            }		
			return n;
            // var _cfg:Array=ConfigServer.system_simple.equip_enhance_cost;
            // return _cfg.length;
        }


        /**
         * 强化的系统配置 [道具id,道具数量,首次成功率,额外成功率,额外成功率最大叠加次数]
         */
        public function getEnhanceCfg():Array{
            var _cfg:Array = ConfigServer.system_simple.equip_enhance_cost;
            var _lv:Number = getEnhanceLv();
            var _arr:Array = getEnhanceLv()>=getEnhanceLvMax() ? _cfg[_lv-1] : _cfg[_lv];
            return [_arr[this.type],_arr[5],_arr[6],_arr[7],_arr[8]];
        }


        /**
         * 当前成功率
         */
        public function getCurProbability():String{
            var _cfg:Array   = this.getEnhanceCfg();
            var _time:Number = this.getEnhanceTimes() < _cfg[4] ? this.getEnhanceTimes() : _cfg[4];
            var s:String = Math.round((_cfg[2]+_cfg[3]*_time)*100)+"%";
            return s;
        }

        /**
         * 检查是否可强化
         */
        public function checkCanEnhance(showTips:Boolean=false):Boolean{
            var _cfg:Array = this.getEnhanceCfg();
            if(!Tools.isCanBuy(_cfg[0],_cfg[1],showTips)) return false;

            if(this.getEnhanceLv()>=this.getEnhanceLvMax()){
                showTips && ViewManager.instance.showTipsTxt(Tools.getMsgById("_enhance04"));
                return false;
            }
            return true;

        }
		
		
		/**
         * 得到对应类型的强化战斗属性配置
         */
        public function getEnhanceRiseCfg():Object{
            return ConfigServer.fight.equipRise[this.type];
        }
		
		/**
         * 得到指定等级的强化属性文字
         */
        public function getEnhanceLvBaseInfo(riseLv:int):String{
			var cfg:Object = this.getEnhanceRiseCfg();
			if (cfg){
				return PassiveStrUtils.translateRsltInfo(Tools.getMsgById('cond'),FightUtils.getRankObj(riseLv, cfg.base),false);
			}
            return '';
        }
		
		/**
         * 得到指定特殊等级解锁的等级和属性文字
         */
        public function getEnhanceLvHighArr(highIndex:int):Array{
			var cfg:Object = this.getEnhanceRiseCfg();
			if (cfg){
				var arr:Array = cfg.high;
				var tempArr:Array = arr[highIndex];
				return [tempArr[0],PassiveStrUtils.translateRsltInfo(Tools.getMsgById('cond'),tempArr[1],false)];
			}
            return null;
        }

        /**
         * 
         */
        public static function upgradeRedPointByType(_type:int):Boolean{
            var b:Boolean = false;
            var myEquips:Object = ModelManager.instance.modelUser.equip;
            var item:ModelEquip;
            for(var key:String in myEquips){
                item = ModelManager.instance.modelGame.getModelEquip(key);
                if(item.type == _type){
                    if(item.isCanUpgrade()){
                        b = true;
                        break;
                    }
                }
            }
            return b;
        }

         /**
         * 
         */
        public static function makeRedPointByType(_type:int):Boolean{
            var b:Boolean = false;
            var emd:ModelEquip;
            if(_type == 5){//特殊宝物
                var specialObj:Object = ConfigServer.equip_make_special;
                if(specialObj && specialObj[1]){
                    for(var i:int = 0; i <specialObj[1].length; i++){
                        emd = ModelManager.instance.modelGame.getModelEquip(specialObj[1][i]);
                        if(emd.isMine() == false){
                            //if(emd.hasSpecialMaterial()){
                            if(emd.isCanMake()){
                                b = true;
                                break;
                            }
                        }
                    }
                }
            }else{
                var makeObj:Object = ConfigServer.system_simple.equip_make_list;
                var cfgArr:Array = makeObj[_type] && makeObj[_type][1] ? makeObj[_type][1] : [];
                //var num1:Number = 0;
                //var num2:Number = cfgArr.length;
                for(var j:int = 0; j < cfgArr.length; j++){
                    var key:String = cfgArr[j];
                    emd = ModelManager.instance.modelGame.getModelEquip(key);
                    //if(emd.isMine()) num1++;                    
                    if(emd.isMine() == false){
                        var payArr:Array = Tools.getPayItemArr(cfgArr[2]);
                        var n1:int = payArr.length;
                        var n2:int = 0;
                        for(var k:Number = 0; k < payArr.length; k++){
                            var payItem:Object = payArr[k];
                            if(payItem.id.indexOf("item")>-1){
                                if(ModelItem.getMyItemNum(payItem.id)>=payItem.data){
                                    n2 += 1;
                                }
                            }else{
                                if(ModelBuiding.getMaterialEnough(payItem.id,payItem.data)){
                                    n2 += 1;
                                }
                            }
                        }
                        if(n1 == n2){
                            b = true;
                            break;
                        }
                    }
                }
                //b = num1<num2;
            }
            return b;
        }


    }   

    
}