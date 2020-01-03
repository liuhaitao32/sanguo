package sg.view.honour
{
	import ui.honour.honourRankUI;
	import ui.honour.itemHonourRankUI;
	import sg.model.ModelUser;
	import sg.manager.ModelManager;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.model.ModelHonour;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewHonourRank extends honourRankUI{

		private var mData:Array;
		public function ViewHonourRank(){
			this.list.scrollBar.visible = false;
			this.list.renderHandler = new Handler(this,listRender);
			this.text0.text = Tools.getMsgById('_public214');
			this.text1.text = Tools.getMsgById('_more_rank07');
			this.text2.text = '战绩总等级';
		}

		override public function onAdded():void{
			this.comTitle.setViewTitle("战绩排名");
			
			if(this.currArg == null) return;
			mData = this.currArg;

			var arr:Array = [];
			if(mData[0].length > ModelHonour.instance.rankNum){
				for(var i:int=0;i<ModelHonour.instance.rankNum;i++){
					if(mData[0][i]) arr.push(mData[0][i]);
					else break;
				}
			}else{
				arr = mData[0];
			}
			this.list.array = arr;

			var myData:Object = mData[1];
			this.myCom.cRank.setRankIndex(mData.rank > ModelHonour.instance.rankNum ? 0 : mData.rank,Tools.getMsgById("_public101")); 
			this.myCom.cHead.setHeroIcon(ModelUser.getUserHead(myData.head));
			this.myCom.tName.text = myData.uname;
			this.myCom.tLv.text = myData.total_lv + '';
		}

		private function listRender(cell:itemHonourRankUI,index:int):void{
			var obj:Object = this.list.array[index];
			cell.cRank.setRankIndex(obj.rank);
			cell.cHead.setHeroIcon(ModelUser.getUserHead(obj.head));
			cell.tName.text = obj.uname;
			cell.tLv.text = obj.total_lv + '';

			cell.off(Event.CLICK,this,itemClick);
			cell.on(Event.CLICK,this,itemClick,[obj.id]);
		}

		private function itemClick(id:*):void {
			if(id)
            	ModelManager.instance.modelUser.selectUserInfo(id);
        }

		override public function onRemoved():void{
			
		}
	}

}