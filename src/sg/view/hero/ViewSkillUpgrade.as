package sg.view.hero
{
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.logic.utils.PassiveStrUtils;
    import ui.hero.heroSkillUpgradeUI;
    import sg.model.ModelHero;
    import sg.model.ModelSkill;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.AssetsManager;
    import laya.ui.Box;
    import laya.ui.CheckBox;
    import sg.model.ModelGame;
    import sg.utils.StringUtil;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import sg.view.effect.HeroSkillUpgrade;
    import sg.utils.MusicManager;

    public class ViewSkillUpgrade extends heroSkillUpgradeUI{
        public var mModel:ModelHero;
        public var mModelSkill:ModelSkill;
        public var mTypePro:Array;
		
		private var mIsMine:Boolean;
        private var mBox_limit:Box;
		private var mDetail:ViewSkillDetail;
        //
        public function ViewSkillUpgrade():void{
            this.btn_coin.on(Event.CLICK,this,this.click,[1]);
            this.btn_gold.on(Event.CLICK,this,this.click,[0]);
            this.btn_del.on(Event.CLICK,this,this.click_del);
            this.btn_from.on(Event.CLICK,this,this.click_from);
            this.btnSpecial.on(Event.CLICK, this, this.click_special);
			this.btn_go.on(Event.CLICK,this,this.click_go);
            //
            this.mBox_limit = new Box();
            this.mBox.addChild(this.mBox_limit);
			
			this.mDetail = new ViewSkillDetail();
			this.boxDetail.addChild(this.mDetail);
			this.dengji.text = Tools.getMsgById("_hero14");
			this.btn_del.label = Tools.getMsgById("ViewSkillUpgrade_1");
			this.btn_from.label = Tools.getMsgById("_bag_text07");
			this.tAbility.text = Tools.getMsgById("ViewSkillUpgrade_2");

            this.tLearn.text = Tools.getMsgById("_shop_text12");
        }
        override public function initData():void{
            this.mModel = this.currArg[0] as ModelHero;
            this.mModelSkill = this.currArg[1] as ModelSkill;
            this.mTypePro = this.currArg[2];
			this.mIsMine = this.currArg[3];
            this.btnSpecial.selected = ModelSkill.getSpecial(this.mModelSkill.id)==this.mModel.id;
            this.setUI();
        }
        private function click_special():void
        {
            if(ModelSkill.getSpecial(this.mModelSkill.id)!=this.mModel.id){
                ModelSkill.setSpecial(this.mModelSkill.id,this.mModel.id);
                this.btnSpecial.selected = true;
            }
            else{
                if(this.btnSpecial.selected){
                    ModelSkill.setSpecial(this.mModelSkill.id,this.mModel.id,true);
                    this.btnSpecial.selected = false;
                }
            }
        }
		/**
		 * 前往副将
		 */
		private function click_go():void
        {
            this.closeSelf();
            ModelManager.instance.modelGame.event(ModelHero.EVENT_HERO_LOOK_UP, [mModel.id, 1]); // 查看对应副将的技能
        }
		/**
		 * 显示副将技
		 */
		private function setAdjutantUI():void{
            this.btnSpecial.visible = false;

            //
			var skillName:String = this.mModelSkill.getName();
			//this.tTilte.text = skillName;
            this.comTitle.setViewTitle(skillName);
			this.tName.text = skillName;
			
			var lv:int = this.mTypePro[0];
            this.tLv.text = lv+"/"+this.mModelSkill.getMaxLv();
			this.tType.text = Tools.getMsgById('skill_type');
			this.tRound.text = Tools.getMsgById('skill_round');
			Tools.textFitFontSize(this.tTypeV, this.mModelSkill.getTypeStr());
			//this.tTypeV.text = this.mModelSkill.getTypeStr();
			Tools.textFitFontSize(this.tRoundV, this.mModelSkill.getRoundStr());
			//this.tRoundV.text = this.mModelSkill.getRoundStr();
			this.mDetail.initData(this.mModelSkill,this.mModel,[lv,this.mTypePro[1]]);
			var color:int = this.mModelSkill.getColor(lv);
            this.skillIcon.setIcon(this.mModelSkill.getIcon());
            this.skillIcon.setNum("");
            this.skillIcon.setBgColor(color);
            this.skillIcon1.setIcon(this.mModelSkill.getIcon());
            this.skillIcon1.setNum("");
            this.skillIcon1.setBgColor(0);
            
            EffectManager.changeSprColor(this.barColor,color);
            //
			this.btn_del.visible = false;
            this.btn_coin.visible = false;
            this.btn_gold.visible = false;
            this.errBox.visible = false;
			this.skillIcon1.visible = this.barSkill.visible = this.tSkill.visible = this.btn_from.visible = this.tAbility.visible = this.ability_info.visible = false;
			this.tLearn.visible = this.imgLearn.visible = false;
            //
            this.mBox_limit.removeChildren();
            this.boxAdjutant.visible = true;
			this.boxDetail.bottom = 200;
			
			this.hInfo.style.color = "#ffffff";
            this.hInfo.style.fontSize=18;
            this.hInfo.style.leading = 10;
            this.hInfo.style.wordWrap = true;
            this.hInfo.style.align = "center";
			
			var info:String = Tools.getMsgById(this.mModelSkill.type == 7?'skill_adjutant_0':'skill_adjutant_1');
			this.hInfo.innerHTML = info;
			this.btn_go.label = Tools.getMsgById('skill_adjutant_go',[this.mModel.getName()]);
        }
		
        private function setUI():void{
			if (this.mModelSkill.type > 6){
				this.setAdjutantUI();
				return;
			}
			this.skillIcon1.visible = this.barSkill.visible = this.tSkill.visible = this.btn_from.visible = this.tAbility.visible = this.ability_info.visible = true;
			this.imgLearn.visible = true;
			this.boxAdjutant.visible = false;
			this.boxDetail.bottom = 276;
			
			
            this.btnSpecial.toggle = false;
            this.btnSpecial.label = Tools.getMsgById("_skill4");//专属（勾选后其他英雄此技能不显示红点提示)
            //
			var skillName:String = this.mModelSkill.getName();
			//this.tTilte.text = skillName;
            this.comTitle.setViewTitle(skillName);
			this.tName.text = skillName;
			
            this.tLv.text = this.mModelSkill.getLv(this.mModel)+"/"+this.mModelSkill.getMaxLv();
			this.tType.text = Tools.getMsgById('skill_type');
			this.tRound.text = Tools.getMsgById('skill_round');
			Tools.textFitFontSize(this.tTypeV, this.mModelSkill.getTypeStr());
			//this.tTypeV.text = this.mModelSkill.getTypeStr();
			Tools.textFitFontSize(this.tRoundV, this.mModelSkill.getRoundStr());
			//this.tRoundV.text = this.mModelSkill.getRoundStr();
			this.mDetail.initData(this.mModelSkill,this.mModel);
			var color:int = this.mModelSkill.getColor(this.mModel);
            this.skillIcon.setIcon(this.mModelSkill.getIcon());
            // this.skillIcon.setData(this.mModelSkill.id);
            this.skillIcon.setNum("");
            this.skillIcon.setBgColor(color);
            this.skillIcon1.setIcon(this.mModelSkill.getIcon());
            // this.skillIcon1.setData(this.mModelSkill.id);
            this.skillIcon1.setNum("");
            this.skillIcon1.setBgColor(0);
            
            EffectManager.changeSprColor(this.barColor,color);
            //
            var lv:int = this.mModelSkill.getLv(this.mModel);
            //
            var isTwo:Boolean = false;
            if(this.mModelSkill.fast_learn>0 && Tools.isNewDay(this.mModel.getFastLearn())){
            //
                if(lv==0){
                    isTwo = true;
                    this.btn_coin.setData("",this.mModelSkill.fast_learn);
                }
            }
            if(this.mModel.skill[this.mModelSkill.id]){
                this.btn_del.visible = lv>this.mModel.skill[this.mModelSkill.id];
            }
            else{
                this.btn_del.visible = lv>0;//true;
            }
            if(isTwo){
                this.btn_coin.visible = true;
                this.btn_gold.visible = true;
                //
                this.btn_coin.centerX = -150;
                this.btn_gold.centerX = 150;
            }
            else{
                this.btn_coin.visible = false;
                this.btn_gold.visible = true;
                this.btn_gold.centerX = 0;
            }
            var goldNum:Number = this.mModelSkill.getUpgradeGoldNum(this.mModel);
            this.btn_gold.gray = ModelManager.instance.modelUser.gold<goldNum;
            this.btn_gold.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(goldNum));
            //
            //
            var abilityArr:Array = this.mModelSkill.getAbility_info();
            //
            var len:int = abilityArr.length;
            var obj:Object;
            var abilityStr:String = "";
            if(len<=0){
                abilityStr = Tools.getMsgById("_skill5");//无限制
            }
            else{
                for(var i:int = 0; i < len; i++)
                {
                    obj = abilityArr[i];
                    obj.num = this.mModelSkill.getAbilityHeroAttsNum(this.mModel,obj.id);
                    abilityStr += obj.name+""+obj.num + "    ";
                }
            }
            this.ability_info.text = abilityStr;
            //
            this.errBox.visible = false;
            //
            this.setLimit();
        }
        private function setLimit():void{
            this.mBox_limit.removeChildren();
            //
            var reData:Object = this.mModelSkill.isCanGetOrUpgrade(this.mModel,(this.mModelSkill.getLv(this.mModel)<1)?this.mTypePro:null);
            var arr:Array = reData.arr;
            this.tLearn.visible = (arr.length > 0);

            // if(arr.length==0){
            //     return;
            // }
            var len:int = arr.length;
            var obj:Object;
            var cb:CheckBox;
            var errObj:Object;
			var isPassAll:Boolean = reData.isOK;
            var errorStr:String = "";
			this.btnSpecial.visible = this.mIsMine;
			if (!this.mIsMine)
			{
				errorStr = Tools.getMsgById("_hero19");
				isPassAll = false;
			}
            //
            for(var i:int = 0; i < len; i++)
            {
                obj = arr[i];
                cb = new CheckBox(AssetsManager.getAssetsUI("btn_checkno.png"));//ui/btn_checkno.png
				cb.labelColors = "#FFFFFF,#FF3311,#32CC6B,#C0C0C0";
                //cb.labelColors = "#FFFFFF";
                cb.mouseEnabled = false;
                cb.toggle = true;
                cb.stateNum = 2;
                cb.scaleX = 0.5;
                cb.scaleY = 0.5;
                cb.labelSize = 36;
                cb.label = "   "+obj.name+""+obj.ext;
                cb.selected = !obj.ok;
                cb.x = 120*i;
                if(!obj.ok && !errorStr){
                    errorStr = obj.estr;
                }
                this.mBox_limit.addChild(cb);
            }
            this.mBox_limit.x = this.tLearn.x +this.tLearn.width+30;
            this.mBox_limit.y = this.tLearn.y - 2;
            //
            
            //
            var m:Number = this.mModelSkill.getMyItemNum();
            var n:Number = this.mModelSkill.getUpgradeItemNum(this.mModel);
            //
            this.tSkill.text = m+"/"+n;
            this.barSkill.value = m/n;
            //     
            
            //豪杰技能
            if(mModelSkill.id=="skill288" && mModel.rarity==4){
                this.btn_coin.visible = false;
                this.btn_gold.visible = false;
                this.errBox.visible = true;
                this.tTips.text = Tools.getMsgById("_hero37");
                return;
            }  


            if(isPassAll){
                var nv:Number = this.mModelSkill.getLv(this.mModel);
                var max:Number = this.mModelSkill.getMaxLv();                
                
                if(nv>=max){
                    isPassAll = false;
                    errorStr = Tools.getMsgById("_public12");//已经是最高等级
                }
                else{
                    var pveArr:Array = ModelSkill.isCanLvUpByPVE(this.mModelSkill.getLv(this.mModel)+1);
                    if(!pveArr[0]){
                        isPassAll = false;
                        errorStr = Tools.getMsgById("_skill6",[StringUtil.numberToChinese(pveArr[1])]);
                    }
                    else if(m<n){
                        isPassAll = false;
                        errorStr = Tools.getMsgById("_public19");//材料不足
                    }
                }
            }
            if(!isPassAll){
                this.btn_coin.visible = false;
                this.btn_gold.visible = false;
                // this.btn_del.visible = false;
                this.errBox.visible = true;
                this.tTips.text = errorStr;
            }   

                 
        }
        private function click(type:int):void{          
            if(type==0){
                if(!Tools.isCanBuy("gold",this.mModelSkill.getUpgradeGoldNum(this.mModel))){
                    return;
                }
                
            }
            if(type==1){
                if(!Tools.isCanBuy("coin",this.mModelSkill.fast_learn)){
                    return;
                }
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_SKILL_LV_UP,{hid:this.mModel.id,skill_id:this.mModelSkill.id,fast_learn:type},Handler.create(this,this.ws_sr_hero_skill_lv_up));
        }
        private function ws_sr_hero_skill_lv_up(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mModel.event(ModelGame.EVENT_HERO_SKILL_CHANGE);
            //
            MusicManager.playSoundUI(MusicManager.SOUND_HERO_SKILL_UP);
            this.changeSelf(true);
        }
        private function checkClip(lvUp:Boolean = false):void{
            this.clipBox.destroyChildren();
            //
            if(lvUp){
                var aniLv:Animation = EffectManager.loadAnimation("glow024","",2);
                aniLv.x = this.skillIcon.x;
                aniLv.y = this.skillIcon.y; 
                this.clipBox.addChild(aniLv);  
                //
                ViewManager.instance.clearViewEffectSpecial("_hero_skill_upgrade_");
                ViewManager.instance.showViewEffect(HeroSkillUpgrade.getEffect(),0,null,false,true,"_hero_skill_upgrade_");      
            }
        }        
        private function click_del():void{
            ViewManager.instance.showView(ConfigClass.VIEW_SKILL_DELETE,[this.mModel,this.mModelSkill]);
        }
        private function click_from():void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_BAG_SOURSE,this.mModelSkill.itemID);
        }
        override public function onAdded():void{
            this.mModel.on(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.changeSelf);            
        }
        override public function onRemoved():void{
            this.mModel.off(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.changeSelf);
            this.clipBox.destroyChildren();
        }
        private function changeSelf(lvUp:Boolean = false):void
        {
            //
            this.checkClip(lvUp);
            //
            this.setUI();            
        }
    }
}