package sg.view.menu
{
	import sg.manager.EffectManager;
	import sg.model.ModelEquip;
    import ui.menu.itemUserHeroUI;
    import sg.model.ModelHero;
    import sg.cfg.ConfigServer;

    public class ItemUserHero extends itemUserHeroUI{
        public function ItemUserHero(){
            
        }
        public function setData(data:Object):void{
            var hmd:ModelHero = new ModelHero(true);
            //hmd.initData(data.id,ConfigServer.hero[data.id]);
            hmd.setData(data);
			hmd.getPrepare(true, data);
            //
            this.tName.text = hmd.getName();
			var group:String = hmd.getPrepare().getGroupId();
			if (group){
				this.tGroup.text = ModelEquip.getGroupEquipName2(group);
				EffectManager.addUIAnimation(this.tGroup, 'glow043', 0.6, this.tGroup.width/2, this.tGroup.height/2, true);
			}
			this.tGroup.visible = group;
			
			this.heroLv.setNum(hmd.getLv());
            //this.tLv.text = hmd.getLv() + "";
			this.comPower.setNum(data.power);
            //this.tPower.text = data.power+"";//hmd.getPower()+"";
            this.heroStar.setHeroStar(hmd.getStar());
            this.heroType.setHeroType(hmd.getType());
            //
            this.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
        }
    }   
}