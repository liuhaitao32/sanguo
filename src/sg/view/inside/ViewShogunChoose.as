package sg.view.inside
{
	import ui.inside.shogunChooseUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelUser;
	import laya.maths.MathUtil;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewShogunChoose extends shogunChooseUI{

		public var mData:Array=[];
		public var listData:Array=[];
		public var curHeroIndex:int;
		public var userData:Object={};
		public function ViewShogunChoose(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.list.selectHandler=new Handler(this,selectHandler);
			this.downBtn.on(Event.CLICK,this,this.btnClick);
			this.downBtn.label=Tools.getMsgById("_public51");
		}

		override public function onAdded():void{
			//this.titleLabel.text=Tools.getMsgById("_shogun_text06");
			this.comTitle.setViewTitle(Tools.getMsgById("_shogun_text06"));
			curHeroIndex=-1;
			mData=this.currArg;//[shogun_index,h_index,hid,shogun_lv]
			// trace("shogun--",mData);
			userData=ModelManager.instance.modelUser.shogun[mData[0]];
			setData();
			
		}

		public function setData():void{
			listData=ModelHero.getShogunHeroList(mData[0],mData[3]);
			for(var i:int=0;i<listData.length;i++){
				var md:ModelHero=listData[i];
				if(md.id==mData[2]){
					//itemClick(i);
					curHeroIndex=i;
					break;
				}else{
					curHeroIndex=-1;
				}
			}
			this.list.array=listData;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index],mData[3]);
			//cell.off(Event.CLICK,this,this.itemClick,[index]);
			cell.offAll();
			cell.on(Event.CLICK,this,this.itemClick,[index]);
			if(index==curHeroIndex){
				cell.setSelection(true);
			}
		}

		public function selectHandler(index:int):void{
			if(index>=0){
               // this.setSelection(true);
            }
		}

		public function itemClick(index:int):void{
			if(index==curHeroIndex)
				return;
			//this.setSelection(false);
			this.list.selectedIndex=index;
			curHeroIndex=index;
			//if(this.list.array[index] && this.list.array[index].id==mData[2]){
				//this.downBtn.label="卸下";
			//}else{
				//this.downBtn.label=Tools.getMsgById("_public51");//"上阵";
			//}
		}

		public function setSelection(b:Boolean):void{
			if(this.list.selection){
				var item:Item=this.list.selection as Item;
				item.setSelection(b);
			}
		}

		public function btnClick():void{
			if(curHeroIndex==-1){
				return;
			}
			var hids:Array=userData.hids;
			var up_hid:String=this.list.array[curHeroIndex].id;
			if(up_hid==mData[2]){//卸下
				//hids[mData[1]]=null;
				ViewManager.instance.closePanel(this);
				return;
			}else{//上阵
				var n:int=hids.indexOf(up_hid);
					hids[mData[1]]=up_hid;
				if(n!=-1){
					hids[n]=mData[2];
				}
				
			}

			for(var i:int=0;i<hids.length;i++){
				if(hids[i]=="block" || hids[i]==""){
					hids[i]=null;
				}
			}
			// trace("shogun--",hids);			
			NetSocket.instance.send("shogun_install_hid",{"shogun_index":mData[0],"hids":hids},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				//ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_SHOGUN_HERO);
				ViewManager.instance.closePanel(this);
			}));
		}

		override public function onRemoved():void{
			//this.setSelection(false);
			curHeroIndex=-1;
			this.list.selectedIndex=-1;
		}
	}

}

import ui.inside.shogunHeroItemUI;
import sg.model.ModelHero;
import sg.model.ModelBuiding;
import sg.utils.Tools;

class Item extends shogunHeroItemUI{
	public function Item(){

	}

	public function setData(hmd:ModelHero,shogun_lv:int):void{
		this.text0.text=Tools.getMsgById("_public52");
		this.text4.text=Tools.getMsgById("_shogun_text11");
		
		setSelection(false);
		this.limitLabel.visible=this.upBtn.visible=this.box1.visible=this.box2.visible=this.box3.visible=false;
		this.downBtn.visible=false;
		this.nameLabel.text=hmd.getName();
		this.comHeroIcon.setHeroIcon(hmd.getHeadId());
		this.comHeroStar.setHeroStar(hmd.getStar());
		this.comHeroType.setHeroType(hmd.getType());
		this.army0.setArmyIcon(hmd.army[0],ModelBuiding.getArmyCurrGradeByType(hmd.army[0]));
		this.army1.setArmyIcon(hmd.army[1],ModelBuiding.getArmyCurrGradeByType(hmd.army[1]));
		
		this.tArmy0.text=hmd.getMyarmyName()[0];
		this.tArmy1.text=hmd.getMyarmyName()[1];

		this.imgRatity.skin=hmd.getRaritySkin(true);
		this.upBox.visible=(hmd.getHeroShogun()!="");
		this.shogunLabel.text=hmd.getHeroShogun();
		this.downBtn.visible=false;
		var o:Object=hmd.getShogunScore(shogun_lv);
		

        // this.armyLv0.setArmyLv(ModelBuiding.getArmyCurrGradeByType(hmd.army[0]));
        // this.armyLv1.setArmyLv(ModelBuiding.getArmyCurrGradeByType(hmd.army[1]));

		this.rankImg.skin=ModelHero.shogun_rank_color[o.rank];
		this.scoreLabel.text=o.score;
		this.lvLabel.text=hmd.getLv()+"";
	}

	public function setSelection(b:Boolean):void{
		this.imgSelected.visible=b;		
	}
}