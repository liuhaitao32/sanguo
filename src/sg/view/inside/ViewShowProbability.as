package sg.view.inside
{
	import ui.inside.pubShowProbabilityUI;
	import ui.inside.pubProbItemUI;
	import sg.model.ModelItem;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import laya.utils.Handler;
	import sg.model.ModelRune;
	import sg.utils.Tools;
	import sg.map.utils.ArrayUtils;

	/**
	 * ...
	 * @author
	 */
	public class ViewShowProbability extends pubShowProbabilityUI{

		public var mData:Array=[];
		public var noSort:Boolean; // 默认会进行排序  不需要排序的话currArg[2]传true.
		public var listData:Array=[];
		public var configStar:Object={};
		public function ViewShowProbability(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,this.listRender);
		}


		override public function onAdded():void{
			configStar=ConfigServer.star;
			mData = this.currArg[1];
			noSort = currArg[2];
			this.comTitle.setViewTitle(Tools.getMsgById(currArg[0]) + Tools.getMsgById("_building45"));
			getData();
		}


		public function getData():void{
			listData=[];
			for(var i:int=0;i<mData.length;i++){
				var o:Object={};
				var s:String=mData[i][0];
				var sort1:Number=0;
				var sort2:Number=0;
				if(s.indexOf("star")!=-1){
					o["id"]=s.substr(0,6);
					o["proba"]=mData[i][1];
					o["icon"]="star0"+configStar[o["id"]].icon+".png";
					o["lv"]=Number(s.substr(s.length-2,2));
					o["name"]=configStar[o["id"]].name;
					o["fix_type"]=configStar[o["id"]].fix_type;
					o["info"]=configStar[o["id"]].info;
					sort1=0;//10000-Number(s.substr(4,2));
					o["sort1"]=sort1;
					o["sort2"]=sort2;
					listData.push(o);
				}else if(s.indexOf("equip")!=-1){
					o["id"]=s;
					o["proba"]=mData[i][1];
					o["sort1"]=sort1;
					o["sort2"]=sort2;
					listData.push(o);
				}else{
					var it:Object={};
					var itemModel:ModelItem=ModelManager.instance.modelProp.getItemProp(s);
					if(itemModel.type==7){
						var hid:String=s.replace("item","hero");
						sort1=ConfigServer.hero[hid].rarity;
						sort1=sort1==2?3.5:sort1;
						sort2=1000-Number(hid.substr(4,3));
					}else{
						sort1=itemModel.index;
					}
					it["id"]=s;
					it["proba"]=mData[i][1];
					it["sort1"]=sort1;
					it["sort2"]=sort2;
					listData.push(it);
				}	

				//trace(sort1,sort2);
			}
			noSort || ArrayUtils.sortOn(["sort1","sort2"],listData,true); //星辰和轩辕铸宝不排序了
			this.list.array=listData;

		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(listData[index]);
		}



		override public function onRemoved():void{

		}
	}

}



import ui.inside.pubProbItemUI;
import sg.cfg.ConfigServer;
import sg.utils.Tools;
import sg.model.ModelItem;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.utils.StringUtil;
import sg.model.ModelEquip;

class Item extends pubProbItemUI{

	public function Item(){

	}

	public function setData(obj:*):void{
		this.heroRatity.visible=false;
		//this.infoLabel.wordWrap=false;
		// this.infoLabel.x=0;
		// this.infoLabel.width=this.width;
		if(obj.id.indexOf("star")!=-1){
			this.infoLabel.text=Tools.getMsgById("_public61",[obj.lv,Tools.getMsgById(obj.name)]);//Number(obj.lv)+"级"+Tools.getMsgById(obj.name);
			this.numLabel.text=StringUtil.numberToPercent(obj.proba,2,true);
			//this.com0.setData(obj.icon,7,"","",0,false);
			this.com0.setData(obj.id,-1,-1);
			//this.infoLabel.x=(this.width-this.infoLabel.width)/2;
		}else if(obj.id.indexOf("equip")!=-1){
			this.com0.setData(obj.id,-1,-1);
			this.infoLabel.text=ModelEquip.getName(obj.id,0);
			this.numLabel.text=StringUtil.numberToPercent(obj["proba"],2,true);
		}else{
			var it:Object=ModelManager.instance.modelProp.getItemProp(obj.id);
			this.infoLabel.text=it.name;
			this.numLabel.text=StringUtil.numberToPercent(obj["proba"],2,true);
			//this.com0.setData(it.icon,it.ratity,"","",it.type);
			this.com0.setData(it.id,-1,-1);
			if(it.type==7){
				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(it.id.replace("item","hero"));
				this.heroRatity.visible=true;
				this.heroRatity.skin=hmd.getRaritySkin(true);
				//this.infoLabel.x=this.heroRatity.width;
				//this.infoLabel.width=this.width-this.heroRatity.width;
			}else{
				//this.infoLabel.x=(this.width-this.infoLabel.width)/2;
			}
			
		}
		
		this.infoLabel.fontSize = this.infoLabel.text.length>=8 ? 16 : 18;
		//this.numLabel.x=this.infoLabel.x + (this.infoLabel.width-this.numLabel.width)/2;
		this.numLabel.x = heroRatity.visible ? heroRatity.x + heroRatity.width+2 : (this.width - this.numLabel.width)/2;

	}
}