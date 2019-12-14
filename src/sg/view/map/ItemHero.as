package sg.view.map
{
    import ui.map.itemHeroUI;
    import sg.model.ModelHero;
    import sg.manager.EffectManager;
    import sg.utils.Tools;

    public class ItemHero extends itemHeroUI{
        public function ItemHero():void{
            
        }
        public function setData(hmd:ModelHero):void{
            //
            this.tName.text = hmd.getName();
            this.tPower.text = Tools.getMsgById("_public84",[hmd.getPower()]);//"战力:"+hmd.getPower();//战力
            //
            this.item.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
        }
        public function setDataOnlyIcon(hmd:ModelHero):void{
            this.tName.visible = false;
            this.tPower.visible = false;
            this.setData(hmd);
        }
    }

}