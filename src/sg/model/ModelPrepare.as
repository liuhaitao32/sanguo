package sg.model
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.fight.test.TestFightData;
	import sg.utils.StringUtil;
	
	/**
	 * 备战数据，传入的数据为PrepareInData，处理完成的数据为PrepareOutData，都可以用来存档
	 * @author zhuda
	 */
	public class ModelPrepare //extends ModelBase
	{
		public static var _testAllTime:Number = 0;
		
		public var data:Object;
		
		///最终固定属性
		private var _fixed:Object;
		///无条件无优先级priority的被动效果，最优先混合
		private var _passive:Object;
		///有条件或有优先级的被动效果
		private var _passiveArr:Array;
		///无条件无优先级的被动特效，最优先混合
		private var _special:Object;
		///有条件或有优先级的被动特效，最后加到对象中
		private var _specialArr:Array;
		///是战斗前使用时，才展开天赋和技能的up并计算_special，且是否最简化
		private var _isFight:Boolean;
		///是否移除装备等信息，如果移除将无法还原面板显示
		//private var _delInfo:Boolean;

		
		/**
		 * 取得指定NPC配置的模拟战力取整到百(忽略技能)  NPC类型，NPC等级，系数
		 */
		public static function getNPCPower(type:String,lv:int,rate:Number = 1, powerType:String = ''):int
		{
			var data:Object;
			//0位NPC类型，1位NPC等级
			var cfgType:Object = ConfigServer.pk_robot[type];
			if(cfgType[lv]){
				data = cfgType[lv];
			}else{
				data = cfgType['default'];
			}
			if (!data){
				return -1;
			}
			data = FightUtils.clone(data);
			data.lv = lv;
			var power:int = ModelPrepare.getNPCDataPower(data);
			var enemy_lv_power:Object = ConfigServer.world.enemy_lv_power;
			if (!powerType) powerType = type;
			var arr:Array = enemy_lv_power[powerType];
			if (arr)
			{
				power = Math.ceil(power + arr[0] + lv * arr[1] + lv * lv * arr[2] + lv * lv * lv * arr[3]);
			}
			power = getFormatPower(power,rate);
			return power;
		}
		/**
		 * 包装战力，系数
		 */
		public static function getFormatPower(power:int,rate:Number = 1):int
		{
			power *= rate;
			power = parseInt(StringUtil.numToWholeStr(power, 100));
			return power;
		}
		/**
		 * 取得指定NPC随机配置的模拟战力(忽略技能)  0位NPC类型，1位NPC等级
		 */
		public static function getNPCDataPower(data:Object):int
		{
			var preData:Object = FightUtils.clone(data);
			preData.hid = 'hero716';
			var skillArr:Array = preData.skill;
			delete preData.skill;
			preData.skill = FightUtils.clone(ConfigServer.hero[preData.hid].skill);
			
			var reObj:Object = (new ModelPrepare(preData)).data;
			return reObj.power;
		}
		
		
		/**
		 * 计算一队的战力，返回结果为{'hero701':200,'hero702':111}
		 */
		public static function getHeroesPower(dataArr:Array):Object
		{
			var reObj:Object = {};
			var reArr:Array = initPrepareDataArr(dataArr, false);
			var len:int = reArr.length;
			for (var i:int = 0; i < len; i++)
			{
				var data:Object = reArr[i];
				reObj[data.hid] = data.power;
			}
			return reObj;
		}
		
		/**
		 * 计算一队的总战力
		 */
		public static function getAllPower(dataArr:Array):int
		{
			var reArr:Array = initPrepareDataArr(dataArr, false);
			var power:int = 0;
			var len:int = reArr.length;
			for (var i:int = 0; i < len; i++)
			{
				var data:Object = reArr[i];
				power += data.power;
			}
			print("\n总战力:" + power);
			return power;
		}
		
		/**
		 * 初始化一队的数据（仅在战前调用）
		 */
		public static function initPrepareDataArr(dataArr:Array, isFight:Boolean):Array
		{
			var reArr:Array = [];
			var len:int = dataArr.length;
			for (var i:int = 0; i < len; i++)
			{
				reArr.push(new ModelPrepare(dataArr[i], isFight).data);
			}
			return reArr;
		}
		
		/**
		 * 自动判断是否重新生成数据
		 */
		public static function getData(data:Object, isFight:Boolean = false):Object
		{
			if (data && !data.hasOwnProperty('power')){
				return new ModelPrepare(data, isFight).data;
			}
			return data;
		}
		/**
		 * 得到指定部队数据的  [当前兵力,总兵力]  （仅客户端在战前调用）
		 */
		public static function getHpAndHpm(data:Object):Array
		{
			var temp:Object = ModelPrepare.getData(data);
			return [temp.army[0].hp + temp.army[1].hp, temp.army[0].hpm + temp.army[1].hpm];
		}
		
		/**
		 * 备战数据
		 * @param	data
		 * @param	isFight  是战斗前使用时，才展开天赋和技能的up并计算_special，isFight是否最简化
		 */
		public function ModelPrepare(data:Object, isFight:Boolean = false)
		{
			// super();
			this._isFight = isFight;
			if (this.setData(data) && isFight)
			{
				this.checkSimplest();
				print("checkSimplest", this.data);
			}
		}
		
		public function setData(data:Object):Boolean
		{
			this.data = data;
			if (data.hasOwnProperty("power"))
				return false;
			if (!data || !ConfigServer.hero[data.hid]){
				console.error("ModelPrepare 被传入了无效的hid，源数据：" + JSON.stringify(data));
			}
			//print("\n新的 ModelPrepare  " + this._isFight);
			
			this.data = FightUtils.clone(data);
			//print("dataIn", this.data);
			if (ConfigApp.testTimeRate)
			{
				var startTime:int = new Date().getTime();
			}
			this.checkDefault();
			//ModelPrepare._testAllTime += (new Date().getTime() - startTime);
			//print("checkDefault", this.data);
			this.checkEquip();
			//print("checkEquip", this.data);
			this.checkStar();
			//print("checkStar", this.data);
			this.checkFormation();
			//print("checkStar", this.data);
			this.checkFate();
			//print("checkFate", this.data);
			this.checkTitle();
			this.checkScience();
			this.checkOfficial();
			this.checkWeak();
			
			this.checkInborn();
			this.checkAdjutant();
			this.checkLegend();
			
			this.checkBeast();
			this.checkSkill();
			//print("checkSkill", this.data);
			this.checkShogun();
			
			this.checkPassive();
			//print("checkPassive", this.data);
			this.checkSpecial();
			this.checkTransform();
			//print("checkTransform", this.data);
			this.checkMerge();
			//print("checkMerge", this.data);
			this.checkPower();
			if (ConfigApp.testTimeRate)
			{
				ModelPrepare._testAllTime += (new Date().getTime() - startTime);
			}
			//print("checkPower", this.data);
			return true;
		}
		
		/**
		 * 返回可以用于战斗初始化的数据
		 */
		public function getData():*
		{
			return this.data;
		}
		
		/**
		 * 混合passive {rslt}或special或fixed
		 */
		private function addPS(psData:*, isPassive:Boolean):void
		{
			if (psData == null || (!isPassive && !this._isFight))
				return;
			if (psData is Array)
			{
				var arr:Array = psData;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++)
				{
					this.addPS(arr[i], isPassive);
				}
			}
			else
			{
				if (psData.priority || psData.cond || psData.special)
				{
					var psArr:Array = isPassive ? this._passiveArr : this._specialArr;
					psArr.push(psData);
				}
				else
				{
					//无条件无优先级的
					var psObj:Object = isPassive ? this._passive : this._special;
					FightUtils.mergeObj(psObj, psData);
				}
			}
		}
		/**
		 ** 混合fixed，只会在非覆盖属性上
		 */
		private function addFixed(fixedData:*):void
		{
			if (fixedData == null)
				return;
			FightUtils.mergeObj(this._fixed, fixedData);
		}
		
		/**
		 * 补足缺省值
		 */
		private function checkDefault():void
		{
			var i:int;
			var j:int;
			var len:int;
			var key:String;
			
			for (key in ConfigFight.propertyDefaultData)
			{
				FightUtils.fillDefault(this.data, key, ConfigFight.propertyDefaultData[key]);
			}
			
			//通过英雄id自行初始化属性
			var heroCfg:* = ConfigServer.hero[this.data.hid];
			for (i = 0, len = ConfigFight.propertyHeroDefaultArr.length; i < len; i++)
			{
				key = ConfigFight.propertyHeroDefaultArr[i];
				FightUtils.fillDefault(this.data, key, heroCfg[key]);
			}
			
			FightUtils.fillDefault(this.data, 'skill', FightUtils.clone(heroCfg.skill?heroCfg.skill:{}));
			
			this._fixed = {};
			this._passive = {};
			this._passiveArr = [];
			if (this._isFight)
			{
				this._special = {};
				this._specialArr = [];
			}
			
			//this.addPS(heroCfg.passive, true);
			//this.addPS(heroCfg.special, false);
			
			this.addPS(this.data.passive, true);
			this.addPS(this.data.special, false);
			this.addFixed(this.data.fixed);
			delete this.data.passive;
			delete this.data.special;
			delete this.data.fixed;
			//this.fillDefault('fate', []);
			//this.fillDefault('adjutant', []);
			//this.fillDefault('shogun', [0, 0]);
			//this.data.power = 0;
	
			//初始化兵种属性
			var armyData:*;
			if (this.data.army == null)
			{
				this.data.army = [];
				
				var armyRank:int = this.data.armyRank != null ? this.data.armyRank : 0;
				var armyLv:int = this.data.armyLv != null ? this.data.armyLv : 0;
				var armyAdd:int = this.data.armyAdd != null ? this.data.armyAdd : 1;
				var armyArr:Array = heroCfg.army;
				for (i = 0; i < ConfigFight.armyNum; i++)
				{
					var armyType:int = armyArr[i];
					armyData = {type: armyType, rank: armyRank, lv: armyLv, add: [armyAdd, 0]};
					this.data.army.push(armyData);
				}
			}
			else
			{
				for (i = 0; i < ConfigFight.armyNum; i++)
				{
					armyData = this.data.army[i];
					if (!armyData.hasOwnProperty('type'))
						armyData.type = 0;
					if (!armyData.hasOwnProperty('rank'))
						armyData.rank = 0;
					if (!armyData.hasOwnProperty('lv'))
						armyData.lv = 0;
					if (!armyData.hasOwnProperty('add'))
						armyData.add = [1, 0];
				}
			}

			var propArr:Array = this._isFight ? ConfigFight.propertySecondLevelArr : ConfigFight.propertyArmyArr;
			//初始化所有二级属性为0
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				armyData = this.data.army[i];
				for (j = propArr.length - 1; j >= 0; j--)
				{
					armyData[propArr[j]] = 0;
				}
			}
			for (j = propArr.length - 1; j >= 0; j--)
			{
				this.data[propArr[j]] = 0;
			}
			
			//默认值初始化完毕
			if (this.data.passiveFirst){
				//首先初始化额外附加的属性
				this.addPS(this.data.passiveFirst, true);
				this.checkPassive();
				this._passiveArr = [];
				delete this.data.passiveFirst;
			}
		}
		
		/**
		 * 将宝物携带的属性，以及洗炼、强化效果加入
		 */
		private function checkEquip():void
		{
			if (!this.data.hasOwnProperty('equip'))
			{
				return;
			}
			for (var j:int = this.data.equip.length - 1; j >= 0; j--)
			{
				var equipDataArr:Array = this.data.equip[j];
				
				var key:String = equipDataArr[0];
				var equipCfg:* = ConfigServer.equip[key];
				if (equipCfg != null)
				{
					var equipLv:int = equipDataArr[1];
					var i:int;
					for (i = 0; i <= equipLv; i++)
					{
						var lvData:Object = equipCfg.upgrade[i.toString()];
						if (lvData)
						{
							this.addPS(lvData.passive, true);
						}
					}
					var equipWashArr:Array = equipDataArr[2];
					//洗炼属性
					for (i = equipWashArr.length - 1; i >= 0; i--)
					{
						var washId:String = equipWashArr[i];
						var washCfg:* = ConfigServer.equip_wash[washId];
						if (washCfg)
						{
							this.addPS(washCfg.passive, true);
						}
					}
					
					var equipRise:int = equipDataArr.length > 3?equipDataArr[3]:0;
					//强化属性
					if (equipRise){
						this.addEquipRise(equipCfg.type, equipRise);
					}
				}
			}
		}
		/**
		 * 追加装备宝物的强化属性
		 */
		protected function addEquipRise(type:int,rise:int):void
		{
			var cfg:Object = ConfigFight.equipRise[type];
			if (cfg){
				var rankObj:Object = FightUtils.getRankObj(rise, cfg.base);
				this.addPS({'rslt':rankObj}, true);
				var arr:Array = cfg.high;
				var len:int = arr.length;
				for (var i:int = 0; i < len; i++) 
				{
					var tempArr:Array = arr[i];
					if (rise >= tempArr[0]){
						this.addPS({'rslt':tempArr[1]}, true);
					}
					else{
						break;
					}
				}
			}
		}
		
		
		/**
		 * 将星辰属性合并
		 */
		protected function checkStar():void
		{
			if (!this.data.hasOwnProperty('star'))
			{
				return;
			}
			var stars:* = this.data.star;
			//var transCfg:* = ConfigFight.starTransform;
			var skillCfg:* = ConfigServer.skill;
			var starCfg:* = ConfigServer.star;
			for (var key:String in stars)
			{
				if (starCfg.hasOwnProperty(key))
				{
					var starData:Object = starCfg[key];
					if (starData)
					{
						starData = PassiveStrUtils.getLvData(starData, stars[key], true);
						this.addPS(starData.passive, true);
					}
				}
				//if (transCfg.hasOwnProperty(key)) {
				////给全军添加属性
				//this.checkTransformOne(stars[key], transCfg[key]);
				//}
				if (skillCfg.hasOwnProperty(key))
				{
					//给该部队添加同key技能，等级也相同
					this.data.skill[key] = stars[key];
				}
			}
			delete this.data.star;
		}
		
		/**
		 * 将阵法属性合并
		 */
		protected function checkFormation():void
		{
			if (!this.data.hasOwnProperty('formation_arr') && !this.data.hasOwnProperty('formation_index') && !this.data.hasOwnProperty('formation'))
			{
				return;
			}
			//如果是养成数据，需要先转置
			ModelFormation.translateObj(this.data);
			
			//return;

			var modelFormation:ModelFormation;
			var formationArr:Array = this.data.formation;
			var formationData:Object = formationArr[1];
			var formationCfg:Object = ConfigServer.fight.formation;
			var formationIndex:int = formationArr[0];
			var formationIndexCfg:Object = formationCfg[formationIndex];
			var passiveObj:Object;

			if (formationData){
				//将所有被动阵法的属性都加上
				var formationCurr:Array;
				var lv:int;
				var star:int;
				
				for (var key:* in formationData){
					formationCurr = formationData[key];
					lv = formationCurr[1];
					if(lv > 0){
						modelFormation = ModelFormation.getModel(key);
						passiveObj = modelFormation.getLvObj(lv, false);
						this.addPS({'rslt':passiveObj}, true);
					}
				}
				
				//将激活阵法的属性都加上(含克制效果)
				if (formationIndexCfg){
					formationCurr = formationData[formationIndex];
					star = 0;
					lv = 0;
					if (formationCurr){
						star = formationCurr[0];
						lv = formationCurr[1];
					}
					
					modelFormation = ModelFormation.getModel(formationIndex);
					passiveObj = modelFormation.getLvObj(lv, true);
					this.addPS({'rslt':passiveObj}, true);
					
					var starRank:Array = formationIndexCfg.starRank;
					if(starRank){
						if (star >= starRank.length) star = starRank.length-1;
						for (var i:int=0; i <= star; i++) 
						{
							var starPS:Object = starRank[i];
							this.addPS(starPS.passive, true);
							this.addPS(starPS.special, false);
						}
					}	
				}
			}
		}
		
		
		/**
		 * 将宿命属性合并
		 */
		protected function checkFate():void
		{
			if (!this.data.hasOwnProperty('fate'))
			{
				return;
			}
			var fightFateArr:Array = [];
			var fateArr:Array = this.data.fate;
			var skillCfg:* = ConfigServer.skill;
			for (var i:int = fateArr.length-1; i >= 0; i--)
			{
				var key:String = fateArr[i];
				var fateCfg:* = ConfigServer.fate[key];
				
				if (fateCfg)
				{
					this.addPS(fateCfg.passive, true);
				}
				if (skillCfg.hasOwnProperty(key))
				{
					//容错，给没有配置的宿命添加合击技能
					this.data.skill[key] = 1;
				}
			}
			//this.data.fate = fightFateArr;
		}
		/**
		 * 将称号属性加入
		 */
		private function checkTitle():void
		{
			if (this.data.title)
			{
				var title:String = this.data.title;
				var titleCfg:* = ConfigServer.title[title];
				if (titleCfg != null){
					var pObj:Object = titleCfg.passive;
					this.addPS(pObj, true);
				}
			}
		}
		/**
		 * 将科技包含的所有被动效果加入
		 */
		private function checkScience():void
		{
			var key:String;
			for (key in this.data.science_passive)
			{
				//key = '999';
				var scienceCfg:* = ConfigServer.science[key];
				if (scienceCfg != null)
				{
					//trace("\n     打印 scienceCfg:\n" + JSON.stringify(skillCfg));
					var lv:int = this.data.science_passive[key];
					if (scienceCfg.hasOwnProperty('passive'))
					{
						var pObj:Object = scienceCfg.passive;
						pObj = PassiveStrUtils.getMultPassive(pObj, lv);
						this.addPS(pObj, true);
					}
				}
			}
			delete this.data.science_passive;
		}
		
		/**
		 * 将官职包含的所有被动效果加入
		 */
		private function checkOfficial():void
		{
			if (this.data.hasOwnProperty('official'))
			{
				var official:int = this.data.official;
				if (official > -100)
				{
					if (official >= 0 && official <= 4)
					{
						var milepost:int = this.data.milepost ? this.data.milepost : 0;
						if (milepost < 5)
						{
							//称帝前属性无效
							return;
						}
					}
					else if (official < 0)
					{
						
					}
					else
					{
						//其他官职无属性
						return;
					}
					var key:String = this.data.official.toString();
					
					var officialCfg:* = ConfigFight.official[key];
					if (officialCfg != null)
					{
						this.addPS(officialCfg, true);
					}
				}
				
			}
		}
		
		/**
		 * 计算天赋效果
		 */
		private function checkInborn():void
		{
			var inbornCfg:Object = ConfigServer.inborn[this.data.hid];
			if (inbornCfg){
				this.addPS(inbornCfg.passive, true);
				this.addPS(inbornCfg.special, false);
				if(inbornCfg.fixed){
					this.addFixed(inbornCfg.fixed);
					this.fixedProp(inbornCfg.fixed);
				}
			}
			//判断觉醒天赋
			if (this.data.awaken){
				inbornCfg = ConfigServer.inborn[this.data.hid + 'a'];
				if (inbornCfg){
					this.addPS(inbornCfg.passive, true);
					this.addPS(inbornCfg.special, false);
				}
			}
		}
		
		/**
		 * 添加副将技能
		 */
		private function checkAdjutant():void
		{
			var adjutantArr:Array = this.data.adjutant;
			if (adjutantArr){
				var adjutantOne:Array;
				var len:int = adjutantArr.length;
				var heroCfg:Object = ConfigServer.hero;
				var skillCfgH:Object = ConfigServer.system_simple.adjutant_skill_hero;
				var skillCfgA:Object = ConfigServer.system_simple.adjutant_skill_army;
				//遍历前后军副将
				for (var i:int = 0; i < len; i++) 
				{
					adjutantOne = adjutantArr[i];
					if (adjutantOne){
						//找到对应副将的特殊效果和技能添加 [副将id, 副将英雄技总等级, 副将兵种技总等, 副将星级, 副将宝物总评分]
						var hid:String = adjutantOne[0];
						var currHeroCfg:Object = heroCfg[hid];
						if (currHeroCfg){
							//英雄技总和
							var skillLvH:int = adjutantOne[1];
							//兵种技总和
							var skillLvA:int = adjutantOne[2];
							//副将宝物评分总和，影响主将属性
							var skillLvE:int = adjutantOne.length>4?adjutantOne[4]:0;
							var skillId:String;
							if (skillLvH > 0){
								this.data.skill[skillCfgH[currHeroCfg.type][i]] = skillLvH;
							}
							if (skillLvA > 0){
								this.data.skill[skillCfgA[currHeroCfg.army[i]]] = skillLvA;
							}
							if (skillLvE > 0){
								var eObj:Object = FightUtils.getRankObj(skillLvE, ConfigFight.adjutantEquipScore);
								this.addPS({'rslt': eObj},true);
							}
							
							//副将星级品质影响主将属性
							var adjutantSpecial:Object = ConfigServer.fight.adjutantSpecial[hid];
							if (adjutantSpecial){
								var arr:Array = adjutantSpecial.hero_star;
								var hero_star:int = adjutantOne[3];
								if (arr){
									var rankArr:Array = FightUtils.getRankArr(hero_star, arr);
									//ModelPrepare.transformToArmy(this.data, rankArr[1], hero_star - rankArr[0]);
									
									this.addPS({'rslt': rankArr[1]},true);
								}
								//特殊副将天赋，按星级赋予
								var inbornAdjCfg:Object = ConfigServer.inborn[hid + 'adj'];
								if (inbornAdjCfg){
									for (var key:String in inbornAdjCfg){
										var starNum:int = parseInt(key);
										if (hero_star >= starNum){
											var inbornCfg:Object = inbornAdjCfg[key];
											this.addPS(inbornCfg.passive, true);
											this.addPS(inbornCfg.special, false);
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		/**
		 * 添加传奇英雄效果
		 */
		private function checkLegend():void
		{
			var key:String;
			for (key in this.data.legend)
			{
				var legendCfg:* = ConfigFight.legendTalent[key];
				if (legendCfg != null)
				{
					var legendArr:Array;
					var armyIndex:int = -1;
					if (legendCfg is Array){
						legendArr = legendCfg as Array;
					}
					else{
						legendArr = legendCfg.prop;
						armyIndex = legendCfg.armyIndex;
					}
					this.checkTransformOne(this.data.legend[key], legendArr, armyIndex);
				}
			}
		}
		
		
		/**
		 * 将技能所包含的passive,以及额外进阶效果加入
		 */
		private function checkSkill():void
		{
			var key:String;
			for (key in this.data.skill)
			{
				var skillCfg:Object = ConfigServer.skill[key];
				if (skillCfg != null)
				{
					var skillObj:Object;
					var skillLv:int = this.data.skill[key];
					var cloneType:int = this._isFight ? 2 : 1;
					skillObj = FightUtils.getSkillLvData(skillCfg, skillLv, cloneType);
					
					//trace("\n     打印 skillCfg:\n" + JSON.stringify(skillCfg));
					this.addPS(skillObj.passive, true);
					this.addPS(skillObj.special, false);
					
					var highObj:Object = skillCfg.high;
					if (highObj && skillLv >= highObj.lv)
					{
						this.addPS(highObj.passive, true);
						this.addPS(highObj.special, false);
					}
					
					//加上N级以后的进阶属性效果
					if (ConfigFight.skillTypeLv.hasOwnProperty(skillCfg.type))
					{
						var obj:* = ConfigFight.skillTypeLv[skillCfg.type];
						if (obj.hasOwnProperty(skillLv))
						{
							this.addPS({'rslt': obj[skillLv]}, true);
								//(this.data.passive as Array).push({'rslt': obj[skillLv]});
						}
					}
				}
			}
		}
		
		/**
		 * 将幕府的战力加入
		 */
		private function checkShogun():void{
			if (ConfigFight.shogunHeroRate && this.data.shogun){
				var arr:Array = this.data.shogun;
				var obj:Object;
				var value:int = arr[0];
				if(value){
					obj = FightUtils.clone(ConfigFight.shogunHeroRate);
					obj = FightUtils.multObject(obj, value) ;
					FightUtils.mergeObj(this.data, obj);
				}
				for (var i:int = 0; i < ConfigFight.armyNum; i++) 
				{
					value = arr[i + 1];
					if (value){
						obj = FightUtils.clone(ConfigFight.shogunArmyRate);
						obj = FightUtils.multObject(obj, value) ;
						FightUtils.mergeObj(this.data.army[i], obj);
					}
				}
			}
		}
		
		/**
		 * 将八门兽灵加入，加入基础效果、副属性、以及套装共鸣
		 */
		private function checkBeast():void{
			if (this.data.beast){
				var arr:Array = this.data.beast;
				var len:int = arr.length;
				
				//基础属性
				var passiveLvObj:Object = {'rslt':ModelBeast.getAllLvObj(arr)};
				this.addPS(passiveLvObj, true);
				
				//全部副属性
				var superValueObject:Object = ModelBeast.getAllSuperObject(arr);
				//内部{beast,skill}
				//var superBeastObj:Object = {beast:{},skill:{}};
				var key:String;
				for (key in superValueObject){
					//FightUtils.mergeObj(superBeastObj, ModelBeast.getSuperBeastObj(key, superValueObject[key]));

					var passiveSuperObj:Object = ModelBeast.getSuperPassiveObj(key, superValueObject[key]);
					this.addPS(passiveSuperObj, true);
				}
				
				//this.addPS(superBeastObj, false);
				//var special
				//this.addPS(passiveLvObj,true);
				//for (var i:int = 0; i < len; i++) 
				//{
					//var oneArr:Array = arr[i];
					//var type:String = oneArr[0];
					//var pos:String = oneArr[1];
					//var star:String = oneArr[2];
					//var lv:String = oneArr[3];
					//var superArr:Array = oneArr[4];
				//}

				//加入共鸣技能
				var resonanceSkillObj:Object = ModelBeast.getResonanceSkillObj(arr);
				FightUtils.mergeObj(this.data.skill, resonanceSkillObj);
			}
		}
		
		
		/**
		 * 排序并将满足条件的被动叠加到对应属性中
		 */
		private function checkPassive():void
		{
			var passiveArr:Array = this._passiveArr;
			if (this._passive.rslt)
			{
				passiveArr.unshift(this._passive);
			}
			
			var i:int;
			var len:int = passiveArr.length;
			for (i = 0; i < len; i++)
			{
				if (!passiveArr[i].hasOwnProperty('priority'))
				{
					passiveArr[i].priority = 0;
				}
			}
			if(len > 1){
				FightUtils.sortPriority(passiveArr);
			}
			
			for (i = 0; i < len; i++)
			{
				this.checkPassiveOne(passiveArr[i]);
			}
		
			//this._passiveArr = null;
			//this._passive = null;
			//delete this.data.passive;
		}
		
		private function checkPassiveOne(passiveData:Object):void
		{
			var mult:int = 1;
			var value:*;

			if (passiveData.hasOwnProperty('cond'))
			{
				var condArr:Array = passiveData.cond;
				var key:String = condArr[0];

				if (key == 'equip')
				{
					mult = this.getEquipMult(condArr);
				}
				else{
					var type:String = condArr[1];
					value = FightUtils.getValueByPath(this.data, key);
					if (value == null){
						value = 0;
					}
					if (!FightUtils.compareValue(value, condArr[2], type))
					{
						return;
					}
					if (type == '*')
					{
						//该值比基准值大N，获得N倍效果，最大不超过M倍
						if (value <= condArr[2])
						{
							return;
						}
						else
						{
							mult = value - condArr[2];
							if (condArr.length > 3)
							{
								mult = Math.min(mult, condArr[3]);
							}
							mult = Math.max(mult, 1);
						}
					}
				}
							
			}
			if (mult <= 0){
				return;
			}

			if (passiveData.hasOwnProperty('rslt'))
			{
				var rsltObj:Object = passiveData.rslt;
				for (var path:String in rsltObj)
				{
					value = rsltObj[path];
					if (value is Number){
						FightUtils.addObjByPath(this.data, path, value * mult);
					}
					else{
						FightUtils.changeObjByPath(this.data, path, value);
					}
				}
			}
			if (passiveData.hasOwnProperty('special'))
			{
				if (mult > 1){
					//倍化
					var specialObj:Object = FightUtils.clone(passiveData.special);
					specialObj = FightUtils.multObject(specialObj, mult);
					this.addPS(specialObj, false);
				}
				else{
					this.addPS(passiveData.special, false);
				}
			}
		}
		/**
		 * 返回当前套装要求下的加成倍数
		 */
		private function getEquipMult(condArr:Array):int
		{
			var equipDataArr:Array = this.data.equip;
			if (!equipDataArr)
				return 0;
				
			var idsArr:Array = condArr[1];
			var groupArr:Array = condArr[2];
			var needIdsLv:int = condArr.length>3?condArr[3]:0;
			
			var hasIdsNum:int = 0;
			var hasGroupNum:int = 0;
			var condIdsNum:int = idsArr?idsArr.length:0;
			var condGroupNum:int = groupArr?groupArr[1]:0;
			
			for (var i:int = equipDataArr.length -1; i >= 0; i--) 
			{
				var equipOneArr:Array = equipDataArr[i];
				var equipId:String = equipOneArr[0];
				var equipLv:int = equipOneArr[1];
				var equipCfg:Object = ConfigServer.equip[equipId];
				
				if (idsArr){
					//必须携带某几种宝物
					if (idsArr.indexOf(equipId) >= 0 && equipLv >= needIdsLv){
						hasIdsNum ++;
					}
				}
				if (groupArr){
					//必须含有的[套装id,套装个数（为负时每件套属性加倍）,套装品质]
					if (groupArr[0] == equipCfg.group && equipLv >= groupArr[2]){
						hasGroupNum ++;
					}
				}
			}
			if (hasIdsNum < condIdsNum || hasGroupNum < condGroupNum){
				//未达到要求
				return 0;
			}
			if (condGroupNum<0){
				return hasGroupNum;
			}
			else {
				return 1;
			}
		}
		
		/**
		 * 混合弱点到Passive
		 */
		private function checkWeak():void
		{
			if (!this._isFight)
				return;
			if (this.data.weak)
			{
				//异邦来访，弱点伤害加成
				var weakArr:Array = this.data.weak;
				var len:int = weakArr.length;
				for (var i:int = 0; i < len; i++)
				{
					this.addPS(FightUtils.formatWeakToPassive(weakArr[i], false), true);
				}
			}
		}
		
		/**
		 * 混合最终的SP数据放入data
		 */
		private function checkSpecial():void
		{
			if (!this._isFight)
				return;
			
			var specialArr:Array = this._specialArr;
			if (!FightUtils.isNullObj(this._special))
			{
				specialArr.unshift(this._special);
			}
			if (!FightUtils.isNullObj(specialArr))
			{
				this.data.special = specialArr;
			}
		}
		
		/**
		 * 将一级属性转化到二级属性，将根目录二级属性转移到兵种属性中，移除根目录二级属性
		 */
		protected function checkTransform():void
		{
			var transCfg:* = ConfigFight.propertyTransform;
			this.checkTransformOne(this.data.str, transCfg.str);
			this.checkTransformOne(this.data.agi, transCfg.agi);
			this.checkTransformOne(this.data.cha, transCfg.cha);
			this.checkTransformOne(this.data.lead, transCfg.lead);
			
			this.checkTransformOne(this.data.lv, transCfg.lv);
			this.checkTransformOne(this.data.hero_star, transCfg.hero_star);
			//this.checkTransformOne(this.data.rarity, transCfg.rarity);
			
			var buildingLv:Array = this.data.building;
			if (buildingLv)
			{
				this.checkTransformOne(buildingLv[0], transCfg.building0);
				this.checkTransformOne(buildingLv[1], transCfg.building1);
			}
			
			var i:int;
			var j:int;
			var key:String;
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				var army:* = this.data.army[i];
				this.checkTransformOne(army.lv, transCfg.armyLv, i);
				this.checkTransformOne(army.rank, transCfg.armyRank, i);
				
				//将兵种强化信息转移到兵种属性
				for (j = 0; j < ConfigFight.armyAddNum; j++)
				{
					var addLv:int = army.add[0] + (j < army.add[1] ? 1 : 0);
					this.checkTransformOne(addLv, transCfg['armyAdd' + j], i);
				}
				
				//将根目录二级属性转移到兵种属性中
				var propArr:Array = this._isFight ? ConfigFight.propertyTransformArr : ConfigFight.propertyArmyArr;
				for (j = propArr.length - 1; j >= 0; j--)
				{
					key = propArr[j];
					army[key] += this.data[key];
				}
			}
			this.checkTransformAdjutant();
			
			//移除根目录二级属性
			for (j = ConfigFight.propertyDeleteArr.length - 1; j >= 0; j--)
			{
				key = ConfigFight.propertyDeleteArr[j];
				delete this.data[key];
			}
		}
		
		/**
		 * 判断前后军副将，转移属性到对应兵种中
		 */
		protected function checkTransformAdjutant():void
		{
			var transCfg:* = ConfigFight.propertyTransform;
			//判断前后军副将，转移属性到对应兵种中
			var adjutantArr:Array = this.data.adjutant;
			if (adjutantArr){
				var adjutantOne:Array;
				var len:int = adjutantArr.length;
				var i:int;
				for (i = 0; i < len; i++) 
				{
					adjutantOne = adjutantArr[i];
					if (adjutantOne){
						//找到对应副将的特殊效果和技能添加
						//var hid:String = adjutantOne[0];
						var skillLv0:int = adjutantOne[1];
						var skillLv1:int = adjutantOne[2];
						this.checkTransformOne(skillLv0, transCfg.adjutantH, i);
						this.checkTransformOne(skillLv1, transCfg.adjutantA, i);
					}
				}
			}
		}
		
		/**
		 * 转化某种一级属性到兵种二级属性。value一级属性值，arr归档前转化数组，armyIndex范围（0前1后-1全）
		 */
		private function checkTransformOne(value:int, arr:Array, armyIndex:int = -1):void
		{
			if(arr){
				var rankArr:Array = FightUtils.getRankArr(value, arr);
				this.transformToArmys(rankArr[1], value - rankArr[0], armyIndex);
			}
		}
		
		/**
		 * 前后军接受某种一级属性的转化属性。rankArr归档后转化数组，value偏移倍数，armyIndex范围（0前1后-1全）
		 */
		private function transformToArmys(rankArr:Array, value:int, armyIndex:int = -1):void
		{
			var armyArr:Array;
			if (armyIndex < 0)
				armyArr = this.data.army;
			else
				armyArr = [this.data.army[armyIndex]];
			
			var i:int;
			var len:int;
			for (i = 0, len = armyArr.length; i < len; i++)
			{
				var army:* = armyArr[i];
				ModelPrepare.transformToArmy(army, rankArr, value);
			}
		}
		
		
		/**
		 * 静态，得到对应兵种的转化数据
		 */
		private static function getArmyTransformObj(army:*, rankArr:Array):*
		{
			if (rankArr.length == 1)
			{
				//统一加成
				return rankArr[0];
			}
			else if (rankArr.length == 2)
			{
				//前军统一加成，后军统一加成
				return rankArr[army.type < 2 ? 0 : 1];
			}
			else if (rankArr.length == 4)
			{
				//不同兵种分别加成
				return rankArr[army.type];
			}
		}
		/**
		 * 静态，兵种接受某种一级属性的转化属性。army数据，rankArr归档后转化数组，value偏移倍数
		 */
		public static function transformToArmy(army:*, rankArr:Array, value:int):*
		{
			var temp:* = getArmyTransformObj(army,rankArr);
			
			for (var key:String in temp)
			{
				if (!army.hasOwnProperty(key))
				{
					army[key] = 0;
				}
				var tempArr:Array = temp[key];
				//在这里不再取整
				army[key] = army[key] + tempArr[0] + tempArr[1] * value;
			}
			return army;
		}
		/**
		 * 静态，兵种接受某种一级属性的转化属性。army数据，rankArr归档后转化数组，value偏移倍数，向下取整
		 */
		public static function transformToArmyFloor(army:*, rankArr:Array, value:int):*
		{
			var temp:* = getArmyTransformObj(army,rankArr);
			
			for (var key:String in temp)
			{
				if (!army.hasOwnProperty(key))
				{
					army[key] = 0;
				}
				var tempArr:Array = temp[key];
				//在这里向下取整
				army[key] = Math.floor(army[key] + tempArr[0] + tempArr[1] * value);
			}
			return army;
		}
		/**
		 * 固定覆盖属性
		 */
		private function fixedProp(obj:Object):void
		{
			for (var path:String in obj)
			{
				FightUtils.fixedObjByPath(this.data, path, FightUtils.clone(obj[path]));
			}
		}
		
		/**
		 * 混合最终属性
		 */
		private function checkMerge():void
		{
			var i:int;
			var j:int;
			var key:String;
			var keyBase:String;
			var keyRate:String;
			var army:*;
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				army = this.data.army[i];
				for (j = ConfigFight.propertyMergeArr.length - 1; j >= 0; j--)
				{
					key = ConfigFight.propertyMergeArr[j];
					keyBase = key + 'Base';
					keyRate = key + 'Rate';
					
					//只在最后一步取整
					army[key] = Math.floor(army[keyBase] * FightUtils.pointToRate(army[keyRate]) + army[key]);
					//删除无关属性
					delete army[keyBase];
					delete army[keyRate];
				}
			}
			
			//最终覆盖属性
			this.fixedProp(this._fixed);
			
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				army = this.data.army[i];
				if (this.data.armyHp)
					army.hp = Math.min(this.data.armyHp[i], army.hpm);
				else if (army.hasOwnProperty('hp'))
					army.hp = Math.min(army.hp, army.hpm);
				else
					army.hp = army.hpm;
			}
		}
		
		/**
		 * 更新战力
		 */
		private function checkPower():void
		{
			//对A、B、C型的加值，最终战力= A基础 * B比率（千分点） + C固定。通过passive加入的战力都为C类型
			var powerArr:Array = [this.data.powerBase, this.data.powerRate, this.data.power];
			
			var powerCfg:* = ConfigFight.powerValue;
			var heroObj:* = powerCfg.hero;
			var armyObj:* = powerCfg.army;
			
			var key:String;
			var arr:Array;
			var i:int;
			var j:int;
			var army:*;
			
			for (key in heroObj)
			{
				arr = heroObj[key];
				for (i = 0; i < 3; i++)
				{
					powerArr[i] += arr[i] * this.data[key];
				}
			}
			for (key in armyObj)
			{
				arr = armyObj[key];
				for (j = 0; j < ConfigFight.armyNum; j++)
				{
					army = this.data.army[j];
					for (i = 0; i < 3; i++)
					{
						powerArr[i] += arr[i] * army[key];
					}
				}
				
			}
			//合并兵种内临时战力
			for (j = 0; j < ConfigFight.armyNum; j++)
			{
				army = this.data.army[j];
				if (army.hasOwnProperty('powerBase'))
					powerArr[0] += army.powerBase;
				if (army.hasOwnProperty('powerRate'))
					powerArr[1] += army.powerRate;
				if (army.hasOwnProperty('power'))
					powerArr[2] += army.power;
			}
			//战力取整
			this.data.power = Math.floor(powerArr[0] * FightUtils.pointToRate(powerArr[1]) + powerArr[2]);
		}
		
		/**
		 * 得到最简式，移除默认值
		 */
		public function checkSimplest():*
		{
			var heroCfg:* = ConfigServer.hero[this.data.hid];
			
			var i:int;
			var j:int;
			var len:int = ConfigFight.propertyHeroDefaultArr.length;
			var key:String;
			for (i = 0; i < len; i++)
			{
				key = ConfigFight.propertyHeroDefaultArr[i];
				
				FightUtils.deleteDefault(this.data, key, heroCfg[key]);
			}
			for (key in ConfigFight.propertyDefaultData)
			{
				FightUtils.deleteDefault(this.data, key, ConfigFight.propertyDefaultData[key]);
			}
			len = ConfigFight.propertyAttackerArr.length;
			for (i = 0; i < len; i++)
			{
				//舍弃攻击者的0值
				key = ConfigFight.propertyAttackerArr[i];
				if (this.data[key] == 0)
				{
					delete this.data[key];
				}
			}
			
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				var armyData:* = this.data.army[i];
				key = ConfigFight.propertyHeroDefaultArr[i];
				for (j = ConfigFight.propertySimplestArr.length - 1; j >= 0; j--)
				{
					key = ConfigFight.propertySimplestArr[j];
					if (armyData[key] == 0)
					{
						delete armyData[key];
					}
				}
				
				//移除兵种临时属性
				if(TestFightData.testMode != -1){
					//delete armyData['lv'];
					delete armyData['add'];
				}
				delete armyData['powerBase'];
				delete armyData['powerRate'];
				delete armyData['power'];
			}
			
			//生成套装id
			var group:String = this.getGroupId();
			if (group){
				this.data.group = group;
			}
			//生成装备强化法球
			var rise:Array = this.getEquipRise();
			if (rise){
				this.data.rise = rise;
			}
			//delete this.data.equip;
			
			//移除NPC初始化临时属性
			delete this.data.armyRank;
			delete this.data.armyLv;
			delete this.data.armyAdd;
			delete this.data.powerBase;
			delete this.data.powerRate;
		}
		
		/**
		 * 获得 套装id
		 */
		public function getGroupId():String
		{
			var group:String;
			if (this.data.equip){
				var equipArr:Array = this.data.equip;
				var i:int;
				var len:int = equipArr.length;
				if (len >= 5){
					//var group:String;
					var equipOneArr:Array = equipArr[0];
					var equipId:String = equipOneArr[0];
					var equipCfg:* = ConfigServer.equip[equipId];
					if (equipCfg != null && equipCfg.group){
						group = equipCfg.group;
						for (i = 1; i < len; i++){
							equipOneArr = equipArr[i];
							equipId = equipOneArr[0];
							equipCfg = ConfigServer.equip[equipId];
							if (equipCfg == null || equipCfg.group != group){
								group = null;
								break;
							}
						}
					}
				}
			}
			return group;
		}
		/**
		 * 获得 装备法球
		 */
		public function getEquipRise():Array
		{
			var arr:Array;
			if (this.data.equip){
				var equipArr:Array = this.data.equip;
				var i:int;
				var len:int = equipArr.length;
				for (i = 0; i < len; i++){
					var equipOneArr:Array = equipArr[i];
					if (equipOneArr.length > 3){
						var rise:int = equipOneArr[3];
						if(rise){
							var equipId:String = equipOneArr[0];
							var equipCfg:Object = ConfigServer.equip[equipId];
							if (equipCfg != null && equipCfg.type < 5){
								if (!arr)
									arr = [0, 0, 0, 0, 0];
								arr[equipCfg.type] = rise;
							}
						}
					}
				}
			}
			return arr;
		}
		
		/////////////////以下为纯客户端使用
		
		
		/**
		 * 获得 单纯兵种段位属性(纯客户端使用)
		 */
		public static function getArmyRankData(type:int, rank:int):*
		{
			print("\n调用 getArmyRankData(" + type + "," + rank + ")");
			var transCfg:* = ConfigFight.propertyTransform;
			var armyData:* = {type: type};
			var rankArr:Array = FightUtils.getRankArr(rank, transCfg.armyRank);
			ModelPrepare.transformToArmy(armyData, rankArr[1], rank - rankArr[0]);
			print("getArmyRankData:", armyData);
			return armyData;
		}
		
		/**
		 * 获得 单纯兵种强化属性(纯客户端使用)
		 */
		public static function getArmyAddData(type:int, addArr:Array):*
		{
			print("\n调用 getArmyAddData(" + type + ",[" + addArr.toString() + "])");
			var transCfg:* = ConfigFight.propertyTransform;
			var armyData:* = {type: type};
			for (var i:int = 0; i < ConfigFight.armyAddNum; i++)
			{
				var rank:int = addArr[0] + (i < addArr[1] ? 1 : 0);
				var rankArr:Array = FightUtils.getRankArr(rank, transCfg['armyAdd' + i]);
				ModelPrepare.transformToArmy(armyData, rankArr[1], rank - rankArr[0]);
			}
			print("getArmyAddData:", armyData);
			return armyData;
		}
		
		/**
		 * 打印(纯客户端使用)
		 */
		public static function print(str:String, data:Object = null):void
		{
			FightPrint.checkPrint("ModelPrepare", str, data);
		}
	}

}