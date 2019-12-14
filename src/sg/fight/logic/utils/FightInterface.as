package sg.fight.logic.utils 
{
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.TroopLogic;
	/**
	 * 战斗与服务器相关接口静态方法
	 * @author zhuda
	 */
	public class FightInterface 
	{


		
		/**
		 * ！！！！！！！静态方法，服务器调用生成战役，按类别生成每场战斗结果，以及最终战斗结果
		 * 返回所有战斗  胜利方，胜利方剩余前后军血量
		 */
		public static function doBattle(data:Object):Object
		{
			///mode  0国战1过关斩将,3比武大会,4王者之巅,5异族入侵,6军团贡品,7讨伐张角,8草上谈兵,100沙盘演义,101群雄逐鹿,102传奇试炼,103蓬莱寻宝,200名将切磋,201占领产业,202叛军野战,203山贼
			var battleLogic:BattleLogic = new BattleLogic(data);
			return battleLogic.getRecord();
		}
		
		
		/**
		 * ！！！！！！！静态方法，服务器用data初始化FightLogic国战中的一场，返回FightLogic的结果对象
		 * 返回值{winner:1,winnerHp:[22,22]}  胜利方，胜利方剩余前后军血量
		 */
		public static function doFight(data:Object):Object
		{
			//var obj:Object = {
				//mode:0,
				//random:new FightRandom(data.rnd),
				//fight_count:data.fight_count,
				//speedUp:data.speedUp,
				//timeScale:data.timeScale,
				//troop0:new TroopLogic(data.troop[0], 0, 0),
				//troop1:new TroopLogic(data.troop[1], 1, 0)
			//};
			data.mode = 0;
			var fightLogic:FightLogic = new FightLogic(data);
			fightLogic.start();
			
			return fightLogic.getRecord();
		}
		
		
		/**
		 * 测试战斗
		 */
		public static function doFightTest(data:Object):FightLogic
		{
			//data = FightUtils.clone(data);
			
			if(data.mode==0)
			{
				data.city = 0;
				data.country = 0;
				data.fireCountry = 1;
				data.country_logs = {};
				data.country_logs[data.country] = {buff:[0, 0], milepost:5};
				data.country_logs[data.fireCountry] = {buff:[0, 0], milepost:5};
			}
			data.battle_special = ConfigFight.getBattleSpecial(data.mode);
			
			var fightLogic:FightLogic = new FightLogic(data);
			fightLogic.start();
			return fightLogic;
		}
	}

}