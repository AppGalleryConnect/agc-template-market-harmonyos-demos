import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  MinorsMode,
  MinorsProtectionUtils,
  TCRouter
} from 'common';
import { MyInfoCard } from '../comp/MyInfoCard';
import { AccountCard } from '../comp/AccountCard';
import { ServiceCard } from '../comp/ServiceCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';

@Builder
export function PersonPageBuilder() {
  PersonPage();
}

@ComponentV2
export struct PersonPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Provider('index') index: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  build() {
    // NavDestination() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.headBarView()
        Scroll() {
          Column({ space: 12 }) {
            if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
              MyInfoCard();
              if (!this.minorsMode.isMinorsMode) {
                AccountCard();
              }
              ServiceCard();
            } else {
              Row({ space: 12 }) {
                MyInfoCard()
                  .layoutWeight(1)
                if (!this.minorsMode.isMinorsMode) {
                  AccountCard()
                    .layoutWeight(1)
                }
              }
              .width('100%')

              ServiceCard();
            }

          }
        }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top).edgeEffect(EdgeEffect.Spring);

      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_SIZE)
      .padding({
        left: 16,
        right: 16,
      })
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))

    // }.hideTitleBar(true)
  }

  @Builder
  headBarView() {
    Column() {
      Row() {
        Text($r('app.string.person'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize(fp2pxUtil(24))
          .fontWeight(FontWeight.Medium)
        Row() {
          Stack({ alignContent: Alignment.TopEnd }) {
            SymbolGlyph($r('sys.symbol.ellipsis_message'))
              .fontSize(fp2pxUtil(24))
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ right: 8 })
              .width(40)
              .height(40)
              .borderRadius(1000)
              .padding(8)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                TCRouter.push(Constants.MESSAGE_PAGE_ROUTE);
              });
            Row() {
              Text('6')
                .fontSize(10)
                .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
            .width(16)
            .height(16)
            .borderRadius(8)
            .backgroundColor('#E84026')
          }


          SymbolGlyph($r('sys.symbol.gearshape'))
            .fontSize(fp2pxUtil(24))
            .fontColor([$r('sys.color.icon_primary')])
            .width(40)
            .height(40)
            .borderRadius(1000)
            .padding(8)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              TCRouter.push(Constants.SETTING_ROUTE);
            })
        }
      }
      .height(36)
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 8 + this.windowTopHeight,
      bottom: 8
    })
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}