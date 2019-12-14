package sg.activities.view
{
	import laya.display.Animation;
	import laya.events.Event;
	import laya.particle.Particle2D;

	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelEquip;
	import sg.utils.Tools;

	import ui.com.hero_icon_equipUI;
	import ui.hero.heroEquipUI;

	/**
	 * ...
	 * @author
	 */
	public class EquipEmboitement extends heroEquipUI{

		public var mEquipArr:Array=[];
		public var mParticle:Particle2D;
		public function EquipEmboitement(arr:Array){
			this.mEquipArr = arr;
			this.btn_go.label = Tools.getMsgById('60001');
		}

		public override function init():void{

			
			this.tType0.text = Tools.getMsgById('_public154');
			this.tType1.text = Tools.getMsgById('_public155');
			this.tType2.text = Tools.getMsgById('_public156');
			this.tType3.text = Tools.getMsgById('_public157');
			this.tType4.text = Tools.getMsgById('_public158');

			setUI();
		}


		public function setUI():void{
			this.clearClicks();
			//
			
			//			
			var equipModel:ModelEquip;
			for(var i:int=0;i< mEquipArr.length;i++){
                equipModel = ModelManager.instance.modelGame.getModelEquip(mEquipArr[i]);
                (this["equip"+equipModel.type] as hero_icon_equipUI).setHeroEquipType(equipModel,equipModel.type,false,-1,true);
				(this["equip"+equipModel.type] as hero_icon_equipUI).label.visible=true;
				(this["equip"+equipModel.type] as hero_icon_equipUI).label.text=equipModel.getName();
				(this["equip"+equipModel.type] as hero_icon_equipUI).imgName.visible=true;
				this["equip"+equipModel.type].on(Event.CLICK,this,this.click,[i]);
			}
			/*
			this.equip0.on(Event.CLICK,this,this.click,[0]);
            this.equip1.on(Event.CLICK,this,this.click,[1]);
            this.equip2.on(Event.CLICK,this,this.click,[2]);
            this.equip3.on(Event.CLICK,this,this.click,[3]);
            this.equip4.on(Event.CLICK, this, this.click, [4]);
			*/
			setSpcial();
		}

		public function updateUI(arr:Array):void{
			this.mEquipArr = arr;
			setUI();
		}

		public function setSpcial():void{
				
				var tempX:Number = this.groupPanel.width * 0.5;
				var tempY:Number = this.groupPanel.height * 0.5 + 16;
				var ani:Animation;
				ani = EffectManager.loadAnimation('equipB', '', 0);
				ani.pos(tempX, tempY);
				ani.name="ani1";
				this.groupPanel.addChild(ani);			
				
				var cfg:Object = ConfigServer.effect.group[ConfigServer.equip[mEquipArr[0]].group];
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
						ani.name="ani2";
						this.groupPanel.addChild(ani);
					}
					
					res = cfg.uiPart;
					if (res){
						var emissionRate:int = cfg.uiPartEmission ? cfg.uiPartEmission:30;
						var maxPartices:int = cfg.uiPartMax ? cfg.uiPartMax:600;
						mParticle = EffectManager.loadParticle(res, emissionRate, maxPartices, this.groupPanel, true, tempX, tempY);
						mParticle.visible = true;
						mParticle.play();
					}
				}
		}

		override public function clear():void{
			this.removedParticle();  
			this.clearClicks();   
			if(this.groupPanel.getChildByName("ani1")){
				this.groupPanel.removeChild(this.groupPanel.getChildByName("ani1"));
			}  
			if(this.groupPanel.getChildByName("ani2")){
				this.groupPanel.removeChild(this.groupPanel.getChildByName("ani2"));
			} 
        }
		private function clearClicks():void
		{
            this.equip0.off(Event.CLICK,this,this.click);
            this.equip1.off(Event.CLICK,this,this.click);
            this.equip2.off(Event.CLICK,this,this.click);
            this.equip3.off(Event.CLICK,this,this.click);
            this.equip4.off(Event.CLICK,this,this.click); 			
		}

		public function removedParticle():void{
			if(mParticle){
				mParticle.visible = false;
				mParticle.stop();
				mParticle.removeSelf();
				mParticle = null;
			}
		}


		public function click(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE_INFO,ModelManager.instance.modelGame.getModelEquip(mEquipArr[index]));
		}


		
	}

}