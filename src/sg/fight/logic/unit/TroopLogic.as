package sg.fight.logic.unit
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.AdjutantLogic;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.LogicBase;
	import sg.fight.logic.utils.FightUtils;
	import sg.model.ModelFormation;
	import sg.model.ModelPrepare;
	
	/**
	 * 战斗中部队
	 * @author zhuda
	 */
	public class TroopLogic extends LogicBase
	{
		public var uid:int;
		public var uname:String;
		public var hid:String;
		
		///黄巾军类型
		public var npc_type:String;
		///战力
		public var power:int;
		///傲气
		public var proud:int;
		///所属国家
		public var country:int;
		///官职，0是皇帝 -1精英 -2大将 -100玩家或普通城防军
		public var official:int = -100;
		
		///称号
		public var title:String;
		///幕府效果基值[英雄，前军，后军]
		public var shogun:Array;
		///卜卦效果，只有包含attack_value的才会传进来
		public var magic:String;
		///整体队伍或特殊稳定祝福效果，提升等量含真实伤害免伤
		public var bless:Number;
		
		///技能
		public var skill:Object;
		///修正特性，战前最终合并（limit判定不过不能加入战斗），战斗开始后再无special（special可能附加出act）
		public var special:Array;
		///由战役带进来的其他数据，只在战斗发生时初始化attends,official(这里是国战最高官职光环效果)tower(国战箭楼1，炮塔2) buff milepost door spirit
		public var others:Object;

		
		//以下属性不直接在data中
		public var heroLogic:HeroLogic;
		public var adjutants:Array;
		public var armys:Array;
		public var spiritTemp:*;
		///额外暴击伤害
		public var critAdd:int;
		///额外格挡保全
		public var blockAdd:int;
		///置为最佳环境mode，可无视状态发生天赋special
		public var freeMode:int;

		///兽灵数组，内含8个，如果未曾装备则为null
		public var beast:Array;
		
		///阵法类型
		public var formationType:int;
		///阵法品质
		public var formationStar:int;
		///额外先手值
		public var priority:int;
		public function getPriority():int
		{
			return this.power + this.priority;
		}
		/**
		 * 返回可能带_觉醒的头像id
		 */
		public function getHeadId():String
		{
			return this.heroLogic.isAwaken?(hid+'_'):hid;
		}
		/**
		 * 返回uid|hid的keyId
		 */
		public function getKeyId(hasInsertId:Boolean = false):String
		{
			return this.uid.toString() +'|' + hid;
		}
		/**
		 * 得到国战下，当前完全的伤害免伤加成显示值（来源于城池信仰、关城建筑、襄阳城门、国战buff）
		 */
		public function getCountryBuffValue(isDmg:Boolean):Number
		{
			var value:Number = 0;
			if (this.others){
				if (this.others.buff){
					var buffArr:Array = this.others.buff;
					value += buffArr[isDmg?0:1];
				}
				value += this.getDoorValue();
			}
			return value;
		}
		/**
		 * 得到国战下，当前部分伤害免伤加成显示值（来源于襄阳城门、国战buff）
		 */
		public function getDoorValue():Number
		{
			if (this.others){
				if (this.others.door){
					return this.others.door;
				}
			}
			return 0;
		}
		
		//以下属性为快速索引
		protected var _teamIndex:int;
		///在队伍中的排序，如果为-1则正在战斗
		public var troopIndex:int;
		
		public function getLogic(armyIndex:int):LogicBase
		{
			if (armyIndex < 0)
				return this.heroLogic;
			return this.armys[armyIndex];
		}
		
		/**
		 * 得到最简副将ids
		 */
		public function getSimplestAdjutantHids():Array
		{
			var arr:Array = [];
			var i:int;
			var len:int = this.adjutants.length;
			for (i = 0; i < len; i++) 
			{
				var adjutant:AdjutantLogic = this.adjutants[i];
				if (adjutant){
					arr.push(adjutant.id);
				}
			}
			return arr;
		}
		public function getAdjutant(adjutantIndex:int):AdjutantLogic
		{
			return this.adjutants[adjutantIndex];
		}
		public function getArmy(armyIndex:int):ArmyLogic
		{
			return this.armys[armyIndex];
		}
		public function getArmys(armyIndex:int):Array
		{
			if (armyIndex < 0)
				return this.armys;
			return [this.getArmy(armyIndex)];
		}
		public function get isNpc():Boolean
		{
			return this.uid < 0;
		}
		override public function get teamIndex():int { 
			return this._teamIndex; 
		}
		override public function getTroopLogic():TroopLogic { 
			return this; 
		}
		
		
		public function TroopLogic(data:*,teamIndex:int,troopIndex:int)
		{
			this._teamIndex = teamIndex;
			this.troopIndex = troopIndex;
			super(data);
		}
		
		
		/**
		 * 战斗开始重置
		 */
		public function resetStart(fightLogic:FightLogic):void
		{
			this.heroLogic.resetStart(fightLogic);
			for (var i:int = this.armys.length - 1; i >= 0; i--) {
                this.getArmy(i).resetStart(fightLogic);
				var adjutant:AdjutantLogic = this.getAdjutant(i);
				if (adjutant)
					adjutant.resetStart(fightLogic);
            }
		}
		/**
		 * 战斗结束，重置该单位的所有数据为初始data，但不重置hp（只有客户端或客户端模拟的服务端战斗才有）
		 */
		public function resetEnd():void
		{
			this.spiritTemp = null;
			this.priority = 0;
			this.heroLogic.resetEnd();
			this.critAdd = 0;
			this.blockAdd = 0;
			this.freeMode = 0;
			//this.speak = '';
			for (var i:int = this.armys.length - 1; i >= 0; i--) {
                this.getArmy(i).resetEnd();
				var adjutant:AdjutantLogic = this.getAdjutant(i);
				if (adjutant)
					adjutant.resetEnd();
            }
		}

		public function newArmy(data:*,armyIndex:int,initHp:int):ArmyLogic
		{
			var army:ArmyLogic = new ArmyLogic(data,this,armyIndex,initHp);
			return army;
		}
		public function newHero(data:*):HeroLogic
		{
			var hero:HeroLogic = new HeroLogic(data,this);
			return hero;
		}
		public function newAdjutant(data:*,adjutantIndex:int):AdjutantLogic
		{
			var adjutant:AdjutantLogic = new AdjutantLogic(data,this,adjutantIndex);
			return adjutant;
		}
		
		

		/**
         * 从类型找到对应的兵队编号，-1代表不存在该兵种
         */
        public function getArmyIndexByType(type:int):int {
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ArmyLogic = this.armys[i];
				if(army.type == type)
					return army.armyIndex;
            }
            return -1;
        }
		/**
         * 硬怼掉生命值，从前往后减血，是否致死
         */
        public function cutHp(dmg:int,canDie:Boolean = false):void {
            var temp:int;
			var len:int = this.armys.length;
            for (var i:int = 0; i < len; i++) {
                var army:ArmyLogic = this.armys[i];
				if (army.hp <= 0)
					continue;
				temp = Math.min(army.hp - (canDie?0:1), dmg);
                army.hp -= temp;
				dmg -= temp;
            }
        }
		/**
         * 得到剩余总生命
         */
        public function getAllHp():int {
            var hp:int = 0;
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ArmyLogic = this.armys[i];
                hp += army.hp;
            }
            return hp;
        }
		/**
         * 得到总生命
         */
        public function getAllHpMax():int {
            var hp:int = 0;
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ArmyLogic = this.armys[i];
                hp += army.hpm;
            }
            return hp;
        }
		/**
         * 当前血量百分比
         */
        public function getHpPer(isEnd:Boolean = false):Number {
            var hp:int = 0;
            var hpMax:int = 0;
            
            for (var i:int = this.armys.length - 1; i >= 0; i--) {
                var army:ArmyLogic = this.armys[i];
                hpMax += army.hpm;
                hp += army.hp;
            }
            return hp / hpMax;
        }

		override public function setData(data:*):void
		{
			this.resetData(data);		
			this.initLogic();
		}
		/**
         * 仅更新数据
         */
		public function resetData(data:*):void
		{
			//补充默认数据
			var i:int;
			var len:int;
			var key:String;

			data = ModelPrepare.getData(data, true);
			
			//已经被 ModelPrepare处理过，可能是精简数据
			for (key in ConfigFight.propertyFightDefaultData)
			{
				FightUtils.fillDefault(data, key, ConfigFight.propertyFightDefaultData[key]);
			}
			//通过英雄id自行初始化属性
			var heroCfg:* = ConfigServer.hero[data.hid];
			for (i = 0, len = ConfigFight.propertyHeroDefaultArr.length; i < len; i++)
			{
				key = ConfigFight.propertyHeroDefaultArr[i];
				FightUtils.fillDefault(data, key, heroCfg[key]);
			}
			
			super.setData(data);
			
			if(!this.data.hasOwnProperty('special'))
				this.special = [];
				
			var tempArr:Array = ModelFormation.getFormationTypeAndStar(this.data.formation);
			this.formationType = tempArr[0];
			this.formationStar = tempArr[1];
			
			//this.formationStar = 0;
			//if (this.data.hasOwnProperty('formation')){
				//var formationArr:Array = this.data.formation;
				//this.formationType = formationArr[0];
				//
				//var formationObj:Object = formationArr[1];
				//if (formationObj){
					//var arr:Array = formationObj[this.formationType];
					//if (arr){
						//this.formationStar = arr[0];
					//}
				//}
			//}
			//else{
				//this.formationType = 0;
			//}
		}
		/**
         * 仅初始化逻辑对象
         */
		public function initLogic():void
		{
			var i:int;
			var len:int;
			
			this.heroLogic = this.newHero(this.data);
			
			this.adjutants = [];
			var adjutantData:Array = this.data.adjutant;
			if (adjutantData != null)
			{
				for (i = 0, len = adjutantData.length; i < len; i++)
				{
					var adjutantOne:Array = adjutantData[i];
					this.adjutants[i] = adjutantOne?this.newAdjutant(adjutantOne, i):null;
				}
			}
			
			this.armys = [];
			var armyData:Array = this.data.army;
			var armyHp:Array = this.data.armyHp;
			for (i = 0, len = armyData.length; i < len; i++)
			{
				var initHp:int = armyHp?armyHp[i]: -1;
				this.armys[i] = this.newArmy(armyData[i],i, initHp);
			}
		}
		/**
         * 仅更新逻辑对象数据，认为核心未动
         */
		public function updateLogicData():void
		{
			//补充默认数据
			var i:int;
			var len:int;
			
			this.heroLogic.setData(this.data);
			
			//this.adjutants = [];
			//var adjutantData:Array = this.data.adjutant;
			//if (adjutantData != null)
			//{
				//for (i = 0, len = adjutantData.length; i < len; i++)
				//{
					//var adjutantOne:Array = adjutantData[i];
					//var adjutant:AdjutantLogic = this.getAdjutant(i);
					//if (adjutant){
						//adjutant.setData(adjutantOne);
					//}
				//}
			//}
			
			//this.armys = [];
			var armyData:Array = this.data.army;
			for (i = 0, len = armyData.length; i < len; i++)
			{
				var army:ArmyLogic = this.getArmy(i);
				army.setData(armyData[i]);
				//this.armys[i] = this.newArmy(armyData[i],i);
			}
		}
		
		/**
		 * 返回当前数据副本(用于客户端中途加入战斗时，恢复到从某一场开始)
		 */
		public function getCurrData():*
		{
			var reData:Object = FightUtils.clone(this.data);
			if (this.isNpc){
				delete reData.others;
			}
			reData.uid = this.uid;
			reData.army[0].hp = this.getArmy(0).hp;
			reData.army[1].hp = this.getArmy(1).hp;
			delete reData.armyHp;

			return reData;
		}
		/**
		 * 返回战前最终数据（用于前后端统一初始化）
		 */
		public function getCompData():*
		{
			var reData:Object = {
				uid:this.uid,
				uname:this.uname,
				hid:this.hid,
				power:this.power,
				proud:this.proud,
				country:this.country,
				official:this.official,
				army:this.data.army,
				lv:this.data.lv,
				hero_star:this.data.hero_star,
				str:this.data.str,
				agi:this.data.agi,
				cha:this.data.cha,
				lead:this.data.lead
			};
			var len:int = ConfigFight.propertyAttackerArr.length;
			for (var i:int = 0; i < len; i++)
			{
				//加入英雄作为攻击者的值
				var key:String = ConfigFight.propertyAttackerArr[i];
				if (this.data[key])
				{
					reData[key] = this.data[key];
				}
			}

			if (this.title){
				reData.title = this.title;
			}
			if (this.data.adjutant){
				reData.adjutant = this.data.adjutant;
			}
			if (this.npc_type){
				reData.npc_type = this.npc_type;
			}
			if (this.shogun){
				reData.shogun = this.shogun;
			}
			if (this.magic){
				reData.magic = this.magic;
			}
			if (this.bless){
				reData.bless = this.bless;
			}
			if (this.data.skill){
				reData.skill = this.data.skill;
			}
			if (this.data.special){
				reData.special = this.data.special;
			}
			if (this.others){
				reData.others = this.others;
			}
			if (this.data.formation){
				reData.formation = this.data.formation;
			}
			if (this.data.equip){
				reData.equip = this.data.equip;
			}
			if (this.beast){
				reData.beast = this.beast;
			}
			reData.armyHp = [this.getArmy(0).hp,this.getArmy(1).hp];
			
			return reData;
		}
		
		/**
		 * 返回原始数据
		 */
		override public function getData():*
		{
			return this.data;
		}
		/**
		 * 获取战斗结束后的战报信息
		 */
		public function getRecord():Object{
			var obj:Object = {hp:0, hpm:0, dead:0};
			var len:int = this.armys.length;
			for (var i:int = 0; i < len; i++) 
			{
				var army:ArmyLogic = this.getArmy(i);
				obj.hp += army.hp;
				obj.hpm += army.hpm;
				obj.dead += Math.max(0,army.initHp - army.hp);
			}
			obj.hid = this.hid;
			return obj;
		}

		
		/**
		 * 获取当前的激励总属性
		 */
		public function getSpiritData():Object{
			if(this.spiritTemp == null){
				if(this.others && this.others.spirit){
					//获得激励
					var obj:Object = {};
					var spiritArr:Array = this.others.spirit;
					var cfg:Object = ConfigFight.legendTalentFight;
					var len:int = spiritArr.length;
					for (var i:int = 0; i < len; i++) 
					{
						var heroArr:Array = spiritArr[i];
						var arr:Array = cfg[heroArr[0]];
						if (arr){
							var rankObj:Object = FightUtils.getRankObj(heroArr[1], arr);
							FightUtils.mergeObj(obj, rankObj);
						}
					}
					this.spiritTemp = obj;
				}
				else{
					this.spiritTemp = false;
				}
			}
			return this.spiritTemp;
		}


		
		override public function clear():void
		{
			//可能被清理多次，先判断
			if (!this.isCleared)
			{
				super.clear();
				this.heroLogic.clear();
				this.heroLogic = null;
				
				var i:int;
				var len:int = this.adjutants.length;
				for (i = 0; i < len; i++)
				{
					var adjutant:AdjutantLogic = this.adjutants[i];
					if(adjutant)
						adjutant.clear();
				}
				this.adjutants = null;
				
				len = this.armys.length;
				for (i = 0; i < len; i++)
				{
					var army:ArmyLogic = this.armys[i];
					army.clear();
				}
				this.armys = null;
			}
		}
	}

}