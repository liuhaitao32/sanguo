package sg.fight.client.view 
{
	import sg.cfg.ConfigServer;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import ui.battle.fightCountryRankItemUI;
	import ui.battle.fightCountryTeamBestItemUI;
	/**
	 * 国战排行榜
	 * @author ...
	 */
	public class ViewFightCountryRankItem extends fightCountryRankItemUI
	{
		
		public function ViewFightCountryRankItem() 
		{
			//this.updateData(index, country, name, kill);
		}
		

		public function updateData(index:int,country:int,name:String,kill:int) :void
		{
			if (country < 0)
			{
				this.txtIndex.text = '--';
				this.flag.visible = false;
				this.txtName.text = '--';
				this.txtKill.text = '--';
			}
			else{
				this.txtIndex.text = kill > 0? (index +1).toString() : '--';
				this.flag.visible = true;
				this.flag.setCountryFlag(country);
				//this.txtName.text = name;
				Tools.textFitFontSize(this.txtName, name);
				this.txtKill.text = kill.toString();
			}

		}
	}

}