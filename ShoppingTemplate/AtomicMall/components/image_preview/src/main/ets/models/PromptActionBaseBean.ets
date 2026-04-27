import { util } from '@kit.ArkTS';

export abstract class PromptActionBaseBean {
  dialogId: string;
  dismissOnSystemBack: boolean = true;
  needDismiss: boolean = false;
  dismissAnimation: boolean = true;
  levelMode?: LevelMode;
  levelUniqueId?: number | string;
  immersiveMode?: ImmersiveMode;

  constructor(dialogId: string = '') {
    if (dialogId === '') {
      dialogId = util.generateRandomUUID();
    }
    this.dialogId = dialogId;
  }
}