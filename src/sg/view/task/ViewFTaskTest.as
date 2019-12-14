package sg.view.task
{
	
import sg.utils.Tools

	import ui.task.ftask_tastUI;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.ui.Label;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.model.ModelGame;
	import sg.model.ModelOfficial;

	/**
	 * ...
	 * @author
	 */
	public class ViewFTaskTest extends ftask_tastUI{

		private var user_ftask:Object={};
		private var list_data:Array=[];
		public function ViewFTaskTest(){
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			//ModelManager.instance.modelUser.on(ModelUser.EVENT_FTASK_UPDATE,this,function():void{
			//	trace("刷新 ftask_test");
			//	setData();
			//});
		}


		public override function onAdded():void{
			setData();
		}

		public function setData():void{
			list_data=[];
			user_ftask=ModelManager.instance.modelUser.ftask;
			for(var s:String in user_ftask){
				var o:Object={};
				var a:Array=user_ftask[s];
				o["id"]=s;
				o["index"]=a[0];
				o["is_get"]=a[1];
				o["is_done"]=a[2];
				list_data.push(o);
			}
			this.list.array=list_data;
			//trace("====================",list_data);
		}

		public function listRender(cell:Box,index:int):void{
			var label:Label=cell.getChildByName("label") as Label;
			var o:Object=this.list.array[index];
			label.text=ModelOfficial.getCityName(o.id)+ " cid:"+o.id+" ,索引:"+o.index+" ,接取:"+o.is_get+" ,完成度:"+o.is_done;

			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function itemClick(index:int):void{
			if(this.list.array[index].index==-1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewFTaskTest_0"));
				return;
			}
			ModelGame.clickFtask(this.list.array[index].id);
			//ViewManager.instance.showView(["ViewFTaskMain",ViewFTaskMain],this.list.array[index].id);
		}


		public override function onRemoved():void{

		}
	}

}