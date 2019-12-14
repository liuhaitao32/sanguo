package sg.activities.view
{
	import laya.events.Event;
	import laya.utils.Handler;

	import sg.activities.model.ModelHappy;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;

	import ui.activities.carnival.ViewSpartaUI;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewSparta extends ViewSpartaUI{

		public var mData:Object;
		public var mGetDay:Number;
		public function ViewSparta(){
			this.list.itemRender=renderHappy;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.scrollBar.visible=false;
		}

		public override function onAdded():void{
			 setData();
		}

		public function setData():void{
			mData=this.currArg;
			mGetDay=Number((mData.index+"")[0]);
			//this.tTitle.text=Tools.getMsgById(mData.title);
			this.comTitle.setViewTitle(Tools.getMsgById(mData.title));
			var arr:Array=[];
			for(var i:int=0;i<mData.target.length;i++){
				var a:Array=mData.target[i];
				var obj:Object=ModelHappy.instance.userHappySparta;
				arr.push({"title":ModelHappy.instance.getTaskProById(mData.id,a[0]),
						  "reward":a[1],
						  "value":obj.hasOwnProperty(mData.id)?obj[mData.id][i+""][0]:0,
						  "max":a[0][0],
						  "isGet":obj.hasOwnProperty(mData.id)?(obj[mData.id][i+""][1]==1):false,
						  "sortIndex":i,
						  "sortGet":obj.hasOwnProperty(mData.id)?(obj[mData.id][i+""][1]==1 ? 1 : 0) : 0
						  });
			}
			arr = ArrayUtils.sortOn(["sortGet","sortIndex"],arr,false,true);
			this.list.array=arr;	 
		}

		public function listRender(cell:renderHappy,index:int):void{
			cell.setData(this.list.array[index]);
			cell.btnGet.off(Event.CLICK,this,itemClick);
			cell.btnGet.on(Event.CLICK,this,itemClick,[index]);
		}

		public function itemClick(index:int):void{
			if(mGetDay>ModelHappy.instance.openDays){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("happy_tips08",[mGetDay]));
				return;
			}
			NetSocket.instance.send("get_happy_sparta_reward",
									{"task_type":mData.id
									,"reward_index":this.list.array[index].sortIndex+""},new Handler(this,function(np:NetPackage):void{
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
			}));
		}


		public override function onRemoved():void{
			this.list.scrollBar.value=0;
		}
	}

}