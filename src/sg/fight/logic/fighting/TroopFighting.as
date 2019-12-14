package sg.fight.logic.fighting
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.AdjutantLogic;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.Tools;
	
	/**
	 * 战斗中部队，初始化合并skill、special
	 * @author zhuda
	 */
	public class TroopFighting extends FightingBase 
	{
		public var fightLogic:FightLogic;
		public var troopLogic:TroopLogic;
		
		public var heroFighting:HeroFighting;
		///内部存有AdjutantFighting
		public var adjutants:Array;
		///内部存有ArmyFighting
		public var armys:Array;
		///内部存有ArmyFighting 和 HeroFighting AdjutantFighting
		public var units:Array;
		///所有技能展开合并（up，宝物天赋都转为skill），转置到每个unitFighting的action后无用
		public var skills:*;
		
		///临时，在战斗中的累计能量，里面有各种key。deaded死兵（可作为反噬消耗）,wounded伤兵（可作为治疗消耗）
		public var energyObj:Object;
		
		///临时，在战斗中的兽灵效果，初始化固定，会影响当前状况的伤害免伤、穿防临防
		public var beastObj:Object;
		
		public function getArmyFighting(armyIndex:int):ArmyFighting
		{
			return this.armys[armyIndex] as ArmyFighting;
		}
		public function getAdjutantFighting(adjutantIndex:int):AdjutantFighting
		{
			if(this.adjutants){
				return this.adjutants[adjutantIndex] as AdjutantFighting;
			}
			else{
				return null;
			}
		}
		/**
		 * 获取行动单位0前军1后军2英雄3前副将4后副将
		 */
		public function getUnitFighting(index:int):UnitFighting
		{
			return this.units[index] as UnitFighting;
		}
		
		/**
		 * 获取敌对的部队
		 */
		public function getEnemyTroopFighting():TroopFighting
		{
			return this.fightLogic.getTroopFighting(this.troopLogic.enemyTeamIndex);
		}

		
		public function TroopFighting(fightLogic:FightLogic, troopLogic:TroopLogic)
		{
			this.fightLogic = fightLogic;
			troopLogic.troopIndex = -1;
			this.troopLogic = troopLogic;
			troopLogic.resetStart(fightLogic);
			//充能
			this.energyObj = {'deaded':0};
			
			this.heroFighting = new HeroFighting(this, this.troopLogic.heroLogic);
			this.armys = [];
			this.adjutants = [];
			this.units = [];
			var i:int;
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				var armyLogic:ArmyLogic = this.troopLogic.getArmy(i);
				armyLogic.initHp = armyLogic.hp;
				var armyFighting:ArmyFighting = new ArmyFighting(this, armyLogic);
				this.armys.push(armyFighting);
				this.units.push(armyFighting);
			}
			this.units.push(this.heroFighting);
			//副将
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				var adjutantLogic:AdjutantLogic = this.troopLogic.getAdjutant(i);
				if (adjutantLogic){
					var adjutantFighting:AdjutantFighting = new AdjutantFighting(this, adjutantLogic);
					this.adjutants.push(adjutantFighting);
					this.units.push(adjutantFighting);
				}else{
					this.adjutants.push(null);
					this.units.push(null);
				}
			}
			//初始化第一步,要等对方也初始化完毕才能checkSpecial（limit判定不过，技能不入战斗）
			this.checkSkill();
			this.print('checkSkill', this.skills);
			//this.checkFightingAction();
			//this.print('checkFightingAction', this.skills);
		}
		
		
		/**
		 * 获得对应能量值
		 */
		public function getEnergy(key:String = 'deaded'):int
		{
			return this.energyObj[key] || 0;
		}
		/**
		 * 充能
		 */
		public function addEnergy(value:int, key:String = 'deaded', tgtData:Object = null):void
		{
			if (this.energyObj[key]){
				this.energyObj[key] += value;
			}else{
				this.energyObj[key] = value;
			}
			//回放纪录
			if (tgtData){
				if(!ConfigFight.ignoreEnergyTypes[key]){
					tgtData.energy = [key, value];
				}
			}
			if (ConfigFight.energyBuff[key]){
				this.heroFighting.buffManager.addEnergeBuff(key, value);
				this.getArmyFighting(0).buffManager.addEnergeBuff(key, value);
				this.getArmyFighting(1).buffManager.addEnergeBuff(key, value);
			}
			
			if (FightLogic.canPrint){
				var info:String;
				if(value > 0){
					info = this.getName() + ' 获得' + key + '标记  ' + value + ' (' + (this.energyObj[key] - value) + ' → ' + this.energyObj[key] + ')';
				}
				else{
					info = this.getName() + ' 消耗' + key + '标记  ' + (-value) + ' (' + (this.energyObj[key] - value) + ' → ' + this.energyObj[key] + ')';
				}
				FightLogic.print('      '+ info, null, FightPrint.getPrintColor(this.troopLogic.teamIndex, '#CCCCCC', 0.8));
			}
			//trace(this.getName() + ' 充能' + key + value + ' >>> ' + this.energyObj[key]);
		}
		/**
		 * 消耗能量（最大倍数），返回最终倍数（基础为1）
		 */
		public function useEnergy(cost:int, costMult:int, multMax:int = 1, key:String = 'deaded', srcData:Object = null):int
		{
			var multNum:int = 0;
			var energy:int = this.getEnergy(key);
			if (energy >= cost){
				multNum = 1;
				var temp:int = energy - cost;
				if(temp >= costMult){
					multNum += Math.floor(temp / costMult);
					if(multMax > 0){
						multNum = Math.min(multMax, multNum);
					}
				}
				this.addEnergy( -(cost + (multNum-1) * costMult), key, srcData);
			}
			return multNum;
		}
		
		/**
		 * 设定为先手或后手
		 */
		public function setPriority(b:Boolean):void
		{
			this.heroFighting.baseSpeed = 1000 + (b?1:0);
			var adjutantFighting:AdjutantFighting;
			adjutantFighting = this.getAdjutantFighting(0);
			if(adjutantFighting){
				adjutantFighting.baseSpeed = 900 + (b?1:0);
			}
			adjutantFighting = this.getAdjutantFighting(1);
			if(adjutantFighting){
				adjutantFighting.baseSpeed = 800 + (b?1:0);
			}
		}
		
		/**
		 * 检查并初始化技能，展开数据，合并up。并添加兵种及天赋相关技能
		 */
		private function checkSkill():void
		{
			var skillLevels:* = this.troopLogic.skill;
			var skillsConfig:* = ConfigServer.skill;
			this.skills = {};
			for (var key:String in skillLevels)
			{
				var skillCfg:Object = skillsConfig[key];
				if (this.canUseSkill(skillCfg))
				{
					var skillLv:int = skillLevels[key];
					var skillObj:Object = FightUtils.getSkillLvData(skillCfg, skillLv, 3);
					skillObj.lv = skillLv;
					this.skills[key] = skillObj;
				}
			}
		}
		
		/**
		 * 检查技能限制，NPC不受限
		 */
		private function canUseSkill(skillConfig:*):Boolean
		{
			if (!skillConfig)
				return false;
			if (this.troopLogic.isNpc)
				return true;
			if (skillConfig.hasOwnProperty('limit'))
			{
				var limit:* = skillConfig.limit;
				var heroLogic:HeroLogic = this.troopLogic.heroLogic;
				
				if (heroLogic.isStudyUnlimit){
					return true;
				}
				//限制属性，type，sex暂无问题忽略，属性必须满足
				for (var key:String in limit)
				{
					if (key == 'type'){
						if (heroLogic.type < 2 && heroLogic.type != limit.type){
							return false;
						}
					}
					else if (key == 'sex'){
						if (heroLogic.sex != limit.sex){
							return false;
						}
					}
					else if (heroLogic[key] < limit[key])
					{
						return false;
					}
				}
			}
			return true;
		}
		
		
		/**
		 * 检查一条修正特性，如果生效则加入
		 */
		public function checkSpecialOne(specialData:Object):void
		{
			var enemyTroopFighting:TroopFighting = this.getEnemyTroopFighting();
			if (specialData.hasOwnProperty('cond'))
			{
				var condsArr:Array = specialData.cond;
				var i:int;
				var len:int = condsArr.length;
				var value0:*;
				var value1:*;
				var troopLogic:TroopLogic = this.troopLogic;
				var enemyTroopLogic:TroopLogic = enemyTroopFighting.troopLogic;
				
				for (i = 0; i < len; i++)
				{
					var condArr:Array = condsArr[i];
					var type:String = condArr[0];
					var key:* = condArr[1];
					var value:* = condArr[2];
					var ok:Boolean = false;

					switch (type)
					{
					case 'fate': //判断同时上阵
						if (!troopLogic.others || FightUtils.getFateHid(troopLogic.others.attends, troopLogic.getSimplestAdjutantHids(), key, value, troopLogic.hid) == null)
						{
							return;
						}
						break;
					case 'enemy': //判断敌人
						if (key == 'army'){
							//拥有兵种
							if (enemyTroopLogic.getArmyIndexByType(value) == -1)
							{
								return;
							}
						}
						if (key == 'formationType'){
							//使用某种阵型
							if (enemyTroopLogic.formationType != value)
							{
								return;
							}
						}
						else{
							value0 = enemyTroopLogic.heroLogic[key];
							if (value0 != value)
							{
								return;
							}
						}
						
						//return;
						break;
					case 'compare': //判断双方比较
						
						if (key == 'hp')
						{
							value0 = this.getArmyHp();
							value1 = enemyTroopFighting.getArmyHp();
							//trace('战前双方比较hp', value0, value1, value);
						}
						else if (key == 'power')
						{
							value0 = troopLogic.power;
							value1 = enemyTroopLogic.power;
							//trace('战前双方比较hp', value0, value1, value);
						}
						else
						{
							value0 = troopLogic.heroLogic[key];
							value1 = enemyTroopLogic.heroLogic[key];
						}
						
						if (!FightUtils.compareValue(value0, value1, value))
						{
							return;
						}
						
						break;
					case 'rnd': //随机千分点
						if (!this.fightLogic.random.determine(key))
						{
							return;
						}
						
						break;
					case 'mode': //判断战斗类型，且作为哪方队伍
						if (!troopLogic.freeMode){
							if (this.fightLogic.mode != key)
							{
								return;
							}else{
								if (value != undefined && troopLogic.teamIndex != value){
									return;
								}
							}
						}
						break;
					case 'proud': //判断自身傲气
						if (!FightUtils.compareValue(troopLogic.proud,value,key))
						{
							return;
						}
						
						break;
					case 'enemyProud': //判断敌方傲气
						if (!FightUtils.compareValue(enemyTroopLogic.proud,value,key))
						{
							return;
						}
						
						break;
					default: 
						break;
					}
				}
			}
			
			if (specialData.hasOwnProperty('change'))
			{
				this.changeSpecial(this, specialData.change);
			}
			if (specialData.hasOwnProperty('changeEnemy'))
			{
				//特殊能力，改变对手，如禁止对方不能使用某类技能
				this.changeSpecial(enemyTroopFighting, specialData.changeEnemy);
			}
		}
		
		/**
		 * 修改对应战斗部队的 技能或属性
		 */
		private function changeSpecial(troopFighting:TroopFighting, changeData:Object):void
		{
			var path:String;
			if (changeData.hasOwnProperty('skill'))
			{
				for (path in changeData.skill)
				{
					FightUtils.changeObjByPath(troopFighting.skills, path, changeData.skill[path]);
				}
			}
			
			if (changeData.hasOwnProperty('prop'))
			{
				for (path in changeData.prop)
				{
					FightUtils.changeObjByPath(troopFighting.troopLogic, path, changeData.prop[path]);
				}
			}
		}
		
		/**
		 * 遍历所有skill数据，将其分配到对应的unit action中，最终遍历unit各类action 优先级排序
		 */
		public function checkUnitAction():void
		{
			var key:String;
			var unitFighting:UnitFighting;
			var i:int;
			var len:int;
			var actObj:Object;
			
			for (key in this.skills)
			{
				//这里的data已经是该部队专属
				var data:* = this.skills[key];
				var defaultObj:Object;
				var defaultKey:String;
				if (data.hasOwnProperty('actDefault'))
				{
					defaultObj = data.actDefault;
					//合并出初始默认值，并加入技能等级
					for (defaultKey in ConfigFight.actDefault)
					{
						FightUtils.fillDefault(defaultObj, defaultKey, ConfigFight.actDefault[defaultKey]);
					}
				}
				else
				{
					defaultObj = FightUtils.clone(ConfigFight.actDefault);
				}
				defaultObj.lv = data.lv;
				
				var skillCfg:Object = ConfigServer.skill[key];
				if (skillCfg){
					if (skillCfg.type == 4){
						//如果是真英雄技，加入额外值
						defaultObj.isHero = 1;
					}
					else if (skillCfg.type == 5 && skillCfg.isAssist){
						//如果是触发辅助技，加入额外值
						defaultObj.isAssist = 1;
					}
				}
				
				if (data.hasOwnProperty('act'))
				{
					var acts:Array = data.act;
					//把外部的默认属性覆盖到内部
					len = acts.length;
					for (i = 0; i < len; i++)
					{
						actObj = acts[i];
						for (defaultKey in defaultObj)
						{
							var value:* = defaultObj[defaultKey];
							if (defaultKey == 'priority')
							{
								value = value + (len - 1 - i);
							}
							FightUtils.fillDefault(actObj, defaultKey, value);
						}
						this.addAction(actObj);
					}
				}
			}
			//取出兵种对应普攻，加入到main
			for (i = 0; i < ConfigFight.armyNum; i++)
			{
				var armyFighting:ArmyFighting = this.getArmyFighting(i);
				actObj = ConfigFight.armyActMainArr[armyFighting.getArmyLogic().type];
				this.addAction(actObj);
			}
			
			//格式化所有Action为类实例，各个数组按优先级排序
			len = this.units.length;
			for (i = 0; i < len; i++)
			{
				unitFighting = this.units[i];
				if(unitFighting)
					unitFighting.formatActions();
			}
			//this.print('checkUnitAction', this.skills);
			this.skills = null;
		}
		
		/**
		 * 将一个合并完成所有默认的行为数据，放置到它应在的unitFighting位置中
		 */
		private function addAction(actObj:*):void
		{
			var unitFighting:UnitFighting;
			var srcType:int = actObj.src;
			if (srcType >= 0)
			{
				unitFighting = this.getUnitFighting(srcType);
				if(unitFighting)
					unitFighting.addAction(actObj);
			}
			else
			{
				var arr:Array;
				if (srcType == -1)
				{
					arr = [this.armys[0], this.armys[1]];
				}
				else if (srcType == -2)
				{
					arr = [this.armys[0], this.armys[1], this.heroFighting];
				}
				else
				{
					arr = [];
				}
				for (var i:int = arr.length - 1; i >= 0; i--)
				{
					unitFighting = this.getUnitFighting(i);
					if(unitFighting)
						unitFighting.addAction(actObj);
				}
			}
		}
		
		/**
		 * 得到本部的战胜战败行动，执行
		 */
		public function getEndActions(isWin:Boolean = true):Array
		{
			var i:int;
			var len:int = this.units.length;
			var unitFighting:UnitFighting;
			var arr:Array = [];
			var tempArr:Array;
			for (i=0; i < len; i++)
			{
				unitFighting = this.units[i];
				if(unitFighting){
					tempArr = unitFighting.actions[isWin?ConfigFight.ACT_WIN:ConfigFight.ACT_LOSS];
					if (tempArr){
						arr = arr.concat(tempArr);
					}
				}
			}
			return arr;
		}
		
		/**
		 * 已经战败，返回战败复仇的行动
		 */
		public function getLossActions(enemyTroopLogic:TroopLogic):Array
		{
			var arr:Array = [];
			//如有一方为特殊阵法，则不适用遗计等
			if (this.troopLogic.formationType < 0 || enemyTroopLogic.formationType < 0){
				return arr;
			}
			if (!ConfigFight.loserAct){
				return arr;
			}
			var loserHero:HeroLogic = this.troopLogic.heroLogic;
			var winnerHero:HeroLogic = enemyTroopLogic.heroLogic;
			if (loserHero.banSrcLossAct || winnerHero.banTgtLossAct){
				return arr;
			}
			
			
			var loserObj:Object = ConfigFight.loserAct[loserHero.type];
			if (loserObj && loserObj.hasOwnProperty('aimType') && loserObj.aimType == winnerHero.type){
				var actArr:Array = loserObj.act;
				var len:int = actArr.length;
				for (var i:int = 0; i < len; i++) 
				{
					var act:AttackAction = new AttackAction(this.heroFighting, actArr[i]);
					arr.push(act);
				}
			}
			
			return arr;
		}

		/**
		 * 获得当前兵力比例
		 */
		public function getArmyHpPer():Number
		{
			var hp:int = 0;
			var hpMax:int = 0;
			for (var i:int = this.armys.length - 1; i >= 0; i--)
			{
				var armyFighting:ArmyFighting = this.armys[i];
				var armyLogic:ArmyLogic = armyFighting.getArmyLogic();
				hpMax += armyLogic.hpm;
				hp += armyLogic.hp;
			}
			return hp/hpMax;
		}
		/**
		 * 获得当前兵力比例千分点
		 */
		public function getArmyHpPoint():int
		{
			return FightUtils.perToPoint(this.getArmyHpPer());
		}
		
		/**
		 * 获得当前兵力总量
		 */
		public function getArmyHp():int
		{
			var hp:int = 0;
			//var hpMax:int = 0;
			for (var i:int = this.armys.length - 1; i >= 0; i--)
			{
				var armyFighting:ArmyFighting = this.armys[i];
				var armyLogic:ArmyLogic = armyFighting.getArmyLogic();
				//hpMax += armyLogic.hpm;
				hp += armyLogic.hp;
			}
			return hp;
		}
		
		/**
		 * 与对方比较总兵力
		 */
		public function compareArmyHp(key:String):Boolean
		{
			var value0:int = this.getArmyHp();
			var value1:int = this.getEnemyTroopFighting().getArmyHp();
			var bool:Boolean = FightUtils.compareValue(value0, value1, key);
			return bool;
		}
		
		/**
		 * 获得英雄对应属性的差值
		 */
		public function getHeroDValue(key:String):int
		{
			var value0:int = this.troopLogic.heroLogic[key];
			var value1:int = this.getEnemyTroopFighting().troopLogic.heroLogic[key];
			return value0 - value1;
		}
		
		/**
		 * 返回当前数据副本(只用于测试打印)
		 */
		public function getCurrData():*
		{
			var reData:Object = this.troopLogic.getCurrData();
			//reData.skills = this.skills;
			
			return reData;
		}
		
		public function get alive():Boolean
		{
			for (var i:int = 0; i < ConfigFight.armyNum; i++)
			{
				var armyFight:ArmyFighting = this.armys[i];
				if (armyFight.alive)
					return true;
			}
			return false;
		}
		
		/**
		 * 只剩单军的id，-2全灭 -1全部存活 0前军存活 1后军存活
		 */
		public function getOnlyArmyIndex():int
		{
			if (this.armys[0].alive)
			{
				if (this.armys[1].alive)
				{
					return -1;
				}else{
					return 0;
				}
			}
			else{
				if (this.armys[1].alive)
				{
					return 1;
				}else{
					return -2;
				}
			}
		}
		
		/**
		 * 得到按armyIndex查找存活的目标armyIndex数组   前后军目标 0前军1后军2英雄 -1全军 -2随机一军 -3另一军（执行时自动按情况变化）
		 */
		public function getAliveArmyArr(targetArmyIndex:int, srcArmyIndex:int):Array
		{
			//只剩单军的id
			var onlyArmyIndex:int = this.getOnlyArmyIndex();
			var armyArr:Array = [];
			var i:int;
			if (onlyArmyIndex == -2){
				return armyArr;
			}
			
			if (targetArmyIndex == 2)
			{
				//英雄
				if (!this.heroFighting.alive)
				{
					return armyArr;
				}
				armyArr.push(targetArmyIndex);
			}
			else if (targetArmyIndex >= 0)
			{
				//指定前后某军，如果已阵亡，则换另一军
				if (onlyArmyIndex >= 0)
				{
					targetArmyIndex = onlyArmyIndex;
				}
				armyArr.push(targetArmyIndex);
			}
			else if (targetArmyIndex == -1)
			{
				//指定全军，如果已阵亡，则单军
				if (onlyArmyIndex >= 0)
				{
					armyArr.push(onlyArmyIndex);
				}
				else
				{
					for (i = 0; i < ConfigFight.armyNum; i++)
					{
						armyArr.push(i);
					}
				}
			}
			else if (targetArmyIndex == -2)
			{
				//-2随机一军
				if (onlyArmyIndex >= 0)
				{
					armyArr.push(onlyArmyIndex);
				}
				else
				{
					armyArr.push(this.fightLogic.random.getRandomRange(0, 1));
				}
			}
			else if (targetArmyIndex == -3)
			{
				// -3另一军（仅对己方有效，如果只剩单军则无目标）
				if (onlyArmyIndex >= 0)
				{
					return armyArr;
				}
				else
				{
					armyArr = [1 - srcArmyIndex];
				}
			}
			else if (targetArmyIndex == -4)
			{
				// -4英雄及前军
				if (!this.heroFighting.alive)
				{
					return armyArr;
				}
				armyArr.push(2);
				//残军或前军
				if (onlyArmyIndex >= 0)
				{
					targetArmyIndex = onlyArmyIndex;
				}
				else
				{
					targetArmyIndex = 0;
				}
				armyArr.push(targetArmyIndex);
			}
			else if (targetArmyIndex == -5)
			{
				// -5同一军
				armyArr = [srcArmyIndex];
			}
			return armyArr;
		}
		

		
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function getName():String
		{
			var str:String;
			var teamIndex:int = this.troopLogic.teamIndex;
			str = teamIndex == 0 ? 'L' : 'R';
			var heroCfg:Object = ConfigServer.hero[this.troopLogic.heroLogic.id];
			str += Tools.getMsgById(heroCfg.name);
			return str;
		}
		
		/**
		 * 打印(纯客户端使用)
		 */
		public function print(str:String, data:Object = null):void
		{
			FightPrint.checkPrint('FightSpecial', '\n' + this.getName() + ' ' + str, data);
		}
		
		override public function clear():void
		{
			this.fightLogic = null;
			
			//this.troopLogic.clear();
			//this.troopLogic = null;
			
			this.heroFighting.clear();
			this.heroFighting = null;
			
			this.armys[0].clear();
			this.armys[1].clear();
			this.armys = null;
			
			this.units = null;
			super.clear();
		}
	}

}