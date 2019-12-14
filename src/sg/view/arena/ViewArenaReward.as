package sg.view.arena
{
	import ui.arena.arenaRewardUI;
	import sg.manager.ViewManager;
	import ui.bag.bagItemUI;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.utils.MusicManager;
	import sg.manager.ModelManager;
	import sg.model.ModelArena;

	/**
	 * ...
	 * @author
	 */
	public class ViewArenaReward extends  arenaRewardUI{

		private var mData:Object;
		private var mGift:Object;
		private var mAct:Number;
		public function ViewArenaReward(){
			this.list.scrollBar.visible=false;
			this.list.mouseEnabled=true;
			this.list.itemRender=bagItemUI;
			this.list.renderHandler = new Handler(this, updateItem);
			this.text.text = Tools.getMsgById("_public114");
		}

		override public function onAdded():void{
			ModelArena.instance.on(ModelArena.EVENT_CLOSE_REWARD,this,closeSelf);
			MusicManager.playSoundUI(MusicManager.SOUND_GET_REWARD);
			mData = this.currArg;
			mGift = mData.gift_dict;
			mAct = mData.act;
			this.tText.text = Tools.getMsgById("arena_text3"+(3+mAct));
			this.list.array = ModelManager.instance.modelProp.getRewardProp(mGift,true);	
			this.list.repeatX = this.list.array.length;
			this.list.centerX = 0;
		}

		public function updateItem(cell:bagItemUI,index:int):void{
			cell.visible=true;
			var data:Array=this.list.array[index];
			cell.setData(data[0],data[1]);
		}


		override public function onRemoved():void{
			ModelArena.instance.off(ModelArena.EVENT_CLOSE_REWARD,this,closeSelf);
			ViewManager.instance.showIcon(mGift, this.width/2, this.height/2, false, '', true);
		}
	}
	

}