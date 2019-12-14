package sg.view.map
{
	
import sg.utils.Tools

	import ui.map.visitMainUI;
	import laya.ui.Box;
	import sg.model.ModelOfficial;
	import laya.ui.Label;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class ViewVisitMain extends visitMainUI{

		private var list_data:Array=[];
		public function ViewVisitMain(){
			this.list.renderHandler=new Handler(this,listRender);
		}

		override public function onAdded():void{
			setData();
			
		}

		public function setData():void{
			var visit:Object=ModelOfficial.visit;
			var cities:Object=ModelOfficial.cities;
			list_data=[];
			for(var s:String in visit){
				if(s!="refresh_time"){	
					var o:Object={};
					var ss:String=visit[s];
					o["cid"]=s;
					o["hid"]=ss;
					o["country"]=cities[s].country;
					list_data.push(o);
				}
			}
			this.list.array=list_data;
		}

		public function listRender(cell:Box,index:int):void{
			var label:Label=cell.getChildByName("label") as Label;
			var o:Object=this.list.array[index];
			var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(o.hid);
			label.text=o.country+"   "+o.cid+"   "+o.hid+"   "+hmd.getName();
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
		}

		public function itemClick(index:int):void{
			//ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,0,1]);
			if(this.list.array[index].country!=ModelUser.getCountryID()){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_ViewVisitMain_0"));
				return;
			}
			//ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_TASK,[1,0,[this.list.array[index].cid,this.list.array[index].hid]]);
			ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,this.list.array[index],1]);
			return;
			var sendData:Object={};
			sendData["city_id"]=this.list.array[index].cid;
			sendData["hid"]="hero701";
			sendData["cost"]=0;
			NetSocket.instance.send("hero_city_visit",sendData,new Handler(function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
			}));
		}

		override public function onRemoved():void{

		}
	}

}