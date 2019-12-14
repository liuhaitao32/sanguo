package sg.fight.client.view 
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import ui.battle.fightCountryTeamBestItemUI;
	/**
	 * 战场最佳显示
	 * @author ...
	 */
	public class ViewFightCountryTeamBestItem extends fightCountryTeamBestItemUI
	{
		private var initFontSize:int;
		
		public function ViewFightCountryTeamBestItem(type:String,userData:Object,milepost:int,value:int,isFlip:Boolean) 
		{
			this.initFontSize = this.txtTitle.fontSize;
			if (isFlip){
				this.scaleX = -1;
				
				this.txtTitle.scaleX *= -1;
				this.txtName.scaleX *= -1;
				this.txtInfo.scaleX *= -1;
				this.txtValue.scaleX *= -1;
				
				this.txtTitle.x -= this.txtTitle.width * this.txtTitle.scaleX;
				this.txtName.x -= this.txtName.width * this.txtName.scaleX;
				this.txtInfo.x -= this.txtInfo.width * this.txtInfo.scaleX;
				this.txtValue.x -= this.txtValue.width * this.txtValue.scaleX;
				this.txtName.align = 'right';
				this.txtInfo.align = 'right';
				this.txtValue.align = 'right';

			}
			this.updateData(type, userData, milepost, value);
		}
		

		public function updateData(type:String,userData:Object,milepost:int,value:int) :void
		{
			if (!type){
				return;
			}
			var infoStr:String;
			var valueStr:String;
			var infoColor:String = '#a4a4a4';
			if (!value) value = 0;
			
			this.txtTitle.fontSize = this.initFontSize;
			this.txtTitle.text = Tools.getMsgById('countryTeamBest_' + type);
			var textWidth:int = this.txtTitle.textField.textWidth;
			//trace(textWidth);
			if (textWidth > this.txtTitle.width){
				this.txtTitle.fontSize = Math.ceil(this.txtTitle.fontSize * this.txtTitle.width/textWidth);
			}
			
			infoStr = Tools.getMsgById('countryTeamBestInfo_' + type);

			if (type == 'official'){
				valueStr = ModelOfficial.getOfficerName(value, milepost, userData.country);
				
				//国战官职buff增加攻击防御
				var officialArr:Array = ConfigFight.officialRate[value.toString()];
				if (officialArr){
					infoStr = Tools.getMsgById('country_official_rate', [Tools.percentFormat(FightUtils.pointToPer(officialArr[2]))]);
					infoColor = '#44FF44';
				}
			}else{
				valueStr = value.toString();
			}
			this.txtInfo.color = infoColor;
			this.txtInfo.text = infoStr;
			this.txtValue.text = valueStr;
			
			var uname:String = userData.uname?userData.uname:'name';
			Tools.textFitFontSize(this.txtName, uname,0,8);
			//this.txtName.text = userData.uname?userData.uname:'name';
			if (type == 'power' && userData.powerHid){
				this.heroItem.setHeroIcon(userData.powerHid);
			}
			else{
				this.heroItem.setHeroIcon(ModelUser.getUserHead(userData.head));
			}
		}
	}

}