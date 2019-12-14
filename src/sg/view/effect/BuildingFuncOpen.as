package sg.view.effect
{
    import ui.com.effect_building_func_openUI;
    import sg.model.ModelBuiding;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;

    public class BuildingFuncOpen extends effect_building_func_openUI
    {
        public function BuildingFuncOpen(bmd:ModelBuiding,index:int)
        {
            this.on(Event.REMOVED,this,this.onRemove,[bmd,index]);
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("icon_war007.png"));
            //
            var arr:Array = bmd.unlockFunc(bmd.lv);
            var data:Array = arr[index];
            //
            this.tName.text = Tools.getMsgById(data[0]);
            this.tInfo.text = Tools.getMsgById(data[1]);
            //
            this.bg.width = this.tName.displayWidth + 140;
            //
            this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
        }
        private function onRemove(bmd:ModelBuiding,index:int):void
        {
            this.off(Event.REMOVED,this,this.onRemove);
            ModelManager.instance.modelGame.checkBaseBuildUnlockFunc(bmd,(index+1));
        }
        public static function getEffect(bmd:ModelBuiding,index:int):BuildingFuncOpen{
            var eff:BuildingFuncOpen = new BuildingFuncOpen(bmd,index);
            return eff;
        }        
    }
}