package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.test.TestCopyrightData;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import ui.battle.fightCountryRankUI;
	import ui.battle.fightTestChapterUI;
	/**
	 * 国战排行榜
	 * @author zhuda
	 */
	public class ViewFightCountryRank extends fightCountryRankUI
	{
		private var dataArr:Array;
		private var myTroopItem:ViewFightCountryRankItem;
		private var uid:int;
		
		public function ViewFightCountryRank(uid:int) 
		{
			this.uid = uid;
			
			this.list.mouseEnabled = true;
			this.list.scrollBar.hide = true;
			
			this.txtTitle.text = Tools.getMsgById('fightRank');
			this.txtIndex.text = Tools.getMsgById('_public214');
			this.txtKill.text = Tools.getMsgById('_country42');
			//
			this.list.renderHandler = new Handler(this, this.onRender);
			this.btnClose.on(Event.CLICK, this, this.onClose);
			this.tab.on(Event.CHANGE, this, this.onChange);
			
			this.myTroopItem = new ViewFightCountryRankItem();
			this.myTroopItem.y = 0;
			this.myTroopItem.centerX = 0;
			this.imgMyTroop.addChild(this.myTroopItem);

			this.onChange();
		}
		public function onClose():void
		{
			FightMain.instance.ui.closePopView();
		}
		
		override public function onChange(type:* = null):void
		{
			//对当前所有玩家/军团纪录做排行榜，
			this.dataArr = [];
			var user_logs:Object = FightMain.instance.client.user_logs;
			var myData:Object;
			var key:String;
			if (this.tab.selectedIndex == 0)
			{
				//个人榜
				for (key in user_logs) 
				{
					this.dataArr.push(user_logs[key]);
				}	
				myData = user_logs[this.uid];
				this.txtName.text = Tools.getMsgById('fightRankUser');
			}else{
				//军团榜
				var guildData:Object = {};
				for (key in user_logs) 
				{
					var userData:Object = user_logs[key];
					if (userData.guild_id != null){
						if (!guildData.hasOwnProperty(userData.guild_id)){
							guildData[userData.guild_id] = {country:userData.country, uname:userData.guild_name, kill:userData.kill};
							if (key == this.uid.toString() ){
								myData = guildData[userData.guild_id];
							}
						}else{
							guildData[userData.guild_id].kill += userData.kill;
						}
					}
				}	
				for (key in guildData) 
				{
					this.dataArr.push(guildData[key]);
				}
				this.txtName.text = Tools.getMsgById('fightRankGuild');
			}
			this.dataArr.sort(MathUtil.sortByKey('kill', true));
			
			if(myData != null){
				this.myTroopItem.updateData(this.dataArr.indexOf(myData), myData.country, myData.uname, myData.kill);
			}else{
				this.myTroopItem.updateData(-1, -1, '', 0);
			}
			
			if (this.dataArr.length > 100){
				this.dataArr.length = 100;
			}
			
			this.list.array = this.dataArr;
			this.list.scrollTo(0);
		}

		private function onRender(cell:Box, index:int):void
		{
			var data:Object = this.dataArr[index];
			var item:ViewFightCountryRankItem = cell.getChildByName('item') as ViewFightCountryRankItem;
			if (item == null){
				item = new ViewFightCountryRankItem();
				item.name = 'item';
				cell.addChild(item);
			}
			item.updateData(index, data.country, data.uname, data.kill);
		}
		
	}

}