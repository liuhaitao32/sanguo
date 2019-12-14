package sg.view.menu
{
	import ui.menu.itemChat2UI;
	import sg.utils.Tools;
	import sg.model.ModelChat;
	import sg.manager.FilterManager;
	import sg.manager.ModelManager;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.manager.ViewManager;
	import sg.view.country.ViewAlienTroopInfo;
	import sg.activities.model.ModelPayRank;
	import sg.activities.model.ModelEquipBox;
	import sg.model.ModelOfficial;
	import laya.utils.HTMLChar;
	import laya.events.Event;

	/**
	 * ...
	 * @author
	 */
	public class ItemChat2 extends itemChat2UI{

		public var mData:Array;
		public var mUid:String;
		public function ItemChat2(){

		}
		
		public function setData(arr:Array):void{
			mData = arr;
			mUid = "";
			var b:Boolean = arr[1]==0;
			this.tHtml.style.color="#ffffff";
			this.tHtml.style.fontSize=this.tName.fontSize;
			this.tHtml.style.leading = 8;
			this.btnChannel.skin=ModelChat.channel_skin[arr[0]];
			this.btnChannel.label=arr[0]==0 && arr[1]!=0 ? Tools.getMsgById("_chat_text18") : ModelChat.channel_arr[arr[0]];
			var user_data:Array=[];
			var _width:Number = btnChannel.width;
			var _content:String = "";
			if(b){
				user_data = arr[3][1];
				var uid:int = user_data[0];
				mUid = uid+"";
				this.tName.color = ModelManager.instance.modelUser.mUID == uid+"" ? "#10F010" : "#d5e6ff";
				this.comFlag.setCountryFlag(user_data[2]);
				this.tName.text = user_data[1]+"";
				this.tName.width = this.tName.textField.textWidth;
				this.comOfficial.setOfficialIcon(user_data[4], ModelOfficial.getInvade(user_data[2]), user_data[2]);
				this.comOfficial.visible = !(user_data[4]==-100);
				this.imgMayor.visible = ModelOfficial.isCityMayor(uid+"",user_data[2])!="";
				
				_content = arr[3][0];// FilterManager.instance.wordBan(arr[3][0]);

				this.tName.visible = this.boxFlag.visible = true;
				_width += boxFlag.width;
				_width += this.tName.width;

				if(comOfficial.visible){
					_width += comOfficial.width;
					comOfficial.x = this.tName.x + this.tName.width;
				} 
				if(imgMayor.visible){
					_width += imgMayor.width;
					if(comOfficial.visible) imgMayor.x = comOfficial.x + comOfficial.width;
					else imgMayor.x = this.tName.x + this.tName.width;
				} 	
				
			}else{
				imgMayor.visible = comOfficial.visible = this.tName.visible = this.boxFlag.visible = false;
				var s:String=ModelManager.instance.modelChat.sysMessage(arr);
				_content = s;
			}
			var temp:String = "&nbsp;&nbsp;";
			var _blank:String = "";
			var n:Number = Math.ceil(_width/11.1);
			for(var i:int=0;i<n;i++){
				_blank += temp;
			}
			_blank += _content;
			this.tHtml.autoSize = true;
			this.tHtml.innerHTML = _blank;
			this.tHtml.height = this.tHtml.contextHeight;
			this.height = 12 + this.tHtml.height;

			this.tHtml.off(Event.LINK,this,click);
			this.tHtml.on(Event.LINK,this,click);

		}



		public function click(data:*):void{
			//trace("================",data,"===========");
			if(data=="country_call"){
				if(ModelManager.instance.modelClub.alien[mData[2]]["team"][0]["troop"].length!=0){
					ViewManager.instance.showView(["ViewAlienTroopInfo",ViewAlienTroopInfo],mData[2]);
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips16"));//"找不到集结编组");
				}
			}else if(data=="look_star"){
				GotoManager.boundFor({type:2,buildingID:"building006","state":1});
			}else if(data=="limit_free"){
				GotoManager.showView(ConfigClass.VIEW_FREE_BILL);
			}else if(data=="pvp_pk"){
				GotoManager.boundForPanel(GotoManager.VIEW_PK);
			}else if(data=="pk_yard"){
				GotoManager.boundForPanel(GotoManager.VIEW_PK_YARD);
			}else if(data=="pay_rank"){
				ModelPayRank.instance.active && !ModelPayRank.instance.notStart && GotoManager.boundForPanel(GotoManager.VIEW_PAY_RANK);
			}else if(data=="equip_box"){
				ModelEquipBox.instance.active &&  GotoManager.boundForPanel(GotoManager.VIEW_EQUIP_BOX);
			}else if(data!=" "){
				GotoManager.boundFor({type:1,cityID:data});
			}
		}


	}

}