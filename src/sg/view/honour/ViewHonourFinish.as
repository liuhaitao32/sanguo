package sg.view.honour
{
	import ui.honour.honourFinishUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourFinish extends honourFinishUI{
		public function ViewHonourFinish(){
			
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle("战绩结算");
		}

		override public function onRemoved():void{
			
		}
	}

}