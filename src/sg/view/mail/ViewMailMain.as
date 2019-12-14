package sg.view.mail
{
	import ui.mail.MailMainUI;
	import ui.mail.mailSysItemUI;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.events.Event;
	import sg.utils.SaveLocal;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import laya.utils.Handler;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.model.ModelGame;
	import sg.view.hero.ViewAwakenHero;

	/**
	 * ...
	 * @author
	 */
	public class ViewMailMain extends MailMainUI{

		public var sysData:Array=[];
		public var psnData:Array=[];
		public var userData:Object={};
		public var isHaveMail:Boolean=false;
		public var redNum:Number=0;
		public function ViewMailMain(){
			this.list0.scrollBar.visible=false;
			this.list1.scrollBar.visible=false;
			this.list0.itemRender=SysItem;
			this.list1.itemRender=PsnItem;
			this.list0.renderHandler=new Handler(this,sysListRender);
			this.list1.renderHandler=new Handler(this,psnListRender);
			this.list0.selectHandler=new Handler(this,sysOnSelct);
			this.list1.selectHandler=new Handler(this,psnOnSelct);
			this.tab0.on(Event.CHANGE,this,this.tabChange);
			this.btn0.on(Event.CLICK,this,this.btnClick);
			this.btnRemove.on(Event.CLICK,this,this.removeAllChatClick);
			
		}

		public function eventCallBack(str:String):void{
			if(str==""){
				setPsnData(false);
			}else{
				
			}
			//trace("新添加了一个私人对话");
		}

		public function sysCallBack():void{
			NetSocket.instance.send("get_msg",{},Handler.create(this,function(np,NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setSysData();
				setPsnData(true);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,userData.usr);
			}));
		}

		override public function onAdded():void{
			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_MAIL_CHAT,this,eventCallBack);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_MAIL_SYSTEM,this,sysCallBack);

			this.text0.text="";
			//this.titleLabel.text=Tools.getMsgById("_country38");
			this.comTitle.setViewTitle(Tools.getMsgById("_country38"));
			this.btnRemove.visible=false;
			this.tab0.labels=Tools.getMsgById("_mail_text06")+","+Tools.getMsgById("_mail_text07");
			
			this.list1.visible=false;
			this.list0.scrollBar.value=0;
			this.list1.scrollBar.value=0;
			//ModelManager.instance.modelUser.clearChatData();//清理空的聊天
			setSysData();
			setPsnData(true);
			this.tab0.selectedIndex=0;
		}

		public function setSysData():void{
			sysData=[];
			userData=ModelManager.instance.modelUser.msg;
			var a:Array=userData.sys;
			isHaveMail=false;
			for(var i:int=0;i<a.length;i++){
				var o:Object={};
				var d:Array=a[i];
				o["title"]=d[0];
				o["info"]=d[1];
				o["gift"]=d[2];
				o["time"]=d[3];
				o["paixu"]=Tools.getTimeStamp(d[3]);
				o["index"]=i;
				o["isOpen"]=d[4];
				if(d[4]==0){
					isHaveMail=true;
				}
				sysData.push(o);
			}
			sysData.sort(MathUtil.sortByKey("paixu",true,false));
			this.list0.array=sysData;
			ModelGame.redCheckOnce(this.tab0.getChildAt(0),isHaveMail);
			this.btn0.gray=!isHaveMail;
			tabChange();
		}

		public function setPsnData(b:Boolean=true):void{
			psnData=[];
			if(b){
				ModelManager.instance.modelUser.setChatData(userData.usr);
			}
			psnData=ModelManager.instance.modelUser.getChatArr();
			redNum=0;
			for(var i:int=0;i<psnData.length;i++){
				if(psnData[i].data.read==false){
					redNum+=1;
				}
			}
			//trace("打印所有聊天记录  ",psnData);
			this.list1.array=psnData;
			ModelGame.redCheckOnce(this.tab0.getChildAt(1),redNum>0);
			tabChange();
		}

		public function tabChange():void{
			if(this.tab0.selectedIndex==0){
				this.list0.visible=true;
				this.list1.visible=false;
				this.btn0.label=Tools.getMsgById("_mail_text02");//"一键阅读";
				this.text0.text=this.list0.array.length==0?Tools.getMsgById("_mail_text08"):"";
				this.btn0.gray=!isHaveMail;
			}else if(this.tab0.selectedIndex==1){
				this.list0.visible=false;
				this.list1.visible=true;
				this.btn0.label=Tools.getMsgById("_mail_text03");//"添加对话";
				this.text0.text=this.list1.array.length==0?Tools.getMsgById("_mail_text01"):"";		
				this.btn0.gray=false;		
			}
		}

		public function sysListRender(cell:SysItem,index:int):void{
			cell.setData(sysData[index]);			
			cell.off(Event.CLICK,this,this.sysItemClick);
			cell.on(Event.CLICK,this,this.sysItemClick,[index]);
		}

		public function psnListRender(cell:PsnItem,index:int):void{
			cell.setData(psnData[index]);
			ModelGame.redCheckOnce(cell.comHead,psnData[index].data.read==false);
			cell.btn1.off(Event.CLICK,this,this.psnItemClick);
			cell.btn1.on(Event.CLICK,this,this.psnItemClick,[index,cell]);
			cell.btn0.off(Event.CLICK,this,this.chatRemoveClick);
			cell.btn0.on(Event.CLICK,this,this.chatRemoveClick,[index]);

			cell.comHead.offAll();
			cell.comHead.on(Event.CLICK,this,this.headClick,[psnData[index].uid]);
		}

		private function headClick(_uid:*):void{
			ModelManager.instance.modelUser.selectUserInfo(_uid);
		}

		public function sysOnSelct(index):void{

		}

		public function psnOnSelct(index):void{

		}

		public function sysItemClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_MAIL_CONTENT,sysData[index]);
		}

		public function psnItemClick(index:int,cell:PsnItem):void{
			ModelGame.redCheckOnce(cell.comHead,false);
			if(psnData[index].data.read==false){
				redNum-=1;
			} 
			ModelGame.redCheckOnce(this.tab0.getChildAt(1),redNum>0);
			ViewManager.instance.showView(ConfigClass.VIEW_MAIL_PERSONAL,psnData[index]);
		}

		public function chatRemoveClick(index:int):void{
			if(psnData[index].data.read==false){
				redNum-=1;
			} 
			ModelGame.redCheckOnce(this.tab0.getChildAt(1),redNum>0);
			ModelManager.instance.modelUser.removeChatData(psnData[index].uid);
			psnData.splice(index,1);
			this.list1.array=psnData;
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_mail_text04"));//"删除聊天成功");
			this.text0.text=this.list1.array.length==0?Tools.getMsgById("_mail_text01"):"";	
		}

		public function removeAllChatClick():void{
			SaveLocal.deleteObj(SaveLocal.KEY_CHAT+ModelManager.instance.modelUser.mUID,true);
			setPsnData(true);
		}


		public function btnClick(index:int):void{
			if(this.tab0.selectedIndex==0){
				if(!isHaveMail){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_mail_tips01"));
					return;
				}
					
				var sendData:Object={};
				sendData["msg_index"]=-1;
				NetSocket.instance.send("accept_sys_gift_msg",sendData,Handler.create(this,function(np:NetPackage):void{
					var gift_dict_list:Array = np.receiveData.gift_dict_list;
					gift_dict_list.forEach(function(gift_dict:Object):void {ViewAwakenHero.checkGiftDict(gift_dict)}, this);
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(gift_dict_list);
					setSysData();
				}));
			}else{
				if(psnData.length>20){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_mail_text05",["20"]));//"聊天个数上限20个");
					return;
				}
				ViewManager.instance.showView(ConfigClass.VIEW_ADD_CHAT,0);
				//ViewManager.instance.showView(ConfigClass.VIEW_MAIL_PERSONAL);
			}
		}

		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_UPDATE_MAIL_CHAT,this,eventCallBack);
			ModelManager.instance.modelUser.off(ModelUser.EVENT_UPDATE_MAIL_SYSTEM,this,sysCallBack);
		}
	}

}



