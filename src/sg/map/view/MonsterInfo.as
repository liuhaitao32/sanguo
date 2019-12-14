package sg.map.view {
	import laya.ui.Label;
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.TestUtils;
	import sg.model.ModelClimb;
	import sg.scene.SceneMain;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.TimeHelper;
	import sg.utils.Tools;
	import ui.mapScene.HeroCatchInfoUI;
	import ui.mapScene.MonsterInfo1UI;
	import ui.mapScene.MonsterInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class MonsterInfo extends NoScaleUI {
		
		private var _ui:*;
		
		private var climb:ModelClimb;
		
		public function MonsterInfo(scene:SceneMain) {
			super();
			this.minLost = true;
			this.initScene(scene);
		}
		
		
		public function setData(entity:EntityMonster):void {
			
			this.climb = entity.climb;
			
			if (!this._ui) {
				if (this.climb.isCaptain()) {
					this._ui = new MonsterInfo1UI();
				} else {
					this._ui = new MonsterInfoUI();
				}				
				this.addChild(this._ui);
			}
			
			if (!entity.climb.pk_npc_fight_ing && entity.climb.pk_npc_award) {
				this._ui.bing_pro.visible = false;
			}else {
				this._ui.bing_pro.visible = true;
			}
			if (!entity.climb.isCaptain()) {				
				this._ui.name_txt.text = entity.name + "·" + Tools.getMsgById(["alien_easy", "alien_normal", "alien_trouble"][entity.climb.pk_npc_diff()]);				
				this._ui.name_txt.color = ["#82a5ff", "#cc5dff", "#ffd02d"][entity.climb.pk_npc_diff()];
			} else {
				this._ui.name_txt.text = entity.name;
				TimeHelper.countDown(this._ui.countDown_txt, this.climb.captain_time());				
				Label(this._ui.countDown_txt).visible = this._ui.bing_pro.visible;
				Label(this._ui.name_txt).align = this._ui.bing_pro.visible ? "right" : "center";
			}
			
			Label(this._ui.name_txt).valign = this._ui.bing_pro.visible ? "top" : "middle";
			this.changeProgress();
			this.climb.on(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE, this, this.changeProgress);
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
		}
		
		private function changeProgress(e:* = null):void {
			this._ui.bing_pro.value = this.climb.pk_npc_get_troop_fight_progress();			
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this.climb.off(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE, this, this.changeProgress);
			TimeHelper.removeCountDown(this._ui.countDown_txt);
			super.destroy(destroyChild);
		}
	}

}