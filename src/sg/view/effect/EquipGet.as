package sg.view.effect
{
    import ui.com.effect_equip_getUI;
    import sg.model.ModelBuiding;
    import sg.model.ModelEquip;
    import laya.utils.Tween;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;

    public class EquipGet extends effect_equip_getUI{
        private var mTween:Tween;
        public function EquipGet(emd:ModelEquip){
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("icon_war007.png"));
            if(emd){
                //this.mIcon.setIcon(ModelEquip.getIcon(emd.id));
                //this.mIcon.setName(emd.getName());
                this.eName.text = emd.getName();
                this.mIcon.setData(emd.id,-1,-1);
            }
            //
            this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
        }
        public static function getEffect(emd:ModelEquip):EquipGet{
            var eff:EquipGet = new EquipGet(emd);
            return eff;
        }
    }   
}