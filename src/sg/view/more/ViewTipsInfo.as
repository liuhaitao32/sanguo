package sg.view.more
{
    import ui.more.tips_infoUI;

    public class ViewTipsInfo extends tips_infoUI
    {
        private var mStyle:Object;
        public function ViewTipsInfo()
        {
            this.mBg.alpha = 0;
        }
        override public function initData():void{
            //#88a3ab
            //
            var tbN:Number = 15;
            var lrN:Number = 15;
            var titleY:Number = tbN;
            var infoY:Number = tbN;
            var txtH:Number = 0;
            var leadingN:Number = 8;
            //            
            var info:String = this.currArg[0];
            var title:String = this.currArg[2];
            var newW:Number = this.currArg[1];
            this.mStyle = this.currArg[3];
            var ww:Number = 360;
            if(newW>0){
                ww = newW;
            }
            //
            this.tTitle.visible = false;
            //
            this.tInfo.style.fontSize = 20;
            this.tInfo.style.align = "left";
            this.tInfo.style.color = (this.mStyle && this.mStyle.iColor)?this.mStyle.iColor:"#88a3ab";
            this.tInfo.style.leading = leadingN;
            this.tInfo.style.wordWrap = true;
            this.tInfo.innerHTML = info;
            this.tInfo.width = ww-lrN*2;
            this.tInfo.x = lrN;
            //
            this.tTitle.style.fontSize = 22;
            this.tTitle.style.align = "left";
            this.tTitle.style.color = (this.mStyle && this.mStyle.tColor)?this.mStyle.tColor:"#AAEAEF";
            this.tTitle.width = this.tInfo.width;
            this.tTitle.x = lrN;

            if(title){
                this.tTitle.innerHTML = title;
                this.tTitle.visible = true;
                infoY = titleY+this.tTitle.contextHeight+leadingN*2;
            }
            this.tTitle.y = titleY;
            this.tInfo.y = infoY;
            txtH = infoY + this.tInfo.contextHeight+tbN;
            //
            this.box.height = txtH;           
            this.box.width = ww;           
        }        
    }
}