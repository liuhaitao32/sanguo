package sg.view.effect
{
	import sg.model.ModelEquip;
	import ui.com.effect_equip_enhanceUI;
	import laya.utils.Tween;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class equipEnhance extends effect_equip_enhanceUI{
		private var mTween:Tween;
		public function equipEnhance(emd:ModelEquip){
			
            if(emd){
                //this.mIcon.setIcon(ModelEquip.getIcon(emd.id));
                //this.mIcon.setName(emd.getName());
                this.tText.text =Tools.getMsgById("_enhance10",[emd.getName()]);
                this.comEquip.setData(emd.id,-1,-1);
            }
            //
            this.test_clip_effict_panel(this.tTitle.x,this.tTitle.y);
        }
        public static function getEffect(emd:ModelEquip):equipEnhance{
            var eff:equipEnhance = new equipEnhance(emd);
            return eff;
        }
	}

}