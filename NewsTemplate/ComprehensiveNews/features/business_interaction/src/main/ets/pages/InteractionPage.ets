import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BreakpointModel,
  CircleButtonModifier,
  CommonConstants,
  LinearColumnModifier,
  RouterMap,
  RouterUtils,
  SettingModel,
  TabModel,
  WindowModel,
} from 'lib_common'
import { NavHeaderBar } from 'lib_widget';
import { NewsSearchEntry } from 'lib_search';
import { TopBar } from '../components/TopBar';
import { TabItem, TAB_LIST } from '../common/Constants';
import { InterActionTabContent } from '../components/InterActionTabContent';

@Builder
export function InteractionPageBuilder() {
  InteractionPage()
}

@ComponentV2
struct InteractionPage {
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local selectedId: number = 0
  @Local targetIndex: number = 0
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.action_linear'));
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '互动',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          },
        })
        Column() {
          TopBar({
            selectedId: this.selectedId,
            onClickBar: (id: number) => {
              this.selectedId = id
              this.targetIndex = TAB_LIST.findIndex(item => item.id === id)
            },
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(40)
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
        })

        Tabs({ index: this.targetIndex }) {
          ForEach(TAB_LIST, (v: TabItem) => {
            TabContent() {
              Column() {
                InterActionTabContent({
                  resource: v,
                  selectedId: this.selectedId,
                })
              }
              .layoutWeight(1)
            }
          }, (v: TabItem) => v.id + v.label)
        }
        .barHeight(0)
        .layoutWeight(1)
        .onAnimationStart((_index: number, targetIndex: number) => {
          this.selectedId = TAB_LIST[targetIndex].id
        })
        .onChange((index: number) => {
          this.targetIndex = index
        })
      }
      .attributeModifier(this.modifier)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_tertiary'))
      .padding({
        bottom: this.pagePaddingBottom,
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  rightHeadPartBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      NewsSearchEntry({ name: 'interaction' })
      Button() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('发帖')
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.PUBLISH_POST_PAGE);
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }

  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }
}