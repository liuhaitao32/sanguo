package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightEvent;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	import sg.utils.StringUtil;
	import ui.battle.fightCountryConfirmPanelUI;
	import ui.com.payTypeUI;
	/**
	 * 国战中使用任意工具的确认面板
	 * @author zhuda
	 */
	public class ViewFightCountryConfirmPanel extends fightCountryConfirmPanelUI
	{
		public var data:Object;
		
		public function ViewFightCountryConfirmPanel(data:Object) 
		{
			this.data = data;
			this.once(Event.ADDED, this, this.initUI);
			
			
			this.htmlInfo.style.fontSize = 20;
            this.htmlInfo.style.align = 'center';
			//this.htmlInfo.style.valign = 'middle';
            this.htmlInfo.style.color = '#88a3ab';
            this.htmlInfo.style.leading = 8;
            this.htmlInfo.style.wordWrap = true;
		}

		
		public function initUI():void
		{
			this.once(Event.REMOVED, this, this.onRemoved);
			this.btnOk.on(Event.CLICK, this, this.onOk);
			this.btnCheck.on(Event.CLICK, this, this.onCheck);
			this.btnClose.on(Event.CLICK, this, this.onClose);
			this.initBoxRepeat();
			this.setUI();
		}
		private function initBoxRepeat():void
		{
			this.boxRepeat.visible=false;
			this.btnCheck.selected=false;
			if(this.data.repeatKey!=''){
				this.txtRepeat.text=Tools.getMsgById('193006');
				this.boxRepeat.visible=true;
				this.btnCheck.x=this.txtRepeat.width+10;
				this.boxRepeat.width=this.btnCheck.x+this.btnCheck.width;
				this.boxRepeat.centerX=0;
			}
		}
		private function setUI(isRe:Boolean=false,data:*=null):void
		{
			this.removeUpdateEvent();
			FightEvent.ED.on(EventConstant.SPEED_UP_FIGHT, this, this.setUI, [true]);
			if (isRe){
				if (data){
					if (data.type == 'speedUp'){
						this.onClose();
					}
				}
			}
		
			this.txtTitle.text = this.data.title;
			this.htmlInfo.innerHTML = StringUtil.substituteWithLineAndColor(this.data.info, '#FCAA44', '#ffffff');
			this.btnOk.label = this.data.btn;
			var item:payTypeUI = this.data.item;
			if(item){
				this.costItem.setData(item.mImg.skin, item['maxTxt']);
				this.costItem.changeTxtColor(item.mLabel.color);
			}
		}
		//public function updateUI():void
		//{
			//this.setUI();
		//}
		
		//public function setData(data:Object):void
		//{
			//this.data = data;
			//this.setUI();
		//}
		
		public function onOk():void
		{
			if (this.data){
				if (this.data.fun){
					this.data.fun.apply(this.data.call, this.data.args);
				}
				this.setLocal();
				if (this.data.close){
					this.onClose();
				}
			}
		}
		public function onCheck():void{
			this.btnCheck.selected=!this.btnCheck.selected;
		}
		public function setLocal():void{
			if(data.repeatKey!='' && this.btnCheck.selected){
				Tools.setAlertIsDel(data.repeatKey);
			}
		}
		
		public function onClose():void
		{
			FightMain.instance.ui.closePopView();
		}
		
		private function removeUpdateEvent():void{
            FightEvent.ED.off(EventConstant.SPEED_UP_FIGHT, this, this.setUI);
			FightEvent.ED.off(EventConstant.CALL_CAR_FIGHT, this, this.setUI);
        }
		
		private function onRemoved():void{
			this.removeUpdateEvent();
        }
	}

}