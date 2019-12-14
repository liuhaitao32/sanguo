package sg.view.task
{
	import laya.ui.Box;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelAlert;
	import sg.model.ModelGame;
	import sg.task.model.ModelTaskBuild;
	import sg.task.model.ModelTaskDaily;
	import sg.task.model.ModelTaskOrder;
	import sg.task.model.ModelTaskPromote;
	import sg.task.model.ModelTaskTrain;
	import sg.task.view.ViewTask;
	import sg.utils.Tools;
	import sg.view.com.ItemBase;
	import ui.task.task_mainUI;
	import sg.utils.MusicManager;
	import sg.utils.ArrayUtil;

    public class ViewTaskMain extends task_mainUI
    {
        private var mBox:Box;
        private var mTabData:Array;
        private var mSelectIndex:int = -1;
        private var mFuncPanel:ItemBase;
        public function ViewTaskMain()
        {
            
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.mBox = new Box();
            this.box.addChildAt(this.mBox, 0);
        }

        override public function initData():void{
            var str:String = "";
            var arr:Array = [{txt:"_jia0025",index:0},{txt:"_jia0026",index:1},{txt:"_jia0027",index:2},{txt:"_jia0028",index:3},{txt:"_jia0029",index:4},{txt:"_jia0030",index:5}];
            this.mTabData = [];
            //
            var len:int = arr.length;
            var obj:Object;
            var b:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                b = false;
                obj = arr[i];
                if(i==0){
                    if (ModelManager.instance.modelUser.getLv() >= ConfigServer.gtask.gtask_unlockLV[0][0]){//
                        b = ModelGame.unlock(null,"task_gtask").visible;
                    }
                }
                else{
                    b = true;
                }
                if(b){
                    this.mTabData.push(obj);
                    str += Tools.getMsgById(obj.txt) + ",";
                }
            }
            this.tab.labels = str.substr(0,str.length-1);
            len = this.mTabData.length;
            for(i = 0;i < len;i++){
                this.tab.items[i].name = "tab_"+this.mTabData[i].index;
            }            
            //
            var index:int = this.currArg is Number ? this.currArg : 0;
            var index2:int = ArrayUtil.findIndex(this.mTabData, function (item:*):Boolean { return item['index'] === index;});
            this.tab.selectedIndex = index2 > 0 ? index2 : 0;
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_RED,this,this.checkRed);
            this.checkRed();
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_TASK_RED,this,this.checkRed);

            this.tab.selectedIndex = -1;
        }
        private function checkRed():void
        {
            ModelGame.redCheckOnce(this.tab.getChildByName("tab_0"),!ModelGame.unlock(null,"task_gtask").stop && ModelAlert.red_task_check(0));
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_1"), ModelAlert.red_task_check(1));
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_2"), ModelAlert.red_task_check(2));
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_3"), ModelAlert.red_task_check(3));
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_4"), ModelAlert.red_task_check(4));
			ModelGame.redCheckOnce(this.tab.getChildByName("tab_5"), ModelAlert.red_task_check(5));
        }
        private function tab_select(index:*):void
        {
            this.clearFuncPanel();
            //
            if(index>-1){
                var obj:Object = this.mTabData[Number(index)];
				this.setTitle(Tools.getMsgById(obj.txt));
				
				//var oriY:Number = this.y + this.tab.y + this.tab.height;
                this.mBox.y = this.tab.height;
                switch(obj.index)
                {
                    case 0:
                        this.mFuncPanel = new ViewWorkMain() as ItemBase;
                        break;
                    case 1:
                        this.mFuncPanel = new ViewTask(ModelTaskDaily.instance);
                        break;
                    case 2:
                        this.mFuncPanel = new ViewTask(ModelTaskTrain.instance);
                        break;
                    case 3:
                        this.mFuncPanel = new ViewTask(ModelTaskBuild.instance);
                        break;
                    case 4:
                        this.mFuncPanel = new ViewTask(ModelTaskOrder.instance);
                        break;
                    case 5:
                        this.mFuncPanel = new ViewTask(ModelTaskPromote.instance);
                        break;
                    default:
                        break;
                }
                if(this.mFuncPanel){
                    this.mBox.addChild(this.mFuncPanel);
                }
            }
        } 
        private function clearFuncPanel():void{
            this.mBox.destroyChildren();
            this.mFuncPanel = null;
        }
    }
}