package sg.fight.client.unit
{
	import sg.cfg.ConfigServer;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.model.ModelFormation;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.spr.FHero;
	import sg.fight.client.spr.FPerson;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightScene;
	import sg.fight.client.view.ViewFightHero;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author zhuda
	 */
	public class ClientHero extends HeroLogic implements IClientUnit
	{
		public var person:FPerson;
		public var name:String;
		
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function getName():String
		{
			var str:String;
			str = this.teamIndex == 0 ? 'L' : 'R';
			str += this.name + '英雄';
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
		public function getHeroStarColorLv():int
		{
			return ModelHero.getHeroStarGradeColor(this.hero_star);
		}
		
		public function getPosX():Number
		{
			return this.person.standX;
		}
		
		public function get isFlip():Boolean
		{
			return this.getClientTroop().isFlip;
		}
		/**
         * 得到幕府描述文字
         */
		public function getShogunName():String
		{
			return Tools.getMsgById('shogun_hero_' + this.type);
		}
		

		
		public function ClientHero(data:*, troopLogic:TroopLogic)
		{
			super(data, troopLogic);
			var heroConfig:* = ConfigServer.hero[this.id];
			this.name = Tools.getMsgById(heroConfig.name);
			
			if (this.isAwaken){
				this.name = Tools.getMsgById('hero_awaken_name',[this.name]);
			}
			//trace('\n打印 person:\n' + JSON.stringify(this.person.x));
		}
		

		
		/**
		 * 显示
		 */
		public function show():void
		{
			//var troop:ClientTroop = this.getClientTroop();
			var pos:Array = this.getStandPos();
			var hero:FHero = new FHero(this, this.id, pos[0], pos[1]);
			this.person = hero;
			
			hero.addGroup(this.troopLogic.data.group);
			hero.addEquipBall(this.troopLogic.data.rise);
			if (this.isAwaken){
				hero.addAwaken(this.id);
			}
			//hero.addAnimation('grow011');
			
			hero.setAlive();
			
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
			if(effObj && effObj.canRevive)
				this.person.revive();
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
		 * 重显现
		 */
		public function reShow():void
		{
			//var troop:ClientTroop = this.getClientTroop();
			this.person.setAlive();
			var pos:Array = this.getStandPos();
			this.person.reset(pos[0], pos[1]);
			//this.person.reset(this.getPersonPosX(troop.posX, troop.isFlip), this.getFormationHero[1]);
		}
		
		/**
		 * 重置位置
		 */
		public function resetPos():void
		{
			//var troop:ClientTroop = this.getClientTroop();
			this.person.alive = true;
			var pos:Array = this.getStandPos();
			this.person.reset(pos[0], pos[1]);
		}
		
		/**
		 * 得到当前应当站立的坐标
		 */
		private function getStandPos():Array
		{
			var troop:ClientTroop = this.getClientTroop();
			var xx:int = troop.posX + (isFlip ? -1 : 1) * troop.getFormation().hero[0];
			var yy:int = troop.getFormation().hero[1];
			return [xx, yy];
		}
		//private function getPersonPosX(troopX:int, isFlip:Boolean):int
		//{
			//return troopX + (isFlip ? -1 : 1) * this.getFormationHero[0];
		//}
		
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
			else if (currHp < 0)
			{
				//受伤转移到英雄动画
				this.person.injured(hurtObj);
			}
			else
			{
				//死亡
				this.person.dead(hurtObj);
				//无hurtObj是最后死亡
				if (hurtObj){
					var heroDeadSound:Object = ConfigServer.effect.heroDeadSound;
					if (heroDeadSound){
						var arr:Array = heroDeadSound[this.sex];
						if (arr)
						{
							FightTime.playSound(arr[0], arr[1], arr[2]);
						}
					}
				}
			}
		}

		
		
		/**
		 * 更新英雄属性(暂未完整实现)
		 */
		public function updateProp():void{
			var view:ViewFightHero = this.getClientFight().fightMain.ui.heroUI;
			if (view){
				view.updateHeroesProp();
			}
		}
		
		/**
		 * 添加Buff显示
		 */
		public function addBuff(buffId:String):void{
			var buffObj:Object = ConfigServer.effect[buffId];
			this.person.addBuff(buffObj);
			
			//this.updateProp();
		}
		
		/**
		 * 移除Buff显示，更新双方属性
		 */
		public function removeBuff(buffId:String):void{
			var buffObj:Object = ConfigServer.effect[buffId];
			this.person.removeBuff(buffObj);
			
			//this.updateProp();
		}
		/**
		 * 战斗结束重置
		 */
		override public function resetEnd():void
		{
			super.resetEnd();
			//被斩了会复活
			if (this.troopLogic.getAllHp() > 0){
				this.person.revive();
			}
			//if (!this.person.alive && this.troopLogic.getAllHp() > 0){
				//this.person.revive();
			//}
			this.person.removeAllAnimation();
		}
		
		override public function clear():void
		{
			super.clear();
			this.person = null;
		}
	}

}