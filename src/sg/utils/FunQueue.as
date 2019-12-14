package sg.utils
{
    import laya.utils.Handler;

    public class FunQueue{
        public var complete:Handler;
        private var list:Array;
        public function init (arr:Array):void
        {
            this.clear();
            this.list = arr;
            this.next ();
        }
        public function clear():void{
            if(this.list){
                var len:int = this.list.length;
                var fun:Handler;
                for(var i:int = 0; i < len; i++)
                {
                    fun = this.list[i] as Handler;
                    if(fun){
                        fun.clear();
                    }
                }
            }
        }
        public function next (data:* = null):void
        {
            if (this.list.length>0)
            {
                var fun:Handler = this.list.shift() as Handler;
                if(fun){
                    fun.runWith(data);
                }
            }
            else
            {
                if (this.complete){
                    this.complete.run();
					this.complete = null;
                }
            }        
        }
    }
}