package sg.fight.logic.unit
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	
	/**
	 * 战斗中英雄
	 * @author zhuda
	 */
	public class HeroLogic extends AttackerLogic
	{
		///英雄品质 0良才，1名将，2国士，3巾帼
		public var rarity:int;
		///英雄性别 0女 1男
		public var sex:int;
		///英雄文武 0武将，1文官，2全才
		public var type:int;
		
		///英雄等级
		public var lv:int;
		///英雄星级
		public var hero_star:int;
		
		///力量
		public var str:int;
		///智力
		public var agi:int;
		///魅力
		public var cha:int;
		///统帅
		public var lead:int;

		///战力
		public var power:int;

		//以下属性不直接在data中

		//public var fates:Array;
		public var id:String;
		
		///四维比拼的替代备选属性，如果为'loss'则主动比拼必定失败
		public var comp:String;
		///是否不死
		public var undead:int;
		///是否禁用自己战败复仇遗计
		public var banSrcLossAct:int;
		///是否禁用对手战败复仇遗计
		public var banTgtLossAct:int;

		public function get isAwaken():Boolean
		{
			if (this.troopLogic.data.awaken){
				if (ConfigServer.inborn[this.id + 'a']){
					return true;
				}
			}
			return false;
		}
		
		override public function get teamIndex():int { 
			return this.troopLogic.teamIndex; 
		}
		
		/**
		 * 无视属性学习技能
		 */
		public function get isStudyUnlimit():Boolean { 
			var obj:Object = ConfigFight.adjutantSpecial[this.id]
			if (obj && obj.studyUnlimit){
				return true;
			}
			return false; 
		}
		
		public function HeroLogic(data:*, troopLogic:TroopLogic)
		{
			this.id = troopLogic.hid;
			super(data, troopLogic, 2);
		}
		
		/**
		 * 战斗开始，重置
		 */
		override public function resetStart(fightLogic:FightLogic):void
		{
			super.resetStart(fightLogic);
			
			this.comp = null;
			this.undead = 0;
			this.banSrcLossAct = 0;
			this.banTgtLossAct = 0;
		}
		
		override public function setData(data:*):void
		{
			super.setData(data);
		}
		
		override public function getData():*
		{
			var reData:Object = {};
			
			reData.id = this.id;
			reData.rarity = this.rarity;
			reData.sex = this.sex;
			reData.type = this.type;
			reData.lv = this.lv;
			reData.hero_star = this.hero_star;
			
			reData.str = this.str;
			reData.agi = this.agi;
			reData.cha = this.cha;
			reData.lead = this.lead;
			
			return reData;
		}
		
		/**
		 * 得到技能初始化属性
		 */
		public function getSkillData():*
		{
			if (this.data.skill != null)
				return this.data.skill;
			var reData:*;
			var heroCfg:* = ConfigServer.hero[this.id];
			if (heroCfg != null)
			{
				reData = heroCfg.skill;
			}
			return reData;
		}
		
		/**
		 * 得到四维总属性
		 */
		public function get sum():int
		{
			return this.str + this.agi + this.cha + this.lead;
		}
		
		/**
		 * 得到替代属性是否高于原四维属性
		 */
		public function isHigher(key:String, comp:String):Boolean
		{
			return this[comp] > this[key];
		}
		/**
		 * 得到四维属性和替代属性的较高值
		 */
		public function getHighAttr(key:String, comp:String):String
		{
			return this[comp] > this[key]?this[comp]:this[key];
		}
	}

}