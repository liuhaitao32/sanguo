package sg.view.arena
{
	import ui.arena.effect_final_winnerUI;
	import sg.utils.Tools;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.utils.MusicManager;
	import laya.utils.Tween;
	import laya.utils.Ease;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class EffectArena extends effect_final_winnerUI{
		public function EffectArena(){
			this.tText.text = Tools.getMsgById('arena_text40');
			var clipAni:Animation = EffectManager.loadAnimation("glow020",'',1);
			this.addChild(clipAni);
			clipAni.x = this.box.x;
			clipAni.y = this.box.y;   
			clipAni.scaleX = 0.4;
			clipAni.scaleY = 0.3;
			MusicManager.playSoundUI(MusicManager.SOUND_POWER_UP);
			this.alpha = 0;
			
			this.scale(0.5, 0.5);
			Tween.to(this, {scaleX:1,scaleY:1,alpha:1}, 200, Ease.backOut);
			Tween.to(this, {alpha:0}, 300, Ease.sineOut, Handler.create(this, this.endClip), 1200);
		}
		private function endClip():void{
            this.destroy();
        } 

	}

}