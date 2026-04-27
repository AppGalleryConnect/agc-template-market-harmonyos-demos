import { OHDialogModel } from 'common';

@ObservedV2
export class LogoutDialogModel extends OHDialogModel{
  @Trace title: ResourceStr = '您确认退出登录';
  onValueConfirmClick = (_model: OHDialogModel) => {
  };
}