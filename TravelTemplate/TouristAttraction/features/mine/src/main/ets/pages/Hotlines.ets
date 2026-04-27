import { Constant } from 'common';
import { TitleBar } from 'uicomponents';
import { Hotline } from 'service_hotline';
import { hotlines } from '../model/HotlineInfo';

@Builder
export function HotlinesBuilder() {
  Hotlines();
}

@ComponentV2
export struct Hotlines {
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        TitleBar({
          isShowBack: true, title: '服务热线', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 12 }) {
          Hotline({ hotlines: hotlines });
        }.padding({ left: 12, right: 12 });
      }.height(Constant.FULL_PERCENT).backgroundColor('#F1F3F5F2');
    }.hideTitleBar(true);
  }
}