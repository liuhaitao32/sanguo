package sg.view.effect
{
    import ui.com.effect_pk_rank_changeUI;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import laya.utils.Tween;
    import laya.utils.Handler;
    import laya.utils.Ease;
    import sg.manager.LoadeManager;
    import sg.utils.StringUtil;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import laya.maths.Point;

    public class PKRankChange extends effect_pk_rank_changeUI
    {
        private var mGift_dict:Object
        public function PKRankChange(pa:Array)
        {
            this.text0.text=Tools.getMsgById("_pk02");
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("icon_war007.png"));
            //
            this.off(Event.REMOVED,this,this.onRemoveSelf);
            this.on(Event.REMOVED,this,this.onRemoveSelf);
            //
            var oldRank:Number = pa[0];
            var newRank:Number = pa[1];
            var re:Object = pa[2];
            var gift_dict:Object = re.gift_dict;
            var pk_result:Object = re.pk_result;
            //
            var isUP:Boolean = oldRank>newRank;
            this.tPre.text = oldRank+"";
            this.tNext.text = newRank+"";
            this.tTitle.skin = AssetsManager.getAssetLater(isUP?"img_name01.png":"img_name12.png");
            //
            this.box_award.visible = false;
            if(gift_dict.hasOwnProperty("coin")){
                this.box_award.visible = true;
                this.tAward.text = gift_dict["coin"];
            }
            this.mGift_dict = gift_dict;
            //
            var records:Array = pk_result.records;
            var len:int = records.length;
            var troop:Array;
            var hpNum:Number = 0;
            var hpmNum:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                troop = records[i].troop;
                for(var j:int = 0; j < troop.length; j++)
                {
                    if(!Tools.isNullObj(troop[1])){
                        hpNum+=troop[1].hp;
                        hpmNum+=troop[1].hpm;
                    }
                    
                }
                
            }
            var ra:Number = 1-(hpNum/hpmNum);
            this.tArmy.text = Tools.getMsgById("_effect4",[StringUtil.numberToPercent(ra)]);//"击杀兵力: "+ra+"%";
            //
            this.tTitle.scaleX=0;
            this.tBg.scaleX=0;
            this.box.visible = false;
            //
            Tween.to(this.tTitle,{scaleX:1},200,Ease.bounceOut,Handler.create(this,this.showBox),200);
            Tween.to(this.tBg,{scaleX:1},200,Ease.bounceOut);
            if(isUP){
                this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
            }
        }
        private function onRemoveSelf():void
        {
            this.off(Event.REMOVED,this,this.onRemoveSelf);
            if(this.mGift_dict){
                var pp:Point = this.box_award.localToGlobal(new Point(0,0));
                ViewManager.instance.showIcon(this.mGift_dict,pp.x,pp.y);
            }
        }
        private function showBox():void
        {
            this.box.visible = true;
            this.box.scaleX = 0.5;
            Tween.to(this.box,{scaleX:1},200,Ease.bounceOut);
            this.timer.once(4000,this,this.endClip);
        }
        private function endClip():void
        {
            (this.parent as EffectUIBase).onRemovedBase();
        }        
        public static function getEffect(pa:Array):PKRankChange{
            var eff:PKRankChange = new PKRankChange(pa);
            return eff;//
        }        
    }
}