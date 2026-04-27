import { OHDialogModel } from '../dialog/OHDialogModel';
import { MOCK_ACCOUNT_LIST } from '../constant/Constants';
import { MockAccountSingleModel } from './MockAccountSingleModel';

@ObservedV2
export class AccountDialogModel extends OHDialogModel {
  @Trace title: ResourceStr = $r('app.string.mock_account_title');
  @Trace value: MockAccountSingleModel[] = MOCK_ACCOUNT_LIST;
  @Trace currentUser: MockAccountSingleModel = new MockAccountSingleModel();
}