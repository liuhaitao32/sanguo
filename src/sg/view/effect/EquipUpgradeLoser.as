package sg.view.effect
{
    import ui.com.effect_equip_loserUI;
    import sg.model.ModelEquip;
    import sg.utils.Tools;
    import ui.bag.bagItemUI;
    import laya.utils.Handler;
    import sg.model.ModelItem;
    import laya.events.Event;
    import sg.cfg.ConfigServer;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.manager.ViewManager;
    import laya.maths.Point;

    public class EquipUpgradeLoser extends effect_equip_loserUI
    {
        private var mGift:Object;
        public function EquipUpgradeLoser(emd:ModelEquip,gift:Object)
        {
            this.mGift = {};
            this.text0.text=Tools.getMsgById("_equip36");
            this.once(Event.REMOVED,this,this.onRemove);
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("icon_war007.png"));
            if(emd){
                //this.mIcon.setIcon(ModelEquip.getIcon(emd.id));
                // this.mIcon.setData(ModelEquip.getIcon(emd.id),-1,-1);
                this.mIcon.setData(emd.id,-1,-1);
                //
                var obj:Object = emd.getUpgradeCfgByLv(emd.getLv()+1);
                var payArr:Array = Tools.getPayItemArr(obj.cost);
                //
                var len:int = payArr.length;
                this.list.itemRender = bagItemUI;
                this.list.spaceX = 0;
                this.list.scrollBar.hide = true;
                this.list.renderHandler = new Handler(this,this.list_render);
                this.list.dataSource = payArr;
            }            
        }
        private function list_render(item:bagItemUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.scale(0.7,0.7);
            //item.setData(ModelItem.getItemIcon(data.id),0,"",Math.floor(data.data*ConfigServer.system_simple.equip_upgrade_fail)+"");
            item.setData(data.id,Math.floor(data.data*ConfigServer.system_simple.equip_upgrade_fail),-1);
            //
            var gifts:Object = {};
            gifts[data.id] = Math.floor(data.data*ConfigServer.system_simple.equip_upgrade_fail);
            mGift[data.id] = {gift:gifts,xy:item.localToGlobal(new Point(0,0))};
        }
        private function onRemove():void{
            this.list.destroy(true);
            //
            for each(var value:Object in mGift)
            {
                ViewManager.instance.showIcon(value.gift,value.xy.x,value.xy.y);
            }
        }        
        public static function getEffect(emd:ModelEquip,gift:Object):EquipUpgradeLoser{
            var eff:EquipUpgradeLoser = new EquipUpgradeLoser(emd,gift);
            return eff;
        }        
    }
}