package sg.view.hero
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.particle.Particle2D;
	import laya.ui.Panel;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
    import ui.hero.heroEquipUI;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.model.ModelEquip;
    import sg.manager.ModelManager;
    import ui.com.hero_icon_equipUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelBuiding;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.model.ModelGame;
    import sg.model.ModelAlert;
    import sg.boundFor.GotoManager;
    import sg.scene.view.MapCamera;

    public class ViewHeroEquip extends heroEquipUI{
        private var mModel:ModelHero;
        private var mModelBuild:ModelBuiding;
        private var mArrInstall:Array;
        private var mArrAllNum:Array;//所有宝物数
		//private var mGroupPanel:Panel;
		static private var mParticle:Particle2D;
		
        public function ViewHeroEquip(md:ModelHero):void{
            this.mModel = md as ModelHero;
            this.btn_go.label = Tools.getMsgById('60001');
        }
        override public function init():void{
            this.mModelBuild = ModelManager.instance.modelInside.getBuilding002();//珍宝阁
            //
            this.equip0.on(Event.CLICK,this,this.click,[0]);
            this.equip1.on(Event.CLICK,this,this.click,[1]);
            this.equip2.on(Event.CLICK,this,this.click,[2]);
            this.equip3.on(Event.CLICK,this,this.click,[3]);
            this.equip4.on(Event.CLICK, this, this.click, [4]);
			
			this.tType0.text = Tools.getMsgById('_public154');
			this.tType1.text = Tools.getMsgById('_public155');
			this.tType2.text = Tools.getMsgById('_public156');
			this.tType3.text = Tools.getMsgById('_public157');
			this.tType4.text = Tools.getMsgById('_public158');
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsAD("bg_bagua.jpg"));
            //
            this.setUI();
            //
            this.btn_go.label = Tools.getMsgById("60001");
            this.btn_go.on(Event.CLICK,this,this.clickGo);
        }
		private function clickGo():void{
			GotoManager.instance.boundForHome("building002",1);
		}        
        private function setUI():void{
            //
            this.mArrInstall = ["","","","",""];
            this.mArrAllNum = [0,0,0,0,0];
            var equipArr:Array = this.mModel.getEquip();
            var equipModel:ModelEquip;
            var i:int = 0;
            for(i=0;i< equipArr.length;i++){
                equipModel = ModelManager.instance.modelGame.getModelEquip(equipArr[i]);
                (this["equip"+equipModel.type] as hero_icon_equipUI).setHeroEquipEmbed(0,0,equipModel);
                this.mArrInstall[equipModel.type] = equipModel.id;
            }
            for(i=0;i<this.mArrInstall.length;i++){
                if(Tools.isNullString(this.mArrInstall[i])){
                    var num:Number = ModelEquip.getTypeNums(i);
                    this.mArrAllNum[i] = ModelEquip.getTypeNums(i,false);
                    (this["equip"+i] as hero_icon_equipUI).setHeroEquipEmbed(num,i,null);
                    
                    ModelGame.redCheckOnce((this["equip"+i] as hero_icon_equipUI),(num>0)?ModelAlert.red_hero_once(2,null,this.mModel):false);
                }
                else{
                    ModelGame.redCheckOnce((this["equip"+i] as hero_icon_equipUI),false);
                    this.mArrAllNum[i] = 1;//已安装的情况下  最少是1 就懒得算个数了
                }
            }
			
			//if (!this.mGroupPanel){
				//var frame:int = 2;
				//this.mGroupPanel = new Panel();
				//this.mGroupPanel.x = frame;
				//this.mGroupPanel.y = frame;
				//this.mGroupPanel.width = this.width-frame*2;
				//this.mGroupPanel.height = this.height-frame*2;
			//}
			ViewHeroEquip.removedParticle();
			this.groupPanel.destroyChildren();
			//this.addChildAt(this.mGroupPanel, 3);
			//检测套装
			var group:String = this.mModel.getEquipGroup();
			if (group){
				var tempX:Number = this.groupPanel.width * 0.5;
				var tempY:Number = this.groupPanel.height * 0.5 + 16;
				var ani:Animation;
				ani = EffectManager.loadAnimation('equipB', '', 0);
				ani.pos(tempX, tempY);
				this.groupPanel.addChild(ani);
				
				var cfg:Object = ConfigServer.effect.group[group];
				if (cfg){
					//变色底纹
					var matrix:Array = cfg.matrix;
					EffectManager.changeSprColorFilter(ani, matrix, false);
					
					var res:String = cfg.uiAni;
					if(res){
						ani = EffectManager.loadAnimation(res, '', 0);
						ani.pos(tempX, tempY);
						if(cfg.uiAniAdd)
							ani.blendMode = 'lighter';
						
						this.groupPanel.addChild(ani);
					}
					
					res = cfg.uiPart;
					if (res){
						var emissionRate:int = cfg.uiPartEmission ? cfg.uiPartEmission:30;
						var maxPartices:int = cfg.uiPartMax ? cfg.uiPartMax:600;
						ViewHeroEquip.mParticle = EffectManager.loadParticle(res, emissionRate, maxPartices, this.groupPanel, true, tempX, tempY);
						ViewHeroEquip.mParticle.visible = true;
						ViewHeroEquip.mParticle.play();
						//this.once(Event.REMOVED, this, this.onRemoved());
					}
				}
			}
        }
        private function setEquipUItoAdd(item:hero_icon_equipUI,typeNum:int,type:int):void{
            item.setHeroEquipEmbed(typeNum,type,null);
        }

        private function click(type:int):void{
            if(this.mModelBuild.lv<=0 && this.mArrAllNum[type]<=0){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_equip1"));//还没有珍宝阁,无法锻造宝物
                return;
            }
            if(!this.mModel.isMine()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero19"));//先获得英雄
                return
            }
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_EQUIP_LIST,[type,this.mModel,this.mArrInstall[type],Handler.create(this,this.checkOnOrOff)]);
        }
        private function ws_sr_equip_make(re:NetPackage):void{
            // Trace.log("ws_sr_equip_make",re.receiveData);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ModelManager.instance.modelInside.upgradeEquipCDByArr();
            //
            this.setUI();
        }
        private function checkOnOrOff(type:int,emd:ModelEquip,otherHid:String = "",meid:String = ""):void{
            if(!this.mModel.idle){
                this.mModel.busyHint();
                return;
            }
            if(type == 0){
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_EQUIP_UNINSTALL,{hid:this.mModel.id,eid:emd.id},Handler.create(this,this.ws_sr_hero_equip_uninstall));
            }
            else if(type == 1){
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_EQUIP_INSTALL,{hid:this.mModel.id,eid:emd.id},Handler.create(this,this.ws_sr_hero_equip_install));
            }
            else if(type == 2){
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_EQUIP_UNINSTALL,{hid:otherHid,eid:emd.id},Handler.create(this,this.ws_sr_hero_equip_uninstall),[type,emd.id,meid]);
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_EQUIP_UNINSTALL,{hid:this.mModel.id,eid:meid},Handler.create(this,this.ws_sr_hero_equip_uninstall),[type,emd.id]);
            }            
        }
        private function ws_sr_hero_equip_install(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.setUI();
            this.mModel.event(ModelHero.EVENT_HERO_EXP_CHANGE);
        }
        private function ws_sr_hero_equip_uninstall(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            if(re.otherData){
                if(re.otherData[0] == 3){
                    this.checkOnOrOff(1,ModelManager.instance.modelGame.getModelEquip(re.otherData[1]));
                    return;
                }
                else if(re.otherData[0] == 2){
                    if(re.otherData[2]==""){
                        this.checkOnOrOff(1,ModelManager.instance.modelGame.getModelEquip(re.otherData[1]));
                    }
                    else{
                        this.checkOnOrOff(3,ModelManager.instance.modelGame.getModelEquip(re.otherData[1]),"",re.otherData[2]);
                    }
                    return;                    
                }
            }
            this.setUI();
            this.mModel.event(ModelHero.EVENT_HERO_EXP_CHANGE);
        }
		
		static public function removedParticle():void{
			if(ViewHeroEquip.mParticle){
				ViewHeroEquip.mParticle.visible = false;
				ViewHeroEquip.mParticle.stop();
				ViewHeroEquip.mParticle.removeSelf();
				ViewHeroEquip.mParticle = null;
			}
		}
		
		//public function onRemoved():void{
			//ViewHeroEquip.removedParticle();
		//}
		override public function clear():void{
			ViewHeroEquip.removedParticle();
            this.btn_go.off(Event.CLICK,this,this.clickGo);
            this.equip0.off(Event.CLICK,this,this.click);
            this.equip1.off(Event.CLICK,this,this.click);
            this.equip2.off(Event.CLICK,this,this.click);
            this.equip3.off(Event.CLICK,this,this.click);
            this.equip4.off(Event.CLICK,this,this.click);         
        }
    }
}