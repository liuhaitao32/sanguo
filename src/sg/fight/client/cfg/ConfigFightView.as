package sg.fight.client.cfg
{
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	
	/**
	 * 战斗场景中的显示配置
	 * @author zhuda
	 */
	public class ConfigFightView
	{
		public static var showTest:Boolean = true;
		public static var touchTest:Boolean = true;
	
		
		///特殊命中的阵型分布Y范围
		public static const FORMATION_Y:int = 220;


		


		///基础跑动近战攻击射程
		//public static const ATTACK_RANGE:int = 30;
		
		///基本兵队行动延迟范围
		public static const ARMY_RANDOM_TIME:int = 200;
		///基础移动时间
		public static const MOVE_BASE_TIME:int = 400;
		///基础攻击到命中时间（攻击动作）
		public static const ATTACK_BASE_TIME:int = 250;

		
		///标准受伤后等待
		public static const HURT_END_TIME:int = 1000;
		///标准连击等待
		public static const HURT_COMBO_TIME:int = 200;

		
		///基础移动速度
		public static const MOVE_BASE_SPEED:Number = 0.3;
		///跑动速度倍率
		public static const RUN_SPEED_RATE:Number = 1.5;
		///子弹速度倍率
		public static const BULLET_SPEED_RATE:Number = 2.5;
		///后退速度倍率
		public static const BACK_SPEED_RATE:Number = 0.9;
		
		///每毫秒的时间片
		public static const FRAME_PER_MS:Number = 0.06;


		///战斗中动作
		public static const ANIMATION_STAND:String = "stand";
		public static const ANIMATION_RUN:String = "run";
		public static const ANIMATION_ATTACK:String = "attack";
		public static const ANIMATION_CHEER:String = "cheer";
		public static const ANIMATION_INJURED1:String = "injured1";
		public static const ANIMATION_INJURED2:String = "injured2";
		public static const ANIMATION_DEAD1:String = "dead1";
		public static const ANIMATION_DEAD2:String = "dead2";

		///合击技角度
		public static const FATE_SKILL_ANGLE:Number = 15;

		///上下UI基础高度（连同中间场景区域，共计1138高）
		public static const TOP_UI_HEIGHT:int = 60;
		public static const BOTTOM_UI_HEIGHT:int = 0;
		
		///默认需要加载的资源，顺序按类别区分
		//public static const DEFAULT_ASSETS:Array = ["army00", "hero_01", "bullet102", "hit102", "bang238", "fire225", "stick216", "special222", "buff216"];
		
		///提取回放中特效引用的特效对象路径
		public static const PICK_EFF_PATHS:Array = ['fire.res', 'move.stick', 'move.atk', 'bullet.res', 'bullet.stick', 'bang.res', 'bang.res2', 'hurt.res', 'hurt.def', 'hurt.special', 'hurt.special2'];
		///提取回放中buff引用的特效对象路径
		public static const PICK_BUFF_PATHS:Array = ['res', 'special'];
		
		

		
		
		
		
		
		
		
		
		//以下应该按照PC和非PC版区分，不配置到后台
		
		///战斗中激励距离边缘
		public static var SPIRIT_X:Number;
		///战斗中猛击距离边缘
		public static var BASH_X:Number;
		///战斗中技能位置距离边缘
		public static var BANNER_SKILL_X:Number;
		///战斗中兽灵技能位置距离边缘
		public static var BANNER_BEAST_SKILL_X:Number;
		///战斗中奖励掉落位置距离边缘
		public static var DROP_X:Number;
		///战斗有效视窗半宽度
		public static var VISIBLE_HALF_WIDTH:Number;
		
		///同队最多显示军队数
		public static var TROOP_SHOW_MAX:int;
		///前军后军站位偏移
		public static var ARMY_OFFSET:Array;
		///同队军队间站位间隔
		public static var TROOP_INTERVAL:int;
		///不同回合，军队站位偏移
		public static var ROUND_OFFSET:Array;
		
		public static var SCENE_GROUND_NUM:int;
		public static var SCENE_SKY_NUM:int;
		public static var SCENE_CURTAIN_NUM:int;
		
		///开炮射程系数，PC版更远
		public static var BULLET_RANGE_RATE:Number;
		
		
		
		
		
		
		//以下应该按照不同换皮区分，配置到后台
		
		///普通单位基础缩放
		public static var ARMY_BASE_SCALE:Number;
		///英雄单位基础缩放
		public static var HERO_BASE_SCALE:Number;
		///副将单位基础缩放
		//public static const ANIMATION_BASE_SCALE:Number = 1;
		
		///单位特殊型号列表，用于阵型，没有指定的使用0, 大兵1，骑兵2，车兵3
		public static var ARMY_SIZE:*;
		///单位在UI中列阵的图标，没有指定的使用0, 大兵1，骑兵2，车兵3
		public static var ARMY_ICON_FORMATION:Array;
		
		
		///子弹受额外重力的距离
		public static var BULLET_DISTANCE_NEAR:Number;
		///子弹发出高度
		public static var BULLET_FIRE_Z:Number;
		///命中高度
		public static var HIT_Z:Number;
		///BUFF_Y
		public static var BUFF_Y:Number;
		
		///战斗信息UI放置到的Y
		public static var TROOP_INFO_Y:Number = -200;
		///战斗信息UI放置到的Z
		public static var TROOP_INFO_Z:Number = 60;
		
		///战斗透视系数
		public static var PERSPECTIVE:Number;
		///战斗Y转换系数
		public static var TRANS_SCREEN_Y:Number = 1;
		
		///战斗场景地面居中宽度
		public static var SCENE_GROUND_INTERVAL:Number;
		public static var SCENE_GROUND_Y:int;
		public static var SCENE_GROUND_CACHE:Number;
		public static var SCENE_GROUND_HALF:Number;
		///对应梯形图形每x距离转透视距离的系数
		public static var SCENE_GROUND_ATAN_RATE:Number;
		public static var SCENE_GROUND_RATE:Number;
		//public static var SCENE_GROUND_IMG_WIDTH:int;
		//public static var SCENE_CENTER_IMG_HEIGHT:int;
		
		///战斗场景天空
		public static var SCENE_SKY_INTERVAL:Number;
		public static var SCENE_SKY_Y:int;
		public static var SCENE_SKY_CACHE:Number;
		public static var SCENE_SKY_HALF:Number;
		public static var SCENE_SKY_RATE:Number;
		
		///战斗场景中远景遮挡物
		public static var SCENE_CURTAIN_INTERVAL:Number;
		public static var SCENE_CURTAIN_Y:int;
		public static var SCENE_CURTAIN_CACHE:Number;
		public static var SCENE_CURTAIN_HALF:Number;
		public static var SCENE_CURTAIN_RATE:Number;
		
		///战斗场景中远景中心
		public static var SCENE_CENTER_X:int;
		public static var SCENE_CENTER_Y:int;
		public static var SCENE_CENTER_RATE:Number;
		
		
		///战斗场景地表
		public static var SCENE_SURFACE_NUM:int;
		public static var SCENE_SURFACE_INTERVAL:Number;
		public static var SCENE_SURFACE_X_RANGE:Array;
		public static var SCENE_SURFACE_Y_RANGE:Array;
		public static var SCENE_SURFACE_IDS:Array;
		public static var SCENE_SURFACE_SCALE:Number;
		public static var SCENE_SURFACE_ALPHA:Array;
		public static var SCENE_SURFACE_HALF:Number;
		///战斗场景远景杂物
		public static var SCENE_FAR_NUM:int;
		public static var SCENE_FAR_INTERVAL:Number;
		public static var SCENE_FAR_X_RANGE:Array;
		public static var SCENE_FAR_Y_RANGE:Array;
		public static var SCENE_FAR_IDS:Array;
		public static var SCENE_FAR_SCALE:Number;
		public static var SCENE_FAR_HALF:Number;
		///战斗场景近景杂物
		public static var SCENE_NEAR_NUM:int;
		public static var SCENE_NEAR_INTERVAL:Number;
		public static var SCENE_NEAR_X_RANGE:Array;
		public static var SCENE_NEAR_Y_RANGE:Array;
		public static var SCENE_NEAR_IDS:Array;
		public static var SCENE_NEAR_SCALE:Number;
		public static var SCENE_NEAR_HALF:Number;
		
		
		public static function init():void {
			var data:* = ConfigServer.effect.cfg;
			for(var key:String in data)
			{
				if(ConfigFightView.hasOwnProperty(key)){
					ConfigFightView[key] = data[key];
				}
			}
			SCENE_GROUND_NUM = 4+(SCENE_GROUND_ATAN_RATE>0.0012?2:0);//+2
			SCENE_SKY_NUM = 4;//+2
			SCENE_CURTAIN_NUM = 4;//+2
			
			
			if (ConfigApp.isPC){
				SPIRIT_X = 600;
				BASH_X = 750;
				BANNER_SKILL_X = 900;
				BANNER_BEAST_SKILL_X = 900;
				DROP_X = 600;
				VISIBLE_HALF_WIDTH = 1000;
				TROOP_SHOW_MAX = 5;
				ARMY_OFFSET = [0, -120];
				TROOP_INTERVAL = 330;
				ROUND_OFFSET = [ -360, -360, -240, -120];
				

				BULLET_RANGE_RATE = 1.5;
				
				SCENE_GROUND_NUM *= 2;
				SCENE_SKY_NUM *= 2;
				SCENE_CURTAIN_NUM *= 2;
			}
			else{
				SPIRIT_X = 100;
				BASH_X = 123;
				BANNER_SKILL_X = 150;
				BANNER_BEAST_SKILL_X = 150;
				DROP_X = 190;
				VISIBLE_HALF_WIDTH = 400;
				TROOP_SHOW_MAX = 5;
				ARMY_OFFSET = [0, -110];
				TROOP_INTERVAL = 320;
				ROUND_OFFSET = [ -210, -210, -160, -110];
				
				BULLET_RANGE_RATE = 1;
			}
			
			
			ConfigFightView.SCENE_GROUND_CACHE = SCENE_GROUND_INTERVAL * SCENE_GROUND_NUM;
			ConfigFightView.SCENE_GROUND_HALF = SCENE_GROUND_CACHE * 0.5;
			ConfigFightView.SCENE_SKY_CACHE = SCENE_SKY_INTERVAL * SCENE_SKY_NUM;
			ConfigFightView.SCENE_SKY_HALF = SCENE_SKY_CACHE * 0.5;
			ConfigFightView.SCENE_CURTAIN_CACHE = SCENE_CURTAIN_INTERVAL * SCENE_CURTAIN_NUM;
			ConfigFightView.SCENE_CURTAIN_HALF = SCENE_CURTAIN_CACHE * 0.5;
			
			ConfigFightView.SCENE_SURFACE_HALF = SCENE_SURFACE_INTERVAL * (SCENE_SURFACE_NUM - 1) * 0.5;
			ConfigFightView.SCENE_FAR_HALF = SCENE_FAR_INTERVAL * (SCENE_FAR_NUM - 1) * 0.5;
			ConfigFightView.SCENE_NEAR_HALF = SCENE_NEAR_INTERVAL * (SCENE_NEAR_NUM - 1) * 0.5;
			

		}
	}
}