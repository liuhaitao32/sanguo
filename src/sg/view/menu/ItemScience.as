package sg.view.menu
{
    import sg.model.ModelScience;
    import sg.manager.ModelManager;
    import sg.model.ModelInside;
    import sg.manager.AssetsManager;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.scene.view.MapCamera;
    import sg.guide.view.GuideFocus;

    public class ItemScience extends ItemBuilder
    {
        public var mModelScience:ModelScience;
        public function ItemScience()
        {
            ModelManager.instance.modelInside.on(ModelInside.SCIENCE_BUILDER_ADD,this,this.science_builder);
            ModelManager.instance.modelInside.on(ModelInside.SCIENCE_UPDATE_CD,this,this.science_builder);
            ModelManager.instance.modelInside.on(ModelInside.SCIENCE_UPDATE_REMOVE,this,this.science_builder);
            ModelManager.instance.modelInside.on(ModelInside.SCIENCE_UPDATE_GET,this,this.science_builder);
            this.mModelScience = null;
            this.on(Event.CLICK,this,this.click);
        }
        override public function initData(md:*):void{
			this.mModelScience = md;
            this.img.skin = AssetsManager.getAssetsUI("icon_paopao15.png");
			this.change();
            //
		}     
        override public function change():void{
            this.visible = (ModelManager.instance.modelInside.getBuilding003().lv>0);
			this.bgTimer.visible = false;
			this.bgTxt.visible = true;  
            this.txt.visible = true;    
            this.txt.color = "#ffffff";      
            if(this.mModelScience){
                var type:int = this.mModelScience.isUpgradeIng();
				if(type>-1){
                    if(this.mModelScience.getLastCDtimer()>0){
					    this.txt.text = Tools.getTimeStyle(this.mModelScience.getLastCDtimer());
                        this.bgTimer.visible = true;
                        this.bgTxt.visible = false;                     
                    }
                    else{
                        this.txt.color = "#1eff00"; 
                        this.txt.text = Tools.getMsgById("_science4");//"可以激活";
                    }
					// this.tname.text = this.mModelScience.getName();
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
            MapCamera.lookAtBuild("building003", 500, true);
            if(this.mModelScience){
                var type:int = this.mModelScience.isUpgradeIng();
				if(type>-1){
                    if(this.mModelScience.getLastCDtimer()<=1000){
                        ModelManager.instance.modelInside.checkScienceGet();
                    }
                    else{
                        GuideFocus.focusOut();
                        ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_QUICKLY,ModelScience.getCDingModel());
                    }
                }
            }
            else{
                
            }
        }               
        private function science_builder(md:ModelScience):void{
            if(md){
                if(this.mModelScience){
                    if(md.isUpgradeIng()>-1){
                        if(this.mModelScience.id == md.id){
                            this.mModelScience = md;
                        }
                    }
                    else{
                        if(md.id == this.mModelScience.id){
                            this.mModelScience = null;
                        }
                    }
                }
                else{
                    this.mModelScience = md;
                }
            }
            this.change();
        }
    }
}