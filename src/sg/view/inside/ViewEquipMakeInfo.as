package sg.view.inside
{
    import ui.inside.equip_make_infoUI;
    import sg.model.ModelEquip;
    import sg.view.com.EquipInfoAttr;
    import sg.utils.StringUtil;
    import sg.model.ModelHero;
    import sg.utils.Tools;
    import sg.cfg.ConfigColor;
    import sg.model.ModelGame;

    public class ViewEquipMakeInfo extends equip_make_infoUI
    {
        private var mInfoAttr:EquipInfoAttr;
        public function ViewEquipMakeInfo()
        {
            
        }
        override public function initData():void{
            var emd:ModelEquip = this.currArg;
            // this.tInfo.text = emd.getInfo();
            //
            this.setInfoUI(emd);
            //
        }
        private function setInfoUI(emd:ModelEquip):void
        {
            if(this.mInfoAttr){
                this.mInfoAttr.removeSelf();
                this.mInfoAttr.destroy(true);
            }
            this.icon.setData(emd.id,-1,-1);
            this.tName.text = emd.getName();
			this.tName.color = ConfigColor.FONT_COLORS[emd.getLv()];
			
			this.tType.x = this.tName.x + this.tName.textField.textWidth + 5;
			var groupName:String = emd.getGroupName();
			if (groupName){
				this.tType.text = Tools.getMsgById('_equip28', [emd.getTypeName(), groupName]);
				this.tType.bold = true;
			}
			else{
				this.tType.text = Tools.getMsgById('_equip27', [emd.getTypeName()]);
				this.tType.bold = false;
			}
			this.tType.color = ConfigColor.FONT_COLORS[emd.getMaxLv()];
			
            
            var hmd:ModelHero = emd.getMyHero();
            this.tHero.text = Tools.getMsgById('_shop_text11', [hmd?hmd.getName():Tools.getMsgById('_public76')]);
			this.tWash.text = Tools.getMsgById('_equip25');
            //
            this.mInfoAttr = null;
            this.mInfoAttr = new EquipInfoAttr(this.mBoxAttr, this.boxBg.width - 25, 0);
            this.mInfoAttr.initData(emd);
			this.mInfoAttr.y = 10;
            this.mBoxAttr.addChild(this.mInfoAttr);
            this.mBoxAttr.height = this.mInfoAttr.height + 15;
            var hh:Number = 115 + this.mInfoAttr.height + 12;
            this.washBox.visible = false;
            this.washInfo.visible = false;
            //
            var winfo:String;
            if(ModelGame.unlock(null,"equip_wash").stop){
               winfo="";
            }else{
                winfo = emd.getWashInfoHtml(true);
            }
            if(winfo!=""){
                this.washBox.visible = true;
                this.washInfo.visible = true;                
                //176
                this.washInfo.style.align = "left";
                this.washInfo.style.fontSize = 18;
                this.washInfo.style.leading = 10;
                this.washInfo.style.wordWrap = true;
                this.washInfo.innerHTML = winfo;
                //
				this.washInfo.x = 15;
                this.washBox.y = hh + 15;
                this.washInfo.y = this.washBox.y + 42;

                hh = hh + this.washInfo.contextHeight + 47;
            }
            //
            // trace(this.washInfo.contextHeight);  
            // this.washInfo.style.align = "center";
            // this.washInfo.style.fontSize = 16;
            // this.washInfo.style.leading = 5;
            // var str:String = emd.getWashInfoHtml();
            // this.washInfo.innerHTML = str;
            // this.washInfo.y = hh;
            // this.washInfo.height = (str!="")?this.washInfo.contextHeight+5:1;
            // hh+=this.washInfo.height+5;
            this.boxBg.height = hh + 20;
        }        
    }   
}