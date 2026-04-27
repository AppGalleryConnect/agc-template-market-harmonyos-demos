import { Logger } from './Logger';

export function alert(title: string, message: string,uiContext:UIContext) {
  uiContext.showAlertDialog({
    title: title,
    message: message,
    alignment: DialogAlignment.Center,
    buttons: [{
      value: '确定', action: () => {
        Logger.info('确定');
      },
    }],
  })
}