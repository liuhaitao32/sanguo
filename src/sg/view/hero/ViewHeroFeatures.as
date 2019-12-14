package sg.view.hero
{
    
	/**
	 * 英雄详细功能信息界面
	 * @author
	 */
	import laya.display.Sprite;
	import laya.particle.Particle2D;
	import sg.cfg.ConfigColor;
	import sg.model.ModelTalent;
    import ui.hero.heroFeaturesUI;
    import laya.utils.Handler;
    import sg.view.ViewPanel;
    import sg.model.ModelHero;
    import sg.view.com.ItemBase;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import laya.events.Event;
    import sg.manager.EffectManager;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelPrepare;
    import sg.utils.Tools;
    import sg.view.effect.HeroStarUpgrade;
    import laya.utils.Tween;
    import laya.maths.Point;
    import sg.model.ModelAlert;
    import laya.ui.Button;
    import laya.ui.List;
    import sg.model.ModelUser;import laya.display.Animation;
    import sg.cfg.ConfigApp;
    import sg.cfg.ConfigServer;
    import sg.utils.StringUtil;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.view.beast.ViewBeastMain;
    import sg.model.ModelBeast;
    import sg.cfg.HelpConfig;

    public class ViewHeroFeatures extends heroFeaturesUI{
        //
        private var mModel:ModelHero;
        private var mFuns:ItemBase;
        private var mLookIndex:int = 0;
        private var mHerosArr:Array;
        private var mSelectIndex:int = -1;
        private var mCurrHeroID:String = "";
		private var mPowerTemp:Number = -1;
		private var mParticles:Array;
        //
        private var mTabData:Array;
        public function ViewHeroFeatures():void{
            this.tab.selectHandler = new Handler(this,this.tab_select);
            //
            this.btn_next.on(Event.CLICK,this,this.click_change,[1]);
            this.btn_pre.on(Event.CLICK,this,this.click_change,[-1]);
            //
            this.btn_title.on(Event.CLICK,this,this.click_title);
            //
			this.heroIcon.on(Event.CLICK,this,this.click_talent);
            //
            this.btn_formation.on(Event.CLICK,this,click_formation);
            //
            this.btn_beast.on(Event.CLICK,this,click_beast);
            //
			box_prop.on(Event.CLICK,this,this._click_prop);

            
        }
		override public function initData():void{
			ViewHeroSkill.lastTabSelectIndex = 0;
            //
            this.mPowerTemp = -1;
            this.mModel = this.currArg[0] as ModelHero;
            this.mHerosArr = this.currArg[1] as Array;
            this.mLookIndex = parseInt(this.currArg[2]);

            if (mHerosArr is Array && mHerosArr.length === 0) { // 觉醒的时候人物不刷新 才加的
                this.changeUI(mModel);
            }

		}

        private function refreshTab(update:Boolean = false):void
        {
            var str:String = "";
            var arr:Array = [
                {txt:Tools.getMsgById("_public1"),index:0}, // 属性
                {txt:Tools.getMsgById("_public2"),index:1}, // 技能
                {txt:Tools.getMsgById("_public3"),index:2}, // 宝物
                {txt:Tools.getMsgById("_public4"),index:3}, // 宿命
                {txt:Tools.getMsgById("_public5"),index:4}, // 星辰
                {txt:Tools.getMsgById("_jia0076"),index:5}, // 副将
            ];
                
            this.mTabData = [];
            //
            var len:int = arr.length;
            var obj:Object;
            var b:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                b = false;
                obj = arr[i];
                switch(i)
                {
                    case 1:
                        b = !ModelGame.unlock(null,"hero_skill").stop;
                        break;
                    case 2:
                        b = ((!ModelGame.unlock(null,"hero_equip").stop || Tools.getDictLength(ModelManager.instance.modelUser.equip)>0) && this.mModel.isMine());
                        break;
                    case 3:
                        b = this.mModel.rarity>0 && !ModelGame.unlock(null,"hero_fate").stop;
                        break;
                    case 4:
                        b = (!ModelGame.unlock(null,"hero_star").stop && this.mModel.isMine());
                        break;
                    case 5:
                        b = ModelGame.unlock(null,"hero_adjutant").visible;
                        // b = this.mModel.isMine() && this.mModel.getStar() >= ConfigServer.system_simple.adjutant_level;
                        break;
                    default:
                        b = true;
                        break;
                }
                if(b){
                    this.mTabData.push(obj);
                    str+=obj.txt+",";
                }
            }
            this.tab.labels = str.substr(0,str.length-1);
            var index:int = 0;
            len = this.mTabData.length;
            for(i = 0;i < len;i++){
                this.tab.items[i]["name"] = "tab_"+this.mTabData[i].index;
                if (mTabData[i]['index'] === mSelectIndex) {
                    index = i;
                }
            }
            if (this.tab.selectedIndex === index) {
                this.tab_select(index);
            }
            else {
                this.tab.selectedIndex = index;
            }
            this.setUI(update);
            this.checkRed();
        }

        private function click_title():void{
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_TITLE,this.mModel);
        }

        private function checkRed():void
        {
            // trace("检查red");
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_5"), ModelAlert.red_hero_once(7,null,this.mModel));
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_4"),!ModelGame.unlock(null,"hero_star").stop && ModelAlert.red_hero_once(6,null,this.mModel));
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_3"),!ModelGame.unlock(null,"hero_fate").stop && this.mModel.rarity>0 && ModelAlert.red_hero_once(5,null,this.mModel));
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_2"),!ModelGame.unlock(null,"hero_equip").stop && ModelAlert.red_hero_once(2,null,this.mModel));
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_1"),!ModelGame.unlock(null,"hero_skill").stop && (ModelAlert.red_hero_once(4,null,this.mModel) || ModelAlert.red_hero_once(3,null,this.mModel)));           
        
            
        }
        private function checkHeroIcon(update:Boolean = false):void{
			var isAwaken:Boolean = this.mModel.getAwaken()==1;
			
            if(!update){
                this.heroIcon.setHeroIcon(this.mCurrHeroID, false);

				//英雄背景粒子
				this.heroIcon.mParticlesBottom.visible = this.heroIcon.mParticles.visible = true;
                box_hint.visible = !this.mModel.isMine();
                this.heroIcon.mParticles.removeChildren();
				this.heroIcon.mParticlesBottom.removeChildren();

				if(isAwaken && mModel.rarity !== 4){
					this.mParticles = EffectManager.loadParticleByArr(ConfigColor.PARTICLE_CONFIG_AWAKEN, this.heroIcon.mParticles, this.heroIcon.mParticlesBottom);
				}
				else{
					this.mParticles = EffectManager.loadParticleByArr(ConfigColor.PARTICLE_CONFIG_BY_HERO_RARITY[this.mModel.rarity], this.heroIcon.mParticles, this.heroIcon.mParticlesBottom);
				}
				//this.mParticles = this.mParticles.concat(EffectManager.loadParticleByArr(ConfigColor.PARTICLE_CONFIG_AWAKEN, this.heroIcon.mParticles, this.heroIcon.mParticlesBottom));
            }
            if (mModel.rarity === 4) {
                heroIconBg.visible=false;
                imgSuper.visible=true;
                LoadeManager.loadTemp(imgSuper, AssetsManager.getAssetsAD(ModelHero.super_hero_bg));
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_super));
                EffectManager.changeSprColor(imgSuper, mModel.getStarGradeColor(), false);
            } else {
                heroIconBg.visible=true;
                imgSuper.visible=false;
                LoadeManager.loadTemp(imgAwaken, AssetsManager.getAssetsAD(ModelHero.img_awaken_normal));
                EffectManager.changeSprColor(heroIconBg, mModel.getStarGradeColor(), false);
            }
			imgAwaken.visible = isAwaken;
			if (isAwaken && imgAwaken.parent) {
				//var ph:Number = (imgAwaken.parent as Component).height;
                if(HelpConfig.type_app == HelpConfig.TYPE_SG){
                    var ph:Number = mFuncImg.height * 0.8;
                    if (ph > 437){
                        imgAwaken.centerY = (ph - 437) * 0.2;
                        ph = 437;
                    }
                    else{
                        imgAwaken.centerY = 0;
                    }
                    imgAwaken.centerY -= 60;
                    imgAwaken.height = ph;
                    imgAwaken.width = ph * 1.4645;
                }			
                mModel.rarity !== 4 && EffectManager.changeSprColor(imgAwaken, mModel.getStarGradeColor(), false);
			}



            if(!ModelGame.unlock(this.btn_formation,"hero_formation",false).stop){
                setFormationBtn();
            }

            if(!ModelGame.unlock(this.btn_beast,"beast",false).stop){
                setBeastBtn();
            }
              
        }

        private function setFormationBtn():void{
            var b:Boolean=mModel.formation_index!=-1;
            if(b) this.btn_formation.cCom.imgIcon.skin=AssetsManager.getAssetsICON("formation"+mModel.getFormationArr()[mModel.formation_index].id+".png");
            else this.btn_formation.cCom.imgIcon.skin=AssetsManager.getAssetsICON("formation0.png");

            if(b) this.btn_formation.tName.text=mModel.getFormationArr()[mModel.formation_index].getName();
            else this.btn_formation.tName.text=Tools.getMsgById("_hero_formation15");

            var n:Number= b ? mModel.getFormationArr()[mModel.formation_index].curStar(mModel) : 0;
			this.btn_formation.tName.color=n==0 ? "#ffffff" : ConfigColor.FONT_COLORS[n];
            Tools.textFitFontSize(this.btn_formation.tName);
			EffectManager.changeSprColor(this.btn_formation.cCom.imgBg,n,true);

            ModelGame.redCheckOnce(this.btn_formation,ModelAlert.red_hero_once(8,null,this.mModel),[50,10]);        
        }

        private function setBeastBtn():void{
            if(this.btn_beast.visible){
                this.btn_beast.visible = this.mModel.isMine() && ModelBeast.isOpen();
                if(this.btn_beast.visible){
                    this.btn_beast.tName.text = Tools.getMsgById('_beast_text0');
                    this.btn_beast.tName.color = ConfigColor.FONT_COLORS[0];
                    this.btn_beast.img0.visible = true;
                    this.btn_beast.img1.visible = false;
                    this.btn_beast.aniBox.destroyChildren();
                    Tools.textFitFontSize(this.btn_beast.tName);
                }
            }
            
            if(this.btn_beast.visible && !this.btn_beast.gray){
                var arr:Array = mModel.getBeastResonanceData();
                if(arr[0] && arr[0][0] && arr[0][0] == 8){
                    this.btn_beast.img0.visible = false;
                    this.btn_beast.img1.visible = true;

                    var ani:Animation = EffectManager.loadAnimation("beast_level8");
                    EffectManager.changeSprColor(ani,arr[0][1]+1);
                    this.btn_beast.aniBox.addChild(ani);
                    ani.scaleX = 0.85;
                    ani.scaleY = 0.85;
                    ani.x = this.btn_beast.width/2;
                    ani.y = this.btn_beast.img0.y;
                    
                    var beastID:String = mModel.getBeastIds()[0];
                    var md:ModelBeast = ModelBeast.getModel(beastID);
                    this.btn_beast.img1.skin = AssetsManager.getAssetLater(md.getIcon());
                    this.btn_beast.tName.text = Tools.getMsgById('_beast_text42',[ModelBeast.getTypeName(md.type)]);
                    this.btn_beast.tName.color = ConfigColor.FONT_COLORS[arr[0][1]+1];
                    Tools.textFitFontSize(this.btn_beast.tName);
                }    
            }
        }

        private function click_hero():void{
            // ViewManager.instance.showTipsTxt(this.mModel.info);
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO_TIPS,this.mModel);
        }
        private function click_talent():void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO,this.mModel);
        }

        private function click_formation():void
        {
            if(!ModelGame.unlock(this.btn_formation,"hero_formation",true).stop){
                ViewManager.instance.showView(["ViewHeroFormation",ViewHeroFormation],this.mModel);
            }
            
        }
        private function click_beast():void
        {
            if(ModelGame.unlock(null,"beast").stop){
                return;
            }
            ViewManager.instance.showView(["ViewBeastMain",ViewBeastMain],mModel);   
        }


        private function _click_prop():void
        {
            //var str:String = StringUtil.substitute('{0}<br/>{1}<br/>{2}<br/>{3}', [
                //Tools.getMsgById('tip_str'),
                //Tools.getMsgById('tip_agi'),
                //Tools.getMsgById('tip_cha'),
                //Tools.getMsgById('tip_lead')
            //]);
            //ViewManager.instance.showTipsPanel(str, 500);
			
			ViewManager.instance.showTipsPanel(Tools.getMsgById('tip_props'), 540);
        }
        private function click_change(v:int):void{
			//切换英雄
			this.clearParticles();
            this.mLookIndex += v;
            this.checkNextOrPre();
            this.mPowerTemp = -1;
            this.changeUI(this.mHerosArr[this.mLookIndex]);
        }

        private function showHero(id:String, tabIndex:* = null):void
        {
            if (tabIndex is Number) {
                mSelectIndex = tabIndex;
            }
            var hero:ModelHero = mHerosArr.filter(function (item:ModelHero):Boolean{return item.id === id;}, this)[0];
            this.click_change(mHerosArr.indexOf(hero) - mLookIndex);
        }

        private function tab_select(index:int):void{
            this.clearFunc();
            if(index>-1){
                var obj:Object = mTabData[index];
                this.mSelectIndex = obj['index'];
                this.setChildPanel(obj['index']);
            }
        }
        private function setChildPanel(type:int):void
        {
            if(type == 0){
                this.mFuns = (new ViewHeroProperty(this.mModel)) as ItemBase;
            }
            else if(type == 1){
                this.mFuns = (new ViewHeroSkill(this.mModel)) as ItemBase;
            }
            else if(type == 2){
                this.mFuns = (new ViewHeroEquip(this.mModel)) as ItemBase;
            }
            else if(type == 3){
                this.mFuns = (new ViewHeroFate(this.mModel)) as ItemBase;
            }
            else if(type == 4){
                this.mFuns = (new ViewHeroRune(this.mModel)) as ItemBase;
            }
            else if(type == 5){
                this.mFuns = (new ViewHeroAdjutant(this.mModel)) as ItemBase;
            }
            if(this.mFuns){
                this.mFuns.init();
                this.mPanel.addChild(this.mFuns);  
            }
                      
        }
        private function checkNextOrPre():void{
            this.btn_pre.visible = false;
            this.btn_next.visible = false;
            if(this.mLookIndex>0){
                this.btn_pre.visible = true;
            }
            if(this.mLookIndex < this.mHerosArr.length-1){
                this.btn_next.visible = true;
            }
            if(this.mHerosArr.length<=1){
                this.btn_pre.visible = false;
                this.btn_next.visible = false;
            }

        }
        private function changeUI(mdHero:ModelHero):void{
            //
            this.removeUpdateEvent();
            if (mdHero) {
                this.mModel = this.currArg[0] = mdHero;
            }
            this.removeUpdateEvent(); 
            this.refreshTab();
        }
        private function checkClip():void
        {
            this.heroIcon.visible = false;
            ViewManager.instance.showViewEffect(HeroStarUpgrade.getEffect(this.mModel,this.heroIcon),0.5,Handler.create(this,this.endClip));
        }
        private function endClip():void{
            this.heroIcon.visible = true;
            // this.heroIcon.alpha = 0;
            // Tween.to(this.heroIcon,{alpha:1},400);
        }
        private function setUI(update:Boolean = false,starUp:Boolean = false):void{
            this.removeUpdateEvent();
            //
            this.mModel.on(ModelHero.EVENT_HERO_STAR_CHANGE,this,this.setUI,[true]);
            this.mModel.on(ModelHero.EVENT_HERO_EXP_CHANGE,this,this.setUI,[true]);
            this.mModel.on(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.setUI,[true]);
            this.mModel.on(ModelHero.EVENT_HERO_ARMY_LV_CHANGE,this,this.setUI,[true]);//EVENT_HERO_RUNE_CHANGE
            this.mModel.on(ModelHero.EVENT_HERO_RUNE_CHANGE,this,this.setUI,[true]);//
            this.mModel.on(ModelHero.EVENT_HERO_FATE_CHANGE,this,this.setUI,[true]);//
            this.mModel.on(ModelHero.EVENT_HERO_TITLE_CHANGE,this,this.setUI,[true]);//
            this.mModel.on(ModelHero.EVENT_HERO_FORMATION_CHANGE,this,this.setUI,[true]);//
            this.mModel.on(ModelHero.EVENT_HERO_ADJUTANT_CHANGE, this, this.setUI, [true]);
			this.mModel.on(ModelHero.EVENT_HERO_BEAST_CHANGE,this,this.setUI,[true]);//
            ModelManager.instance.modelGame.on(ModelHero.EVENT_HERO_LOOK_UP,this,this.showHero);
            //
            if(this.mCurrHeroID!=this.mModel.id){
                this.mCurrHeroID = this.mModel.id;
            }
            else{
                if(!update){
                    return;
                }
            }
            if(starUp){
                this.checkClip();
            }
            //
            var hmp:ModelPrepare = this.mModel.getPrepare(true);
            //
            this.tName.text = (ConfigApp.isTest?this.mModel.id + " ":"") + this.mModel.getName();
			this.tName.color = EffectManager.getFontColor(this.mModel.getStarGradeColor());
			
			
            var powerNew:Number = this.mModel.getPower(hmp);
            if(this.mPowerTemp!=powerNew){
                if(this.mPowerTemp >0){
                    //
                    var pdes:Number = powerNew - this.mPowerTemp;
                    var p:Point = new Point(this.comPower.x,this.comPower.y);//this.tPower.localToGlobal(new Point(0,0));
                    
                    EffectManager.textFlight(pdes + "", "", p.x + 100, p.y + 10, this.comPower.parent, (pdes > 0)? -1:1);
                }
                this.mPowerTemp = powerNew;
            }
			this.comPower.setNum(this.mPowerTemp);
            //
            this.heroType.setHeroType(this.mModel.getType(true));
            //this.heroType.x = this.tName.x + this.tName.displayWidth + 10;
            //
            this.imgRarity.skin = this.mModel.getRaritySkin();
            //
            this.heroStr.setHeroProp4(Tools.getMsgById("info_str"),this.mModel.getStr(hmp));//武力
            this.heroInt.setHeroProp4(Tools.getMsgById("info_agi"),this.mModel.getInt(hmp));//智力
            this.heroCha.setHeroProp4(Tools.getMsgById("info_cha"),this.mModel.getCha(hmp));//魅力
            this.heroLead.setHeroProp4(Tools.getMsgById("info_lead"),this.mModel.getLead(hmp));//统帅
            //
            this.checkHeroIcon(update);
			
            this.comAwaken.setAwakenIcon(this.mModel.id);
            this.comTalent.setTalentIcon(this.mModel.id);
			this.comAwaken.visible = this.mModel.getAwaken();
            //
            this.setUItitle();
            this.checkRed();
        }
        private function setUItitle():void
        {
            this.btn_title.visible = false;
            if(this.mModel.isMine()){
                //
                var titleTxt:String = this.mModel.getTitleStatus();
                var titlesB:Boolean  = ModelManager.instance.modelUser.getMyTitleCanSet(); 
                if(Tools.isNullString(titleTxt)){
                    if(titlesB){
                        this.tTitle.text = Tools.getMsgById("_title1");//可安装称号
                        this.btn_title.visible = true;
                    }
                }
                else{
                    this.tTitle.text = ModelHero.getTitleName(titleTxt);
                    this.btn_title.visible = true;
                }
            } 
            this.clipTitle.destroyChildren();
            // this.clipTitle.anchorX=0.5;
            // this.clipTitle.anchorY=0.5;
            if(this.btn_title.visible){
                // this.clipTitle.x = this.btn_title.x + this.btn_title.width*0.5;
                var glowClip:Animation = EffectManager.loadAnimation("glow014");
                glowClip.scaleX = HelpConfig.type_app == HelpConfig.TYPE_SG ? 0.8 : 1.2;
                glowClip.scaleY = HelpConfig.type_app == HelpConfig.TYPE_SG ? 0.3 : 0.5;
                this.clipTitle.addChild(glowClip);
            }           
        }
        override public function onAdded():void{
            //
            this.mFuncImg.height = this.height - this.mFunc.height;
            //
            var index:Number = this.mSelectIndex<0?0:this.mSelectIndex;
            this.click_change(0);            
        }
        override public function onRemoved():void{
			this.clearParticles();
            this.timer.clear(this,this.checkRed);
            //
            this.removeUpdateEvent();
            //
            this.clearFunc();
            this.tab.selectedIndex = -1;
            this.mCurrHeroID = "";
        }
        private function removeUpdateEvent():void{
            this.mModel.off(ModelHero.EVENT_HERO_STAR_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_EXP_CHANGE,this,this.setUI);
            this.mModel.off(ModelGame.EVENT_HERO_SKILL_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_ARMY_LV_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_RUNE_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_FATE_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_TITLE_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_FORMATION_CHANGE,this,this.setUI);
            this.mModel.off(ModelHero.EVENT_HERO_ADJUTANT_CHANGE, this, this.setUI);
			this.mModel.off(ModelHero.EVENT_HERO_BEAST_CHANGE,this,this.setUI);//
            ModelManager.instance.modelGame.off(ModelHero.EVENT_HERO_LOOK_UP,this,this.showHero);
        }
		
		private function clearParticles():void{
			if (this.mParticles){
				for (var i:int = 0,len:int = this.mParticles.length; i < len; i++) 
				{
					var part:Particle2D = this.mParticles[i];
					part.stop();
				}
			}
            this.mParticles = null;   	
		}
		
        private function clearFunc():void{
            if(this.mFuns){
                this.mFuns.clear();
                this.mFuns.destroy(true);
            }
            this.mPanel.destroyChildren();  
            this.mFuns = null;   

            //this.clearParticles();   
        }

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
            var item:* = null;
			if (this.mFuns[name])   return this.mFuns[name];
            else if (name.indexOf('tab') !== -1) {
                if (name.length === 5) {
                    item = this.tab.items[parseInt(name[name.length - 1])];
                    if (item)    return item;
                }
                else if (this.mFuns['tab']) {
                    item = this.mFuns['tab'].items[parseInt(name[name.length - 1])];
                    if (item)    return item;
                }
            }
            else if (name.indexOf('list') !== -1) {
                item = (this.mFuns['list'] as List).getCell(parseInt(name[name.length - 1]));
                if (item)    return item;
            }
            return super.getSpriteByName(name);
		}
    }
}