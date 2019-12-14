package sg.view.fight
{
    import ui.fight.itemWorshipUI;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigColor;
    import laya.display.Animation;
    import sg.model.ModelClimb;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigServer;

    public class ItemWorship extends itemWorshipUI{
        private var tempIndex:int = -1;
        public function ItemWorship(){
            this.text0.text=Tools.getMsgById("_more_rank07");
            this.text1.text = Tools.getMsgById("_guild_text01");
			this.btn.label = Tools.getMsgById("ItemWorship_1");
        }
        public function setUI(data:Object,index:int):void{
            EffectManager.changeSprColor(this.boxRank,index,false,ConfigColor.COLOR_CHAMPION_RANK);
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            // this.tIndex.text = (index+1)+"";
            this.rank0.visible = this.bg0.visible = (index ==0);
            this.rank1.visible = this.bg1.visible = (index ==1);
            this.rank2.visible = this.bg2.visible = (index ==2);
            this.tName.text = data.uname;
			this.comPower.setNum(data.power);
            //this.tPower.text = ""+data.power;
            this.heroIcon.setHeroIcon(Tools.isNullObj(data.head)?(data.troop?data.troop[0].hid:ConfigServer.system_simple.init_user.head):data.head,true,-1,false);
            this.countryIcon.setCountryFlag(data.country);			
            //
            this.btn.gray = !ModelClimb.isChampionWorship();
            this.tTeam.text = data.team?data.team:"无";
            //工会没有数据
            //
            if(this.tempIndex!=index){
                this.tempIndex = index;
                this.boxGlow.destroyChildren();
                //var glowName:Array = ["glow033", "glow035", "glow036"]
                //var glow:Animation = EffectManager.loadAnimation(glowName[index]);
				var glowName:String = 'glow033';
				var glow:Animation = EffectManager.loadAnimation(glowName);
				glow.scaleX = 1.3;
				EffectManager.changeSprColor(glow,index,false,ConfigColor.COLOR_WORSHIP);
				
                glow.x = this.heroIcon.width * 0.5 + 60;
                glow.y = this.height*0.5-10;
                this.boxGlow.addChild(glow);
            }
        }
    }   
}