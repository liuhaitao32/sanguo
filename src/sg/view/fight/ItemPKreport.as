package sg.view.fight
{
    import ui.fight.itemPKreportUI;
    import sg.utils.Tools;
    import laya.ui.Box;
    import ui.com.hero_icon1UI;
    import sg.manager.ModelManager;
    import sg.manager.AssetsManager;
    import sg.utils.StringUtil;

    public class ItemPKreport extends itemPKreportUI{
        private var mBox0:Box;
        private var mBox1:Box;
        public function ItemPKreport(){
            this.text0.text=Tools.getMsgById("_public214");
        }
        public function setData(data:Object):void{
            var fd:Date = new Date();
            fd.setTime(Tools.getTimeStamp(data.fight_time));
            //
            this.tTime.text = (fd.getMonth()+1)+"-"+fd.getDate()+" "+fd.getHours()+":" + StringUtil.padding(String(fd.getMinutes()), 2, '0', false);
            //
			var teamWin:Array = data.teamWin ? data.teamWin: [0,0];
			if (teamWin[0] > teamWin[1]){//胜
                this.imgArrow.rotation = -90;
				this.imgWin.skin = AssetsManager.getAssetsUI('icon_win06.png');
			}else if (teamWin[0] < teamWin[1]){//败
                this.imgArrow.rotation = 90;
				this.imgWin.skin = AssetsManager.getAssetsUI('icon_win07.png');
			}else{//ping
                this.imgArrow.rotation = 0;
				this.imgWin.skin = AssetsManager.getAssetsUI('icon_win08.png');
			}
			this.tResult.text = teamWin[0] + " : " + teamWin[1];
            //this.tStatus.selected = (data.hasOwnProperty("pk_result")?(data.pk_result?true:false):false);
            //
            // 
            //
            var r0:Number = this.setUserUI(data.team[0],0);
            var r1:Number = this.setUserUI(data.team[1],1);
            //
            var rd:Number = r0+r1;
            //
            this.tRank.text = ((rd>0)?"+":"-")+rd;
        }
        private function setUserUI(user:Object,lr:int):Number{
            this["tName"+lr].text = user.uname;
            //
            if(this["mBox"+lr]){
                (this["mBox"+lr] as Box).destroyChildren();
                this["mBox"+lr] = null;
            }
            this["mBox"+lr] = new Box();
            //
            this.addChild(this["mBox"+lr]);
            //
			var ww:int = 40;
            var troopArr:Array = user.hids;
            var len:int = troopArr.length;
            var icon:hero_icon1UI;
            for(var i:int = 0; i < len; i++)
            {
                icon = new hero_icon1UI();
                // icon.setHeroIcon(troopArr[i][0], true,  md.getStarGradeColor());
                icon.setHeroIcon(troopArr[i][0], true);
                icon.scale(0.4,0.4,true);
                
                icon.x = ((lr==0)?(len-i):i)*ww;
                icon.setReportTag(troopArr[i][1] == 0);
                
                (this["mBox"+lr] as Box).addChild(icon);
            }
            var w:Number = (this["mBox"+lr] as Box).width + 25;
            (this["mBox"+lr] as Box).y = 50;
            //
            (this["mBox"+lr] as Box).x = (lr>0)?330+ww:330-w;
            //
            var rank:Number = Math.abs(user.rank);
            if(user.uid != ModelManager.instance.modelUser.mUID){
                rank = rank * -1;
            }
            return rank;
        }
    }   
}