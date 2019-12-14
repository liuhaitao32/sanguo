package sg.view.com
{
    import laya.ui.Box;
    import sg.model.ModelEquip;
    import ui.com.equip_info_attrUI;
    import sg.manager.EffectManager;
    import laya.ui.Panel;
    import laya.display.Sprite;
    import sg.manager.AssetsManager;
    import sg.model.ModelFormation;
    import sg.model.ModelHero;

    public class EquipInfoAttr extends ItemBase
    {
        private var mBoxRuler:Sprite;
        private var mW:Number;
        private var mH:Number;
        private var mModel:*;
        private var mMax:Number;
        private var mArr:Array;
        private var mLv:Number;
        private var mPanel:Panel;
        public function EquipInfoAttr(bg:Sprite = null,w:Number=0,h:Number=0)
        {
            if(bg){
                this.mBoxRuler = bg;
                this.x = 5;
                this.y = 5;
            }
            this.mW = w;
            this.mH = h;
            //
            this.mPanel = new Panel();
            this.mPanel.vScrollBarSkin = AssetsManager.getAssetsCOMP("vscroll.png");
            this.mPanel.vScrollBar.hide = true;
            this.mPanel.x = 0;
            this.mPanel.y = 0;
            this.addChild(this.mPanel);
        }
        /**
         * 设置宝物洗练属性
         */
        public function initData(emd:ModelEquip):void{
            this.mModel = emd;
            this.mMax = emd.getMaxLv();
            this.mLv = emd.isMine()?emd.getLv():0;
            this.mArr = [];            
            //
            this.initUI();
        }
        /**
         * 设置阵法属性
         */
        public function initFormation(fmd:ModelFormation,hmd:ModelHero):void{
            this.mModel = fmd;
            this.mMax = fmd.maxStar();
            this.mLv = fmd.curStar(hmd);
            this.mArr = [];
            this.initUI();
        }

        public function updateFormation():void{

        }

        private function initUI():void
        {
            this.clearPanel();
            //
            var len:int = this.mMax +1;
            var item:equip_info_attrUI;

            var h:Number = 0;
            var w:Number = 0;
            var lnum:Number = 30;
            for(var i:int = 0;i < len;i++){
                item = new equip_info_attrUI();
                if(this.mW>0){
                    item.txt.width = this.mW - lnum;
                }
                else{
                    item.txt.width = 252;
                }
                item.icon.toggle = false;
                item.icon.selected = (this.mLv>=i);
                EffectManager.changeSprColor(item.icon,i);
                item.txt.text = this.mModel.getAttrInfo(i);
                item.txt.leading = 5;
                item.txt.color = (this.mLv>=i)?"#e2f2ff":"#999999";
                item.width = this.mW>0?this.mW:w;
                //
                this.mPanel.addChild(item);
                //
                item.height = item.txt.displayHeight+3;
                item.height = (item.height<20)?15:item.height;
                w = item.width;
                if(i>0){
                    item.y = h;
                }
                if(i<len){
                    h+=item.height+10;             
                }
            }
            h-=10;
            this.mPanel.width = this.mW>0?this.mW:w;
            this.mPanel.height = this.mH>0?this.mH:h;
            this.width = this.mPanel.width;
            this.height = this.mPanel.height;

        }
        public function updateData(emd:ModelEquip):void{
            this.mModel = emd;
            this.mMax = emd.getMaxLv();
            this.mLv = emd.isMine()?emd.getLv():-1;  
            var len:int = this.mArr.length;
            var item:equip_info_attrUI;
            for(var i:int = 0;i < len;i++){
                item = this.mArr[i];
                item.icon.selected = (this.mLv>=i);
                item.txt.color = (this.mLv>=i)?"#e2f2ff":"#999999";              
            }
        }

        /**
         * 设置面板高度
         */
        public function getPanelHeight():Number{
            var n:Number=0;
            var item:equip_info_attrUI=this.mPanel.getChildAt(this.mPanel.numChildren-1) as equip_info_attrUI;
            n = item.y+item.height+4;
            this.mPanel.height = n;
            return n;
        }

        private function clearPanel():void
        {
            if(this.mPanel){
                this.mPanel.destroyChildren();
            }
        }
        override public function clear():void
        {
            this.mBoxRuler = null;
            this.mModel = null;
            this.mArr = null;
            this.clearPanel();
            this.destroy(true);
        }
    }
}