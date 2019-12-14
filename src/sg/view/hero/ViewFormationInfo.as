package sg.view.hero
{
	import ui.hero.formationInfoUI;
	import sg.model.ModelFormation;
	import sg.model.ModelHero;
	import ui.hero.formationItem2UI;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import laya.ui.Image;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewFormationInfo extends formationInfoUI{

		private var mHmodel:ModelHero;
		public function ViewFormationInfo(){
			this.cTitle.setViewTitle(Tools.getMsgById("_hero_formation21"));
			this.tText.text=Tools.getMsgById("_hero_formation22");
			
		}

		override public function onAdded():void{
			mHmodel=this.currArg;
			for(var i:int=1;i<=6;i++){
				var com:formationItem2UI=this["com"+i];
				var m:ModelFormation=ModelFormation.getModel(i);
				com.imgIcon.skin=AssetsManager.getAssetsICON("formation"+i+".png");
				com.tName.text=m.getName();
				EffectManager.changeSprColor(com.imgBg,m.curStar(mHmodel),true);
				(this["img"+i] as Image).visible=(mHmodel.cfg.arr.indexOf(i)!=-1) && m.curStar(mHmodel)>=4;
				com.gray=(mHmodel.cfg.arr.indexOf(i)==-1);
			}
		}


		override public function onRemoved():void{
			
		}
	}

}