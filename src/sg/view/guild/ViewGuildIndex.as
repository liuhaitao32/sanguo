package sg.view.guild
{
	import ui.guild.guildIndexUI;
	import ui.guild.guildItemUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.ui.Box;
	import sg.cfg.ConfigServer;
	import sg.manager.AssetsManager;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelUser;
	import sg.manager.ModelManager;
	import laya.maths.MathUtil;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildIndex extends guildIndexUI{
		
		public var configData:Object={};
		public var listData:Array=[];		
		public var searchId:String="";
		public var userModel:ModelUser;
		public var isSearchSuc:Boolean=false;
		public function ViewGuildIndex(){
			this.title0.text=Tools.getMsgById("add_guild");
			this.title1.text=Tools.getMsgById("_guild_text08");
			this.title2.text=Tools.getMsgById("_guild_text108");
			this.title3.text=Tools.getMsgById("_guild_text109");
			this.title4.text=Tools.getMsgById("_guild_text110");

			this.tSearch.text = Tools.getMsgById("_guild_text88");// "搜索军团";
			this.putText.prompt=Tools.getMsgById("_guild_text67");// "请输入兵团名称";
			this.putText.restrict="\u4e00-\u9fa5,a-zA-Z";
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.btnCreat.on(Event.CLICK,this,this.creatClick);
			this.btnSearch.on(Event.CLICK,this,this.searchClick);
			this.btnSearch.label=Tools.getMsgById("_guild_text68");//"搜索";
			this.putText.on(Event.INPUT,this,inputChange);
		}

		override public function onAdded():void{
			userModel=ModelManager.instance.modelUser;
			configData=ConfigServer.guild;
			this.btnCreat.setData(AssetsManager.getAssetItemOrPayByID("coin"),configData.configure.consumegold+" "+Tools.getMsgById("_guild_text60"));
			listData=this.currArg;
			listData.sort(MathUtil.sortByKey("power",true));
			this.list.array=listData;
			this.text0.text=this.list.array.length==0?Tools.getMsgById("_public201"):"";
		}

		public function inputChange():void{
			if(searchId!=""){
				if(this.putText.text==""){
					searchId="";
					if(isSearchSuc){
						this.list.array=listData;
						isSearchSuc=false;
					}
				}
			}
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.btnApply.off(Event.CLICK,this,this.applyClick);
			cell.btnApply.on(Event.CLICK,this,this.applyClick,[index]);

		}

		public function applyClick(index:int):void{
			//trace("申请加入:"+index);
			var o:Object={};
			o["gid"]=this.list.array[index].guild_id;
			NetSocket.instance.send("guild_application",o,Handler.create(this,this.socketCallBack,[index]));
		}

		public function socketCallBack(index:int,np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			(this.list.getCell(index) as Item).setData(this.list.array[index]);
		}

		public function searchClick():void{
			if(this.putText.text!=""){
				if(searchId==this.putText.text){
					return;
				}
				searchId=this.putText.text;
				NetSocket.instance.send("find_guild",{"guild_name":searchId},Handler.create(this,searchCallBack));
			}
		}

		public function applyCallBack():void{

		}

		public function searchCallBack(np:NetPackage):void{
			if(np.receiveData){
				var arr:Array=[];
				arr.push(np.receiveData);
				this.list.array=arr;
				isSearchSuc=true;
			}else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips05"));
			}
		}

		public function creatClick():void{
			if(!Tools.isCanBuy("coin",configData.configure.consumegold)){
				return;
			}
			ViewManager.instance.showView(ConfigClass.VIEW_CREAT_TEAM,"creat");
		}

		override public function onRemoved():void{

		}
	}

}



import ui.guild.guildItemUI;
import sg.manager.ModelManager;
import sg.cfg.ConfigServer;

class Item extends guildItemUI{
	public function Item(){

	}
	public function setData(obj:*):void{
		this.img1.visible=this.img2.visible=this.btnApply.visible=false;
		if(ModelManager.instance.modelUser.application_log.hasOwnProperty(obj.guild_id)){
			//this.btnApply.mouseEnabled=false;
			this.img1.visible=true;
			//this.btnApply.label="已申请";
		}else{
			if(obj.user_len>=ConfigServer.guild.configure.maxpeople){
				this.img2.visible=true;
				//this.btnApply.mouseEnabled=false;
				//this.btnApply.label="已满";
			}else{
				this.btnApply.visible=true;
				//this.btnApply.mouseEnabled=true;
				//this.btnApply.label="申请";
			}
		}
		
		this.nameLabel.text=obj.guild_name;
		this.numLabel.text=obj.user_len+"/"+ConfigServer.guild.configure.maxpeople;
		this.idLabel.text = obj.leader_uname == null?"null":obj.leader_uname;
		this.comPower.setNum(obj.power);
		//this.atkLabel.text=obj.power;
	}
}