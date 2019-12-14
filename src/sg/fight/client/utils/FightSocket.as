package sg.fight.client.utils
{
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	import sg.manager.ModelManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	
	/**
	 * 国战网络消息
	 * @author zhuda
	 */
	public class FightSocket
	{
		public static var hasInit:Boolean;
		
		public static function init():void
		{
			if (!FightSocket.hasInit){
				trace('初始化观察国战');
				FightSocket.hasInit = true;
				NetSocket.instance.registerHandler(EventConstant.FINISH_FIGHT_FOLLOW, new Handler(null, FightSocket.finish_fight_follow));
				NetSocket.instance.registerHandler(EventConstant.JOIN_FIGHT_FOLLOW, new Handler(null, FightSocket.join_fight_follow));
				NetSocket.instance.registerHandler(EventConstant.EXIT_FIGHT_FOLLOW, new Handler(null, FightSocket.exit_fight_follow));
				NetSocket.instance.registerHandler(EventConstant.FIGHT_END, new Handler(null, FightSocket.fight_end));
				NetSocket.instance.registerHandler(EventConstant.SPEED_UP_FIGHT_FOLLOW, new Handler(null, FightSocket.fight_speed_up_follow));
				//获得擂台下一场战斗
				//NetSocket.instance.registerHandler(EventConstant.GET_ARENA_NEXT, new Handler(null, FightSocket.onGetNextArena));
				//NetSocket.instance.registerHandler(EventConstant.SPEED_UP_FIGHT_FOLLOW, new Handler(null, FightSocket.fight_speed_up_follow));
			}
		}
		

		
		/**
		 * 国战一场结束(视图才强制开启这场国战，并且要检验结果是否一致)
		 * @param	np
		 */
		private static function finish_fight_follow(np:NetPackage):void
		{
			var data:* = np.receiveData;
			if (data is Boolean)
			{
				return;
			}
			//var result:Object = data.result;
			//trace('国战一场结束', data.city, result.winner);
			//跳过并开始下一场战斗
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.city == data.city){
					clientBattle.serverFinishFight(data);
				}
				else{
					trace(data.city + ' 收到了非观察国战的战斗结束，无视');
				}
			}
		}
		
		/**
		 * 国战增援 增援方0/1，增援部队信息 仅通知关注该城市国战的玩家
		 * @param	np
		 */
		private static function join_fight_follow(np:NetPackage):void
		{
			var data:* = np.receiveData;
			if (data is Boolean)
			{
				return;
			}
			//trace('国战增援', data.city, data.side, data.army);
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.city == data.city){
					if(data.army.uid >= 0){
						clientBattle.user_logs[data.army.uid] = data.user_log;
					}
					clientBattle.country_logs[data.army.country] = data.country_log;
					clientBattle.addTroopBySocket(data.army, data.side, data.front);
				}
				else{
					trace(data.city + ' 收到了非观察国战的增援，无视');
				}
				
			}
		}
		
		/**
		 * 国战退出 退出方0/1，退出部队信息（能手动退出的部队必定唯一） 仅通知关注该城市国战的玩家
		 * @param	np
		 */
		private static function exit_fight_follow(np:NetPackage):void
		{
			var data:* = np.receiveData;
			if (data is Boolean)
			{
				return;
			}
			//trace('国战退出', data.city, data.side, data.army);
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.city == data.city){
					clientBattle.removeTroopBySocket(data.army.uid, data.army.hid, data.hasOwnProperty('side')?data.side: -1);
				}
				else{
					trace(data.city + ' 收到了非观察国战的退出，无视');
				}
				
			}
		}
		
		/**
		 * 国战结束
		 * @param	np
		 */
		private static function fight_end(np:NetPackage):void
		{
			var data:* = np.receiveData;
			if (data is Boolean)
			{
				return;
			}
			//trace('国战结束', data.city, data.country);
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.city == data.city.cid){
					clientBattle.serverEndBattle(data.city.country);
				}
				else{
					trace(data.city.cid + ' 收到了非观察国战的结束，无视');
				}
				
			}
		}
		
		/**
		 * 战鼓消息推送
		 * @param	np
		 */
		private static function fight_speed_up_follow(np:NetPackage):void
		{
			var data:Object = np.receiveData;
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.city == data.city){
					FightEvent.ED.event(EventConstant.SPEED_UP_FIGHT, {type:'speedUp',uid:data.uid,uname:data.uname,country:data.country});
				}
				else{
					trace(data.city + ' 收到了非观察国战的加速，无视');
				}
			}
		}
		/**
		 * 发出战鼓消息
		 */
		public static function sendFightSpeedUp(cityId:String, costIndex:int):void
		{
			if (ConfigApp.testFightType){
				//模拟推送结果
				FightEvent.ED.event(EventConstant.SPEED_UP_FIGHT, {type:'speedUp',uid:FightMain.getCurrUid(),uname:FightMain.getCurrUname(),country:FightMain.getCurrCountry()});
			}
			else{
				//, costIndex:costIndex
				NetSocket.instance.send(EventConstant.SPEED_UP_FIGHT, {cid:cityId}, Handler.create(null, FightSocket.onFightHandler));
			}
		}
		/**
		 * 发出战鼓消息等返回
		 */
		private static function onFightHandler(np:NetPackage):void {
			var data:* = null;
			var id:String = null;
			//var mids:String ='mid';
			switch(np.receiveMethod) {
				case EventConstant.SPEED_UP_FIGHT://发出战鼓消息
					break;
			}
			ModelManager.instance.modelUser.updateData(np.receiveData);
		}
		
		/**
		 * 发出擂台继续观战消息
		 */
		public static function sendGetArenaNext(group_type:int, log_index:int):void
		{
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle){
				if (ConfigApp.testFightType){
					//模拟推送结果
					var data:Object = FightUtils.clone(clientBattle.data);
					data.team[0].troop[0].hid = TestFightData.getRandomHeroId();
					data.canEndTime = ConfigServer.getServerTimer() / 1000 + 3;
					FightMain.instance.reset(data);
				}
				else{
					NetSocket.instance.send(EventConstant.GET_ARENA_NEXT, {'arena_index':clientBattle.arena_index,'log_index':clientBattle.log_index+1}, Handler.create(null, FightSocket.onGetNextArena));
				}
			}
		}
		/**
		 * 继续观战,下一场擂台战斗消息返回
		 */
		private static function onGetNextArena(np:NetPackage):void
		{
			var data:Object = np.receiveData;
			var clientBattle:ClientBattle = FightMain.instance.client;
			if (clientBattle)
			{
				if (clientBattle.isArena){
					var pk_data:Object = data.pk_data;
					if (pk_data){
						pk_data.canEndTime = Tools.getTimeStamp(pk_data.done_time) / 1000;
						FightMain.instance.reset(pk_data);
					}
				}
				else{
					trace(np,' 非擂台观战下，无视');
				}
			}

		}
		

		

	}

}