package sg.activities.model
{
    import sg.model.ViewModelBase;
    import laya.maths.MathUtil;
    import laya.utils.Handler;
    import sg.model.ModelItem;
    import sg.utils.Tools;

    public class ModelDialBse extends ViewModelBase {
		public var mRecrodList:Array;
        public function ModelDialBse() {
            
        }

		/**
		 * 额外奖励列表
		 */
		public function get addList():Array {
			var obj:Object = addCfg;
			var arr:Array=[];
			for(var s:String in obj){
				arr.push([Number(s),obj[s]]);
			}
			arr.sort(MathUtil.sortByKey("0",false,false));
			return arr;
		}

		/**
		 * 选择的奖励
		 */
		public function get giftArr():Array{
			var arr:Array=[];
			for(var i:int=0;i < awardList.length;i++){
				var a:Array = awardCfg[i][2];
				var aa:Array = awardList[i];
				for(var j:int=0;j<aa.length;j++){
					arr.push([a[aa[j]],i==2]);
				}
			}
			return arr;
        }

		/**
		 * 抽奖记录
		 */
		public function getRecrodsList():Array{
			var arr:Array=[];
			for(var i:int=0;i<this.mRecrodList.length;i++){
				var a:Array=this.mRecrodList[i];
				var item:String="";
				for(var s:String in a[1]){
					item=ModelItem.getItemName(s)+"x"+a[1][s]+"  ";
				}
				var str:String=Tools.getMsgById("dial_text13",[Tools.dateFormat(a[0]),item]);
				arr.push(str);
			}
			return arr;
		}

        public function drawReward(handler:Handler):void {
		}

        public function get awardList():Array{
            return [];
        }

        public function get addCfg():Object{
            return {};
        }

        public function get awardCfg():Array{
            return [];
        }

        public function get canGetTimes():int {
            return 0;
        }

        public function get getTimes():int {
            return 0;
        }

        public function get payMoney():int {
            return 0;
        }

        public function get buyNum():int {
            return 0;
        }

        public function get remainTime():String {
            return '';
        }

        public function get tips():String {
            return '';
        }
    }
}