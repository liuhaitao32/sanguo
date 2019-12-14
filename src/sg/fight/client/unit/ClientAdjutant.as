package sg.fight.client.unit
{
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FHero;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightScene;
	import sg.fight.logic.unit.AdjutantLogic;
	import sg.fight.logic.unit.TroopLogic;
	
	/**
	 * 副将
	 * @author zhuda
	 */
	public class ClientAdjutant extends AdjutantLogic implements IClientUnit
	{
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function getName():String
		{
			var str:String;
			str = this.teamIndex == 0 ? 'L' : 'R';
			str += this.getClientTroop().getClientHero().name + '副将';
			return str;
		}
		public function getResId():String
		{
			return this.id;
		}
		public function getClientFight():ClientFight
		{
			return this.getClientTroop().fight;
		}
		
		public function getClientTroop():ClientTroop
		{
			return this.troopLogic as ClientTroop;
		}
		/**
		 * 获取当前场景
		 */
		public function getScene():FightScene
		{
			return this.getClientTroop().getClientTeam().getClientBattle().fightMain.scene;
		}
		
		public function getArmyType():int
		{
			return -1;
		}
		
		public function getPosX():Number
		{
			return this.person.standX;
		}
		
		public function get isFlip():Boolean
		{
			return this.getClientTroop().isFlip;
		}

		public var person:FHero;
		
		public function ClientAdjutant(data:*, troopLogic:TroopLogic, adjutantIndex:int)
		{
			super(data, troopLogic, adjutantIndex);
		}
		
		/**
		 * 显示
		 */
		public function show():void
		{
			var troop:ClientTroop = this.getClientTroop();
			var pos:Array = this.getPersonPosX(troop.posX, troop.isFlip);
			var scene:FightScene = this.getScene();
			this.person = new FHero(this, this.id, pos[0], pos[1]);
			this.person.setAlive();
		}
		
		/**
		 * 重显现
		 */
		public function reShow():void
		{
			var troop:ClientTroop = this.getClientTroop();
			this.person.setAlive();
			var pos:Array = this.getPersonPosX(troop.posX, troop.isFlip);
			this.person.reset(pos[0], pos[1]);
		}
		
		/**
		 * 重置位置
		 */
		public function resetPos():void
		{
			var troop:ClientTroop = this.getClientTroop();
			var pos:Array = this.getPersonPosX(troop.posX, troop.isFlip);
			this.person.reset(pos[0], pos[1]);
		}
		
		private function getPersonPosX(troopX:int, isFlip:Boolean):Array
		{
			var pos:Array = this.getClientTroop().getFormation().adjutant[this.getAdjutantIndex()];
			return [troopX + (isFlip ? -1 : 1) * pos[0], pos[1]];
		}
		
		/**
		 * 整个部队去做某事
		 */
		public function allPersonTo(funName:String, args:Array = null):void
		{
			var method:Function;
			method = this.person[funName] as Function;
			method.apply(this.person, args);
		}
		
		/**
		 * 整个部队延迟接到指令去做某事，序号靠前的优先行动
		 */
		public function allPersonDelayTo(funName:String, args:Array = null, delay:int = 0, rndDelay:int = 200):void
		{
			FightTime.delayTo(delay, this.person, this.person[funName], args);
			//FightTime.timer.once(delay, this.person, this.person[funName], args);
		}
		
		/**
		 * 进行攻击
		 */
		public function attackTo(aimMinX:Number, aimMaxX:Number, effObj:Object):void
		{
			var aimX:Number = (aimMinX + aimMaxX) / 2;
			this.person.autoAttack(aimX, aimX, effObj);
		}
		
		/**
		 * 进行施法
		 */
		public function fire(fireObj:Object):void
		{
			this.person.fire(fireObj);
		}
		/**
		 * 进行防御
		 */
		public function defense(hurtObj:Object):void
		{
			this.person.defense(hurtObj);
		}
		
		/**
		 * 进行移动
		 */
		public function move(dis:Number):void
		{
			this.person.move(dis);
		}
		
		/**
		 * 执行动作序列
		 */
		public function doAnimationQueue(stateName:String = '', endType:int = 0):void
		{
			this.person.doAnimationQueue(stateName, endType);
		}
		
		/**
		 * 更新血量（千分比）
		 */
		public function changeHp(currHp:int, hurtObj:Object, updateParent:Boolean = true, isDead:Boolean = true):void
		{
			if (currHp > 0)
			{
				//复活
				this.person.revive();
			}
			else
			{
				//死亡
				this.person.dead(hurtObj);
			}
		}
		
		
		/**
		 * 添加Buff显示
		 */
		public function addBuff(buffId:String):void{
			
		}
		
		/**
		 * 移除Buff显示
		 */
		public function removeBuff(buffId:String):void{
			
		}
	}

}