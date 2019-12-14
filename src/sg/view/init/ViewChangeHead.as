package sg.view.init
{
	import sg.utils.Tools;
	import ui.init.changeHeadUI;
	import ui.com.hero_icon1UI;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import laya.events.Event;
	import laya.ui.Image;
	import sg.net.NetPackage;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewChangeHead extends changeHeadUI{

		public var listData:Array=[];
		public var curHeroId:String="";
		public function ViewChangeHead(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=hero_icon1UI;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,listOnSelect);
			this.btn.on(Event.CLICK, this, okClick);
			this.btn.label = Tools.getMsgById("_public183");
			//this.title.text = Tools.getMsgById("_public213");
			this.comTitle.setViewTitle(Tools.getMsgById("_public213"));
		}

		override public function onAdded():void{
			curHeroId="";
			setData();
		}

		public function setData():void{
			listData=ModelManager.instance.modelUser.getMyHeroArr(true,"",null,false);
			this.list.array=listData;
			this.list.selectedIndex=-1;
		}

		public function listRender(cell:hero_icon1UI,index:int):void{
			var o:ModelHero=listData[index];
			cell.name="hero_icon";
			cell.setHeroIcon(o.getHeadId());
			cell.setHeroSelection(index==this.list.selectedIndex);
			cell.off(Event.CLICK,this,this.itemClick,[index]);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function listOnSelect(index:int):void{
			if(index>=0){
                //this.setSelection(true);
            }
		}

		public function itemClick(index:int):void{
			if(index==this.list.selectedIndex)
				return;
			this.setSelection(false);
			this.list.selectedIndex=index;
			curHeroId=this.list.array[index].id;
		}

		public function okClick():void{
			if(curHeroId=="")
				return;
			
			NetSocket.instance.send("change_head",{"head_id":curHeroId},Handler.create(this,socektCallBack));
		}

		public function socektCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_INFO_UPDATE);
			//ViewManager.instance.closePanel();
			this.closeSelf();
		}

		public function setSelection(b:Boolean):void{
			//if(this.list.selection){
			//	var item:hero_icon1UI=this.list.selection as hero_icon1UI;
			//	item.setHeroSelection(b);
			//}
		}

		override public function onRemoved():void{
			this.setSelection(false);
		}

	}

}