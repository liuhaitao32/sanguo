package sg.view.map
{
    import ui.map.country_officer_tips_kingUI;
    import sg.utils.Tools;
    import sg.model.ModelOfficial;
    import sg.model.ModelUser;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class ViewCountryKingTips extends country_officer_tips_kingUI
    {
        public function ViewCountryKingTips()
        {
            
        }
        override public function initData():void{
            this.tText.text = Tools.getMsgById("_public114");
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_167.png"));
            var country:Number = this.currArg[1];
            var oname:String = ModelOfficial.getOfficerName(0);
            this.tTitle.text = oname;
            this.tName.style.color = "#b6d1ff";
            this.tName.style.align = "center";
            this.tName.style.fontSize = 20;
            //
            this.tName.innerHTML = Tools.getMsgById("530070",[this.currArg[0],ModelUser.country_name2[country],oname]);
            //
        }
    }
}