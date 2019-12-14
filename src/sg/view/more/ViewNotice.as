package sg.view.more
{
    import sg.view.com.ItemBase;
    import ui.more.item_noticeUI;
    import laya.utils.Tween;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import sg.model.ModelHero;
    import sg.model.ModelOfficial;
    import sg.map.model.MapModel;
    import sg.map.model.entitys.EntityCity;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.manager.ViewManager;
    import sg.map.view.MapViewMain;
    import sg.fight.FightMain;

    public class ViewNotice extends ItemBase
    {
        private var mTempArr:Array = [];
        public var upNumMax:Number = 2;
        private var mAddData:Object;
        private var mDelData:Object;
        private var mWaitArr:Array;
        private var clipIng:Boolean = false;
        public var mDelAllTime:Number = 3;
        public function ViewNotice()
        {
            this.mTempArr = [];
            this.mWaitArr = [];
            this.mouseThrough = true;
            
        }
        public function input(info:*):void{
            var isFight:Boolean = ViewManager.instance.mLayerFight.numChildren>0;
            if(isFight){
                var fb:String = FightMain.getCurrCityId();
                var rcid:String = info.cid+"";
                if(fb && fb == rcid && info.status==1){
                    return;
                }
            }
            var data:Object = {};
            data["id"] = new Date().getTime();
            data["info"] = info;
            data["status"] = 0;
            var item:item_noticeUI = data["ui"] = new item_noticeUI;
            var hn:String = ModelHero.getHeroName(info.hid);
            var cn:String = ModelOfficial.getCityName(info.cid);
            item.tName.text = (info.status==0)?Tools.getMsgById("_npc_info12"):Tools.getMsgById("_npc_info13");//"部队到达":"国战中";
            item.tInfo.text = (info.status==0)?Tools.getMsgById("_npc_info14",[hn,cn]):Tools.getMsgById("_npc_info15",[hn,cn]);//hn+"部队已经到达"+cn:hn+"部队正在"+cn+"战斗";
            //
            item.boxFight.visible = info.status ==1;
            item.boxMove.visible = info.status ==0;
            //
            if(info.status==0){
                var ec:EntityCity = MapModel.instance.citys[info.cid];
                EffectManager.fillCityAnimation(ec, item.cityIcon,2);
            }
            else{
                item.heroIcon.setHeroIcon(info.hid);
            }
            item.btn_go.label = Tools.getMsgById("501030");
            if(!isFight){
                item.btn_go.off(Event.CLICK,this,this.click);
                item.btn_go.on(Event.CLICK,this,this.click,[info.cid,item,info.status]);
            }else{
                //item.mouseEnabled = false;
                //item.mouseThrough = true;
            }
            item.mouseEnabled = true;
            item.mouseThrough = true;
            //item.boxFight.visible=item.boxMove.visible=false;
            this.mTempArr.push(data);
            this.check();
        }
        private function click(cid:*,item:item_noticeUI,status:Number):void
        {
            item.mouseEnabled = false;
            item.mouseThrough = true;
            if(ViewManager.instance.mLayerFight.numChildren<1){
                GotoManager.boundFor({type:1,cityID:cid});
                if(status == 1){
                    MapViewMain.instance.sendNetToInFight(MapModel.instance.citys[cid+""]);
                }                
            }
        }
        private function check():void{
            this.timer.clear(this,this.delAll);
            if(this.mTempArr.length>0 && !this.clipIng){
                this.clipIng = true;
                this.addClip(this.mTempArr.shift());
            }
            else{
                this.timer.once(mDelAllTime*Tools.oneMillis,this,this.delAll);
            }
        }
        private function delAll():void{
            var data:Object;
            var arr:Array = this.mWaitArr.concat();
            this.mWaitArr = [];
            var len:Number = arr.length;
            for(var i:int = 0; i < len; i++)
            {
                data = arr[i];
                Tween.to(data.ui,{alpha:0},100,null,Handler.create(this,this.delAllEnd,[data]));                
            }            
        }
        private function delAllEnd(data:Object):void{
            if(data && data.ui){
                data.ui.destroy(true);
            }
        }
        private function addClip(data:Object):void
        {
            this.mWaitArr.push(data);
            this.mAddData = data;
            this.mAddData.status = 1;
            this.addChild(this.mAddData.ui);
            this.mAddData.ui.y = Laya.stage.height - 300;
            this.mAddData.ui.x = Laya.stage.width;
            Tween.to(this.mAddData.ui,{x:Laya.stage.width - 380},200,null,Handler.create(this,this.waitClip));
        }
        private function waitClip(clear:Boolean = false):void
        {
            this.mAddData = null;
            if(this.mWaitArr.length >this.upNumMax){
                this.delClip(this.mWaitArr.shift())
            }
            var data:Object;
            var len:Number = this.mWaitArr.length;
            for(var i:int = 0; i < len; i++)
            {
                data = this.mWaitArr[i];
                Tween.to(data.ui,{y:data.ui.y-100},200,null,(i==(len-1))?Handler.create(this,this.delEnd):null);
            }
        }
        private function delClip(data:Object):void
        {
            this.mDelData = data;
            this.mDelData.status = 2;
            Tween.to(this.mDelData.ui,{y:this.mDelData.ui.y-100,alpha:0},190);
        }
        private function delEnd():void
        {
            if(this.mDelData && this.mDelData.ui){
                this.mDelData.ui.destroy(true);
            }
            this.mDelData = null;
            this.clipIng = false;
            this.check();
        }
    }
}