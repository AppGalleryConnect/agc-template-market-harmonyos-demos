import { contextUtil } from './ContextUtil';
import { Logger } from './Logger';

export function alertToConfirm(message: string, confirm: () => Promise<void>) {
  contextUtil.getUiContext()?.showAlertDialog({
    message: message,
    alignment: DialogAlignment.Center,
    height: 125,
    primaryButton: {
      value: '取消',
      fontColor: $r('sys.color.font_secondary'),
      action: () => {
        Logger.info('取消');
      },
    },
    secondaryButton: {
      value: '确定',
      fontColor: $r('sys.color.comp_background_emphasize'),
      action: async () => {
        await confirm();
      },
    },
  });
}