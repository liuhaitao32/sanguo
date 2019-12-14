package sg.view.hero
{
	import sg.manager.EffectManager;
    import ui.hero.heroSkillItemUI;
    import sg.model.ModelSkill;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.cfg.ConfigClass;
    import sg.manager.ViewManager;
    import laya.maths.Rectangle;
    import laya.utils.Tween;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import sg.manager.AssetsManager;

    public class ItemHeroSkill extends heroSkillItemUI{
        public var mModel:ModelHero;
        public var mModelSkill:ModelSkill;
        public function ItemHeroSkill():void{
            this.width = 246;
            this.height = 96;
        }
        public function click():void{
            ViewManager.instance.showView(ConfigClass.VIEW_SKILL_UPGRADE, [
				this.mModel,
				this.mModelSkill,
				[this.mModel.getMySkillsNum(this.mModelSkill.type), this.mModel.getMySkillLimit(this.mModelSkill.type)],
				this.mModel.isMine()
			]);
        }
        public function initData(md:ModelHero,skill:ModelSkill):void{
            this.mModel = md;
            this.mModelSkill = skill;
            //
            this.setUI();
        }
        public function setUI():void{
            var slv:int = this.mModelSkill.getLv(this.mModel);
            this.tName.text = this.mModelSkill.getName(true);
			
            // this.tLv.text = this.mModelSkill.getLv(this.mModel)+" "+this.mModelSkill.id;
            this.item.setIcon(this.mModelSkill.getIcon());
            this.item.mCanClick = false;
			//this.item.setTypeIcon(this.mModelSkill);
			
			var color:int = this.mModelSkill.getColor(mModel);
			this.tName.color = EffectManager.getFontColor(color);
			this.item.setBgColor(color);

			this.tName.bold = slv > 0;
            Tools.textFitFontSize(this.tName);
			if (slv > 0){
				this.item.setNum(slv + "");
				this.item.setNumColor(color);
				this.item.setNumBold(true, 12);
			}
			else{
				this.item.setNum("");
			}
           
            //
            var reData:Object = this.mModelSkill.isCanGetOrUpgrade(this.mModel);
            // var nv:Number = this.mModelSkill.getLv(this.mModel);
            // var max:Number = this.mModelSkill.getMaxLv();    
            var cn:Number = this.mModel.getMySkillsNum(this.mModelSkill.type);      
            var cmax:Number = this.mModel.getMySkillLimit(this.mModelSkill.type);
            //
            var m:Number = this.mModelSkill.getMyItemNum();
            var n:Number = this.mModelSkill.getUpgradeItemNum(this.mModel);            
            var itemOK:Boolean = m>=n;
            this.imgUp.visible = (this.mModel.isMine() && (cn<cmax) && slv==0  && itemOK  && reData.isOK);
            //
            Tween.clearAll(this.imgUp);
            
            //else{
                //
                var pveArr:Array = ModelSkill.isCanLvUpByPVE(this.mModelSkill.getLv(this.mModel)+1);
                //
                var sk:String = ModelSkill.getSpecial(this.mModelSkill.id);
                var b:Boolean = sk?sk == this.mModel.id:true;
				var b2:Boolean = !(this.mModelSkill.id=="skill288" && this.mModel.rarity == 4);//传奇英雄不可学习豪杰技能
				if(this.imgUp.visible){//未解锁的判断材料是否够 并且还需要判断携带最大等级。
					this.glow1();					
					ModelGame.redCheckOnce(this, (this.mModel.isMine() && (cn < cmax) && itemOK && reData.isOK && pveArr[0] && b && b2));
				} else {//可升级判断材料是否够。
					ModelGame.redCheckOnce(this, (this.mModel.isMine() && slv > 0 && slv < this.mModelSkill.getMaxLv() && itemOK && reData.isOK && pveArr[0] && b  && b2));
				}
                
				
            //}

            //            
            this.skill.text = m+" / "+n;
            this.bar.value = m/n;
            //
            // var canUpgrade:Boolean = this.mModelSkill.isCanGetOrUpgrade(this.mModel).isOK;
            //
            this.item.gray = (slv<=0);// || !this.mModel.isMine()
        }
        private function glow1():void
        {
            Tween.clearAll(this.imgUp);
            Tween.to(this.imgUp,{alpha:0},500,null,Handler.create(this,this.glow2));
        }
        private function glow2():void
        {
            Tween.clearAll(this.imgUp);
            Tween.to(this.imgUp,{alpha:1},500,null,Handler.create(this,this.glow1));
        }        
    }
}