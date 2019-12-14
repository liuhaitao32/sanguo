package sg.view.hero
{

    import ui.hero.heroItemUI;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.manager.EffectManager;
    import laya.utils.Tween;
    import laya.utils.Ease;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.cfg.ConfigApp;
    import sg.model.ModelAlert;
    import sg.model.ModelGame;
    import sg.manager.AssetsManager;
    import sg.cfg.HelpConfig;

    public class ItemHero extends heroItemUI{
        public function ItemHero():void{
            
        }
        public function checkUI(type:int,md:ModelHero):void{
			Tween.clearTween(this.clipGet);
			this.clipGet.visible = false;
            this.tName.text = md.getName();//+md.id;
			
			Tools.textFitFontSize(this.tName);
			// this.tRarity.text = md.getRarity();
			this.imgRarity.skin = md.getRaritySkin();
			var star:Number = md.getStar();
			var item:Number = md.getMyItemNum();
			this.boxReady.visible = false;
			this.boxStar.visible = false;
			this.mTitle.visible = !Tools.isNullString(md.getTitleStatus());
			this.tTitle.text = ModelHero.getTitleName(md.getTitleStatus());
			this.itemNum.visible = false;
			this.tItem.text = item+"/"+md.itemRuler;
			this.barItem.value = item/md.itemRuler;
			this.heroStarBg.filters = null;
			this.heroStarBg.skin=AssetsManager.getAssetsUI(md.rarity==4?"actPay1_15.png":"bg_29.png");
			this.heroStarBg.left=this.heroStarBg.right=this.heroStarBg.top=this.heroStarBg.bottom=2;
			imgAwaken.visible = Boolean(md.getAwaken());
			if(md.rarity==4) {
				this.heroStarBg.left=this.heroStarBg.right=-20;
            	imgAwaken.visible && (imgAwaken.skin = AssetsManager.getAssetsUI(ModelHero.img_awaken_super_s));
            	EffectManager.changeSprColorFilter(imgAwaken, null);
			} else if (imgAwaken.visible) {
            	imgAwaken.skin = AssetsManager.getAssetsUI(ModelHero.img_awaken_normal_s);
            	EffectManager.changeSprColor(imgAwaken, md.getStarGradeColor(), false);
			}
			
			if(type == 1){
				this.boxReady.visible = true;
				this.box_hero.gray = true;
				this.heroLv.setNum(1);
				//this.tLv.text = "1";
			}
			else{
				
				if (md.isReadyGetMine()){
					this.heroLv.setNum(1);
					//this.tLv.text = "1";
					this.boxReady.visible = true;	
					this.box_hero.gray = true;
					this.clipGet.visible = true;
					this.clipGetFunc1();
				}else{
					EffectManager.changeSprColor(this.heroStarBg,md.getStarGradeColor(),false);
					this.box_hero.gray = false;
					this.boxReady.visible = false;
					if(star>=0){
						this.boxStar.setHeroStar(md.getStar());
						this.boxStar.visible = true;
					}
					this.heroLv.visible = true;
					this.heroLv.setNum(md.getLv());
					//this.tLv.text = md.getLv()+"";
					this.itemNum.visible = true;
					this.tItemNum.text = item+"";
				}
			}
			//
			ModelGame.redCheckOnce(this,ModelAlert.red_hero_once(-1,[2,3,4,5,6],md));
        }
		private function clipGetFunc1():void{
			if(this.clipGet.visible){
				this.clipGet.alpha = 1;
				Tween.to(this.clipGet,{alpha:0.2},1000,null,Handler.create(this,this.clipGetFunc2));
			}
		}
		private function clipGetFunc2():void{
			if(this.clipGet.visible){
				this.clipGet.alpha = 0.2;
				Tween.to(this.clipGet,{alpha:1},1000,null,Handler.create(this,this.clipGetFunc1));
			}
		}	
		override public function clear():void{
			Tween.clearTween(this.clipGet);
			this.offAll(Event.CLICK);
		}	
    }
}