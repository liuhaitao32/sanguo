package sg.activities.view
{
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Box;

	import sg.activities.model.ModelDial;
	import sg.utils.Tools;

	import ui.activities.dial.dialRecordUI;

	/**
	 * ...
	 * @author
	 */
	public class ViewDialRecord extends dialRecordUI{

		private var mListData:Array;
		private var mBox:Box;
		public function ViewDialRecord(){
			this.comTitle.setViewTitle(Tools.getMsgById("dial_text05"));
			this.panel.vScrollBar.visible=false;
		}


		public override function onAdded():void{
			if(mBox==null){
				mBox=new Box();
				this.panel.addChild(mBox);
			}
			this.mListData=ModelDial.instance.getRecrodsList();
			setLabel();
		}

		public function setLabel():void{
			if(mBox){
				mBox.removeChildren();
			}
			if(mListData.length>0){
				this.info.text="";
				for(var i:int=0;i<mListData.length;i++){
				/*
				var label:Label=new Label();
				label.fontSize=20;
				label.wordWrap=true;
				label.leading=5;
				label.valign="left";
				label.stroke=0;
				//label.strokeColor="#ffffff";
				label.color="#ffffff";
				label.width=553;
				label.name="label"+i;
				label.text=mListData[i];
				label.x=0;
				*/
				var label:HTMLDivElement=new HTMLDivElement();
				label.style.color="#ffffff";
				label.style.fontSize=20;
				label.style.wordWrap = true;
				label.style.leading=5;
				label.width=553;				
				label.innerHTML=mListData[i];
				label.height=label.contextHeight;
				mBox.addChild(label);
				}
				for(var j:int=0;j<mBox.numChildren;j++){
					var html:HTMLDivElement=mBox.getChildAt(j) as HTMLDivElement;
					if(j==0){
						html.y=0;
					}else{
						html.y=(mBox.getChildAt(j-1) as HTMLDivElement).y+(mBox.getChildAt(j-1) as HTMLDivElement).height;
					}
					
				}
				this.mBox.height=(mBox.getChildAt(mBox.numChildren-1) as HTMLDivElement).y+(mBox.getChildAt(mBox.numChildren-1) as HTMLDivElement).height;
		
			}else{
				this.info.text=Tools.getMsgById("dial_text14");
			}
		}


		public override function onRemoved():void{
			
		}
	}

}