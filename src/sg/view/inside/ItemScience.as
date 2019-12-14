package sg.view.inside
{
    import ui.inside.item_scienceUI;
    import sg.model.ModelScience;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelBuiding;
    import sg.manager.EffectManager;
    import sg.manager.AssetsManager;
    import laya.display.Sprite;
    import laya.filters.ColorFilter;
    import sg.cfg.ConfigColor;
    import laya.ui.UIUtils;
    import laya.display.Graphics;
    import laya.webgl.shapes.Line;
    import sg.utils.StringUtil;
    import laya.events.Event;
    import laya.display.Animation;

    public class ItemScience extends item_scienceUI
    {
        public static var mArrTable:Object;
        public static var mDic:Object;
        private var mXY:String;
        public var mModel:ModelScience;
        private var mModelUpgrade:ModelScience;
        public var isUp:Boolean = false;
        public var mStatus:Number = 0;
        private var mClip:Animation;
        public function ItemScience()
        {
            
        }
        public function initData(xy:String,smdUp:ModelScience):void{
            this.mModelUpgrade = smdUp;
            this.mXY = xy;
            //
            var had:Boolean = this.isHad(this.mXY);
            //
            this.mModel = had?ModelManager.instance.modelGame.getModelScience(mArrTable[this.mXY]):null;
            this.mHave.visible = had;
            this.tXY.text = "";//had?this.mModel.id:"";
            //
            this.timer.clearAll(this);
            //
            this.hideLines();
            //
            this.checkStatus();
            //
            this.mHave.x = 12;
            this.mLine.x = 0;
            this.ll3.x = 62;
            this.ll9.x = 62;
            if(had){
                if(this.mModel){
                    if(!Tools.isNullObj(this.mModel.deviation)){
                        this.mHave.x = 12+124*this.mModel.deviation[0];
                        // this.mLine.x = 0+124*this.mModel.deviation[0];
                        if(this.ll3.visible){
                            this.ll3.x = this.mHave.x + 100*0.5;
                        }
                        if(this.ll9.visible){
                            this.ll9.x = this.mHave.x + 100*0.5;
                        }                        
                    }
                }
            }

        }
        private function checkStatus():void{
            this.mStatus = 0;
            this.isUp = false;
            if(this.mModelUpgrade && this.mModel){
                if(this.mModelUpgrade.id == this.mModel.id){//当前升级的
                    this.isUp = true;//升级中
                }
            }
            var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuilding003();// 军府
            //
            this.lock.visible = false;
            this.icon.setScienceUI(null);
            this.gray = false;
            this.icon.gray = false;
            this.tLv.style.fontSize = 14;
            this.tLv.style.align = "center";
            this.boxTime.visible = false;
            this.tLv.text = "";
            this.tLv.innerHTML = "";
            this.checkClip(true);
            this.boxEffect.destroyChildren();
            if(this.mModel){
                this.mStatus = 1;
                var limitOK:Boolean = (bmd.lv>=this.mModel.limit);
                var lock1:Boolean = this.mModel.checkLock1();
                var lock2:Array = this.mModel.checkLock2();
                this.tName.text = this.mModel.getName(true);
				Tools.textFitFontSize(this.tName);
				this.tName.stroke = 2;
				//按类别描边文字
				if (this.mModel.isPassive()){
					this.tName.strokeColor = '#CC4400';
				}
				else if (this.mModel.isInterior()){
					this.tName.strokeColor = '#111111';
				}
				else{
					this.tName.strokeColor = '#0066CC';
				}
				
                this.icon.setScienceUI(this.mModel,limitOK);
                //
                var clv:Number = this.mModel.getLv();
                var max:Number = this.mModel.max_level;
                var str:String = ""+clv+" / "+max+"";
                if(!limitOK){//未开启
                    str = clv+" / "+max;
                    this.tLv.style.color = "#999999";
                    this.tName.color = "#999999";
                    this.icon.gray = true;
                    this.mStatus = this.mModel.limit*-1;
                    this.tLv.innerHTML = str;
                }
                else{
                    if(!lock2[0]){//!lock1 || 
                        this.lock.visible = true;
                    }
                    this.tName.color = "#ffffff";
                    
                    if(clv>=max){
                        this.tLv.style.color = "#afff68";
                        str = clv+" / "+max;
                    }
                    else{
                        this.tLv.style.color = "#ffffff";
                        str = clv+" / <Font color='#fed063'>"+max+"</Font>";
                    }
                    this.tLv.innerHTML = str;
                    // if(this.lock.visible){
                    //     return;
                    // }
                    if(this.mModel.isUpgradeIng()>0){
                        this.checkUpgradeIng();
                        if(this.mModel.getLastCDtimer()>0){
                            this.timer.loop(1000,this,this.onTimer);
                        }
                    }
                    else{
                        if(!Tools.isNullObj(this.mModel.effect)){
                            this.checkClip(false);
                        }
                        if(lock2[0] && clv<max && !ModelScience.getCDingModel()){
                            
                            var upClip:Animation = EffectManager.loadAnimation("glow014");
                            upClip.x = 50;
                            upClip.y = 50;
                            this.boxEffect.addChild(upClip);
                        }
                    }
                }
            }
        }
        private function checkClip(clear:Boolean):void
        {
            if(this.mClip){               
                if(this.mClip.name.indexOf(this.mStatus+"")>-1 && !clear){

                }
                else{
                    this.mClip.destroy(true);
                    this.boxClip.destroyChildren();
                    this.mClip = null;
                }
            }
            if(clear){
                return;
            }            
            if(!this.mClip){    
                var scaleXY:Number = 1;           
                if(this.mStatus==3){
                    this.mClip = EffectManager.loadAnimation("glow034");
                    this.mHave.setChildIndex(this.boxClip,0);
                }
                else if(this.mStatus==4){
                    this.mClip = EffectManager.loadAnimation("glow000");
                    scaleXY = 0.8;
                    this.mHave.setChildIndex(this.boxClip,this.mHave.numChildren-1);
                }
                else{
                    this.mClip = EffectManager.loadAnimation(this.mModel.effect);
                    scaleXY = 1.5;
                    this.mHave.setChildIndex(this.boxClip,0);
                }
                this.mClip.name = "eff_"+this.mStatus;
                this.mClip.scale(scaleXY,scaleXY);
                this.mClip.x = 50;
                this.mClip.y = 50;
                //
                this.boxClip.addChild(this.mClip);
            }
        }
        private function checkUpgradeIng():void
        {
            if(this.mModel.isUpgradeIng()>0){
                var cd:Number = this.mModel.getLastCDtimer();
                if(cd>0){
                    //倒计时
                    this.mStatus = 3;
                    this.boxTime.visible = true;
                    this.tTime.text = this.mModel.getLastCDtimerStyle(3);
                }
                else{
                    this.timer.clearAll(this);
                    //准备收获
                    this.mStatus = 4;
                }
                this.checkClip(false);
            }     
            else{
                this.boxTime.visible = false;
            }       
        }
        private function onTimer():void
        {
            this.checkUpgradeIng();
        }
        public function isHad(xy:String):Boolean{
            return mArrTable.hasOwnProperty(xy);
        }
        public function getMeClip():void{
            this.checkClip(true);
            this.mClip = EffectManager.loadAnimation("glow040","",2);
            this.mClip.name = "eff_xx";
            // this.mClip.scale(scaleXY,scaleXY);
            this.mClip.x = 50;
            this.mClip.y = 50;
            this.mHave.setChildIndex(this.boxClip,this.mHave.numChildren-1);
            //
            this.boxClip.addChild(this.mClip);            
        }
        private function hideLines():void{
            var dic:Object = {};
            if(mDic.hasOwnProperty(this.mXY)){
                dic = mDic[this.mXY];
            }            
            for(var i:int=1;i<=12;i++){
                if(dic.hasOwnProperty("l"+i)){
                    this["ll"+i].visible = true;
                    this["ll"+i].gray = dic["l"+i]<1;
                }
                else{
                    this["ll"+i].visible = false;
                    this["ll"+i].alpha = 1;
                }
            }
        }
        public function clearAll():void
        {
            this.timer.clearAll(this);
            this.offAll(Event.CLICK);
        }
    }
}