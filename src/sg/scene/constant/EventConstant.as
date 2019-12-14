package sg.scene.constant 
{
	/**
	 * 事件的常量
	 * @author light
	 */
	public class EventConstant {
		
		public static const MARCH_CREATE:String = "w.troop_move";	
		public static const UPDATE_BUILD:String = "build_city_build";	
		public static const CLICK_CLIP:String = "clickClip";	
		public static const HERE_CATCH:String = "heroCatch";	
		public static const HERE_CATCH_DIE:String = "heroCatchDie";	
		public static const CLICK_BUBBLE:String = "clickBubble";	
		
		public static const MARCH_RESET:String = "marchReset";		
		public static const MARCH_COMPLETE:String = "marchComplete";		
		public static const MARCH_RATE_CHANGE:String = "marchRateChange";
		//部队

		public static const TROOP_CREATE:String = "w.troop_create";
		public static const TROOP_REMOVE:String = "w.troop_dissmiss";
		public static const TROOP_MARCH_SPEED_UP:String = "w.troop_move_speedup";
		public static const TROOP_MARCH_RECALL:String = "w.troop_move_dismiss";		
		public static const TROOP_GET_MY_TROOPS:String = "w.get_my_troops";
		public static const TROOP_ADD_NUM:String = "w.troop_add";//补兵
		public static const TROOP_BREAK:String = "w.troop_break";		
		public static const TROOP_RUN_AWAY:String = "w.troop_runaway";		
				
		public static const TROOP_UPDATE:String = "troopUpdate";
		
		//行军收到的包。
		public static const TROOP_MARCH_MOVE:String = "w.troop_move_push";		
		public static const TROOP_MARCH_STATE_CHANGE:String = "w.troop_status_change";
		public static const TROOP_MARCH_REMOVE:String = "w.troop_move_delete";
		
		
		public static const DEAD:String = "dead";
		
		//旗子 之后的什么都用这个了。。 之前写的太傻逼了。
		public static const BUFF_CORPS:String = "buff_corps";
		
		public static const BEFORE_MOVE:String = "before_move";
		public static const SCALE_CHANGE:String = "scaleChange";
		public static const MOVE_CHANGE:String = "moveChange";
		
		public static const CITY_FIRE:String = "w.city_fire";
		public static const CITY_COUNTRY_CHANGE:String = "city_country_change";
		public static const CITY_DETECT:String = "w.join_fire";
		
		public static const JOIN_FIGHT:String = "w.join_fight";
		
		public static const FINISH_FIGHT_FOLLOW:String = "w.finish_fight_follow";
		public static const JOIN_FIGHT_FOLLOW:String = "w.join_fight_follow";
		public static const EXIT_FIGHT_FOLLOW:String = "w.exit_fight_follow";
		public static const FIGHT_END:String = "w.fight_end";
		public static const SPEED_UP_FIGHT_FOLLOW:String = "w.speed_up_fight_follow";
		///获得擂台下一场战斗
		public static const GET_ARENA_NEXT:String = "get_arena_log";
		 
		
		///下一场战斗的客户端事件
		public static const FIGHT_NEXT:String = "fightNext";
		///战斗中发出战鼓消息
		public static const SPEED_UP_FIGHT:String = "w.speed_up_fight";
		///战斗中发出刃车消息
		public static const CALL_CAR_FIGHT:String = "w.call_car_fight";
		
		public static const LOOK_FIGHT_IN:String = "w.follow_fight";
		public static const LOOK_FIGHT_OUT:String = "w.unfollow_fight";
		public static const FIGHT_READY:String = "w.fight_ready";
		public static const FIGHT_FINISH_FIGHT:String = "w.finish_fight";
		public static const COUNTRY_ARMY_DEAD:String = "w.country_army_dead";
		
		///测试功能，改变自己的银币值和英雄数据
		public static const TEST_CHANGE:String = "testChange";
		
		public static const SPEED_LOW:String = "speedLow";
		
		public static const HERO_CATCH_CHANGE:String = "heroCatchChange";
		//黄巾军
		public static const THIEF:String = "w.sync_attack_npc";
		public static const UPDATE_GTASK:String = "udpateGtask";
		//
		public static const EVENT_PK_NPC_STATUS_TROOP_FIGHT_ING:String = "event_pk_npc_status_troop_fight_ing";//异族入侵 的部队状态通知
		public static const EVENT_PK_NPC_STATUS_TROOP_FIGHT_READY:String = "event_pk_npc_status_troop_fight_ready";//异族入侵 的部队状态通知
		
		public static const REPEAT:String = "repeat";
		
		
	}

}