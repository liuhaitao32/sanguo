package sg.fight.client.utils 
{
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	import laya.utils.Timer;
	import laya.utils.Tween;
	import laya.utils.Utils;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.guide.model.ModelGuide;
	import sg.utils.MusicManager;
	/**
	 * 控制所有战斗时间
	 * @author zhuda
	 */
	public class FightTime 
	{
		///战斗时间，该时间受到倍速影响
		public static var timer:Timer = new Timer();
		///正在活跃的所有缓动
		public static var tweenMap:Dictionary = new Dictionary();
		///正在活跃的所有额外时间动画
		//public static var timeMap:Dictionary = new Dictionary();
		
		public static var hasInit:Boolean;
		
		
		public static function init(clientBattle:ClientBattle = null):void
		{
			if(!FightTime.hasInit){
				FightTime.timer.scale = ConfigFight.fightHighSpeed;
				//Laya.scaleTimer.scale = 0;
				FightTime.hasInit = true;
			}
			if (!ConfigServer.world.guideSpeedMode){
				
			}
			if (ModelGuide.forceGuide()){
				if(!ConfigServer.world.guideSpeedMode || ConfigServer.world.guideSpeedMode==1){
					//强制引导中锁定低速
					FightTime.timer.scale = ConfigFight.fightLowSpeed;
				}
				else{
					FightTime.timer.scale = ConfigFight.fightHighSpeed;
				}
			}
			else if (clientBattle){
				FightTime.timer.scale = clientBattle.getCurrentTimeScale();
				//if(clientBattle.isCountry){
					//FightTime.timer.scale = clientBattle.speedUp? ConfigServer.world.countryFightSpeedUpTimeScale:ConfigFight.fightHighSpeed;
				//}
				//else if(FightTime.timer.scale > ConfigFight.fightHighSpeed){
					//FightTime.timer.scale = ConfigFight.fightHighSpeed;
				//}
			}
			//FightTime.clearAll();
			FightTime.updateTimeScale();
		}
		
		
		/**
		 * 清理所有缓动和时间动画（动画也不保留）
		 */
		public static function clearAll(clearTimer:Boolean = false):void
		{
			var keys:Array;
			var i:int;
			var target:*;
			//FightTime.timer.clearAllHandlers();
			//var b:* = FightTime.tweenMap;
			keys = FightTime.tweenMap.keys;
			for (i = keys.length -1; i >= 0; i--) 
			{
				target = keys[i];
				//Tween.clearAll(target);
				Tween.completeAll(target);
			}
			FightTime.tweenMap.clear();
			//这里不默认删除是防止有的对象是延迟自动删除
			if(clearTimer)
				FightTime.timer.clearAll(null, true);
			//FightTime.timer.clearAll(null, true);
			//keys = FightTime.timeMap.keys;
			//for (i = keys.length -1; i >= 0; i--) 
			//{
				//target = keys[i];
				//FightTime.timer.clearAll(target);
			//}
			//FightTime.timeMap.clear();
			//FightTime.tweenMap.clear();
			
			FightEvent.ED.event(FightEvent.FIGHT_TIME_CLEAR);
		}
		/**
		 * 增加缓动
		 */
		public static function tweenTo(target:*, props:Object, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0):void
		{
			var timeScale:Number = FightTime.timer.scale;

			duration /= timeScale;
			delay /= timeScale;

			Tween.to(target, props, duration, ease, complete, delay);
			FightTime.tweenMap.set(target, true);
		}
		
		/**
		 * 延迟执行战斗方法，如果执行时对象已被回收，则不再执行
		 */
		public static function delayTo(delay:int, caller:*, method:Function, args:Array = null, coverBefore:Boolean = true):void 
		{
			FightTime.timer.once(delay, caller, function ():void 
			{
				if (caller && caller.isCleared) return;
				method.apply(caller, args);
			}, args,coverBefore);
			
			//if(caller){
			//	FightTime.timeMap.set(caller, true);
			//}
		}
		
		/**
		 * 延迟执行普通
		 */
		public static function scaleTimerDelayTo(delay:int, caller:*, method:Function, args:Array = null, coverBefore:Boolean = true):void 
		{
			Laya.scaleTimer.once(delay, caller, function ():void 
			{
				if (caller && caller.isCleared) return;
				method.apply(caller, args);
			}, args,coverBefore);
			
			//if(caller){
			//	FightTime.timeMap.set(caller, true);
			//}
		}
		
		/**
		 * 清理某个延迟事件
		 */
		//public static function clearTimerCall(caller:*, method:Function):void
		//{
			//FightTime.timer.clear(caller, method);
		//}
		
		/**
		 * 延迟执行战斗音效
		 */
		public static function playSound(res:String, volume:Number = -1,delay:int = 0):void 
		{
			if(ConfigFight.fightOpenSound)
				FightTime.delayTo(delay, null, MusicManager.playSoundFight, [res, volume]);
		}
		
		

		/**
		 * 修改战斗速率
		 */
		public static function changeTimeScale():void
		{
			var oldTimeScale:Number = FightTime.timer.scale;
			if (oldTimeScale != ConfigFight.fightHighSpeed)
			{
				FightTime.timer.scale = ConfigFight.fightHighSpeed;
			}
			else
			{
				FightTime.timer.scale = ConfigFight.fightLowSpeed;
			}
			FightTime.updateTimeScale();
		}
		
		
		/**
		 * 战斗结束，如果倍速超快，恢复正常
		 */
		public static function resetTimeScale():void
		{
			var oldTimeScale:Number = FightTime.timer.scale;
			if (oldTimeScale > ConfigFight.fightHighSpeed)
			{
				FightTime.setTimeScale(ConfigFight.fightHighSpeed);
			}
		}
		/**
		 * 自由设定战斗速率
		 */
		public static function setTimeScale(value:Number):void
		{
			var oldTimeScale:Number = FightTime.timer.scale;
			if (oldTimeScale != value)
			{
				FightTime.timer.scale = value;
				//FightTime.updateTimeScale();
			}
		}
		/**
		 * 刷新战斗速率
		 */
		private static function updateTimeScale():void
		{
			//this.timer.scale = this.timeScale;
			//Laya.scaleTimer.scale = this.timeScale;
			FightMain.instance.ui.updateTimeScale();
		}
		
	}

}