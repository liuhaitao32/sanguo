package sg.view.hero
{
    import ui.hero.heroRuneItemUI;
    import sg.model.ModelRune;
    import sg.model.ModelItem;
    import laya.ui.Image;
    import laya.ui.Label;
    import sg.model.ModelHero;

    public class ItemHeroRune extends heroRuneItemUI{
        public var mModel:ModelRune;
        public function ItemHeroRune():void{
           
        }
        public function setData(rmd:ModelRune,hmds:ModelHero):void{
            this.mModel = rmd;
            // this.img.setData(ModelItem.getItemIcon(md.id));
            // (this.runeIcon.img).skin = md.getIcon();
            //
            // this.runeIcon.diff.visible = false;//ModelRune.fix_position_diff.indexOf(ModelRune.searchCfgTypeBy(this.mCurrUItype,md.fix_type)))>-1;
            //this.runeIcon.setIcon(rmd.getImgName());
            this.runeIcon.setData(rmd.id);
            this.runeIcon.mCanClick=false;
            //
            var hmd:ModelHero = rmd.getHeroModel();
            var b:Boolean = false;
            if(hmd){
                if(hmd.id == hmds.id){
                    b = true;
                }
            }  
            this.tLv.text = rmd.getLv()+"";
            this.imgCurr.visible = b;      
        }
        public function showSelect(b:Boolean):void{
            // this.imgSelect.visible = b;
            this.imgSelect.visible = b;
        }
        public function setName():void{
            // this.tName.text = this.mModel.getName();
            // (this.runeIcon.tName).text = this.mModel.getName();
            this.runeIcon.setName(this.mModel.getName());
        }
    }   
}