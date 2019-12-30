package sg.model
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigColor;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.manager.EffectManager;
	import sg.map.utils.TestUtils;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.manager.AssetsManager;
    import sg.utils.SaveLocal;
    import sg.map.utils.ArrayUtils;
	import sg.utils.StringUtil;

    public class ModelSkill extends ModelBase{
		public static const NAEM_HEAD:String = "skill";
//
        public static const ability_info_type:Array = [
            "str",
            "agi",
            "cha",
            "lead",
            "sex",
            "type",
            "rarity",
            "hero",
            "army",
			"sum"
        ];
        public static const ability_info_name:Array = [
            Tools.getMsgById("info_str"),
            Tools.getMsgById("info_agi"),
            Tools.getMsgById("info_cha"),
            Tools.getMsgById("info_lead"),
            Tools.getMsgById("msg_ModelSkill_0"),
            Tools.getMsgById("msg_ModelSkill_1"),
            Tools.getMsgById("msg_ModelSkill_2"),
            Tools.getMsgById("msg_ModelSkill_3"),
			Tools.getMsgById("msg_ModelSkill_4"),
			Tools.getMsgById("info_sum")
        ];

        public static const skill_type_icon:Array=[
            "skilltype0.png",
            "skilltype1.png",
            "skilltype2.png",
            "skilltype3.png",
            "skilltype4.png",
            "skilltype5.png",
            "skilltype6.png",
            "skilltype7.png",
            "skilltype8.png"
        ];
        public static const skill_type_name:Array = [
            Tools.getMsgById("_skill7"),Tools.getMsgById("_skill8"),Tools.getMsgById("_skill9"),Tools.getMsgById("_skill10"),
            Tools.getMsgById("_skill11"),Tools.getMsgById("_skill12"),Tools.getMsgById("_skill13")
            // "步兵技能","骑兵技能","弓兵技能","方士技能","英雄技能","辅助技能","内政技能"
        ]
        public var id:String;
        public var icon:String;
        public var index:int;
        public var type:int =-1;
		public var state:int = 1;
		public var merge:int;
		public var open_date:Object;
        public var cost_type:int;
        public var ability_info:Array;
        public var limit:Object;
        public var fast_learn:int = 0;
        public var max_level:int;
        //
        public var itemID:String;
        public var shogun_type:int=0;
        public var estate_active:Array=[];
        public function ModelSkill():void{
            
        }
        public static var skillModels:Object = {};
		
        public static function getModel(key:String):ModelSkill{
			var model:ModelSkill = ModelSkill.skillModels[key];
			if (!model){
				var cfg:Object = ModelSkill.getConfig(key);
				if(cfg){
					model = new ModelSkill();
					model.initData(key,cfg);
					ModelSkill.skillModels[key] = model;
				}
			}
			return model;
		}
		public static function getConfig(key:String):Object{
            return ConfigServer.skill[key];
        }
		
        public function initData(key:String,obj:Object):void{
            this.id = key;
			this.data = obj;
            for(var m:String in obj)
			{
				if(this.hasOwnProperty(m)){
					this[m] = obj[m];
				}
			}
            if(obj && obj.hasOwnProperty("fast_learn")){
                fast_learn = obj["fast_learn"];
            }
            else{
                fast_learn = 0;
            }
            this.itemID = this.id.replace(NAEM_HEAD,ModelHero.NAEM_ITEM_HEAD);
        }
        public function getName(canTest:Boolean = false):String{
			var name:String = Tools.getMsgById(this.id);
			if (canTest && TestUtils.isTestShow){
				name += this.id;
			}
            return name;
        }
        public static function getSkillName(id:String):String{
            return Tools.getMsgById(id);
        }


        public function getIcon():String{
			if(this.icon)
				return AssetsManager.getAssetsICON(this.icon+".png");
            return AssetsManager.getAssetsICON(this.itemID+".png");
        }
		public function getTypeValue():int{
			if (this.data.hasOwnProperty('type')){
				return this.data.type;
			}
			return -1;
		}
		
		/**
		 * 是否可显示该技能
		 */
		public function get isOpenState():Boolean{
			//如果我已获得道具碎片，则显示
			//if (this.getMyItemNum() > 0){
				//return true;
			//}
			
			
			//当前时间比设定开启时间晚
			if (this.open_date){
				if (ConfigServer.getServerTimer() < Tools.getTimeStamp(this.open_date)){
					return false;
				}
			}
			
			if (this.state <= 0){
				return false;
			}
			
			var modelUser:ModelUser = ModelManager.instance.modelUser;
			var mergeNum:int = modelUser.mergeNum;
			if (mergeNum > this.merge){
				return true;
			}
			else if (mergeNum < this.merge){
				return false;
			}
			else{
				if (this.state == 1){
					return true;
				}
				else if (this.state > 1){
					//已开服天数 >=this.state可显示
					return modelUser.getGameDate() >= this.state;
				}
			}
			
			//if (this.state == 1){
				//return true;
			//}
			//else if (this.state > 1){
				////已开服天数 >=this.state可显示
				//return ModelManager.instance.modelUser.getGameDate() >= this.state;
			//}
			return false;
		}
		/**
         * 得到该技能在对应类型、等级上的颜色index
         */
        public function getColor(value:* = null):int
        {
			var color:int;
			if (this.getTypeValue() < 0 || value == null){
				color = -1;
			}
			else
			{
				color = 0;
				var lv:int = 1;
				if (value is ModelHero){
					var hero:ModelHero = value;
					lv = this.getLv(hero);
				}
				else {		//if (value > 0)
					lv = value;
				}
				
				var o:Array = ConfigServer.system_simple.skill_color[this.cost_type];
				for (var i:int = o.length - 1; i >= 0; i--)
				{
					if (lv >= o[i])
					{
						color = i;
						break;
					}
				}
			}
			
            return color;
        }
		/**
         * 得到该技能在对应英雄身上的等级
         */
        public function getLv(hero:ModelHero = null):int{
            var num:Number = 0;
            var skills:Object = {};
            if(hero){
                if(hero.isMine()){
                    skills = hero.getMySkills();
                }
                else{
					var heroData:Object = hero.getMyData();
                    skills = heroData && heroData.skill? heroData.skill:hero.skill;
                }
				if(skills && skills.hasOwnProperty(this.id)){
                    num = skills[this.id];
                }
                else{
                    num = 0;
                }
            }
            return num;
        }
        /**
         * 是否 能够 学习/升级 ,需要 各种类型匹配
         */
        public function isCanGetOrUpgrade(hero:ModelHero = null,typePro:Array = null):Object{            
            var arr:Array = [];
            var reObj:Object = {};
            // if(this.isMine(hero)){
            //     return true;
            // }
            var sexB:Boolean = false;
            var typeB:Boolean = false;
            var strB:Boolean = false;
            //
            var all:int = 0;
            var okInt:int = 0;
            var b:Boolean = false;

            var va:Number = 0;
            var txt:String = "";
            var err:String = "";

            for(var key:String in this.limit)
            {
                all+=1;
                b = false;
                va = this.limit[key];
                txt = va+"";
                if(key == "sex"){
                    if(hero && hero.sex == this.limit[key]){
                        okInt+=1;
                        b = true;
                    }
                    if(hero && !b){
                        err = Tools.getMsgById("_skill14");//"英雄性别不符";
                    }
                    txt = Tools.getMsgById((this.limit[key] == 1)?"_skill15":"_skill16");//(this.limit[key] == 1)?"男":"女";
                }
                else if(key == "type" || key == "rarity"){
                    if(hero && (hero.type == 2 || hero.type == this.limit[key])){
                        okInt+=1;
                        b = true;
                    }
                    if(hero && !b){
                        err = Tools.getMsgById("_skill17");//"英雄职业不符";
                    }                    
                    txt = ModelHero.type_name_all[this.limit[key]];
                }
				else{
					//对比最终四维
					if (hero){
                        if(hero.isStudyUnlimit){//副将专用英雄学习任意技能时不受属性限制
                            okInt+=1;
							b = true;
                        }else{
                            if (hero.getProp(key,hero.getPrepare(false)) >= this.limit[key]){
							okInt+=1;
							b = true;
                            }
                            if(!b){
                                err = Tools.getMsgById("_skill18");//"英雄属性不足";
                            }    
                        }
					}
				}
                arr.push({id:key,ok:b,name:ability_info_name[ability_info_type.indexOf(key)],ext:txt,estr:err});
            }
            if(!Tools.isNullObj(typePro)){
                all+=1;
                b = false;
                if(typePro[0]<typePro[1]){
                    okInt+=1;
                    b = true;
                }
                if(!b){
                    err = Tools.getMsgById("_skill19");//"英雄技能数量达到上限";
                }
                arr.push({id:"hero_limit", ok:b, name:this.getTypeStr(false), ext:typePro[0] + "/" + typePro[1], estr:err});
            }
            reObj["isOK"] = (okInt == all);
            reObj["arr"] = arr;            
            return reObj;
        }
        public function getAbility_info():Array{
            var arr:Array = [];
            var len:int = this.ability_info.length;
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                index = ability_info_type.indexOf(this.ability_info[i]);
                arr.push({id:this.ability_info[i],num:0,name:ability_info_name[index]});
            }
            return arr;
        }
        public function getAbilityHeroAttsNum(hmd:ModelHero,type:String):Number{
            var num:Number = 0;
            // trace("getAbilityHeroAttsNum,-------",type);
			var modelPrepare:ModelPrepare = hmd.getPrepare(true);
            switch(type)
            {
                case "str":
                    num = hmd.getStr(modelPrepare);
                    break;
                case "agi":
                    num = hmd.getInt(modelPrepare);
                    break; 
                case "cha":
                    num = hmd.getCha(modelPrepare);
                    break;
                case "lead":
                    num = hmd.getLead(modelPrepare);
                    break;        
				case "sum":
                    num = hmd.getStr(modelPrepare) + hmd.getInt(modelPrepare) + hmd.getCha(modelPrepare) + hmd.getLead(modelPrepare);
                    break;     
            }           
            return num;
        }
        /**
         * 是否 是 英雄 身上的 技能
         */
        public function isMine(hero:ModelHero = null):Boolean{
            var b:Boolean = false;
            if(hero){
                if(hero.isMine()){
                    if(hero.getMySkills().hasOwnProperty(this.id)){
                        b = true;
                    }
                }
            }
            return b;
        }

        public function getMaxLv():int{
			var arr:Array = getUpgradeCfgArr(this.cost_type);
            var lv_science:Array;
            var sid:String;
            var maxLv:int;
			if (arr){
                var n:Number = this.max_level;
                if(ConfigServer.system_simple.skill_lv_science){
                    lv_science = ConfigServer.system_simple.skill_lv_science[this.type];
                    if(lv_science){
                       sid = lv_science[0];
                        n += (ModelManager.instance.modelGame.getModelScience(sid).getLv()*lv_science[1]);
                    }
                }
                return n;//arr.length;
            }else{
                
				return getMaxLvByType(this.cost_type);
			}
            
        }

        public static function getMaxLvByType(_type:int):int{
            var lv_science:Array;
            var sid:String;
            var maxLv:int = 0;
            if(_type == 7 || _type == 8){
                maxLv = ConfigServer.system_simple.skill_cost_max_lv[_type];
                if(ConfigServer.system_simple.skill_cost_max_lv_science){
                    lv_science = ConfigServer.system_simple.skill_cost_max_lv_science[_type];
                    if(lv_science){
                        sid = lv_science[0];
                        maxLv += (ModelManager.instance.modelGame.getModelScience(sid).getLv()*lv_science[1]);
                    }
                }
            }
            return maxLv;
        }
        /**
         * 技能 需要的 碎片数量
         */
        public function getMyItemNum():Number{
            return ModelItem.getMyItemNum(this.itemID);
        }
        /**
         * 升级 等级 配置 
         */
        public function getUpgradeArrByLv(lv:int):Array{
            return getUpgradeCfgArr(this.cost_type)[(lv>=this.getMaxLv())?(this.getMaxLv()-1):lv];
        }
        /**
         * 升级 道具 数量
         */
        public function getUpgradeItemNum(hero:ModelHero = null):Number{
            var lv:int = this.getLv(hero);
            return getUpgradeArrByLv(lv)[0];
        }
        /**
         * 升级 gold
         */
        public function getUpgradeGoldNum(hero:ModelHero = null):Number{
            var lv:int = this.getLv(hero);
            return getUpgradeArrByLv(lv)[1];
        }
        /**
         * 升级 配置
         */
        public static function getUpgradeCfgArr(costType:int):Array{
            return ConfigServer.system_simple.skill_cost[costType];
        }
        /**
         * 遗忘 技能 返回 的 道具 和 gold
         */
        public function getDeleteItemsAndGold(hero:ModelHero = null):Array{
            var lv:int = this.getLv(hero);
            var intN:int = 0;
            if(hero.skill.hasOwnProperty(this.id)){
                intN = hero.skill[this.id];
            }
            //
            var num:Number = 0;
            var golds:Number = 0;
            //
            var arr:Array;
            //
            for(var i:int = intN; i < lv; i++)
            {
                arr = this.getUpgradeArrByLv(i);
                num += arr[0];
                golds+=arr[1];
            }
            return [num,golds];
        }


        
        /**
         * 获得产业技能id  aid产出的物品  eid产业的配置id
         */
        public static function getEstateSID(aid:String,eid:String):String{
            var allSkill:Object=ConfigServer.skill;
            for(var s:String in allSkill){
                var o:Object=allSkill[s];
                if(o.estate_active){
                    if(o.estate_active[0]==aid && o.estate_active[1].indexOf(eid)!=-1){
                        return s;
                    }
                }
            }
            return "";
        }

        /**
         * 获得技能类型图标
         */
        public function getSkillTypeIcon():String{
            return "ui/"+skill_type_icon[this.type];
        }

        /**
         * 是否是问道获得
         */
        public function isResolve(hmd:ModelHero):Boolean{
            if(Tools.isNullObj(hmd)){
                return false;
            }
            var arr:Array=hmd.resolve;
            //trace("=========",this.id,hmd.id,arr);
            if(arr){
                for(var i:int=0;i<arr.length;i++){
                    var sid:String=this.id.replace("skill","item");
                    if(sid==arr[i][0][0]){
                        return true;
                    }
                }
            }else{
                // trace("error ",hmd.id,"没有resolve");
            }
            return false;
        }
		
		
		/**
         * 得到指定等级的data数据，
         */
		public function getLvData(skillLv:int):Object{
			var skillObj:Object = this.data;
			var key:String;
			var upData:*;
			if (skillLv - 1 > 0)
			{
				upData = skillObj.up;
				if (upData){
					var multNum:int = skillLv - 1;
					skillObj = FightUtils.clone(skillObj);
					for (key in upData)
					{
						FightUtils.addObjByPath(skillObj, key, upData[key] * multNum);
					}
				}
			}
			var lvPatch:* = skillObj.lvPatch;
			if (lvPatch){
				var lvPatchData:* = lvPatch[skillLv]; 
				if (lvPatchData){
					if (!upData){
						skillObj = FightUtils.clone(skillObj);
					}
					for (key in lvPatchData)
					{
						FightUtils.addObjByPath(skillObj, key, lvPatchData[key]);
					}
				}
			}
			return skillObj;
		}
		
		/**
         * 得到描述的html文本
         */
		public function getInfoHtml(value:*):String{
			var lv:int = (value is ModelHero)?this.getLv(value):value;
			return this.getReplaceHtml('info',lv);
		}

		/**
         * 得到下一级的html文本
         */
		public function getNextHtml(value:*):String{
			var lv:int = (value is ModelHero)?this.getLv(value):value;
			if (lv >= this.getMaxLv()){
				return Tools.getMsgById('skill_lv_max');
			}
			else if (lv == 0){
				if (TestUtils.isTestShow){
					lv = 1;
				}
				else{
					return '';
				}
			}
			return Tools.getMsgById('skill_next',[this.getReplaceHtml('next',lv + 1)]);
		}
		
		/**
         * 得到替换的html文本
         */
		public function getReplaceHtml(key:String, skillLv:int, hasBrackets:Boolean = true):String{
			var replaceArr:Array = [];
			var skillObj:Object = PassiveStrUtils.getLvData(this.data, skillLv);
			var arr:Array = skillObj[key + 'Arr'];
			if (arr){
				var i:int;
				var len:int = arr.length;
				for (i = 0; i < len; i++) 
				{
					replaceArr.push(PassiveStrUtils.translateSkillInfo(skillObj, arr[i], skillLv, hasBrackets,true));
				}
			}
			return Tools.getMsgById(this.id + '_'+ key,replaceArr);
		}
		
		
		/**
         * 获取高级效果的解锁等级
         */
		public function getHighUnlockLv():int{
			var obj:Object = this.getHighObj();
			return obj?obj.lv:0;
		}
		/**
         * 获取高级效果的数据对象
         */
		private function getHighObj():Object{
			
			return this.data.high;
		}
		/**
         * 判定高级效果是否激活
         */
		public function checkHigh(hero:ModelHero = null):Boolean{
			var lv:int = this.getLv(hero);
			return lv >= this.getHighUnlockLv();
		}
		/**
         * 得到高级效果的解锁文本
         */
		public function getHighUnlockStr():String{
			var lv:int = this.getHighUnlockLv();
			var msg:String = lv > 0? Tools.getMsgById('skill_unlock', [this.getHighUnlockLv()]):Tools.getMsgById('skill_lock');
			return msg;
		}
		/**
         * 得到高级效果的html文本
         */
		public function getHighHtml():String{
			var lv:int = this.getHighUnlockLv();
			if (lv <= 0 ){
				return ' ';
			}
			var highArr:Object = this.data.highArr;
			if (!highArr){
				highArr = ['p|high.passive'];
			}
			var replaceArr:Array = [];
			var i:int;
			var len:int = highArr.length;
			for (i = 0; i < len; i++) 
			{
				replaceArr.push(PassiveStrUtils.translateSkillInfo(this.data, highArr[i],0,true,true));
			}
			var msg:String = Tools.getMsgById(this.id + '_high');
			if (!msg){
				msg = '{0}';
			}
			return Tools.replaceMsg(msg,replaceArr);
		}
		/**
         * 得到兽灵共鸣技能获得方式的描述，这里的star为兽灵品质
         */
		public function getBeastResonanceEnergyInfo(star:int, isHtml:Boolean = false):String{
			var len:int = this.id.length;
			var type:String = this.id.substr(len-2,1);
			var num:int = parseInt(this.id.substr(len-1));
			var min:int;
			var max:int;
			
			var energyArr:Array = this.data.energyArr;
			var starData:Object = this.getLvData(star);

			min = parseInt(PassiveStrUtils.translateSkillInfo(starData, energyArr[0], 0, false, false));
			max = parseInt(PassiveStrUtils.translateSkillInfo(starData, energyArr[1], 0, false, false)) + min;
			var countInfo:String = min == max?min.toString():Tools.getMsgById('_beastResonanceNum', [min, max]);
			if (isHtml){
				countInfo = '['+countInfo+']';
			}
			var typeInfo:String = Tools.getMsgById('_beastType_' + type);

			var msg:String = Tools.getMsgById('_beastResonanceNum' + num, [countInfo, typeInfo]);
			if (isHtml){
				msg = StringUtil.substituteWithLineAndColor(msg, EffectManager.getFontColor(star), '#EEEEEE');
			}
			return msg;
		}
		
		
		/**
         * 得到当前副将技能，提供的[攻,防]加成
         */
		public function getAdjutantArmyValues(armyType:int, skillLv:int):Array{
			//找到对应兵种的归档转化数组（简化）
			var cfgArr:Array = ConfigFight.propertyTransform[this.type == 7?'adjutantH':'adjutantA'];
			var rankArr:Array = FightUtils.getRankArr(skillLv, cfgArr);
			var obj:Object = {type:armyType};
			ModelPrepare.transformToArmy(obj, rankArr[1], skillLv - rankArr[0]);
			return [parseInt(Tools.numberFormat(obj.atk)),parseInt(Tools.numberFormat(obj.def))];
		}
			

		/**
         * 得到技能类型文本
         */
		public function getTypeStr(hasDetail:Boolean = true):String{
			return PassiveStrUtils.translateSkillTypeInfo(this.data, hasDetail);
		}
		/**
         * 得到技能类型单字文本
         */
		public function getTypeSimpleStr():String{
			var type:String = 'null';
			if (this.data.hasOwnProperty('type'))
			{
				type = this.data.type +'';
			}
			return Tools.getMsgById('skill_type_simple_' + type);
		}
		/**
         * 得到技能发动时机描述
         */
        public function getRoundStr():String{
			var str:String = this.id + '_round';
			if(!Tools.hasMsgById(str))
			{
				if (this.type == 5){
					return Tools.getMsgById(this.data.isAssist?'round_info_cond':'round_info_null');
				}
				else{
					return PassiveStrUtils.translateRoundInfo(FightUtils.getValueByPath(this.data, 'act[0]'));
				}
			}
			return Tools.getMsgById(str);
		}
		
		
		

        /**
         * 获得可学习这个技能前五的英雄
         */
        public function getSkillTopHero():Array{
            var allHero:Array=ModelManager.instance.modelUser.getMyHeroArr(true);
            var arr:Array=[];
            for(var i:int=0;i<allHero.length;i++){
                var hmd:ModelHero=allHero[i];
                var b:Boolean = this.isCanGetOrUpgrade(hmd).isOK;
                if(b){
                    if(this.type<=3){
                        if(hmd.army.indexOf(this.type)!=-1){
                            allHero[i]["sortSlv"]=this.getLv(hmd);
                            arr.push(allHero[i]);
                        }
                    }else{
                        allHero[i]["sortSlv"]=this.getLv(hmd);
                        arr.push(allHero[i]);
                    }
                    
                }
            }
            ArrayUtils.sortOn(["sortSlv","sortPower"],arr,true);
            var a:Array=[];
            for(var j:int=0;j<5;j++){
                if(arr[j]){
                    a.push(arr[j]);
                }
            }
            return a;
        }

		/**
         * 输入技能对象，返回排好顺序的技能数组
         */
        public static function getSortSkillArr(skills:Object,hmd:ModelHero,ignore0:Boolean = false):Array
        {
			var skillArr:Array = [];
			var skill:Object;
			var lv:int;
			var key:String;
			var smd:ModelSkill;
			
			for (key in skills){
				smd = ModelManager.instance.modelGame.getModelSkill(key);
				if(smd && smd.id.indexOf('skill')==0){
					if(hmd){
						lv = smd.getLv(hmd);
					}
					else{
						lv = skills[key];
					}
					if (ignore0 && lv <= 0){
						continue;
					}
					smd["sortLv"] = ((lv > 0)?1:2) * 1000000 + smd.index;
					smd["lv"] = lv;
					skillArr.push(smd);
				}
			}
            skillArr.sort(MathUtil.sortByKey("sortLv"));
            return skillArr;
        }

        /**
         * 沙盘演义决定了技能是否可以升级
         */
        public static function isCanLvUpByPVE(lv:Number):Array{
            //var o:Object=ConfigServer.pve.chapter;
            var skill_lv_limit:Array=ConfigServer.system_simple.skill_lv_limit;
            var arr:Array=[true,0];
            lv-=1;
            if(lv>skill_lv_limit.length-1){
                return arr;
            }
           for(var i:int=0;i<skill_lv_limit.length;i++){
                var oo:Object=ModelManager.instance.modelUser.pve_records.chapter;
                var s:String=skill_lv_limit[i]<10?"chapter00"+skill_lv_limit[i]:"chapter0"+skill_lv_limit[i];
                if(skill_lv_limit[i]!=0 && i == lv){
                    if(oo.hasOwnProperty(s)){
                        var n:Number=0;
                        var star:Object=oo[s].star;
                        for(var key:String in star){
                            var a:Array=star[key];
                            for(var j:int=0;j<a.length;j++){
                                n+=a[j];
                            }
                        }
                        arr=[n==12,skill_lv_limit[i]];
                    }else{
                        arr=[false,skill_lv_limit[i]];
                    }
                    break;
                }
                
           }
        //    trace(lv,arr);
           return arr;
        }
        public static function setSpecial(sid:String,hid:String,del:Boolean = false):void{
            var dic:Object = SaveLocal.getValue(SaveLocal.KEY_HERO_SKILL_SPECIAL);
            if(!dic){
                dic = {};
            }
            dic[sid] = hid;
            if(del){
                delete dic[sid];
            }
            SaveLocal.save(SaveLocal.KEY_HERO_SKILL_SPECIAL,dic);
        }
        public static function getSpecial(sid:String):String{
            var dic:Object = SaveLocal.getValue(SaveLocal.KEY_HERO_SKILL_SPECIAL);
            if(dic && dic[sid]){
                return dic[sid];
            }
            return "";
        }

        /**
         * 是否可以通过问道获得
         */
        public static function isCanResolve(sid:String):Boolean{
            var allHeros:Object=ModelManager.instance.modelUser.hero;
            var itemSkill:ModelSkill=ModelManager.instance.modelGame.getModelSkill(sid);
            for(var h:String in allHeros){
                var itemHero:ModelHero=ModelManager.instance.modelGame.getModelHero(h);
                if(itemSkill.isResolve(itemHero)){
                    return true;
                }
            }
            return false;
        }
    }
}