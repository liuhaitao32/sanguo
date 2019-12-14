package sg.view.bag
{
	import ui.shop.shopItemTipsUI;
	import sg.model.ModelItem;
	import sg.manager.ModelManager;
	import sg.model.ModelRune;
	import sg.cfg.ConfigServer;
	import sg.model.ModelEquip;
	import sg.utils.Tools;
	import sg.model.ModelSalePay;

	/**
	 * ...
	 * @author
	 */
	public class ViewBagItemTips extends shopItemTipsUI{

		public var itemID:String;
		public var num:Number=0;
		public function ViewBagItemTips(){
			this.mBg.alpha = 0;
		}


		override public function onAdded():void{
			itemID=this.currArg[0];
			num=this.currArg[1]?this.currArg[1]:0;
			if(ModelManager.instance.modelProp.allProp.hasOwnProperty(itemID)){
				var item:ModelItem=ModelManager.instance.modelProp.getItemProp(itemID);
				this.icon.setData(item.id,-1,-1);
				this.nameLabel.text = item.getName(true);
				this.nameLabel.color = item.getColor();
				if(num==-1){
					this.numLabel.text=Tools.getMsgById("_public18",[item.num+""]);
				}else{
					this.numLabel.text=Tools.getMsgById("_public18",[num+""]);
				}
				this.infoLabel.text=item.info;
			}else if(itemID.indexOf("star")!=-1){
				var sStr:String=itemID.substr(0,6);
				var itemRune:ModelRune=new ModelRune();
				itemRune.initData(sStr,ConfigServer.star[sStr]);
				this.icon.setData(itemRune.id,-1,-1);
				this.nameLabel.text=itemRune.getName(true);
				this.numLabel.text=Tools.getMsgById("_public18",[ModelRune.getNum(itemID)+""]);
				//this.infoLabel.text=itemRune.getInfoHtml();
				this.infoLabel.text=itemRune.getCfgInfo();
			}else if(itemID.indexOf("equip")!=-1){
				var emd:ModelEquip=new ModelEquip();
				emd.initData(itemID,ConfigServer.equip[itemID]);
				this.icon.setData(emd.id,-1,-1);
				this.nameLabel.text=emd.getName();
				this.numLabel.text="";
				this.infoLabel.text=emd.getInfo();
			}else if(itemID.indexOf("sale")!=-1){
				var saleArr:Array = itemID.indexOf("|") ? itemID.split('|') : [itemID,0];
				var spmd:ModelSalePay = ModelSalePay.getModel(saleArr[0]);
				this.icon.setData(spmd.id,-1,-1);
				this.nameLabel.text=spmd.getName(saleArr[1]);
				this.numLabel.text="";
				this.infoLabel.text=spmd.getInfo();
			}
			this.box.height=this.infoLabel.y+this.infoLabel.height+4;
		}



		override public function onRemoved():void{
			
		}
	}

}