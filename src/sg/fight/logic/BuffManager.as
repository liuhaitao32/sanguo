package sg.fight.logic
{
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.AttackerLogic;
	import sg.fight.logic.unit.BuffLogic;
	import sg.fight.logic.unit.ShieldLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.Tools;
	
	/**
	 * 战斗中的buff管理器，含护盾
	 * @author zhuda
	 */
	public class BuffManager
	{
		public var unitFighting:UnitFighting;
		
		public function get logic():AttackerLogic
		{
			return this.unitFighting.logic;
		}
		public function get armyLogic():ArmyLogic
		{
			if(this.unitFighting.logic is ArmyLogic)
				return this.unitFighting.logic as ArmyLogic;
			else
				return null;
		}
		public function get buffArr():Array
		{
			return this._buffArr;
		}
		
		///状态数组
		private var _buffArr:Array;
		///护盾数组
		private var _shieldArr:Array;
		
		public function BuffManager(unitFighting:UnitFighting)
		{
			this.unitFighting = unitFighting;
			this._buffArr = [];
			this._shieldArr = [];
		}
		
		/**
		 ** 承受伤害，尝试用护盾依次抵挡（最优先的护盾优先抵挡）,返回[实际伤害，是否有完全抵挡护盾生效]
		 */
		public function bearDamage(dmgIn:int,tgtData:Object):Array
		{
			var len:int = this._shieldArr.length;
			var isNumShield:Boolean = false;
			for (var i:int = 0; i < len; i++)
			{
				var shield:ShieldLogic = this._shieldArr[i];
				dmgIn = shield.bearDamage(dmgIn, tgtData);
				if (shield.value <= 0){
					//该护盾消失移除
					i--;
					len--;
				}
				isNumShield = shield.bearPoint < 0;
				if (dmgIn <= 0)
					break;
			}
			return [dmgIn,isNumShield];
		}
	
		
		/**
		 * 部队开始行动前或后，遍历所有buff
		 */
		public function checkBuffs(checkEnd:int):void
		{
			//if (FightLogic.canPrint)
			//{
				//FightLogic.print(' ' + this.unitFighting.getName() + ' 检测状态', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
			//}
			
			var actArr:Array = [];
			var i:int;
			var len:int = this._buffArr.length;
			for (i = len-1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				if(buff.checkEnd == checkEnd){
					var actObj:Object = buff.act;
					if (actObj)
					{
						actObj.type = ConfigFight.ACT_BUFF;
						actObj.buffId = buff.id;
						actArr.push(actObj);
					}
					buff.round--;
					if (buff.round == 0)
					{
						this.removeBuffByIndex(i, true, false);
					}
					else{
						if (FightLogic.canPrint)
						{
							FightLogic.print('  ' + this.unitFighting.getName() +' 当前状态 ' +buff.getInfo(), null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
						}
					}
				}
			}
			if(!checkEnd){
				//战斗中,将本回合checkbuff整理好的arr传入，排序并生成Actions
				this.unitFighting.addBuffActions(actArr);
			}
		}

		

		
		/**
		 * 标记数量改变，检查是否需要调整buff层数
		 */
		public function addEnergeBuff(key:String, value:int):void
		{
			var buff:BuffLogic;
			buff = this.findBuffById(key);
			if (buff){
				//已经有了，增减叠加层数
				buff.addStack(value);
			}
			else{
				buff = this.newBuff(key, ConfigFight.buffDefault[key]);
				buff.addStack(value);
				this._buffArr.push(buff);
			}
		}
		
		/**
		 * 加入或叠加buff。tgtData只是回放对象，如果有返回，说明附加了护盾数据
		 */
		public function addBuffs(attackAction:AttackAction, hitData:Object,  tgtData:Object):Array
		{
			var buffs:Object = hitData.buff;
			var fight:FightLogic = this.unitFighting.getFight();
			var shieldArr:Array;
			var buffObj:Object;
			var id:String;
			var key:*;
			
			//填充默认值
			for(id in buffs){
				var defaultObj:Object = ConfigFight.buffDefault[id];
				if (defaultObj){
					//data = FightUtils.clone(data);
					buffObj = buffs[id];
					for (key in defaultObj)
					{
						FightUtils.fillDefault(buffObj,key,defaultObj[key]);
					}
				}
			}
			
			//需要在此保证buff执行顺序
			var buffArr:Array = FightUtils.objectToArrayAddKey(buffs);
			var len:int = buffArr.length;
			if (len > 1){
				FightUtils.sortPriority(buffArr);
			}
			var i:int;
			for (i = 0; i < len; i++){
				buffObj = buffArr[i];
				id = buffObj.id;
				var rnd:int;
				if (buffObj.hasOwnProperty('rnd'))
				{
					rnd = buffObj.rnd;
					if (rnd <= 0)
						continue;
				}
				else{
					rnd = ConfigFight.ratePoint;
				}
				var getRate:int;
				if (buffObj.type == 2 && this.logic.deBuffRate)
				{
					//不良BUFF，且承受者对其有抵抗或易伤效果（减免或增加中buff几率）
					getRate = this.logic.deBuffRate;
					//<=-1000才完全不中异常
					if (getRate <= -ConfigFight.ratePoint){
						if (FightLogic.canPrint)
						{
							FightLogic.print('      ' + this.unitFighting.getName() + ' 因免疫所有不良状态  ' + BuffLogic.getDataName(buffObj) + ' 无效', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
						}
						continue;
					}
					rnd = Math.floor(rnd * FightUtils.pointToRate(getRate));
				}
				
				if (this.logic.others && this.logic.others['get_'+id])
				{
					//如果有专门的状态命中加成或抗性，在此结算
					getRate = this.logic.others['get_' + id];
					//<=-1000才完全不中该异常
					if (getRate <= -ConfigFight.ratePoint){
						if (FightLogic.canPrint)
						{
							FightLogic.print('      ' + this.unitFighting.getName() + ' 因免疫特定状态  ' + BuffLogic.getDataName(buffObj) + ' 无效', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
						}
						continue;
					}
					rnd = Math.floor(rnd * FightUtils.pointToRate(getRate));
				}
				
				//无效buff和绝对免疫buff已经剔除完毕
				
				if (!fight.random.determine(rnd))
				{
					if (FightLogic.canPrint)
					{
						FightLogic.print('      ' + this.unitFighting.getName() + ' 因概率判定失败  ' + BuffLogic.getDataName(buffObj) + ' 无效', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
					}
					//判定失败，但若是不良状态，再判定检查获得buff时动作
					
					var isForce:Boolean = attackAction.getTroopFighting().heroFighting.doForceDebuffActions(attackAction, this.unitFighting, buffObj.name);
					
					if (isForce){

					}
					else{
						continue;
					}
				}

				var buff:BuffLogic;
				buff = this.findBuffById(id);
				var newBuff:BuffLogic = this.newBuff(id, buffObj);
				var isMerge:Boolean;
				var shield:ShieldLogic;
				var armyLogic:ArmyLogic = this.armyLogic;
				
				if (buff)
				{
					if (newBuff.shield){
						//[1]伤害类型0普通 1暴击 -1格挡 3治疗 4护盾
						if (armyLogic){
							shield = new ShieldLogic(id, newBuff.shield, this, newBuff, buffObj.priority);
							newBuff.shield = shield;
							shieldArr = [shield.value, 4, armyLogic.hpm];
						}
					}
					
					buff.mergeBuff(newBuff);
					//print('叠加了buff', buff);
					isMerge = true;
				}
				else
				{
					buff = newBuff;
					buff.addStack(1);
					this._buffArr.push(buff);
					//print('添加了buff', buff);
					if (!tgtData.buffs)
					{
						tgtData.buffs = [];
					}
					tgtData.buffs.push(id);
					
					if (buffObj.shield){
						shield = new ShieldLogic(id, buffObj.shield, this, buff, buffObj.priority);
						//按护盾优先级排序，仙隐最先
						this.addShield(shield);
						//[1]伤害类型0普通 1暴击 -1格挡 3治疗 4护盾
						if(armyLogic){
							shieldArr = [shield.value, 4, armyLogic.hpm];
						}
					}
				}
				
				if (FightLogic.canPrint)
				{
					var mergeInfo:String;
					if (isMerge){
						if (buff.stackMax == -2){
							mergeInfo = '叠加护盾';
						}
						else if (buff.stackMax == -1){
							mergeInfo = '保持状态';
						}
						else if (buff.stackMax == 0){
							mergeInfo = '更新状态';
						}
						else if (buff.stackMax == buff.stackCurr){
							mergeInfo = '状态叠满';
						}
						else{
							mergeInfo = '叠加状态';
						}
					}
					else{
						mergeInfo = '被施加了';
					}
					var priorityStr:String = '  优先级:'+buff.data.priority;
					FightLogic.print('      ' + this.unitFighting.getName() + ' ' + mergeInfo + ' ' + buff.getInfo() + priorityStr, null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
				}
			}
			return shieldArr;
		}
		
		/**
		 * 按护盾优先级排序，仙隐最先
		 */
		public function addShield(shield:ShieldLogic):void
		{
			this._shieldArr.push(shield);
			if (this._shieldArr.length > 1){
				FightUtils.sortPriority(this._shieldArr);
			}
		}
		
		
		/**
		 * 获得当前buff的数量 0特殊不可被清 1有益buff 2有害buff，或者特定类型buff数量。   containOneRound为包含仅剩1回合的，预备期清除状态应不包含
		 */
		public function getBuffNum(type:*, containOneRound:Boolean = true):int
		{
			//特定类型
			if (type is String){
				if (this.hasBuff(type,containOneRound)){
					return 1;
				}
				else{
					return 0;
				}
			}
			
			var i:int;
			var len:int = this._buffArr.length;
			var num:int = 0;
			for (i = len-1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				var actObj:Object = buff.act;

				if (buff.type == type){
					if (!containOneRound && buff.isOneRound){
						//仅剩1回合的非动作型buff，预备期不做清除
						continue;
					}
					num++;
				}

			}
			return num;
		}
		
		/**
		 * 有状态buff
		 */
		public function hasBuff(id:String, containOneRound:Boolean = true):Boolean
		{
			return this.findBuffById(id, containOneRound) != null;
		}
		
		/**
		 * 找到buff
		 */
		public function findBuffById(id:String, containOneRound:Boolean = true):BuffLogic
		{
			for (var i:int = this._buffArr.length - 1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				if (!containOneRound && buff.isOneRound){
					//仅剩1回合的非动作型buff，预备期不做清除
					continue;
				}
				if (buff.id == id)
					return buff;
			}
			return null;
		}
		
		
		/**
		 * 清理buff的所有效果
		 */
		private function clearBuff(buff:BuffLogic,buffIndex:int = -1):void
		{
			if (buff.shield){
				var shieldIndex:int = this._shieldArr.indexOf(buff.shield);
				if(shieldIndex >=0)
					this._shieldArr.splice(shieldIndex, 1);
			}
			if (buffIndex < 0)
				buffIndex = this._buffArr.indexOf(buff);
			if(buffIndex>=0){
				this._buffArr.splice(buffIndex, 1);
			}
			buff.clear();
		}
		

		/**
		 * 移除指定Index buff(含实体移除时对数据的改变)
		 * removeAction 移除其相关action，用于主回合前清理混乱和内讧
		 */
		private function removeBuffByIndex(index:int, addPlayback:Boolean = true, removeAction:Boolean = true):Object
		{
			var buff:BuffLogic = this._buffArr[index];
			
			//print('移除了buff', buff);
			var logic:AttackerLogic = this.logic;
			var valueObj:Object = {unit: [logic.teamIndex, logic.armyIndex], id: buff.id};
			//buff.clear();
			//this._buffArr.splice(index, 1);
			this.clearBuff(buff, index);
			
			if (addPlayback){
				var fight:FightLogic = this.unitFighting.getFight();
				fight.addPlayback({key: 'removeBuff', value: valueObj});
				if (FightLogic.canPrint)
				{
					FightLogic.print('  ' + this.unitFighting.getName() +' ' +buff.getName()+  ' 效果已消失', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
				}
			}
			else{
				if (FightLogic.canPrint)
				{
					FightLogic.print('    ' + this.unitFighting.getName() + ' ' +buff.getName()+ ' 被移除', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
				}
			}
			if (removeAction){
				this.unitFighting.removeBuffAction(buff.id);
			}
			return valueObj;
		}
		
		/**
		 * 移除指定的buff(护盾被打爆调用)
		 */
		public function removeBuff(buff:BuffLogic, tgtData:Object):void
		{
			var index:int = this._buffArr.indexOf(buff);
			if (index < 0)
				return;
			var valueObj:Object = this.removeBuffByIndex(index, !tgtData);
			//加入回放
			if(tgtData){
				if (!tgtData.removeBuffs)
				{
					tgtData.removeBuffs = [];
				}
				tgtData.removeBuffs.push(valueObj.id);
			}
		}
		
		/**
		 * 移除Type下若干buff   type 1增益 2减益，containOneRound为包含仅剩1回合的预备期清除状态应不包含
		 */
		public function removeBuffsByType(type:int, num:int, tgtData:Object, containOneRound:Boolean = true):void
		{
			if (num > ConfigFight.maxPoint){
				this.removeAllBuffsByType(type, tgtData);
				return;
			}
			for (var i:int = 0; i < num; i++) 
			{
				var buffId:String = this.removeOneBuffByIndexArr(type, tgtData, containOneRound);
				if (!buffId){
					break;
				}
			}
		}
		/**
		 * 移除indexArr范围下1个随机buff，containOneRound为包含仅剩1回合非动作型buff,预备期清除应不包含        返回是否移除成功
		 */
		public function removeOneBuffByIndexArr(type:int, tgtData:Object, containOneRound:Boolean = true):String
		{
			var indexArr:Array = [];
			for (var i:int = this._buffArr.length - 1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				if (buff.type == type)
				{
					if (!containOneRound && buff.isOneRound){
						//仅剩1回合的非动作型buff，预备期不做清除
						continue;
					}
					indexArr.push(i);
				}
			}
			if (indexArr.length > 0){
				var fight:FightLogic = this.unitFighting.getFight();
				var index:int = fight.random.getRandomIndex(indexArr.length);
				var valueObj:Object = this.removeBuffByIndex(indexArr[index], false);
				
				//加入回放
				if (!tgtData.removeBuffs)
				{
					tgtData.removeBuffs = [];
				}
				tgtData.removeBuffs.push(valueObj.id);
				return valueObj.id;
			}
			return null;
		}
		
		
		
		/**
		 * 移除指定Type的所有buff
		 */
		public function removeAllBuffsByType(type:int, tgtData:Object):void
		{
			for (var i:int = this._buffArr.length - 1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				if (buff.type == type)
				{
					var valueObj:Object = this.removeBuffByIndex(i,false);
					//加入回放
					if (!tgtData.removeBuffs)
					{
						tgtData.removeBuffs = [];
					}
					tgtData.removeBuffs.push(valueObj.id);
				}
			}
		}
		
		/**
		 * 新建buff，此行为不会直接改变属性，也不会加入到判定列表
		 */
		private function newBuff(id:String, buffObj:Object):BuffLogic
		{
			var buff:BuffLogic = new BuffLogic(id, buffObj, this);
			return buff;
		}
		
		/**
		 * 打印
		 */
		private function print(str:String, buff:BuffLogic):void
		{
			var fight:FightLogic = this.unitFighting.getFight();
			trace(fight.round + '回合，' + this.unitFighting.getName() + ' ' + str + ': ' + buff.id + '('+buff.stackCurr+'层)');
		}
		
		/**
		 * 清理
		 */
		public function clear():void
		{
			for (var i:int = this._buffArr.length - 1; i >= 0; i--)
			{
				var buff:BuffLogic = this._buffArr[i];
				buff.clear();
			}
			this._buffArr = null;
		}
	
	}

}