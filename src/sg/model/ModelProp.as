package sg.model
{
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import laya.maths.MathUtil;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ModelProp extends ModelBase{

		public static const boxImg:String="item055";//通用宝箱显示图片
		private var runeConfig:Object=ConfigServer.star;
		private var userModel:ModelUser=ModelManager.instance.modelUser;
		public var allProp:Object={};
		public var userProp:Array=[];
		public var itemID:String="";
		//public var curProp:ModelItem=null;//弃用了
		//public var rewardProp:Array;
		public var food:ModelItem=new ModelItem;
		public var wood:ModelItem=new ModelItem;
		public var iron:ModelItem=new ModelItem;
		public var gold:ModelItem=new ModelItem;
		public var coin:ModelItem=new ModelItem;
		public var merit:ModelItem=new ModelItem;

		public static var pve_gift_dict:Object={};
		public static var event_updateprop:String="update_bag_list";
		public static var event_updatePub:String="update_pub_list";
		public static var EVENT_GET_NEW_PROP:String="event_get_new_prop";

		public var buildUpGift:Object={};//building001升级时候获得的奖励
		public var hasOpenBox:Boolean;
		public function ModelProp(){
			

		}

		

		public function initProp(obj:Object):void{//获得所有配置道具
			for(var value:String in obj)
			{
				var value2:Object=obj[value];
				var _name:String=value2["name"]?value2["name"]:_id+" has no name";
				var _id:String=value+"";
				var _info:String=value2["info"]?value2["info"]:_id+" has no info";
				var _icon:String=value2["icon"]?value2["icon"]:_id+" has no icon";
				var _type:Number=value2["type"]?value2["type"]:1;
				var _sourse:Object=value2["source"]?value2["source"]:null;
				var _quality:Number=value2["quality"]?value2["quality"]:0;
				var _index:Number=value2["index"]?value2["index"]:0;
				var _isB:*=value2["awardid"]?"awardid":value2["range"]?value2["range"]:null;
				var ip:ModelItem =new ModelItem;
				ip.initData(_name,_id,_info,_type,_icon,_sourse,_quality,_index,_isB);
				allProp[_id]=ip;
				setMoneyProp();
			}
		}

		public function setMoneyProp():void{//钱粮木铁
			var obj:Object=ConfigServer.system_simple.material_info;
			coin.initData( obj.coin.name,  "coin", obj.coin.info, 1,"img_icon_09_big.png",obj.coin.source, 7,                -1006,null);
			gold.initData( obj.gold.name,  "gold", obj.gold.info, 1,"img_icon_04_big.png",obj.gold.source, obj.gold.quality, -1004,null);
			food.initData( obj.food.name,  "food", obj.food.info, 1,"img_icon_05_big.png",obj.food.source, obj.food.quality, -1003,null);
			wood.initData( obj.wood.name,  "wood", obj.wood.info, 1,"img_icon_06_big.png",obj.wood.source, obj.wood.quality, -1002,null);
			iron.initData( obj.iron.name,  "iron", obj.iron.info, 1,"img_icon_07_big.png",obj.iron.source, obj.iron.quality, -1001,null);
			merit.initData(obj.merit.name, "merit",obj.merit.info,1,"img_icon_08_big.png",obj.merit.source,obj.merit.quality,-1005,null);
			allProp["coin"]=coin;
			allProp["gold"]=gold;
			allProp["food"]=food;
			allProp["wood"]=wood;
			allProp["iron"]=iron;
			allProp["merit"]=merit;
		}


		/**
		 * 获得用户的所有道具
		 */
		public function getUserProp(obj:Object):void{
			userProp=[];
			for(var value:String in obj){
				var itemModel:ModelItem=this.getItemProp(value);
				if(itemModel && itemModel.num!=0){
					userProp.push(itemModel);
				}	
			}
			hasBoxProp();
		}

		/**
		 * 是否有可开启的随机宝箱
		 */
		private function hasBoxProp():void{
			hasOpenBox = false;
			var obj:Object = ModelManager.instance.modelUser.property;
			var cfg:Object = ConfigServer.property;
			for(var s:String in obj){
				if(obj[s]>0){
					if(cfg[s] && cfg[s].awardid){//随机宝箱
						if(cfg[s].type != 10){   //非兽灵宝箱
							hasOpenBox = true;
							break;
						}
					}
				}
			}
		}

		/**
		 * 返回排序后的道具[["id","addNum"],...,["id","addNum"]]
		 */
		/*
		public function getRewardArr(data:*):Array{
			var arr:Array=getRewardProp(data);
			var a:Array=[];
			for(var i:int=0;i<arr.length;i++){
				var b:Array=["",0];
				b[0]=(arr[i] as ModelItem).id;
				b[1]=(arr[i] as ModelItem).addNum;
				a.push(b);
			}
			return a;
		}*/


		/**
		 * 获得奖励道具
		 */
		public function getRewardProp(data:*,is_new:Boolean=false):Array{
			var arr:Array=[];
			var d:Object={};
			if(data is Array){
				var temp:Array=[];
				for(var i:int=0;i<data.length;i++){
					d=data[i];
					temp=getRewardPropObj(d,is_new);
					for(var j:int=0;j<temp.length;j++){
						arr.push(temp[j]);
					}
				}

			}else if(data is Object){
				d=data;
				arr=getRewardPropObj(d,is_new);
				
			}
			arr.sort(MathUtil.sortByKey("2",false,false));
			// trace(arr);
			return arr;
		}

		private function getRewardPropObj(d:Object,is_new:Boolean):Array{
			var arr:Array=[];//[id,数量,排序index]
			for(var value:String in d){
				if(value=="prop"){
					var prop:Object=d["prop"];
					for(var v:String in prop){
						arr.push([v,prop[v],this.getItemProp(v).index]);
						if(is_new){
							setItemPropNew(v);
						}
					}
				}else if(value=="title"){					
					var title:Array=d[value];
					for(var j:int=0;j<title.length;j++){
						var tid:String=title[j];
						var sortTitle:Number=100-Number(tid.substr(tid.length-3,3));
						arr.push([tid,1,-(9000+sortTitle)]);
					}
				}else if(value=="equip"){
					var equip:Array=d[value];
					for(var i:int=0;i<equip.length;i++){
						var s:String=equip[i];
						arr.push([s,1,-8000]);
					}
				}else if(value=="credit"){//战功
					arr.push(["item041",d[value],0]);
				}else if(value=="awaken"){//觉醒英雄
					var awaken:Array=d[value];
					for(var k:int=0;k<awaken.length;k++){
						arr.push([awaken[k],1,-6000]);
					}
				}else{
					if(value.indexOf("star")!=-1){
						if(value.length<8){
							// trace("错误的星辰id",value);
						}
						var sStr:String=value.substr(0,6);
						var sortStar:Number=Number(sStr.substr(sStr.length-2,2));
						arr.push([value,d[value],-(7000+sortStar)]);
					}else if(value.indexOf("title")!=-1){
						var st:Number=Number(value.substr(value.length-3,3));
						arr.push([value,d[value],-(9000+st)]);
					}else if(value.indexOf("equip")!=-1){
						arr.push([value,d[value],-8000]);
					//}
					// else if(value.indexOf("sale")!=-1){//抵用券 "id":[[num,time],[pf,]]
					// 	var pfArr:Array = d[value][2] ? d[value][2] : [];
					// 	if(pfArr.length==0 || pfArr.indexOf(ModelManager.instance.modelUser.pf)==-1){
					// 		arr.push([value+"|"+d[value][1],d[value][0],-10000]);
					// 	}
					}else if(ConfigServer.system_simple.sale_depot && ConfigServer.system_simple.sale_depot[value]){
						var depotArr:Array = ConfigServer.system_simple.sale_depot[value];
						var pfArr:Array = depotArr[2] ? depotArr[2] : [];
						if(pfArr.length==0 || pfArr.indexOf(ModelManager.instance.modelUser.pf)==-1){
							arr.push([depotArr[0]+"|"+depotArr[1],d[value],-10000]);
						}
					}else if(value.indexOf("beast")!=-1){
						arr.push([value,d[value],-5000]);
					}else{
						var item:ModelItem=this.getItemProp(value);
						if(item && d[value]>0){
							item.addNum=d[value];							
							arr.push([value,d[value],item.index]);
							if(is_new){
								setItemPropNew(value);
							}
						}
					}
				}
			}
			if(is_new){
				this.event(ModelProp.EVENT_GET_NEW_PROP);
			}
			return arr;
		}

		/**
		 * 获得配置里的道具数组
		 */
		public function getCfgPropArr(a:Array):Array{
			var arr:Array=[];
			for(var i:int=0;i<a.length;i++){
				var _a:Array=a[i];
				if(_a[0]=="equip" || _a[0]=="title"){
					for(var j:int=0;j<_a[1].length;j++){
						arr.push([_a[1][j],1]);
					}
				// }else if(_a[0].indexOf("sale")!=-1){
				// 	var pfArr:Array = _a[1][2] ? _a[1][2] : [];
				// 	if(pfArr.length==0 || pfArr.indexOf(ModelManager.instance.modelUser.pf)==-1){
				// 		arr.push([_a[0]+"|"+_a[1][1],_a[1][0],-1]);
				// 	}
				 }else if(ConfigServer.system_simple.sale_depot && ConfigServer.system_simple.sale_depot[_a[0]]){
					 var depotArr:Array = ConfigServer.system_simple.sale_depot[_a[0]];
					var pfArr:Array = depotArr[2] ? depotArr[2] : [];
					if(pfArr.length==0 || pfArr.indexOf(ModelManager.instance.modelUser.pf)==-1){
						arr.push([depotArr[0]+"|"+depotArr[1],_a[1],-1]);
					}
				}else{
					arr.push(_a);
				}
			}
			return arr;
		}
		
		/**
		 * 清理刚获得的奖励的新获得状态
		 */
		public function clearRewardProp():void{
			for(var value:Object in allProp)
			{
				allProp[value].isNew=1;
			}
		}


		public function getPropType(t:Number):Array{//获得某种类型的道具
			var a:Array=[];
			for each(var value:ModelItem in userProp)
			{
				if(value.num!=0){
					if(t==0){
						if(value.type==1 || value.type==10){
							a.push(value);	
						}
					}else if(t==3){
						if(value.type==4 || value.type==8){
							a.push(value);	
						}
					}else{
						if(value.type==t+1){
							a.push(value);
						}
					}
				}
			}
			ArrayUtils.sortOn(["isNew","index"],a,false);
			return a;
		}


		/**
		 * 获得单个道具属性
		 */
		public function getItemProp(id:String):ModelItem{
			if(allProp){
				if(allProp.hasOwnProperty(id)){
					var item:ModelItem=allProp[id];
					return item;
				}else{
					if(id.indexOf("item")!=-1) Trace.log("error:   错误的id： "+id);
				}	
			}
			return null;
		}

		/**
		 * 是否有该数量的道具
		 */
		public function isHaveItemProp(id:String,n:Number):Boolean{
			if(ModelManager.instance.modelUser.property.hasOwnProperty(id)){
				var num:Number=ModelManager.instance.modelUser.property[id];
				if(num>=n){
					return true;
				}
			}else if(id=="coin" || id == "gold" || id == "wood" || id == "iron" || id == "iron" || id == "merit"){
				var resNum:Number=ModelManager.instance.modelUser[id];
				if(resNum>=n){
					return true;
				}
			}
			return false;
		}


		/**
		 * 设置是否是新获得
		 */
		public function setItemPropNew(id:String):void{
			if(this.getItemProp(id)){
				(this.getItemProp(id) as ModelItem).isNew=0;
			}
			return;
			/*
			if(rewardProp!=null && rewardProp.length>0){
				var len:int = rewardProp.length;
				for(var index:int = 0; index < len; index++)
				{
					var element:ModelItem = rewardProp[index];
					if(element.id==id){
						element.isNew=1;
					}
				}
			}*/
		}

		/**
		 * 配置的道具obj转array
		 */
		/*
		public function getConfigRewardList(obj:Object):Array{
			var a:Array=[];
			for(var s:String in obj){
				var itemModel:ModelItem=this.getItemProp(s);
				itemModel.addNum=obj[s];
				a.push(itemModel);
			}
			a.sort(MathUtil.sortByKey("index",false,false));
			return a;
		}*/



		/**
		 * 获得沙盘中获得的道具
		 */
		public function getPveGiftDict():void{
			var c_army:Array=ConfigServer.army.upgrade_cost;
			var item_arr:Array=[];
			for(var i:int=0;i<c_army.length;i++){
				var arr:Array=c_army[i];
				for(var j:int=0;j<4;j++){
					if(item_arr.indexOf(arr[j][0])==-1){
						item_arr.push(arr[j][0]);
					}
					if(item_arr.indexOf(arr[j][1])==-1){
						item_arr.push(arr[j][1]);
					}
				}
			}
			//trace("升级兵种的道具id:",item_arr);
			var c_pve:Object=ConfigServer.pve.battle;
			for(var s:String in c_pve){
				if(c_pve[s].battle_type==1){
					var o:Object=c_pve[s].reward;
					for(var r:String in o){
						var battle_obj:Object={};
						if(r.indexOf("item")!=-1 && item_arr.indexOf(r)!=-1){	
							var n:Number=ModelScience.func_sum_type("pve_get");
							n=n==0?o[r]:Math.floor((n+1)*o[r]);
							if(pve_gift_dict.hasOwnProperty(r)){
								battle_obj=pve_gift_dict[r];
								if(n>=400){									
									battle_obj[s]=n;
								}
							}else{
								if(n>=400){									
									battle_obj[s]=n;
								}
							}
							pve_gift_dict[r]=battle_obj;
						}
					}
				}
			}

			//trace("==========================pve",pve_gift_dict);
		}

	}
}
