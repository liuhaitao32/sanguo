package sg.view.hero
{
	import sg.fight.logic.utils.PassiveStrUtils;
    import ui.hero.heroFateUI;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import laya.ui.Button;
    import laya.events.Event;
    import laya.display.Node;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import laya.ui.Label;
    import laya.ui.Image;
    import laya.maths.MathUtil;
    import ui.hero.itemFateUI;
    import sg.cfg.ConfigServer;
    import sg.cfg.ConfigColor;
    import sg.utils.StringUtil;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.ui.Box;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelGame;
    import sg.utils.MusicManager;

    public class ViewHeroFate extends heroFateUI{
        private var mModel:ModelHero;
        private var mOK:Object;
        private var mHeroFid:String = "";
        private var mSelectIndex:int = -1;
        // private var mClipBox:Box;
        public function ViewHeroFate(md:ModelHero):void{
            this.mModel = md as ModelHero;
            //
            // this.mClipBox = new Box();
            // this.addChild(this.mClipBox);
            //
            btn_ok.label = Tools.getMsgById('_jia0101');
            this.btn_ok.on(Event.CLICK,this,this.click_ok);
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
        }
        override public function init():void{
            var arr:Array = [];
            for(var key:String in this.mModel.fate){
                arr.push({id:key,index:this.mModel.fate[key][0],data:this.mModel.fate[key],status:-1});
            }
            arr.sort(MathUtil.sortByKey("index"));
            //
            (this["heroName"] as Label).text = this.mModel.getName();
            //
            this.mOK = {};            
            //
            var len:int = 4;//arr.length;
            var heroArr:Array;
            var heroID:String;
            var heroIDicon:String;
            var heroModel:ModelHero;
            var heroIcon:itemFateUI;
            var heroName:Label;
            var nameBg:Image;
            var myFateArr:Array = this.mModel.getMyFate();
            //
            var obj:Object;
            var heroOK:int = -1;
            var status:int = -1;
            var heroNameStr:String = "";
            var sok:Button;
            var heroData:Array;
            var isGray:Boolean = false;
            var sp:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                (this["hj"+i] as Image).visible = false;
                heroIcon = this[ModelHero.NAEM_HEAD+i] as itemFateUI;
                heroName = this["heroName"+i] as Label;
                sok = this["sok"+i] as Button;    
                nameBg = this["namebg"+i] as Image;    
                sok.selected = false;            
                //
                obj = null;
                heroOK = -1;
                status = -1;
                //
                heroNameStr = "";
                heroModel = null;
                isGray = false;
                nameBg.visible = true;
                sp = false;
                //
                if(i<arr.length){//在宿命里面
                    obj = arr[i];
                    var fateCfg:Object = ModelHero.getFateCfg(obj.id);
					if (fateCfg)
					{
						heroArr = this.checkHeroData((obj.data as Array).concat());
						if(fateCfg["icon"]){
							heroIDicon = fateCfg.icon;
							// heroNameStr = "";
							heroOK = heroArr[2];
							sp = true;
							
						}
						else{
							heroNameStr = heroArr[1];
							heroIDicon = heroArr[0];
							heroOK = heroArr[2];
						}
						if(fateCfg["tip"] && !Tools.isNullString(fateCfg["tip"])){
							heroNameStr = Tools.getMsgById(fateCfg["tip"]);
						}
						else{
							heroNameStr = heroArr[1];
						}                    
						heroID = heroArr[0];
						this.setHJ((this["hj"+i] as Image),fateCfg.type);
						if(heroOK>0){
							if(myFateArr.indexOf(obj.id)>-1){//已经激活
								obj["status"] = status = 2;
								sok.selected = true;
							}
							else{//没有激活
								obj["status"] = status = 1;
							}
						}
						else{//没有激活,没有
							obj["status"] = status = 0;
						}
						this.mOK[i] = obj;
						heroModel = ModelManager.instance.modelGame.getModelHero(heroID);
                    }
                }
                heroName.visible = (status>-1);
                heroName.visible = (heroName.visible && !Tools.isNullString(heroNameStr));
                heroName.text = heroNameStr;//
                nameBg.visible =  heroName.visible;
                //
                this.checkHeroIcon(heroIcon,heroIDicon,status);
                //
                heroIcon.off(Event.CLICK,this,this.click);
                heroIcon.on(Event.CLICK,this,this.click,[i,obj]);
                //
                if(heroModel){
                    if(!heroModel.isMine()){
                        isGray = true;
                    }
                }
                else{
                    isGray = true;
                }
                //
                this["b"+i].gray = isGray;
                this["sok"+i].gray = isGray;
                this["hero"+i].heroIcon.gray = isGray;
                ModelGame.redCheckOnce(this["hero"+i],!this["sok"+i].selected && !isGray && this.mModel.isMine());
            }
            var initIndex:int = (this.mSelectIndex>-1)?this.mSelectIndex:0;
            //
            this.click(initIndex,arr[initIndex]);
            //
            this.heroMine.heroIcon.setHeroIcon(this.mModel.id);
            this.heroMine.imgSelect.visible = false;
        }
        private function checkHeroData(heroArr:Array):Array
        {
            var heroID:String="";
            var heroModel:ModelHero;
            var heroNameStr:String="";
            var heroOK:int = 0;
            for(var j:int = 1;j<heroArr.length;j++){
                
                heroID = heroArr[j];
                if(heroID.indexOf("hero")<0){
                    continue;
                }
                heroModel = ModelManager.instance.modelGame.getModelHero(heroID);
                heroNameStr+=heroModel.getName()+",";
                if(heroModel.isMine()){
                    heroOK+=1;
                    break;
                }
            }
            heroNameStr = heroNameStr.substring(0,heroNameStr.length-1);  
            return [heroID,heroNameStr,heroOK];          
        }
        private function checkHeroIcon(heroIcon:itemFateUI,heroID:String,status:int):void{   
            if(status>-1){
                heroIcon.visible = true;
                heroIcon.heroIcon.setHeroIcon(heroID);
            }
            else{
                heroIcon.heroIcon.setHeroIcon("hero000");
                // heroIcon.visible = false;
            }
        }
        override public function clear():void{
            this.timer.clear(this,this.init);
            this.mClipBox.destroy(true);
            this.mSelectIndex = -1;
            this.destroy(true);
        }
        private function click_ok():void{
            if(!Tools.isNullString(this.mHeroFid)){
                //
                var mfid:String = this.mHeroFid;
                if(this.mClipBox.numChildren>0){
                    this.mClipBox.destroyChildren();
                    this.init();
                }
                this.btn_ok.visible = false;
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_FATE,{hid:this.mModel.id,fate_id:mfid},Handler.create(this,this.ws_sr_hero_fate));
            }
        }
        private function ws_sr_hero_fate(re:NetPackage):void{
            MusicManager.playSoundUI(MusicManager.SOUND_UNLOCK_FATE);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            this.mClipBox.destroyChildren();
            var glowClip:Animation = EffectManager.loadAnimation("glow029","",1);
            // glowClip.on(Event.COMPLETE,this,function():void{
            //     this.init();
            // })
            this.timer.clear(this,this.init);
            this.timer.frameOnce(60,this,this.init);
            var vx:Number = 0;
            var vy:Number = 0;
            switch(this.mSelectIndex)
            {
                case 0:
                    vx = -5;
                    vy = 5;
                    break;
                case 1:
                    vx = 5;
                    vy = 5;
                    break; 
                case 2:
                    vx = 5;
                    vy = -5;
                    break; 
                case 3:
                    vx = -5;
                    vy = -5;
                    break;                                                  
                default:
                    break;
            }
            glowClip.x = this["sok"+this.mSelectIndex].x+vx;
            glowClip.y = this["sok"+this.mSelectIndex].y+vy;
            glowClip.rotation = this["sok"+this.mSelectIndex].rotation;
            glowClip.scaleX = this["sok"+this.mSelectIndex].scaleX;
            glowClip.scaleY = this["sok"+this.mSelectIndex].scaleY;
            this.mClipBox.addChild(glowClip);
            ModelGame.redCheckOnce(this["hero"+this.mSelectIndex],false);
            //
            this.mModel.event(ModelHero.EVENT_HERO_FATE_CHANGE);
        }
        private function click(index:int,obj:Object):void{
            this.mSelectIndex = index;
            if(obj){//此处有宿命
                this.mHeroFid = obj.id;
            }
            //
            var heroIcon:itemFateUI;
            for(var i:int = 0; i < 4; i++)
            {
                heroIcon = this[ModelHero.NAEM_HEAD+i] as itemFateUI;
                heroIcon.imgSelect.visible = (i==index)?true:false;
                // (this["hj"+i] as Image).visible = false;
            }            
            this.status_ok.visible = false;
            this.status_no.visible = false;
            //
            var b:Boolean = false;
            var type:int = -1;
            var fData:Object;
            var fateCfg:Object;
            //
            this.tStatus.color = ConfigColor.FONT_COLORS[0];
            this.tStatusType.color = ConfigColor.FONT_COLORS[0];
            this.tGet.visible = false;
            this.btn_ok.visible = true;
            this.tGet.style.fontSize = 14;
            this.tGet.style.color = "#ffffff";            
            //
            if(this.mOK.hasOwnProperty(index)){
                fData = this.mOK[index];
                fateCfg =  ModelHero.getFateCfg(fData.id);
                type = fData.status;
                this.tStatus.text = Tools.getMsgById(fateCfg.name);
                this.tStatusType.text = ModelHero.fate_type_name[fateCfg.type];
                //
                this.tStatus.color = ConfigColor.FONT_COLORS[fateCfg.quality];
                this.tStatusType.color = ConfigColor.FONT_COLORS[fateCfg.quality];               
                //
                if(type == 1){
                    b = true;
                }
                else if(type == 2){
                    this.status_ok.visible = true;
                    this.btn_ok.visible = false;
                }
                else if(type == 0){
                    // this.tStatus.text = "暂未拥有";
                    this.tGet.visible = true;
                    var hnstr:String = ""
                    if(fateCfg["call"]){
                        hnstr = Tools.getMsgById(fateCfg["call"]);
                    }
                    else{
                        var heroArr:Array = this.checkHeroData((obj.data as Array).concat());
                        hnstr = heroArr[1];
                    }
					this.tGet.style.fontSize = 18;
                    this.tGet.innerHTML = Tools.getMsgById("_office1",[hnstr]);//招募{}可激活
                }

            }
            else{
                this.tStatus.text = Tools.getMsgById("_skill1");//神秘技能
                this.tStatusType.text = "";
                this.btn_ok.visible = false;
                this.status_no.visible = true;
            }
			
			this.tInfo.style.fontSize = 18;
			this.tInfo.style.leading = 6;
			var infoStr:String = '';
			
            if(type>-1){
                this.setHJ((this["hj" + index] as Image),fateCfg.type);
				var passiveObj:* = fateCfg.passive;
				if (passiveObj){
					infoStr = Tools.getMsgById('fate_unlock') + PassiveStrUtils.translatePassiveInfo(passiveObj, false, false, 1);
				}
            }
			this.tInfo.innerHTML = StringUtil.substituteWithColor(infoStr, '#FCAA44', '#ffffff');
            this.btn_ok.disabled = !b;
            //
            if(!this.mModel.isMine()){
                this.btn_ok.disabled = true;
            }
        }
        private function setHJ(img:Image, type:Number):void
        {
            img.visible = (type==3 || type==0);
            img.skin = AssetsManager.getAssetsUI((type==0)?"icon_heji.png":"icon_heji_1.png");
        }
    }
}