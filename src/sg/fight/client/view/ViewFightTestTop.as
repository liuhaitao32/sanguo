package sg.fight.client.view 
{
	import laya.events.Event;
	import sg.fight.FightMain;
	import sg.manager.AssetsManager;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import ui.battle.fightTestTopUI;
	/**
	 * 章节选择
	 * @author zhuda
	 */
	public class ViewFightTestTop extends fightTestTopUI
	{
		public function ViewFightTestTop() 
		{
			this.onChange();
			this.btnChapter.on(Event.CLICK, this, this.onChapter);
		}

		override public function onChange(type:* = null):void{
			this.gold_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(ModelManager.instance.modelUser.gold));
		}
		
		public function onChapter():void{
			var view:ViewFightTestChapter = new ViewFightTestChapter();
			FightMain.instance.ui.popView(view);
		}
	}

}