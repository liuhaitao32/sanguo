package sg.activities.view
{
	import sg.utils.Tools;

	import ui.activities.carnival.ViewEmboitementUI;
	import ui.activities.carnival.item_emboUI;
	import sg.boundFor.GotoManager;
	import laya.events.Event;

	/**
	 * ...
	 * @author
	 */
	public class ViewEmboitement extends ViewEmboitementUI{
		public var arr:Array=[];
		public var mPanel:EquipEmboitement;
		private var mEquipArr:Array;
		private var mInfo:String;
		private var mTitle:String;
		public function ViewEmboitement(){
			
			//this.titleLabel.text=Tools.getMsgById("happy_text05");
			this.panel.vScrollBar.visible=false;
			//this.list.scrollBar.visible=false;
			//this.list.renderHandler=new Handler(this,listRender);
		}

		public override function onAdded():void{
			mEquipArr=this.currArg[0];
			mInfo=this.currArg[1];
			mTitle=this.currArg[2];
			this.comTitle.setViewTitle(mTitle);
			arr=mEquipArr;//ModelHappy.instance.cfg.addup.show;
			//this.list.array=arr;
			this.info.style.fontSize=18;
			//this.info.style.wordWrap=true;
			this.info.style.align="left";
			this.info.style.valign="top";
			this.info.style.color="#ffffff";
			this.info.style.leading=5;
			this.info.innerHTML=Tools.getMsgById(mInfo);//Tools.getMsgById(ModelHappy.instance.cfg.addup.info); 
			//this.info.height=(this.info.height>232)?232:this.info.height;
			//this.box.height=this.info.y + this.info.contextHeight + 20;
			
			if(mPanel==null){
				mPanel=new EquipEmboitement(arr);
				this.box.addChild(mPanel);
				mPanel.init();
				mPanel.y=57;
				mPanel.centerX=0;
				mPanel.scale(0.9,0.9);
			}else{
				mPanel.updateUI(arr);
			}
			mPanel.btn_go.off(Event.CLICK,this,this.clickGo);
			mPanel.btn_go.on(Event.CLICK,this,this.clickGo);
		}
		private function clickGo():void{
			GotoManager.instance.boundForHome("building002",1);
		}   


		public function listRender(cell:item_emboUI,index:int):void{
			//cell.icon.setData(this.list.array[index],-1,-1);
		}



		public override function onRemoved():void{
			this.panel.vScrollBar.value=0;
			mPanel.clear();
		}
	}

}