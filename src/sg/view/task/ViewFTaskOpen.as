package sg.view.task
{
	import ui.task.ftask_openUI;
	import ui.bag.bagItemUI;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import laya.ui.Button;
	import laya.events.Event;
	import laya.maths.Point;

	/**
	 * ...
	 * @author
	 */
	public class ViewFTaskOpen extends ftask_openUI{
		
		private var mCid:String="";
		private var reward:Object={};
		private var n:Number=0;
		public function ViewFTaskOpen(){
			this.list.scrollBar.visible=false;
			//this.list.itemRender=bagItemUI;
			this.list.renderHandler=new Handler(this,listRender);
			var btn:Button=new Button;
			this.addChild(btn);
			btn.alpha=0;
			btn.width=this.width;
			btn.height=this.height;
			btn.centerX=btn.centerY=0;
			btn.on(Event.CLICK,this,click);
		}

		public override function onAdded():void{
			this.text0.text=Tools.getMsgById("_ftask_text07");
			this.text1.text=Tools.getMsgById("_ftask_text08");
			this.text2.text=Tools.getMsgById("_public114");
			n=0;
			mCid=this.currArg[0];
			reward=this.currArg[1];
			this.cityLabel.text=Tools.getMsgById(ConfigServer.city[mCid].name);

			var arr:Array=ModelManager.instance.modelProp.getRewardProp(reward);
			this.list.array=arr;
		}


		public function listRender(cell:bagItemUI,index:int):void{
			var it:Array=this.list.array[index];
			//cell.scaleX=0.6;
			//cell.scaleY=0.6;
			//cell.setData(it.icon,it.ratity,"",it.addNum+"",it.type);
			cell.setData(it[0],it[1]);
		}

		public function click():void{
			//if(n==0){
				for(var i:int=0;i<this.list.array.length;i++){
					var obj:Object={};
					obj[this.list.array[i][0]] = this.list.array[i][1];
					//ViewManager.instance.showIcon(obj, list.x + 48 + 96 * i, this.height / 2 +150);
					var itemCell:* = this.list.getCell(i);
					var pos:Point = Point.TEMP.setTo(itemCell.x + itemCell.width/2, itemCell.y + itemCell.height/2);
            		pos = itemCell['parent'].localToGlobal(pos, true);
					ViewManager.instance.showIcon(obj, pos.x, pos.y);
				}
				
			//}else{
				this.closeSelf();
			//}
			//n+=1;
		}


		public override function onRemoved():void{

		}
	}

}