import { BaseViewModel } from 'lib_common';
import { MessageServiceApi } from 'lib_news_api';
import { SystemMessageInfo } from '../common/ObservedModel';

@ObservedV2
export class MsgSystemViewModel extends BaseViewModel {
  @Trace list: SystemMessageInfo[] = [];

  constructor() {
    super()
    MessageServiceApi.setSystemRead();
    MessageServiceApi.queryAllSystemInfoList().then((resp) => {
      this.list = resp;
    })
  }
}