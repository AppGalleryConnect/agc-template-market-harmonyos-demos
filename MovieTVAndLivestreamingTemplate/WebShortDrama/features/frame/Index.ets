import { TabHeaderInfo } from './src/main/ets/view/components/tabs/TabItem';

export { TabHeaderInfo } from './src/main/ets/view/components/tabs/TabItem';

export { initMainPageContent } from './src/main/ets/view/model/InitContent';

export interface TabInfo {
  tabHeaderInfo: TabHeaderInfo;
  tabContentBuilder: WrappedBuilder<[number]>;
}

@ObservedV2
export class TabInfoRegister {
  @Trace static tabInfos: TabInfo[] = [];
}
