package sg.fight.client.spr 
{
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.view.FightScene;
	import sg.fight.client.view.ViewFightTroopFlag;
	/**
	 * 战斗部队的旗子，包含缓动和消失(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FTroopFlag extends FInfoBase
	{
		public var troop:ClientTroop;
		public var offset:Array;
		
		public function FTroopFlag(troop:ClientTroop)
		{
			this.troop = troop;
			var scene:FightScene = troop.getClientTeam().getClientBattle().fightMain.scene;
			
			var baseScale:Number;
			var flagPos:Array = this.troop.getFormation().flag;
			if(flagPos){
				this.offset = [flagPos[0] * (troop.isFlip? -1: 1), flagPos[1]];
				baseScale = 1;
			}
			else{
				this.offset = [0, 0];
				baseScale = 0;
				//this
			}
			
			super(scene, '', this.getX(), this.offset[1], 0, troop.isFlip, baseScale, 1);
		}
		
		override public function init():void
		{
			var view:ViewFightTroopFlag = new ViewFightTroopFlag(this.troop);
			
			this.spr = view;
			this.spr.visible = this._baseScale > 0;
			
			//FightTime.timer.once(6000, this, this.clear);
			this.addToScene();
			if(this.offset[1]<0){
				this.setItemIndex(0);
			}
		}
		
		override public function getX():int
		{
			return this.troop.posX + this.offset[0];
		}
		
		public function get view():ViewFightTroopFlag
		{
			return this.spr as ViewFightTroopFlag;
		}
		

	}

}