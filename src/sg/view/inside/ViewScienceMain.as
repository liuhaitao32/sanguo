package sg.view.inside
{
    import ui.inside.science_mainUI;
    import ui.inside.item_scienceUI;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelScience;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelInside;
    import sg.model.ModelBuiding;
    import laya.maths.Point;
    import laya.ui.Image;
    import sg.utils.Tools;

    public class ViewScienceMain extends science_mainUI
    {
        private var mArrTable:Object;
        private var mArr:Array;
        private var mModelUpgrade:ModelScience;
        private var mScrollBarMax:Number;
        private var mScrollBarIndex:Number;
        private var mDic:Object;
        private var mMaxX:Number;
        private var mMaxY:Number;
        public function ViewScienceMain()
        {   
            this.list.itemRender = ItemScience;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
            this.mDic = {};
            this.mArrTable = {};
            this.mArr = [];
            this.mMaxX = 5;
            this.mMaxY = 0;
            var smd:ModelScience;
            for(var key:String in ConfigServer.science)
            {
                if(key!="science_type"){
                    smd = ModelManager.instance.modelGame.getModelScience(key);
                    smd["px"] = smd.coordinate[0];
                    smd["py"] = smd.coordinate[1];
                    this.mMaxY = Math.max(this.mMaxY,smd["py"]);
                    this.mArrTable[smd.coordinate[0]+"_"+smd.coordinate[1]] = smd.id;
                }
            }
            this.mScrollBarMax = -1;
            var len:Number = this.mMaxX*this.mMaxY;
            //
            var xy:String = "";
            for(var i:int = 0; i < len; i++)
            {   
                xy = ((i%5)+1)+"_"+(Math.floor(i/5)+1);
                this.mArr.push(xy);
                if(this.mArrTable.hasOwnProperty(xy)){
                    smd = ModelManager.instance.modelGame.getModelScience(this.mArrTable[xy]);
                    this.checkXY(smd);
                }
            }      
            ItemScience.mDic = this.mDic;
        }
        private function checkXY(smd:ModelScience):void
        {
            var pmd:ModelScience;
            var xy:String = smd.coordinate[0]+"_"+smd.coordinate[1];
            if(!this.mDic.hasOwnProperty(xy)){
                this.mDic[xy] = {x:smd.coordinate[0],y:smd.coordinate[1],key:xy};
            }
            var i:int = 0;
            for(i=0;i < smd.upper_level.length;i++){
                this.check_parent(smd.upper_level[i],xy,smd);
            }
            for(i=0;i < smd.lower_level.length;i++){
                this.check_child(smd.lower_level[i],xy);
            }
            
        }
        private function check_child(childID:String,selfXY:String):void
        {
            var smd:ModelScience = ModelManager.instance.modelGame.getModelScience(this.mArrTable[selfXY]);
            var mlv:Number = smd.getLv();
            var childMD:ModelScience = ModelManager.instance.modelGame.getModelScience(childID);
            var cx:Number = childMD.coordinate[0];
            var cy:Number = childMD.coordinate[1];
            //
            var i:Number = 0;
            var xx:Number = this.mDic[selfXY].x;
            var yy:Number = this.mDic[selfXY].y;  
            //
            this.mDic[selfXY]["l9"]=mlv;
            if(yy<cy){
                //
                if(cx<xx){
                    this.mDic[selfXY]["l10"]=mlv;
                }
                else if(cx>xx){
                    this.mDic[selfXY]["l12"]=mlv;
                }
            }
            else{
                if(cx<xx){
                    this.mDic[selfXY]["l6"]=mlv;
                }
                else if(cx>xx){
                    this.mDic[selfXY]["l8"]=mlv;
                }                
            }
        }
        private function check_parent(parentID:String,selfXY:String,smd:ModelScience):void
        {
            var parentMD:ModelScience = ModelManager.instance.modelGame.getModelScience(parentID);
            var plv:Number = parentMD.getLv();
            var px:Number = parentMD.coordinate[0];
            var py:Number = parentMD.coordinate[1];
            //
            var mlv:Number = smd.getLv();
            var i:Number = 0;
            var xx:Number = this.mDic[selfXY].x;
            var yy:Number = this.mDic[selfXY].y;
            if(px==xx){//父级 =x
                if(py<yy){
                    this.mDic[selfXY]["l3"]=plv;
                }
            }
            else if(px<xx){//父级 <x
                if(py<yy){
                    this.mDic[selfXY]["l3"]=plv;
                    this.mDic[selfXY]["l2"]=plv;
                }
                else if(py==yy){
                    this.mDic[selfXY]["l6"]=plv;
                }
            }
            else{
                if(py<yy){//父级 >x
                    this.mDic[selfXY]["l3"]=plv;
                    this.mDic[selfXY]["l4"]=plv;
                }
                else if(py==yy){
                    this.mDic[selfXY]["l8"]=plv;
                }                
            }
            this.check_x(px,py,selfXY,plv);
            this.check_y(px,py,selfXY,plv);
        }
        private function check_y(px:Number,py:Number,selfXY:String,plv:Number):void
        {
            var i:Number = 0;
            var xx:Number = this.mDic[selfXY].x;
            var yy:Number = this.mDic[selfXY].y;
            var xy:String = "";
            for(i=yy-1;i>py;i--){
                xy = xx+"_"+i;
                if(!this.mArrTable.hasOwnProperty(xy)){//空
                    if(!this.mDic.hasOwnProperty(xy)){
                        this.mDic[xy] = {x:xx,y:i,key:xy};
                    }          
                    // if(i==yy){//就在上面 
                        if(px == xx){//同轴
                            this.mDic[xy]["l3"]=plv;
                            this.mDic[xy]["l9"]=plv;
                        }
                    // }
                }
            }            
        }
        private function check_x(px:Number,py:Number,selfXY:String,plv:Number):void
        {
            var i:Number = 0;
            var xx:Number = this.mDic[selfXY].x;
            var yy:Number = this.mDic[selfXY].y;
            var xy:String = "";
            var pmd:ModelScience = ModelManager.instance.modelGame.getModelScience(this.mArrTable[px+"_"+py]);
            var rmd:ModelScience;
            for(i=1;i<=5;i++){
                xy = i+"_"+yy;
                if(i!=xx){//不是自己
                    if(!this.mDic.hasOwnProperty(xy)){
                        this.mDic[xy] = {x:i,y:yy,key:xy};
                    }                
                    if(!this.mArrTable.hasOwnProperty(xy)){//空
                        if((yy-py)==1){//自己的p就在头上
                            if(i<xx){//自己在右
                                if(i==px){
                                    this.mDic[xy]["l4"]=plv;
                                }
                                else if(px>i){
                                    
                                }
                                else{
                                    this.mDic[xy]["l2"]=plv;
                                    this.mDic[xy]["l4"]=plv;
                                } 
                            }
                            else{//自己在左
                                if(i==px){
                                    this.mDic[xy]["l2"]=plv;
                                }
                                else if(px>i){
                                    this.mDic[xy]["l2"]=plv;
                                    this.mDic[xy]["l4"]=plv;                                            
                                } 
                                else{
                                    
                                }                                       
                            }                                       
                        }
                        else if(yy == py){//p在同一行
                            if(i>xx){
                                if(i<px){
                                    this.mDic[xy]["l6"]=plv;
                                    this.mDic[xy]["l8"]=plv;                                              
                                }
                            }
                            else if(i<xx){
                                if(i>px){
                                    this.mDic[xy]["l6"]=plv;
                                    this.mDic[xy]["l8"]=plv;                                            
                                }
                            }
                        }
                    }
                    else{

                        rmd = ModelManager.instance.modelGame.getModelScience(this.mArrTable[xy]);                                               
                        if(rmd.upper_level.indexOf(pmd.id)>-1){
                            if((yy-py)==1){//自己的p就在头上
                                if(i<xx){
                                    if(i>px){
                                        this.mDic[xy]["l4"]=plv;
                                    }
                                }
                                else if(i>xx){
                                    if(i<px){
                                        this.mDic[xy]["l2"]=plv;
                                    }
                                }
                            }
                        }
                    }
                }
            }            
        }

        private function list_scroll(v:Number):void
        {
            if(v>=this.mScrollBarMax){
                this.list.scrollBar.value = this.mScrollBarMax;
                // this.list.scrollBar.stopScroll();
                this.box_unlock.visible = this.mScrollBarMax<this.list.scrollBar.max;
            }
            else{
                this.box_unlock.visible = false;
            }
            
            if(this.box_unlock.visible){
                var len:int = this.list.content.numChildren;
                var item:ItemScience;
                for(var i:int = 0; i < len; i++)
                {
                    item = (this.list.content.getChildAt(i) as ItemScience);
                    if(item.mModel){
                        
                        if(item.mModel.hasOwnProperty("mScrollBarIndex")){
                            var po:Point = new Point(item.x,item.y);
                            po = this.globalToLocal(this.list.content.localToGlobal(po));
                            this.box_unlock.y = po.y;
                        }
                    }
                }
                
            }
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelInside.SCIENCE_CHANGE_STATUS,this,this.update_smd);
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelInside.SCIENCE_CHANGE_STATUS,this,this.update_smd);
            this.timer.clear(ModelManager.instance.modelInside,ModelManager.instance.modelInside.checkScienceGet);
            //
            if(this.list){
                if(this.list.content && this.list.content.numChildren>0){
                    for(var i:int = 0;i < list.content.numChildren;i++){
                        if(list.content.getChildAt(i) is ItemScience){
                            (list.content.getChildAt(i) as ItemScience).clearAll();
                        }
                    }
                }
            }
        }
        private function update_smd():void{
            //
            var len:Number = this.mMaxX*this.mMaxY;
            var xy:String = "";
            var smd:ModelScience;
            for(var i:int = 0; i < len; i++)
            {   
                xy = ((i%5)+1)+"_"+(Math.floor(i/5)+1);
                if(this.mArrTable.hasOwnProperty(xy)){
                    smd = ModelManager.instance.modelGame.getModelScience(this.mArrTable[xy]);
                    this.checkXY(smd);
                }
            }      
            ItemScience.mDic = this.mDic;   
            //         
            this.initData();
        }
        override public function initData():void{
            this.setTitle(Tools.getMsgById("_public48"));
            //
            this.mModelUpgrade = ModelScience.getCDingModel();
            //
            this.box_unlock.visible = false;
            //
            var smd:ModelScience;
            var len:int = this.mArr.length;
            var xy:String;
            var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuilding003();
            var vh:Number = 124;
            var max:Number = 0;
            this.mScrollBarMax = -1;
            for(var i:int = 0; i < len; i++)
            {
                xy = this.mArr[i];
                if(this.mArrTable.hasOwnProperty(xy)){
                    smd = ModelManager.instance.modelGame.getModelScience(mArrTable[xy]);
                    if(bmd.lv<smd.limit){
                        this.tUnlock.text = Tools.getMsgById("_public49",[smd.limit]);//"军府"+smd.limit+"级后开启";//军府{}级后开启
                        this.mScrollBarMax = vh*(Math.floor(i/5)+1);
                        this.mScrollBarIndex = Math.floor(i/5)+1;
                        //
                        smd["mScrollBarIndex"] = vh;
                        break;
                    }
                }               
            }
            
            this.list.height = this.height - this.list.y - 10;
            max = Math.floor(len/5)*vh-this.list.height;
            if(this.mScrollBarMax>0){
                this.mScrollBarMax = this.mScrollBarMax - (Math.floor(this.list.height/vh))*vh;
                this.mScrollBarMax = this.mScrollBarMax<0?0:this.mScrollBarMax;
            }
            else{
                this.mScrollBarMax = max;
            }
            //
            ItemScience.mArrTable = this.mArrTable;            
            //
            this.list.dataSource = this.mArr;
            //
            this.timer.clear(this,this.list_scroll_set);
            this.timer.once(500,this,this.list_scroll_set);
        }
        private function list_scroll_set():void
        {
            if(this.list.scrollBar.changeHandler){
                this.list.scrollBar.changeHandler.clear();
            }
            this.list.scrollBar.changeHandler = new Handler(this,this.list_scroll);   
            this.list_scroll(0);
        }
        private function list_render(item:ItemScience,index:int):void
        {
            item.initData(this.list.array[index],this.mModelUpgrade);
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[item.mModel,item]);
        }
        private var itemGetTimer:Number = 0;
        private function click(smd:ModelScience,item:ItemScience):void
        {
            if(smd){
                if(item.mStatus == 4){
                    this.itemGetTimer = Tools.runAtTimer(this.itemGetTimer,1000,Handler.create(this,this.getScience,[item]));
                }
                else if(item.mStatus == 3){
                    ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_QUICKLY,this.mModelUpgrade);
                }
                else if(item.mStatus>0){
                    ViewManager.instance.showView(ConfigClass.VIEW_SCIENCE_UPGRADE,smd);
                }
            }
        }
        private function getScience(item:ItemScience):void
        {
            item.getMeClip();
            this.timer.clear(ModelManager.instance.modelInside,ModelManager.instance.modelInside.checkScienceGet);
            this.timer.once(500, ModelManager.instance.modelInside,ModelManager.instance.modelInside.checkScienceGet);            
        }
    }
}