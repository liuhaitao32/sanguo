package sg.fight.client.interfaces
{
	import sg.fight.client.ClientFight;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.view.FightScene;
	
	/**
	 * 能够执行行动或承受效果的客户端战斗对象
	 * @author zhuda
	 */
	public interface IClientUnit
	{
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		function getName():String
		/**
		 * 获取资源id
		 */
		function getResId():String
		
		/**
		 * 获取当前场景
		 */
		function getScene():FightScene
		/**
		 * 获得当前战斗
		 */
		function getClientFight():ClientFight
		/**
		 * 获得父级部队
		 */
		function getClientTroop():ClientTroop
		
		/**
		 * 获得在本场战斗内的唯一id
		 */
		function getFightId():String
		
		/**
		 * 获得兵种类型编号
		 */
		function getArmyType():int
		
		/**
		 * 前后军序号 0前1后2英雄3前副将4后副将
		 */
		function getArmyIndex():int
		
		/**
		 * 获得X坐标
		 */
		function getPosX():Number
		

		
		/**
		 * 添加Buff显示
		 */
		function addBuff(buffId:String):void
		
		/**
		 * 移除Buff显示
		 */
		function removeBuff(buffId:String):void
		
		/**
		 * 得到自身是否翻转
		 */
		function get isFlip():Boolean
		
		/**
		 * 整个部队去做某事
		 */
		function allPersonTo(funName:String, args:Array = null):void
		
		/**
		 * 整个部队延迟接到指令去做某事，序号靠前的优先行动
		 */
		function allPersonDelayTo(funName:String, args:Array = null, delay:int = 0, rndDelay:int = 200):void
		
		/**
		 * 进行攻击
		 */
		function attackTo(aimMinX:Number, aimMaxX:Number, effObj:Object):void
		/**
		 * 进行施法
		 */
		function fire(fireObj:Object):void
		/**
		 * 进行防御
		 */
		function defense(hurtObj:Object):void
		/**
		 * 进行移动
		 */
		function move(dis:Number):void
		/**
		 * 执行动作序列
		 */
		function doAnimationQueue(stateName:String = '', endType:int = 0):void
		
		/**
		 * 更新血量
		 */
		function changeHp(currHp:int, hurtObj:Object, updateParent:Boolean = true, isDead:Boolean = true):void

	}

}