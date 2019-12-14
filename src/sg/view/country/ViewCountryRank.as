package sg.view.country
{
	import ui.country.country_rankUI;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import ui.country.item_country_rank_newUI;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import laya.ui.Label;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewCountryRank extends country_rankUI{

		private var mPage:Number = 0;
        private var mData:Object;
        private var mSortArr:Array=[0,4,5,6,7];
		public function ViewCountryRank(){
            
			this.tab.dataSource = [Tools.getMsgById("add_building001"),Tools.getMsgById("_public89"),Tools.getMsgById("_public90"),Tools.getMsgById("_public91"),Tools.getMsgById("_public92")];
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.list.scrollBar.hide=true;
            this.list.renderHandler = new Handler(this,this.list_render);

            // 设置列表标题
            (list_title.getChildByName('txt_rank') as Label).text = Tools.getMsgById('_public214');
            (list_title.getChildByName('txt_player') as Label).text = Tools.getMsgById('_more_rank07');
            (list_title.getChildByName('txt_city') as Label).text = Tools.getMsgById('_country13');
            (list_title.getChildByName('txt_online') as Label).text = Tools.getMsgById('_country60');

            this.comTitle.setViewTitle(Tools.getMsgById("_country59"));// "国家功臣");
		}


		override public function onAdded():void{
            mData={};
            this.list.dataSource = [];
			this.tab.selectedIndex=0;
		}

		private function tab_select(index:int):void
        {
            if(index>-1){
                (list_title.getChildByName('txt_tab') as Label).text = this.tab.dataSource[index];
                this.mPage = 0;
                this.checkPage();
            }
        }

		private function checkPage():void
        {
            var b:Boolean = false;
            if(this.mData.hasOwnProperty(this.tab.selectedIndex)){
                if(this.mPage<this.mData[this.tab.selectedIndex].page){
                    b = true;
                }
            }   
            if(b){
                this.setListData(this.mData[this.tab.selectedIndex]);
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_USERS,{type:this.tab.selectedIndex,page:this.mPage},Handler.create(this,this.ws_sr_get_users));
            }            
        }

		private function ws_sr_get_users(re:NetPackage):void
        {
            if(this.mData.hasOwnProperty(re.sendData.type)){
                if(re.receiveData.data && re.receiveData.data.length>0){
                    this.mData[re.sendData.type].page+=1;
                    this.mData[re.sendData.type].self = re.receiveData.self;
                    this.mData[re.sendData.type].rank = re.receiveData.rank;
                    this.mData[re.sendData.type].data = this.mData[re.sendData.type].data.concat(re.receiveData.data);
                } //re.receiveData.rank;
            }
            else{
                this.mData[re.sendData.type] = re.receiveData;
                this.mData[re.sendData.type]["page"] = 1;
            }
            
            this.setListData(this.mData[re.sendData.type]);
        }        
        private function setListData(obj:Object):void
        {
            this.list.scrollBar.value=0;
            var n:Number=ConfigServer.getServerTimer();
            if(this.tab.selectedIndex==0){
                for(var i:int=0;i<obj.data.length;i++){
                    var a:Array=obj.data[i];
                    a["sortLv"]=a[3];
                    a["sortTime"]=a[2]==true ? n+10000 : Tools.getTimeStamp(a[2]);
                }
                obj.data=ArrayUtils.sortOn(["sortLv","sortTime"],obj.data,true);
            }
            for(var j:int=0;j<obj.data.length;j++){
                if(obj.data[j][0]==ModelManager.instance.modelUser.mUID){
                    obj.rank=j+1;
                    break;
                }
            }
            this.setItemData(this.mSelf,obj.self,obj.rank-1);
            this.list.dataSource = obj.data;
            
        }
        private function list_render(item:item_country_rank_newUI,index:int):void
        {
            var data:Array = this.list.array[index];
            this.setItemData(item,data,index);
        }
        private function setItemData(item:*,data:Array,index:int):void
        {
            var uid:int = data[0];
            var uname:String = data[1];
            var online:String = data[2];
            //
            item.tName.text = uname;//+uid;
            Tools.textFitFontSize(item.tName);
            item.cRank.setRankIndex(index+1,"",true);
            item.tOnline.text=online===true?Tools.getMsgById("_guild_text29"):Tools.howTimeToNow(Tools.getTimeStamp(online));
            item.tOnline.color=online===true?"#10F010":"#828282";

            item.imgMayor.visible=ModelOfficial.getMayorByUID(uid)!="";

            var n:Number=ModelOfficial.getUserOfficer(uid+"");
			if(n>=0){
				item.comOfficer.visible = true;
				item.comOfficer.setOfficialIcon(n,ModelOfficial.getInvade(ModelUser.getCountryID()), ModelUser.getCountryID());
			}else{
				item.comOfficer.visible = false;
			}

			if (this.tab.selectedIndex == 1){
				item.comPower.visible = true;
				item.comPower.setNum(data[3 + this.tab.selectedIndex]); 
			}
			else{
				item.comPower.visible = false;
				item.tNum.text = data[3 + this.tab.selectedIndex]; 
			}
			item.tNum.visible = !item.comPower.visible;
            //item.power.visible = this.tab.selectedIndex == 1;      
            item.off(Event.CLICK,this,itemClick);
            item.on(Event.CLICK,this,itemClick,[uid]);   
        }

        private function itemClick(_id:*):void{
            ModelManager.instance.modelUser.selectUserInfo(_id);
        }


		override public function onRemoved():void{
			this.tab.selectedIndex=-1;
		}
	}

}