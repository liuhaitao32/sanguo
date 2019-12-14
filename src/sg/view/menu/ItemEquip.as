package sg.view.menu
{
    import ui.menu.builderUI;
    import sg.model.ModelEquip;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetPackage;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.manager.AssetsManager;
    import sg.cfg.ConfigClass;
    import sg.scene.view.MapCamera;
    import sg.guide.view.GuideFocus;

    public class ItemEquip extends ItemBuilder{
        public var mModelEquip:ModelEquip;
        public function ItemEquip(){
            //
            ModelManager.instance.modelInside.on(ModelInside.EQUIP_BUILDER_ADD,this,this.equip_builder);
            ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_CD,this,this.equip_builder);
            ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_REMOVE,this,this.equip_builder);
            ModelManager.instance.modelInside.on(ModelInside.EQUIP_UPDATE_GET,this,this.equip_builder);
            this.mModelEquip = null;
            this.on(Event.CLICK,this,this.click);
        }
        override public function initData(md:*):void{
			this.mModelEquip = md;
            this.img.skin = AssetsManager.getAssetsUI("icon_paopao17.png");
			this.change();
            //
            // this.img.skin = AssetsManager.getAssetsUI("btn_34.png");
            //
            // this.visible = (ModelManager.instance.modelInside.getBuilding002().lv>0);
		}
        override public function change():void{
            this.visible = (ModelManager.instance.modelInside.getBuilding002().lv>0);
            this.bgTimer.visible = false;
			this.bgTxt.visible = true;
            this.txt.visible = true;
			this.txt.color = "#ffffff"; 
            if(this.mModelEquip){
                var type:int = this.mModelEquip.isUpgradeIng();
				if(type>-1){
                    if(this.mModelEquip.getLastCDtimer()>0){
					    this.txt.text = Tools.getTimeStyle(this.mModelEquip.getLastCDtimer());
                        this.bgTimer.visible = true;
                        this.bgTxt.visible = false;                        
                    }
                    else{
						this.txt.color = "#1eff00"; 
                        this.txt.text = Tools.getMsgById("_science5")//"可以收取";
                    }
					// this.tname.text = this.mModelEquip.getName();
				}
                else{

                }
			}
			else{
				//this.txt.color = "#ffff00"; 
				this.txt.text = Tools.getMsgById("_science3");//"闲置状态";
                this.bgTxt.visible = false;
                this.txt.visible = false;
				// this.tname.text = "";
			}
            this.checkIsFree();
        }
        private function click():void{
            MapCamera.lookAtBuild("building002", 500, true);
            if(this.mModelEquip){
                
                var type:int = this.mModelEquip.isUpgradeIng();
				if(type>-1){
                    if(this.mModelEquip.getLastCDtimer()<=1000){
                        ModelManager.instance.modelInside.checkEquipGet();
                    }
                    else{
                        GuideFocus.focusOut();
                        ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_QUICKLY,ModelEquip.getCDingModel());
                    }
                }
            }
            else{
                
            }
        }
        private function equip_builder(md:ModelEquip):void{
            if(md){
                if(this.mModelEquip){
                    if(md.isUpgradeIng()>-1){
                        if(this.mModelEquip.id == md.id){
                            this.mModelEquip = md;
                        }
                    }
                    else{
                        if(md.id == this.mModelEquip.id){
                            this.mModelEquip = null;
                        }
                    }
                }
                else{
                    this.mModelEquip = md;
                }
            }
            this.change();
        }
    }
}