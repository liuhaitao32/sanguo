package sg.view.inside
{
	import ui.inside.shogunLvUpUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelHero;
	import laya.events.Event;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewShogunLvUp extends shogunLvUpUI{

		public var curLv:Number=0;
		public var useItemName:String="";
		public var configData:Object={};
		public var curIndex:int=0;
		public var bLv:int=0;
		public function ViewShogunLvUp(){
			this.btn0.on(Event.CLICK,this,this.btnClick,[0]);
			this.btn1.on(Event.CLICK,this,this.btnClick,[1]);
			this.comPay1.on(Event.CLICK,this,click);
		}

		public function click():void{
			ViewManager.instance.showItemTips(useItemName);
		}

		override public function onAdded():void{
			this.btn0.label=Tools.getMsgById("_shogun_text03");
			this.btn1.label=Tools.getMsgById("_public183");
			this.textX.text=Tools.getMsgById("_shogun_text04");

			bLv=ModelManager.instance.modelInside.getBase().lv;
			curIndex=this.currArg;
			curLv=ModelManager.instance.modelUser.shogun[curIndex].lv;
			configData=ConfigServer.shogun;
			useItemName=configData.shogun_book[curIndex];//消耗道具
			var cur_lv_data:Array=[];//configData.shogun_levelup[curLv];
			var next_lv_data:Array=[];
			cur_lv_data=configData.shogun_levelup[curLv-1];
			next_lv_data=configData.shogun_levelup[curLv];
			this.titleLabel.text=Tools.getMsgById("_building42",[ModelHero.shogun_name[curIndex+1]]);//ModelHero.shogun_name[curIndex+1]+"府升级";
			this.text01.text=Tools.getMsgById("_building43");//"等级";
			this.text02.text=curLv+"";
			this.text03.text=(curLv+1)+"";
			//this.box0.width=this.text01.width+this.text02.width+this.text03.width+this.img01.width+18;
			//this.text01.x=0;
			//this.text02.x=this.text01.width+this.text01.x+6;
			//this.img01.x=this.text02.width+this.text02.x+6;
			//this.text03.x=this.img01.width+this.img01.x+6;
			//this.box0.centerX=0;
			
			this.text11.text=Tools.getMsgById("_building44");//"英雄评分上限";
			this.text12.text=cur_lv_data[2]+"";
			this.text13.text=next_lv_data[2]+"";
			//this.box1.width=this.text11.width+this.text12.width+this.text13.width+this.img11.width+18;
			//this.text11.x=0;
			//this.text12.x=this.text11.width+this.text11.x+6;
			//this.img11.x=this.text12.width+this.text12.x+6;
			//this.text13.x=this.img11.width+this.img11.x+6;
			//this.box1.centerX=0;
			this.lvLabel.text=Tools.getMsgById("_public58",[next_lv_data[3]]);//"官邸"+next_lv_data[3]+"级开启";
			this.lvLabel.color=bLv>=next_lv_data[3]?"#ffffff":"#ff7358";
			var nn:int=ModelManager.instance.modelUser.gold>=cur_lv_data[1]?0:1;
			this.comPay0.setData(AssetsManager.getAssetItemOrPayByID("gold"),cur_lv_data[1],nn);
			var n:int=ModelManager.instance.modelUser.property.hasOwnProperty(useItemName)?ModelManager.instance.modelUser.property[useItemName]:0;
			var m:int=n>=cur_lv_data[0]?0:1;
			this.comPay1.setData(AssetsManager.getAssetItemOrPayByID(useItemName),n+"/"+cur_lv_data[0],m);
			//this.lvLabel.color="";
		}


		public function btnClick(index:int):void{
			if(index==0){
				ViewManager.instance.closePanel(this);
				return;
			}
			if(!Tools.isCanBuy("gold",configData.shogun_levelup[curLv-1][1])){
				return;
			}
			if(!Tools.isCanBuy(useItemName,configData.shogun_levelup[curLv-1][0])){
				return;
			}
			var slv:int=configData.shogun_levelup[curLv][3];
			if(bLv<slv){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public59",[slv]));//"官邸等级到达"+slv+"时可升级"
				return;
			}
			//return;
			NetSocket.instance.send("shogun_lvup",{"shogun_index":curIndex},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public60"));//升级成功
				//ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_SHOGUN_HERO);
				ViewManager.instance.closePanel(this);
				ModelManager.instance.modelInside.updateBaseBuilding();
			}));
		}
		


		override public function onRemoved():void{

		}
	}

}