import { AddressVM } from './AddressVM';
import { Operation } from '../common/CustomTypes';

@ObservedV2
export class AddressFormSheetContext {

  @Trace
  public title: string = '';

  @Trace
  public address: AddressVM = new AddressVM();

  @Trace
  public operation: Operation = Operation.EDIT;

  @Trace
  public isOpen: boolean = false;

  @Trace
  public sheetType: SheetType = SheetType.BOTTOM;

  @Trace
  public onWillSpringBackWhenDismiss: Callback<SpringBackAction> = (action: SpringBackAction) => action.springBack();

  @Trace
  public onWillDismiss: (reason: DismissReason, hasChange: boolean) => void = () => {};

  @Trace
  public onAddressListUpdate: Callback<void> = () => {};

  @Trace
  public close: () => void = () => {};

}
