package sg.view.com
{
    import ui.com.progress_cd_freeUI;
    import sg.utils.Tools;

    public class ProgressCDfree extends progress_cd_freeUI{

        private var mMax:Number = 0;
        private var mCurr:Number = 0;
        private var mFree:Number = 0;
        private var mWidth:Number = 0;
        private var mP:Number = 0;
        public function ProgressCDfree(){

        }
        public function initData(w:Number,max:Number,curr:Number = 0,free:Number = 0):void{
            this.mWidth = w;
            //
            this.mMax = max;
            this.mCurr = curr;
            this.mFree = free;
            
            //
            this.width = this.mWidth;
            //
            this.check();
        }
        private function checkFree():void{
            this.free.visible = this.mFree>0;
            this.free.width = Math.floor(this.mWidth * (this.mFree/this.mMax));
            this.free.x = this.mWidth - this.free.width;           
        }
        public function recommendNum(mi:Number):void{
            var pp:Number = (mi*Tools.oneMinuteMilli+this.mCurr)/this.mMax;
            pp = (pp>1)?1:pp;
            this.bg.width = Math.floor(pp*this.mWidth);
        }
        private function check():void{
            this.checkOK();
            this.checkFree();
            if(this.isFree()){
                this.free.width = this.mWidth;
                this.free.x = 0;
                this.ok.visible = false;
            } 
        }
        private function checkOK():void{
            this.ok.visible = true;
            this.mP = this.mCurr/this.mMax;
            this.ok.width = Math.floor(this.mWidth * (this.mP));
            this.ok.x = 0;
        }
        public function isFree():Boolean{
            if(this.mFree>0 && (this.mMax - mCurr)<=this.mFree){
                return true;
            }
            else{
                return false;
            }
        }
        public function setPercent(p:Number):void{
            this.mP = p;
            this.mCurr = this.mMax * this.mP;
            //
            this.check();
        }
        public function setValue(curr:Number):void{
            this.mCurr = curr;
            //
            this.check();
        }       
    }   
}