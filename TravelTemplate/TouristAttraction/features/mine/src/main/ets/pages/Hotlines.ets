import { Constant } from 'common';
import { Hotline } from 'service_hotline';
import { TitleBar } from 'uicomponents';
import { GridRowColSetting } from '../common/GridRowColSetting';
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

        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            Column({ space: 12 }) {
              Hotline({ hotlines: hotlines });
            }.padding({ left: 16, right: 16 });
          }
        }
      }.height(Constant.FULL_PERCENT).backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true);
  }
}