import ui.mail.mailSysItemUI;
import sg.utils.Tools;
import ui.mail.mailItemUI;
import sg.model.ModelUser;
import sg.manager.AssetsManager;

class SysItem extends mailSysItemUI{
	
	public function SysItem():void{

	}

	public function setData(obj:Object):void{
		this.timeLabel.text=Tools.dateFormat(obj.time);
		this.titleLabel.text=obj.title;
		this.mailImg.skin=obj.isOpen==0 ? AssetsManager.getAssetsUI("icon_more06.png") : AssetsManager.getAssetsUI("icon_more09.png");
		this.boxImg.visible=obj.isOpen==0;
		this.gray=obj.isOpen==1;
	}

	public function setSelection():void{

	}
}


class PsnItem extends mailItemUI{

	public function PsnItem(){
		this.btn0.label = Tools.getMsgById("PsnItem_1");
	}

	public function setData(obj:Object):void{
		this.nameLabel.text=obj.data.uname;
		this.lvLabel.text=obj.data.lv;
		this.guildLabel.text="";// obj.data.guild_name==null?Tools.getMsgById("msg_ViewMailMain_0"):obj.data.guild_name;
		this.infoLabel.text=obj.text;
		this.comHead.setHeroIcon(ModelUser.getUserHead(obj.data.head));
		this.comFlag.setCountryFlag(obj.data.country);
	}
}