package sg.model
{
    import sg.cfg.ConfigServer;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.map.utils.TestUtils;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.manager.AssetsManager;

    public class ModelRune extends ModelBase{

        public static const EVENT_SET_IN_OUT:String = "event_set_in_out";
        public var id:String;
        public var name:String;
        public var info:String;
        public var icon:String;
        public var fix_type:int;
        public var exp_type:int;
        public var max_level:int;
        public var cfgID:String;
        public static var runeModels:Object = {};
        public function ModelRune():void{
            
        }
        public static function getConfig(key:String):Object{
            return ConfigServer.star[getCfgID(key)];
        }
        /**
         * 处理id,获取配置 id
         */
        public static function getCfgID(key:String):String{
            var cid:String = key;
            var cidi:int = key.indexOf("|");
            if(cidi>-1){
                cid = key.substring(0,cidi);
            }
            return cid;
        }
        public function initData(key:String, obj:Object):void{
			this.data = obj;
            this.id = key;
            this.cfgID = getCfgID(key);
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
				name += this.id;
			}
            return name;
        }
		public function getOnlyInfo():String{
			var name:String = '';
			var arr:Array = ConfigServer.system_simple.fix_star_only;
			if (arr.indexOf(this.cfgID) !=-1){
				return Tools.getMsgById('star_only',[this.getName()]);
			}
			else{
				return '';
			}
        }
		public function getModelSkill():ModelSkill{
			return ModelSkill.getModel(this.cfgID);
		}
		/**
         * 得到当前等级的星辰描述
         */
        public function getInfoHtml():String{
			var ms:ModelSkill = this.getModelSkill();
			var lv:int = this.getLv();
			var info:String;
			if (ms){
				info = ms.getReplaceHtml('info', lv);
			}
			if(!info){
				var starObj:Object = PassiveStrUtils.getLvData(this.data, lv, true);
				info = PassiveStrUtils.translatePassiveInfo(starObj.passive);
				if (!starObj.passive){
					info = this.id + " " + info;
				}
			}
			return info;
        }
		/**
         * 得到下一等级的星辰描述
         */
		public function getNextHtml():String{
			var lv:int = this.getLv() + 1;
			if (lv > this.getMaxLv())
			{
				return '';
			}
			var info:String;
			var ms:ModelSkill = this.getModelSkill();
			if (ms){
				info = ms.getReplaceHtml('info', lv);
			}
			if(!info){
				var starObj:Object = PassiveStrUtils.getLvData(this.data, lv, true);
				info = PassiveStrUtils.translatePassiveInfo(starObj.passive);
			}
			return info;
        }

        public function getCfgInfo():String{
            return Tools.getMsgById(ConfigServer.star[this.id].info);
        }



        public function getIcon():String{
            return AssetsManager.getAssetsICON(this.getImgName());
        }    
        public function getImgName():String{
            return "star0"+this.icon+".png";
        }

        public function isMine():Boolean{
            var b:Boolean = false;
            if(ModelManager.instance.modelUser.star.hasOwnProperty(this.id)){
                b = true;
            }
            return b;
        }
		public function getMaxLv():Number{
			var lv_science:Array;
            var sid:String;
            var n:Number = this.max_level;
            lv_science = ConfigServer.system_simple.star_lv_science[this.fix_type];
            if(lv_science){
                sid = lv_science[0];
                n += (ModelManager.instance.modelGame.getModelScience(sid).getLv()*lv_science[1]);
            }
            return n;
        }
        public function getLv():Number{
            var lv:Number = 0;
            var md:Object = this.getMyData();
            if(md){
                lv = Number(md["lv"]);
            }
            return lv;
        }
        public function getExp():Number{
            var exp:Number = 0;
            var md:Object = this.getMyData();
            if(md){
                exp = md["exp"];
            }
            return exp;
        }
        /**
         * 绑定的 英雄 model
         */
        public function getHeroModel():ModelHero{
            var hero:ModelHero;
            var md:Object = this.getMyData();
            if(md){
                if(md["hid"]){
                    hero = ModelManager.instance.modelGame.getModelHero(md["hid"]);
                }
            }
            return hero;
        }     
        /**
         * 下一级别exp
         */
        public function getLvExp(lv:Number):Number{
            var exp:Number = 0;
            if(this.isMine()){
                var cfg:Array = getCfgToUpDel(this.exp_type);
                exp = cfg[0][lv];
            }
            return exp;
        }   
        /**
         * 消耗材料
         */
        public function getUpgradeItems():Object{
            var obj:Object = {};
            if(this.isMine()){
                var cfg:Array = getCfgToUpDel(this.exp_type);
                obj = cfg[1];
            }
            return obj;
        }
        /**
         * 升级、卸载、配置
         */
        public static function getCfgToUpDel(type:int):Array{
            return ConfigServer.system_simple.star_exp[type];
        }
        /**
         * 当前星辰的,存储数据
         */
        public function getMyData():Object{
            var obj:Object = null;
            if(this.isMine()){
                obj = ModelManager.instance.modelUser.star[this.id];
            }
            return obj;
        }
        /**
         * 根据类型获取 星辰
         */
        public static function getMyRunesByType(type:int,myHero:ModelHero = null,index:int = -1):Array{
            var arr:Array = [];
			var obj:Object = ModelUser.rune_type_dic[type+""];//ModelManager.instance.modelUser.star;
			var rmd:ModelRune;
            var hmd:ModelHero;
            var heroOfRMD:ModelRune;
			for(var key:String in obj)
			{
				rmd = ModelManager.instance.modelGame.getModelRune(key);
                rmd["sortLv"] = rmd.getLv();
                rmd["sortMine"] = rmd.isMine()?0:1;
                rmd["sortNum"] = rmd.getLv();
                rmd["sortId"] = Number(ModelRune.getCfgID(rmd.id).split('r')[1]);
				if(rmd.fix_type == type){
                    if(myHero!=null){
                        heroOfRMD = myHero.getRuneByIndex(index);
                        hmd = rmd.getHeroModel();
                        if(hmd){
                            if(heroOfRMD){
                                if(heroOfRMD.id == rmd.id){
                                    rmd["sortNum"] = (rmd.isMine()?200000:100000)+rmd.getLv();
                                    arr.push(rmd);
                                }
                            }                       
                        }
                        else{
                            arr.push(rmd);
                        }
                    }
                    else{
                        arr.push(rmd);
                    }
					
				}
			}
			return arr;
        }
        public function checkOnly(rid:String):Boolean
        {
            var arr:Array = ConfigServer.system_simple.fix_star_only;
            var len:int = arr.length;
            for(var i:int = 0;i < len;i++){
                if(rid.indexOf(arr[i])>-1){
                    return true;
                }
            }
            return false;
        }
        public static const fix_position_diff:Array = [4,5,6,7];
        /**
         * dnxb == 东南西北
         * type == 每页的位置
         */ 
        public static function pageAndTypeToPosValue(dnxb:*,type:*):Number{
            return ConfigServer.system_simple.fix_position[pageAndTypeToPosIndex(dnxb,type)];
        }
        /**
         * dnxb == 东南西北
         * type == 每页的位置
         */
        public static function pageAndTypeToPosIndex(dnxb:*,type:*):Number{
            return Number(dnxb)*5+Number(type);
        }

        public static function getFixType0(arr:Array,myAll:Object):Array{
            var newArr:Array = [];
            var len:int = arr.length;
            var i:int = 0;
            var pb:Boolean = true;
            
            for(i = 0;i < len;i++){
                // if(arr[i].icon == currRun.icon){
                pb = true;
                for(var key:String in myAll){
                    if(myAll[key].split("|")[0] == (arr[i] as ModelRune).id.split("|")[0]){
                        pb = false;
                        break;
                    }
                }
                if(pb){
                    newArr.push(arr[i]);
                }
                // }
            }  
            return newArr;          
        }
        public static function getNum(star_id:String):Number{
            if(star_id.length==8){
                star_id = star_id.substr(0,6);
            }
            var user_star:Object=ModelManager.instance.modelUser.star;
            var n:Number=0;
            for(var s:String in user_star){
                if(s.indexOf(star_id)!=-1){
                    n+=1;
                }
            }
            return n;
        }

        /**
         * 测试方法
         */
        private static function testtest():void{
            // var cfg1:Object = ConfigServer.star;
            // for(var s:String in cfg1){
            //     if(cfg1[s].max_level==null){
            //         trace("11111   ",s);
            //     }
            // }
            // var cfg2:Object = ConfigServer.skill;
            // for(var ss:String in cfg2){
            //     if(cfg2[ss].max_level==null && ss.indexOf("skill")!=-1){
            //         trace("222222   ",ss);
            //     }
            // }
        }
    }
}