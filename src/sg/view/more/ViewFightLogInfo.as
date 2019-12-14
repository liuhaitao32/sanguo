package sg.view.more
{
    import ui.more.fight_log_infoUI;
    import sg.model.ModelOfficial;
    import sg.manager.AssetsManager;
    import sg.model.ModelItem;
    import sg.utils.Tools;

    public class ViewFightLogInfo extends fight_log_infoUI
    {
        
        public function ViewFightLogInfo()
        {
			this.guanbi.text = Tools.getMsgById("_public114");
        }
        override public function initData():void{
            // [时间,cid,守方,攻方,谁赢了1,奖励,我是否输赢,兵力,杀部队,杀敌,阵亡,团队奖励];
            var data:Array = this.currArg;
            var carr:Array = ["icon_country1.png","icon_country2.png","icon_country3.png"];
            var h:Number = 455;
            this.boxTeam.visible = false;
            //
            //this.tTitle.text = Tools.getMsgById("_npc_info10");//详细战报
            this.comTitle.setViewTitle(Tools.getMsgById("_npc_info10"));
            this.iDel.text = Tools.getMsgById("_npc_info9");
            this.iKill.text = Tools.getMsgById("_npc_info8");
            this.iTeam.text = Tools.getMsgById("_npc_info7");
            this.iArmy.text = Tools.getMsgById("_npc_info6");
            //
            this.tNameAtt.text = Tools.getMsgById("_npc_info2");//"攻方";
            this.tNameDiff.text = Tools.getMsgById("_npc_info3");//"守方";

            this.iconAtt.skin = AssetsManager.getAssetsUI((data[4]==1)?"icon_win06.png":"icon_win07.png");
            this.iconDiff.skin = AssetsManager.getAssetsUI((data[4]==0)?"icon_win06.png":"icon_win07.png");
            //
            this.cAtt.skin = AssetsManager.getAssetsUI((data[3]>=0 && data[3]<=2)?carr[data[3]]:"icon_country4.png");
            this.cDiff.skin = AssetsManager.getAssetsUI((data[2]>=0 && data[2]<=2)?carr[data[2]]:"icon_country4.png");
            //
            this.tCity.text = ModelOfficial.getCityName(data[1]);
            //
            // 1 == 攻击方胜利
            this.iAward.text = Tools.getMsgById("_npc_info4");//"本场战斗奖励";
            this.award.setData(AssetsManager.getAssetsICON(ModelItem.getItemIcon("item041")),data[5]);
            //
            this.tArmy.text = data[7];
            this.tTeam.text = data[8];
            this.tKill.text = data[9];
            this.tDel.text = data[10];
            //
            if(data[11]){
                h = 540;
                this.boxTeam.visible = true;
                this.iTeamAward.text = Tools.getMsgById("_npc_info5");//"军团资源获得";
                this.coin.setData(AssetsManager.getAssetsUI(ModelItem.getItemIcon("coin")),data[11][0]);
                this.gold.setData(AssetsManager.getAssetsUI(ModelItem.getItemIcon("gold")),data[11][1]);
                this.food.setData(AssetsManager.getAssetsUI(ModelItem.getItemIcon("food")),data[11][2]);
            }
            this.boxPapa.height = h;
            this.boxPapa.mouseThrough = true;
            this.boxPapa.mouseEnabled = false;
            //
            this.t1.text = Tools.getMsgById("_lht60");
        }
    }
}