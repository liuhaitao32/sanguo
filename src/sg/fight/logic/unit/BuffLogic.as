package sg.fight.logic.unit 
{
	import sg.fight.logic.BuffManager;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.Tools;
	/**
	 * 战斗中状态
	 * @author zhuda
	 */
	public class BuffLogic extends LogicBase
	{
		///绑定的对象
		public var buffManager:BuffManager;
		///必须指定id 同id会叠加或覆盖
		public var id:String;
		///中招千分点
		public var rnd:int;
		///0特殊不可被清 1有益buff 2有害buff
		public var type:int;
		///持续回合数，任意单位的回合开始时-1，到0时移除 ，-1无限时间，默认0无限回合
		public var round:int;
		///影响logic上的某些属性（buffChange时重算缓存）
		public var prop:Object;
		//checkBuff时生效的效果（毒等，不可致死）
		public var act:Object;
		///最大叠加层数 默认0重置成回合更多的 -1不可叠加或重置 -2新的替换旧
		public var stackMax:int;
		///当前层数
		public var stackCurr:int;
		///绑定的护盾，护盾移除时需要移除buff，反之也是
		public var shield:ShieldLogic;
		///特效
		public var effect:int;
		///是每回合行动结束后才清除
		public var checkEnd:int;
		
		///仅客户端调用
		public var name:String;
		
		public function BuffLogic(id:String,data:*,buffManager:BuffManager) 
		{
			this.id = id;
			this.buffManager = buffManager;
			
			super(data);
			//this.setStack(stack);
		}
		
		

		/**
		 * 仅客户端调用
		 */
		public static function getDataName(data:*) :String
		{
			var typeStr:String;
			var nameStr:String = data.name?data.name:data.id;
			if (data.type == 1){
				typeStr = '▲';
			}
			else if (data.type == 2){
				typeStr = '▼';
			}
			else{
				typeStr = '◆';
			}
			return typeStr + Tools.getMsgById(nameStr, null, false);
		}
		/**
		 * 仅客户端调用
		 */
		public function getName() :String
		{
			return BuffLogic.getDataName(this);
		}
		/**
		 * 仅客户端调用
		 */
		public function getRoundInfo() :String
		{
			if (this.round >= 1){
				return this.round + '回合';
			}
			return '无限回合';
		}
		/**
		 * 仅客户端调用
		 */
		public function getShieldInfo() :String
		{
			if (this.shield){
				return '  护盾值' + this.shield.value;
			}
			return '';
		}
		/**
		 * 仅客户端调用
		 */
		public function getInfo() :String
		{
			var stackInfo:String = this.stackCurr > 1?' ' + this.stackCurr + '层 ':' ';
			return this.getName() + stackInfo + this.getRoundInfo() + this.getShieldInfo();
		}
		
		/**
		 * 是否是可马上清算的buff（仅剩1回合、非动作型buff、回合行动前执行），预备期不做清除
		 */
		public function get isOneRound() :Boolean
		{
			return this.round == 1 && !this.act && !this.checkEnd;
		}
		
		/**
		 * 尝试叠加上id相同的状态，可能回合数不同    默认0重置成回合更多的 -1不可叠加或重置 -2新的替换旧
		 */
		public function mergeBuff(newBuff:BuffLogic) :void
		{
			if (this.stackMax == 0)
			{
				//重置回合数较多的
				this.round = Math.max(this.round,newBuff.round);
			}
			else if (this.stackMax > 0){
				//叠加层数
				if (this.stackCurr < this.stackMax){
					this.addStack(1);
				}
			}
			else if (this.stackMax == -1){
				//-1不可叠加或重置
				return;
			}
			else if (this.stackMax == -2){
				//-2护盾叠加
				if (this.shield && newBuff.shield){
					this.shield.value += newBuff.shield.value;
				}
			}
		}
		
		
		/**
		 * 叠加指定层数，并使层数属性生效
		 */
		public function addStack(num:int) :void
		{
			this.setStack(this.stackCurr+num);
		}
		/**
		 * 修改层数属性，倍数
		 */
		private function setStack(num:int) :void
		{
			if (!this.prop)
				return;
			if (this.stackCurr != num){
				var add:int = num - this.stackCurr;
				this.stackCurr = num;
				
				var logic:AttackerLogic = this.buffManager.logic;
				if(logic){
					for (var key:String in this.prop){
						FightUtils.addObjByPath(logic, key, this.prop[key] * add);
						
						//if (logic[key] <-1000){
							//trace(this.buffManager.unitFighting.getName()+'【'+key+'值异常！！！】' + logic[key]);
						//}
					}
				}
			}
		}
		/**
		 * 追加层数属性，倍数，不会删除
		 */
		//public function addStack(add:int) :void
		//{
			//if (!this.prop)
				//return;
			//if (add != 0){
				//this.stackCurr += add;
				//
				//for (var key:String in this.prop){
					//FightUtils.addObjByPath(this.buffManager.logic, key, this.prop[key] * add);
				//}
			//}
		//}

		/**
		 * 移除buff，还原属性
		 */
		override public function clear() :void
		{
			if (this.isCleared)
				return;
			this.setStack(0);
			this.prop = null;
			this.buffManager = null;
			super.clear();
			if (this.shield){
				this.shield.clear();
				this.shield = null;
			}
		}
		
	}

}