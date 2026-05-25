import {
  BookApi,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  GetUserInfoRsp,
  NavHeaderBar,
  ReturnButton,
  TCRouter
} from 'common';
import { AvatarIcon, SelectAvatarCard } from '../comp/SelectAvatarCard';
import { emitter } from '@kit.BasicServicesKit';
import { UserInfo } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct PrivacyPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '隐私设置',
          hasBackButton: true,
          hasBgColor: true,
          isMainPage: false,
        })
        Scroll() {
          Column({ space: 12 }) {
            this.privacyOptionView('隐私协议', Constants.PRIVACY_POLICY_ROUTE)
            this.privacyOptionView('第三方共享信息清单', Constants.DATA_SHARING_ROUTE)
            this.privacyOptionView('个人信息收集清单', Constants.DATA_COLLECTION_ROUTE)
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : '100%')
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({
            left: 16,
            right: 16,
            top: 12
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  privacyOptionView(text: string, url: string) {
    Row() {
      Text(text)
        .fontSize(this.fontModel.getFg(16))
        .height(21)
        .width(Constants.FULL_SIZE)
      Image($r('app.media.ic_arrow_right'))
        .width(12)
        .height(14)
        .objectFit(ImageFit.Contain)
    }
    .width(Constants.FULL_SIZE)
    .height(61)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 18,
      top: 20,
      bottom: 20,
      right: 18
    })
    .onClick(() => {
      TCRouter.push(url);
    })
  }
}