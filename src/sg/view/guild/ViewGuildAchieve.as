package sg.view.guild
{
	import ui.guild.guildAchieveUI;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import laya.maths.MathUtil;
	import laya.ui.Label;
	import sg.manager.ModelManager;
	import laya.ui.ProgressBar;
	import sg.view.com.ComPayType;
	import sg.manager.AssetsManager;
	import laya.ui.Button;
	import laya.ui.Image;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildAchieve extends guildAchieveUI{

		

		public var config_data:Object;

		public function ViewGuildAchieve(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.selectHandler=new Handler(this,this.listSelect);

			this.list1.renderHandler=new Handler(this,this.listRender1);
			this.rewardList.renderHandler=new Handler(this,this.listRender2);
		}

		override public function onAdded():void{
			config_data=ConfigServer.guild.achievement;
			setData();
		}

		public function setData():void{
			var arr:Array=[];
			for(var s:String in config_data){
				var obj:Object={};
				var o:Object=config_data[s];
				obj["index"]=Number(s);
				for(var ss:String in o){
					obj[ss]=o[ss];
				}
				obj["finish"]=false;
				var b1:Boolean=ModelManager.instance.modelGuild.getAddDays()>=obj.days;
				if(obj.type==""){
					obj["finish"]=b1;
				}else{
					if(ModelManager.instance.modelGuild.effort.hasOwnProperty(obj.index+"")){
						obj["finish"]=(ModelManager.instance.modelGuild.effort[obj.index+""]==1)&&b1;
					}else{
						
					}
				}
				obj["sort"]=obj["finish"]?0:1;
				arr.push(obj);
			}
			ArrayUtils.sortOn(["sort","index"],arr);
			//arr.sort(MathUtil.sortByKey("index",false,false));
			this.list.array=arr;
			itemClick(0);

		}

		public function setUI():void{
			var obj:Object=this.list.array[this.list.selectedIndex];
			this.infoLabel.text=Tools.getMsgById(obj.info);
			this.titleLabel.text=Tools.getMsgById(obj.name);
			var arr:Array=getConditionData(this.list.selectedIndex);
			this.list1.array=arr;


			var _reward:Array=[["coin",obj.reward[1]],["gold",obj.reward[0]],["food",obj.reward[2]]];
			var _re:Array=[];
			for(var i:int=0;i<3;i++){
				if(_reward[i][1] && _reward[i][1]!=0){
					_re.push(_reward[i]);
				}
			}
			if(_re.length==0){
				this.rewardList.visible=false;
			}else{
				this.rewardList.visible=true;
				this.rewardList.array=_re;
				this.rewardList.repeatX=_re.length;
				this.rewardList.x=(this.boxBottom.width-this.rewardList.width)/2;
			}

			this.imgGet.visible=_re.length==0?false:obj.finish;
			
		}

		private function getConditionData(index:int):Array{
			var obj:Object=this.list.array[index];
			var arr:Array=[];
			if(obj.days){
				arr.push(["days",obj.days]);
			}
			if(obj.need && obj.need.length!=0){
				arr.push([obj.type,obj.need[0]]);
			}
			return arr;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
			cell.setSelection(this.list.selectedIndex==index);
			cell.off(Event.CLICK,this,this.itemClick,[index]);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function listRender1(cell:Box,index:int):void{
			var _title:Label=cell.getChildByName("title") as Label;
			var _num:Label=cell.getChildByName("num") as Label;
			var _pro:Label=cell.getChildByName("pro") as Label;
			var _index:Button=cell.getChildByName("index") as Button;			
			(cell.getChildByName("pro") as Label).text=Tools.getMsgById("_guild_text63");
			var arr:Array=this.list1.array[index];
			_index.mouseEnabled=false;
			_index.label=Tools.getMsgById("_guild_text64",[index+1]);// "条件"+(index+1);
			
			_title.text=Tools.getMsgById("guild_achi_"+arr[0],[""]);
			_pro.text=arr[1]+"";
			_num.text=ModelManager.instance.modelGuild.getNeedNum(arr[0])+"/"+arr[1];
			var b:Boolean=ModelManager.instance.modelGuild.getNeedNum(arr[0])/arr[1]>=1;
			(cell.getChildByName("finish") as Image).visible=b;
			_index.selected=b;
			_num.color= b?"#10F010":"#ffffff";
		}

		public function listRender2(cell:Box,index:int):void{
			var _com:ComPayType=cell.getChildByName("reward0") as ComPayType;
			_com.setData(AssetsManager.getAssetItemOrPayByID(this.rewardList.array[index][0]),this.rewardList.array[index][1]+"");

		}

		public function listSelect(index:int):void{

		}


		public function itemClick(index:int):void{
			this.list.selectedIndex=index;
			setUI();
		}


		override public function onRemoved():void{
			this.list.selectedIndex=-1;
		}
	}
	

}


import ui.guild.guildAchieveItemUI;
import sg.utils.Tools;
import sg.manager.ModelManager;

class Item extends guildAchieveItemUI{
	
	public function Item(){

	}

	public function setData(obj:Object):void{
		this.imgFinish.visible=false;
		this.titleLabel.text=Tools.getMsgById(obj.name);
		this.imgFinish.visible=obj.finish;

	}

	public function setSelection(b:Boolean):void{
		this.imgSelect.visible=b;
	}
}