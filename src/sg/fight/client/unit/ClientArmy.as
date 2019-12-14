package sg.fight.client.unit
{
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.model.ModelFormation;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FEffect;
	import sg.fight.client.spr.FPerson;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.client.view.FightScene;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.map.utils.ArrayUtils;
	import sg.utils.Tools;
	
	/**
	 * 前后军
	 * @author zhuda
	 */
	public class ClientArmy extends ArmyLogic implements IClientUnit
	{
		///格式站位数组
		public var formation:Array;
		///站位偏移
		public var floatPosArr:Array;
		///士兵们的总数量，阵法中已排除副将的不算
		private var personNum:int;
		///包含的士兵们
		public var persons:Array;
		///上一次的血量（客户端血条）
		public var lastHp:int;
		

		
		public function getClientFight():ClientFight
		{
			return this.getClientTroop().fight;
		}
		
		public function getResId():String
		{
			return this.resId?this.resId:'army' + this.type.toString() + this.rank.toString();
		}
		
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function getName():String
		{
			var str:String;
			var clientTroop:ClientTroop = this.getClientTroop();
			var clientHero:ClientHero = clientTroop.getClientHero();
			str = clientTroop.teamIndex == 0 ? 'L' : 'R';
			str += clientHero.name + (this.armyIndex == 0 ? '前军' : '后军');
			return str;
		}
		
		public function getClientTroop():ClientTroop
		{
			return this.troopLogic as ClientTroop;
		}
		/**
         * 得到幕府描述文字
         */
		public function getShogunName():String
		{
			return Tools.getMsgById('shogun_army_' + this.type);
		}
		
		public function getArmyType():int
		{
			return this.type;
		}
		/**
		 * 获取当前场景
		 */
		public function getScene():FightScene
		{
			return this.getClientTroop().getClientTeam().getClientBattle().fightMain.scene;
		}
		
		public function getPosX():Number
		{
			var troop:ClientTroop = this.getClientTroop();
			return troop.posX + (troop.isFlip ? -1 : 1) * ConfigFightView.ARMY_OFFSET[this.armyIndex];
		}
		
		public function get isFlip():Boolean
		{
			return this.getClientTroop().isFlip;
		}
		
		public function ClientArmy(data:*, troopLogic:TroopLogic, armyIndex:int ,initHp:int)
		{
			super(data, troopLogic, armyIndex, initHp);
			this.updateLastHp();
		}
		
		override public function setData(data:*):void
		{
			super.setData(data);
			this.updateLastHp();
			//trace(this.getName(),'lastHp', this.lastHp);
		}
		override public function resetEnd():void
		{
			super.resetEnd();
			this.updateLastHp();
		}
		private function updateLastHp():void
		{
			this.lastHp = this.hp;
		}
		
		/**
		 * 显示
		 */
		public function show():void
		{
			this.persons = [];
			var id:String = this.getResId();
			var armyIndex:int = this.armyIndex;
			var troop:ClientTroop = this.getClientTroop();
			var troopX:int = troop.posX;
			var isFlip:Boolean = troop.isFlip;
			
			var size:int = ConfigFightView.ARMY_SIZE[id] != null ? ConfigFightView.ARMY_SIZE[id] : 0;
			var modelFormation:ModelFormation = this.getClientTroop().getFormation();
			this.formation = modelFormation.getArmyFormation(armyIndex, size);
			this.floatPosArr = modelFormation.float;
			//this.formation = ConfigFightView.ARMY_FORMATION[armyIndex][size] as Array;
			//近战单位
			//var isMelee:Boolean = this.type < 2;
			
			var hasAdjutantArr:Array = [false,false]; 
			if (this.troopLogic.adjutants){
				if (this.troopLogic.adjutants[0])
					hasAdjutantArr[0] = true;
				if (this.troopLogic.adjutants[1])
					hasAdjutantArr[1] = true;
			}
			var scene:FightScene = this.getScene();
			
			var i:int;
			var len:int = this.formation.length;
			var posArr:Array;
			//整理出士兵人数
			this.personNum = 0;
			if (this.hpm <= 0) return;
			
			for (i = 0; i < len; i++)
			{
				posArr = this.formation[i];
				if (posArr.length > 2 && hasAdjutantArr[posArr[2]])
				{
					continue;
				}
				this.personNum++;
			}
			
			var aliveNum:int = this.getAliveNum(this.hp);
			var num:int = 0;
			
			for (i = 0; i < len; i++)
			{
				posArr = this.formation[i];
				if (posArr.length > 2 && hasAdjutantArr[posArr[2]])
				{
					continue;
				}
				posArr = this.getPersonPos(i, troopX, isFlip);
				var person:FPerson = new FPerson(scene, this, id, posArr[0], posArr[1], ConfigFightView.ARMY_BASE_SCALE);
				//person.isMelee = isMelee;
				person.index = i;
				this.persons.push(person);
				if (num >= aliveNum)
				{
					person.setDead();
				}
				else
				{
					person.setAlive();
				}
				num++;
			}
			//只乱序初始化兵力存在的数组
			//ArrayUtils.randomArr(this.persons, aliveNum);
			//this.changeHp(this._hp);
		}
		
		/**
		 * 重显现
		 */
		public function reShow():void
		{
			var armyIndex:int = this.armyIndex;
			var troop:ClientTroop = this.getClientTroop();
			var troopX:int = troop.posX;
			var isFlip:Boolean = troop.isFlip;
			
			var i:int;
			var len:int = this.persons.length;
			for (i = 0; i < len; i++)
			{
				var person:FPerson = this.persons[i];
				var pos:Array = this.getPersonPos(person.index, troopX, isFlip);
				person.reset(pos[0], pos[1], true);
			}
		}
		
		/**
		 * 重置前后部人员位置
		 */
		public function resetPos():void
		{
			var armyIndex:int = this.armyIndex;
			var troop:ClientTroop = this.getClientTroop();
			var troopX:int = troop.posX;
			var isFlip:Boolean = troop.isFlip;
			
			var i:int;
			var len:int = this.persons.length;
			for (i = 0; i < len; i++)
			{
				var person:FPerson = this.persons[i];
				var pos:Array = this.getPersonPos(person.index, troopX, isFlip);
				person.reset(pos[0], pos[1]);
			}
			//this.changeHp(this._hp);
		}
		
		private function getPersonPos(index:int, troopX:int, isFlip:Boolean):Array
		{
			var pos:Array = this.formation[index];
			var arr:Array = [troopX + (isFlip ? -1 : 1) * (pos[0] + ConfigFightView.ARMY_OFFSET[armyIndex]), pos[1]];
			if (this.floatPosArr){
				arr[0] += (2 * Math.random()-1) * this.floatPosArr[0];
				arr[1] += (2 * Math.random()-1) * this.floatPosArr[1];
			}
			return arr;
		}
		
		/**
		 * 整个部队去做某事
		 */
		public function allPersonTo(funName:String, args:Array = null):void
		{
			var person:FPerson;
			var method:Function;
			for (var i:int = this.persons.length - 1; i >= 0; i--)
			{
				person = this.persons[i];
				//person[funName]();
				method = person[funName] as Function;
				method.apply(person, args);
			}
		}
		
		/**
		 * 整个部队延迟接到指令去做某事，序号靠前的优先行动。返回前摇或行动时间
		 */
		public function allPersonDelayTo(funName:String, args:Array = null, delay:int = 0, rndDelay:int = 200):void
		{
			var person:FPerson;
			var i:int;
			var len:int = this.persons.length;
			for (i = 0; i < len; i++)
			{
				person = this.persons[i];
				//前排中央的延迟少
				var finalDelay:int = Math.floor((Math.random() + (person.index / len) * 0.5) * rndDelay + delay);
				FightTime.delayTo(finalDelay, person, person[funName], args);
					//FightTime.timer.once(finalDelay, person, person[funName], args);
			}
			//预先计算行动时间
			//var actTime:int = 0.7 * rndDelay + delay;
			//if (funName == 'autoAttack')
			//{
				//var aimX:Number = args[0];
				//var speedRate:Number = args[1];
				//var dis:Number = FightViewUtils.getRunDis(this.getPosX(), aimX);
				//actTime += FightViewUtils.getRunTime(dis, speedRate);
			//}
		}
		
		/**
		 * 进行攻击
		 */
		public function attackTo(aimMinX:Number, aimMaxX:Number, effObj:Object):void
		{
			var delayRnd:int;
			delayRnd = effObj.hasOwnProperty('rndTime') ? effObj.rndTime : ConfigFightView.ARMY_RANDOM_TIME;
			
			var dis:Number = 0;
			//如果有阵法，更加整齐划一的行动
			if (this.troopLogic.formationType){
				delayRnd = Math.ceil(0.3 * delayRnd);
				//这里只用于锁定整体方向
				dis = FightViewUtils.getSignDisX(this.getPosX(), (aimMinX + aimMaxX) / 2, 0);
				if (this.isFlip)
					dis = -dis;
			}
			
			this.allPersonDelayTo('autoAttack', [aimMinX, aimMaxX, effObj, dis], 10, delayRnd);
		}
		
		/**
		 * 进行施法
		 */
		public function fire(fireObj:Object):void
		{
			var delayRnd:int;
			delayRnd = fireObj.hasOwnProperty('rndTime') ? fireObj.rndTime : ConfigFightView.ARMY_RANDOM_TIME;
			this.allPersonDelayTo('fire', [fireObj], 0, delayRnd);
		}
		/**
		 * 进行防御
		 */
		public function defense(hurtObj:Object):void
		{
			var delayRnd:int;
			delayRnd = ConfigFightView.ARMY_RANDOM_TIME*0.5;
			this.allPersonDelayTo('defense', [hurtObj], 0, delayRnd);
		}
		
		/**
		 * 进行移动
		 */
		public function move(dis:Number):void
		{
			this.allPersonTo('move', [dis]);
		}
		
		/**
		 * 执行动作序列
		 */
		public function doAnimationQueue(stateName:String = '', endType:int = 0):void
		{
			this.allPersonDelayTo('doAnimationQueue', [stateName, endType]);
		}
		
		/**
		 * 得到当前兵力应有的数量
		 */
		public function getAliveNum(currHp:int):int
		{
			var hpPer:Number = currHp / this.hpm;
			return Math.ceil(this.personNum * hpPer);
		}
		
		/**
		 * 修改剩余兵力，同时更新troop血量
		 */
		public function changeHp(currHp:int, hurtObj:Object, updateParent:Boolean = true, isDead:Boolean = true):void
		{
			if (this.isCleared) return;
			//trace(this.getName(),'currHp/lastHp/hp', currHp, this.lastHp, this.hp);
			//trace(this.getName(),'当前部队人数/currHp/isDead', this.getPersonNum(), currHp, isDead, this.lastHp, this.hp);
			if (this.getClientFight().isEnd) return;
			//因为伤害显示异步结算，如果本次是减血，当前血量比目标血量更低时不更新
			if (isDead && this.lastHp < currHp) return;
			if (this.hpm <= 0) return;

			//如果当前阵兵人数为0，改为由英雄承担动画
			var clientTroop:ClientTroop = this.getClientTroop();
			var allNum:int = this.persons.length;
			if (allNum <= 0){
				clientTroop.getClientHero().changeHp( -1, hurtObj);
				this.lastHp = currHp;
				clientTroop.updateHp(false);
				return;
			}

			var lastAliveNum:int = this.getAliveNum(this.lastHp);
			var aliveNum:int = this.getAliveNum(currHp);
			this.lastHp = currHp;
			//trace(this.getName(),'当前部队人数', this.getPersonNum(), lastAliveNum);
			var i:int;
			var index:int;
			var changeNum:int = aliveNum - lastAliveNum;
			
			var person:FPerson;
			if (changeNum > 0){
				//复活
				for (i = 0; i < changeNum; i++) 
				{
					person = this.getRandomPerson(false);
					person.revive();
				}
			}
			else if (changeNum < 0){
				//击杀，如果全部击杀特殊优化
				if (aliveNum == 0){
					for (i = 0; i < allNum; i++)
					{
						person = this.persons[i];
						if(person.alive)
							person.dead(hurtObj);
					}
				}
				else{
					changeNum = -changeNum;
					for (i = 0; i < changeNum; i++) 
					{
						person = this.getRandomPerson(true);
						person.dead(hurtObj);
					}
				}
			}
	
			var sort:Boolean = false;
			
			//如果产生了人数变化，也有阵法，按阵行顺序重整队形，计算应存活的部队数，所有已死的部队用活着的部队去跑位填充
			if (changeNum && clientTroop.formationType){
				var dis2:Number;
				var dis2Min:Number;
				var indexMin:int;
				var person2:FPerson;
				for (i = 0; i < allNum; i++)
				{
					person = this.persons[i];
					if (!person.alive){
						//太远也不直接补位
						dis2Min = 20000;
						indexMin = i;
						for (index = i+1; index < allNum; index++)
						{
							person2 = this.persons[index];
							if(person2.alive){
								dis2 = person.dis2To(person2);
								if (dis2 < 1000){
									//近距离直接补位
									indexMin = index;
									break;
								}
								else if(dis2 < dis2Min){
									dis2Min = dis2;
									indexMin = index;
								}
							}
						}
						//由indexMin补位
						if(indexMin != i){
							person2 = this.persons[indexMin];
							person.exchange(person2);
							
							this.persons[i] = person2;
							this.persons[indexMin] = person;
						}
					}
				}
				sort = true;
				//this.reFormation();
			}
			
			for (i = 0; i < allNum; i++)
			{
				person = this.persons[i];
				if(person.alive){
					person.delayTo(50, person, person.injured, [hurtObj]);
				}
			}
			//this.addSpecialEffect(hurtObj);
			
			
			if (updateParent)
			{
				if (aliveNum>lastAliveNum)
				{
					sort = true;
					
				}
				clientTroop.updateHp(false);
			}
			
			if (sort)
				this.getClientFight().sortTroops();
		}

		
		/**
		 * 得到当前活着人的实际数量
		 */
		public function getPersonNum(alive:Boolean = true):int
		{
			var i:int;
			var num:int = 0;
			var allNum:int = this.persons.length;
			for (i = 0; i < allNum; i++) 
			{
				var person:FPerson = this.persons[i];
				if (person.alive == alive)
					num++;
			}
			return num;
		}
		/**
		 * 得到随机一个活人或死人，实在出错了获得一个随机人
		 */
		public function getRandomPerson(alive:Boolean):FPerson
		{
			var allNum:int = this.persons.length;
			var index:int = Math.floor(Math.random() * allNum); 
			var num:int = 1; 
			var person:FPerson = this.persons[index];
			while (person.alive != alive && num<allNum){
				index = (index + 1) % allNum;
				person = this.persons[index];
				num++;
			}
			return person;
		}
		
		/**
		 * 增加单军特殊特效
		 */
		public function addSpecialEffect(hurtObj:Object):void
		{
			if (!hurtObj || !hurtObj.special) return;
			//if (Math.random() > 0.3) return;
			
			var clientTroop:ClientTroop = this.getClientTroop();
			var scene:FightScene = clientTroop.getClientTeam().getClientBattle().fightMain.scene;
			//反向
			var isFlip:Boolean = !this.isFlip;
			//var res:String = hurtObj.special;
			var len:int = hurtObj.num;
			var offsetY:Number = ConfigFightView.FORMATION_Y * 2 / len;
			var baseX:Number = (hurtObj.specialX?hurtObj.specialX:0) * (isFlip? -1:1);
			var baseY:Number = hurtObj.specialY?hurtObj.specialY:0;
			var baseZ:Number = ConfigFightView.HIT_Z + (hurtObj.specialZ?hurtObj.specialZ:0);
			var tempY:Number;
			
			if (ConfigApp.isPC){
				baseX *= 0.2;
			}
			if (clientTroop.playbackRound == 2){
				baseX *= 0.4;
			}
			else if (clientTroop.playbackRound > 2){
				baseX *= 0.1;
			}
			baseX += this.getPosX();
			
			for (var i:int = 0; i < len; i++)
			{
				//分布y
				tempY = baseY + offsetY * (i - (len - 1) / 2);
				var delayRnd:Number = FightViewUtils.getRandomValue(hurtObj.specialDelay);
				if(hurtObj.special2)
					new FEffect(scene, hurtObj.special2, baseX, tempY, baseZ, isFlip, 0, hurtObj.special2Scale, hurtObj.special2Alpha, delayRnd, hurtObj.special2Add);
				
				new FEffect(scene, hurtObj.special, baseX, tempY, baseZ, isFlip, 0, hurtObj.specialScale, hurtObj.specialAlpha, delayRnd, hurtObj.specialAdd);
			}
		
		}
		
		/**
		 * 添加Buff显示
		 */
		public function addBuff(buffId:String):void{
			var buffObj:Object = ConfigServer.effect[buffId];
			if (buffObj){
				this.allPersonDelayTo('addBuff', [buffObj]);
			}
		}
		
		/**
		 * 移除Buff显示
		 */
		public function removeBuff(buffId:String):void{
			var buffObj:Object = ConfigServer.effect[buffId];
			if (buffObj){
				this.allPersonDelayTo('removeBuff', [buffObj]);
			}
		}
		
		override public function clear():void
		{
			super.clear();
			this.formation = null;
			this.persons = null;
		}
	}

}