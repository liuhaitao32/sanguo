package sg.fight.client.view
{
	import laya.ui.Box;
	import sg.fight.logic.BattleLogic;
	
	/**
	 * 战场所有最佳显示
	 * @author ...
	 */
	public class ViewFightCountryTeamBest extends Box
	{
		private const NUM:int = 3;
		
		private var _battle:BattleLogic;
		private var _itemArr:Array;
		
		public function ViewFightCountryTeamBest(battle:BattleLogic, teamBest:Array)
		{
			this.left = 0;
			this.right = 0;
			this._itemArr = [];
			this._battle = battle;
			
			for (var i:int = 0; i < 2; i++)
			{
				var items:Array = [];
				this._itemArr.push(items);
				var teamObj:Object = teamBest[i];
				var isFlip:Boolean = i != 0;
				for (var j:int = 0; j < NUM; j++)
				{
					var item:ViewFightCountryTeamBestItem = new ViewFightCountryTeamBestItem('', null, 0, 0, isFlip);
					if (!isFlip)
					{
						item.x = 0;
					}
					else
					{
						item.x = Laya.stage.width - 0;// - item.width;
					}
					item.y = 5 + j * 70;
					this.addChild(item);
					items.push(item);
				}
				
				this.updateTeam(i);
			}
		}
		
		public function updateTeam(teamIndex:int):void
		{
			var items:Array = this._itemArr[teamIndex];
			var bestObj:Object = this._battle.teamBest[teamIndex];
			var bestArr:Array = [];
			if (bestObj.kill)
			{
				bestArr.push(['kill', bestObj.kill]);
			}
			if (bestObj.power)
			{
				bestArr.push(['power', bestObj.power]);
			}
			if (bestObj.official)
			{
				bestArr.push(['official', bestObj.official]);
			}
			
			var bestNum:int = bestArr.length;
			for (var i:int = 0; i < NUM; i++)
			{
				var item:ViewFightCountryTeamBestItem = items[i];
				if (i >= bestNum)
				{
					item.visible = false;
				}
				else
				{
					item.visible = true;
					var best:Array = bestArr[i];
					var type:String = best[0];
					var uid:String = best[1][0].toString();
					var value:* = best[1][1];
					var userData:Object = this._battle.user_logs[uid];
					var country:int = userData.country;
					var milepost:int = this._battle.country_logs[country] ? this._battle.country_logs[country].milepost : 0;
					
					item.updateData(type, userData, milepost, value);
				}
			}
		}
	}

}