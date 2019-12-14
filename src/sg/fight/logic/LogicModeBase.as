package sg.fight.logic 
{
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.LogicBase;
	//import sg.fight.logic.utils.FightRandom;
	/**
	 * ...
	 * @author zhuda
	 */
	public class LogicModeBase extends LogicBase
	{
		///0国战1过关斩将,3比武大会,4王者之巅,5异族入侵,6军团贡品,7讨伐张角,8草上谈兵,100沙盘演义,101群雄逐鹿,102传奇试炼,103蓬莱寻宝,104福将踏关,200名将切磋,201占领产业,202叛军野战,203山贼
		public var mode:int;
		///随机种子
		//public var random:FightRandom;
		
		/**
		 * 模式0~99 玩家轮换死战，如果是NPC则不轮换
		 */
		public function get isWheel():Boolean
		{
			return this.mode < 100;
		}
		
		/**
		 * 模式100~199 比赛 N局(N/2+1)胜，中途不允许加入
		 */
		public function get isMatch():Boolean
		{
			return this.mode >= 100 && this.mode < 200;
		}
		
		/**
		 * 模式200+ 单挑
		 */
		public function get isSolo():Boolean
		{
			return this.mode >= 200;
		}
		
		/**
		 * 模式传奇之路
		 */
		public function get isLegend():Boolean
		{
			return this.mode == 102;
		}
		
		/**
		 * 战斗结束不显示胜败的战斗类型
		 */
		public function get isNoWin():Boolean
		{
			return this.mode == 0 || this.mode == 10 || this.mode == 3 || this.mode == 102;
		}
		
		/**
		 * PVE世界部队，结算时要有损失数据
		 */
		public function get isWorldPVE():Boolean
		{
			return this.mode == 5 || this.mode == 200 || this.mode == 201 || this.mode == 202 || this.mode == 203;
		}
		
		/**
		 * 是沙盘演义，或蓬莱寻宝有相应的三星评定规则
		 */
		public function get isSandTable():Boolean
		{
			return this.mode == 100 || this.mode == 103;
		}
		/**
		 * 是蓬莱寻宝，有卜卦
		 */
		public function get isMagic():Boolean
		{
			return this.mode == 103;
		}
		
		/**
		 * 是过关斩将
		 */
		public function get isClimbPVE():Boolean
		{
			return this.mode == 1;
		}
		
		/**
		 * PVE持续时间，记录每波时间，能够中途恢复，到达最终时间才能结算
		 */
		public function get isDurationPVE():Boolean
		{
			return this.mode == 1 || this.mode == 5;
		}
		/**
		 * PVE记录波数，并且有奖励的
		 */
		public function get isWavePVE():Boolean
		{
			return this.mode == 1 || this.mode == 5;
		}
		/**
		 * 记录击杀和战损，一般有任务和排行
		 */
		public function get isKillHp():Boolean
		{
			return this.mode == 1 || this.mode == 10 || this.mode == 102 || this.mode == 104 || this.isWorldPVE;
		}
		/**
		 * 短小战斗，只打4回合就强制结束，算0方败走
		 */
		public function get isShortFight():Boolean
		{
			return this.mode == 6;
		}
		/**
		 * 强制测试模式
		 */
		public function get isTestTrace():Boolean
		{
			return this.mode == ConfigFight.testPlaybackMode;
		}
		/**
		 * 国战模式
		 */
		public function get isCountry():Boolean
		{
			return this.mode == 0;
		}
		/**
		 * 比武大会或跨服战等双方全认为是玩家的，目前仅用于完成后显示比赛结束
		 */
		public function get isCross():Boolean
		{
			return this.mode == 3;
		}
		/**
		 * 擂台战
		 */
		public function get isArena():Boolean
		{
			return this.mode == 10;
		}
		/**
		 * 胜利后增加疲劳值的
		 */
		public function get isTired():Boolean
		{
			return this.mode == 3 || this.mode == 10;
		}
		/**
		 * 没有NPC参与的战斗模式，此模式下所有uid为负的强制为正
		 */
		public function get isNoNPC():Boolean
		{
			return this.mode == 3 || this.mode == 4 || this.mode == 103 || this.mode == 104;
		}
		
		public function LogicModeBase(data:*)
		{
			super(data);
		}
		
	}

}