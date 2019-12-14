package sg.view.effect
{
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
    import ui.com.effect_power_userUI;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import laya.display.Animation;
    import sg.manager.EffectManager;
    import laya.events.Event;
    import sg.utils.Tools;
    import sg.utils.MusicManager;

    public class UserPowerChange extends effect_power_userUI
    {
        private var mNum:Number;
        public function UserPowerChange(num:Number)
        {
            this.mNum = num;
            // trace(num);
            //最强战力
            this.tPower.text = Tools.getMsgById("_public110")+((num>0)?("+"+num):(""+num));
            //
			var time:int = 1200;
			if(num >0){
				var clipAni:Animation = EffectManager.loadAnimation("glow020",'',1);
				this.addChild(clipAni);
				clipAni.x = this.box.x;
				clipAni.y = this.box.y;   
				time += 500;
                MusicManager.playSoundUI(MusicManager.SOUND_POWER_UP);
			}
            //
            this.box.gray = (num<0);
            //
			this.alpha = 0;
			this.scale(0.5, 0.5);
			Tween.to(this, {scaleX:1,scaleY:1,alpha:1}, 200, Ease.backOut);
			Tween.to(this, {alpha:0}, 300, Ease.sineOut, Handler.create(this, this.endClip), time);
            //this.timer.once(3000,this,this.endClip);
            //
            ModelManager.instance.modelUser.myPowerChangeNum = 0;
            //
            ModelManager.instance.modelGame.event(ModelUser.EVENT_USER_UPDATE);
        }
        private function endClip():void
        {
            (this.parent as EffectUIBase).onRemovedBase();
        }        
        public static function getEffect(num:Number):UserPowerChange{
            var eff:UserPowerChange = new UserPowerChange(num);
            return eff;//
        }        
    }
}