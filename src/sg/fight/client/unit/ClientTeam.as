package sg.fight.client.unit
{
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.unit.TeamLogic;
	import sg.fight.logic.unit.TroopLogic;
	
	/**
	 * 战斗场景中的一队阵营（攻方或守方），包含多个部队
	 * @author zhuda
	 */
	public class ClientTeam extends TeamLogic
	{
		
		public function getClientBattle():ClientBattle
		{
			return this.battleLogic as ClientBattle;
		}
		
		public function getClientTroop(troopIndex:int):ClientTroop
		{
			return this.troops[troopIndex] as ClientTroop;
		}


		
		public function ClientTeam(data:*, battleLogic:BattleLogic, teamIndex:int)
		{
			super(data, battleLogic, teamIndex);
			
			//this.updateTroopShow();
		}
		
		override public function newTroop(data:*, troopIndex:int):TroopLogic
		{
			this.packTroopData(data);
			var troop:TroopLogic = new ClientTroop(data, this, troopIndex);
			this.askBattle(troop);
			return troop;
		}
		/**
		 * 移除指定部队
		 */
		public function removeTroop(troopIndex:int):TroopLogic
		{
			var arr:Array = this.troops.splice(troopIndex, 1);
			var troop:ClientTroop = arr[0];
			
			var fightMain:FightMain = this.getClientBattle().fightMain;
			fightMain.ui.updateLowerPanel();
			
			troop.back(true);
			this.updateTroopIndex(troopIndex);
			this.allTroopMoveTo(fightMain.scene.centerCameraOffset);
			return troop;
		}
		
		/**
		 * 刷新部队显示
		 */
		public function updateTroopShow():void
		{
			var i:int;
			var len:int = Math.min(ConfigFightView.TROOP_SHOW_MAX, this.troops.length);
			for (i = 0; i < len; i++)
			{
				var troop:ClientTroop = this.getClientTroop(i);
				troop.show();
			}
		}
		
		/**
		 * 所有部队向战场中心补位, 排除exclude
		 */
		public function allTroopMoveTo(centerX:Number, exclude:ClientTroop = null):void
		{
			var i:int;
			var len:int = this.troops.length;
			var x:Number;
			var temp:int = this.getClientBattle().isFighting ? 1 : 0;
			
			for (i = 0; i < len; i++)
			{
				var troop:ClientTroop = this.getClientTroop(i);
				if (i == ConfigFightView.TROOP_SHOW_MAX)
				{
					troop.back(true);
					break;
				}
				if (!troop.isInit)
					continue;
				if (exclude != troop)
				{
					troop.moveTo(centerX + (this.teamIndex == 0 ? 1 : -1) * (ConfigFightView.ROUND_OFFSET[0] - ConfigFightView.TROOP_INTERVAL * (i + temp)));
				}
			}
		}
	/**
	 * 所有部队向前补位，如果未显示的部队或排除部队停止
	 */
		 //public function allTroopMove(dis:Number,exclude:ClientTroop = null):void
		 //{
		 //var i:int;
		 //var len:int = this.troops.length;
		 //
		 //for (i = 0; i < len; i++)
		 //{
		 //var troop:ClientTroop = this.getClientTroop(i);
		 //if (!troop.isShow)
		 //{
		 //break;
		 //}
		 //if(exclude != troop){
		 //troop.move(dis);
		 //}
		 //}
		 //}
	
	}

}