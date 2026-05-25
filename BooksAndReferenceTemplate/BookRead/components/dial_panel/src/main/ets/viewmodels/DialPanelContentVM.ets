import { AsyncCallback } from '@kit.BasicServicesKit';

@ObservedV2
export class DialPanelContentVM {

  @Trace
  public title: string = '';

  @Trace
  public phoneNumber: string = '';

  @Trace
  public isOpen: boolean = false;

  @Trace
  public isAutoClosePanel: boolean = true;

  @Trace
  public sheetType: SheetType = SheetType.BOTTOM;

  @Trace
  public onMakeCall: AsyncCallback<void> = () => {};

  @Trace
  public onWillDismiss: Callback<DismissReason> = () => {};

  @Trace
  public onWillSpringBackWhenDismiss: Callback<SpringBackAction> = (action: SpringBackAction) => action.springBack();

  @Trace
  public close: () => void = () => {};

}
