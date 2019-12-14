package sg.view.mail
{
	import ui.mail.mailContentUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.events.Event;
	import ui.bag.bagItemUI;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelUser;
	import sg.model.ModelItem;
	import sg.view.hero.ViewAwakenHero;

	/**
	 * ...
	 * @author
	 */
	public class ViewMailContent extends mailContentUI{

		public var mData:Object={};
		public function ViewMailContent(){
			this.list.scrollBar.visible=false;
			//this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,listRender);
			this.getBtn.on(Event.CLICK,this,this.getClick);
			this.pan.vScrollBar.visible=false;
			this.getBtn.label = Tools.getMsgById("_jia0035");
		}

		override public function onAdded():void{
			this.pan.vScrollBar.value=0;
			getBtn.gray=false;
			getBtn.mouseEnabled=true;
			mData=this.currArg;
			//this.titleLabel.text=mData["title"];
			this.comTitle.setViewTitle(mData["title"]);
			this.textLabel.text=mData["info"];
			this.timeLabel.text=Tools.dateFormat(mData["time"]);
			if(!mData.gift || Tools.getDictLength(mData.gift)==0){
				this.getBtn.visible=this.list.visible=false;
				this.imgBg1.height = 478;
				this.imgBg2.visible = false;
				getClick();
			}else{
				this.imgBg1.height = 348;
				this.imgBg2.visible = true;

				var a:Array=ModelManager.instance.modelProp.getRewardProp(mData.gift);
				this.list.array=a;
				this.getBtn.visible=this.list.visible=true;
				this.getBtn.gray=mData.isOpen;
				
			}
			this.pan.height = this.imgBg1.height - 8;

		}

		public function listRender(cell:bagItemUI,index:int):void{
			var it:Array=this.list.array[index];
			//cell.setData(it.icon,it.ratity,it.name,it.addNum+"",it.type);
			cell.setData(it[0],it[1]);
		}

		public function getClick():void{
			if(mData["isOpen"]){
				return;
			}
			NetSocket.instance.send("accept_sys_gift_msg",{"msg_index":mData.index},Handler.create(this,function(np:NetPackage):void{
				var gift_dict_list:Array = np.receiveData.gift_dict_list;
				gift_dict_list.forEach(function(gift_dict:Object):void {ViewAwakenHero.checkGiftDict(gift_dict)}, this);
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(gift_dict_list);
				getBtn.gray=true;
				getBtn.mouseEnabled=false;	
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_SYSTEM);
			}));
			
		}

		override public function onRemoved():void{

		}
	}

}