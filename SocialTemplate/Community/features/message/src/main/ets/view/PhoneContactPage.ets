import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ContactSingleModel, PhoneContactModel } from '../viewmodel/PhoneContactModel';
import { PhoneContactRow } from '../components/PhoneContactRow';
import { ChatJumpManager } from '../utils/ChatJumpManager';

@Builder
export function PhoneContactPageBuilder() {
  PhoneContactPage()
}

@ComponentV2
export struct PhoneContactPage {
  @Local phoneContactVM: PhoneContactModel = new PhoneContactModel();
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage();
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onContactClick: (contactVM: ContactSingleModel) => void =
    (contactVM: ContactSingleModel) => {
      if (contactVM.isFriend) {
        ChatJumpManager.gotoC2CChatPage(contactVM.userId);
      }
    }
  @Local onAddFriendClick: (contactVM: ContactSingleModel) => void =
    (contactVM: ContactSingleModel) => {
      this.phoneContactVM.addFriend(contactVM);
    }

  aboutToAppear(): void {
    this.phoneContactVM.setContactStatus();
  }

  @Builder
  setHeaderBuilder(title: ResourceStr) {
    Text(title)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)
      .width('100%')
      .height($r('app.float.vp_46'))
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  render() {
    CommonHeader({
      title: this.phoneContactVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List() {
        ForEach(Array.from(this.phoneContactVM.localContactMap.keys()), (item: string) => {
          ListItemGroup({
            header: this.setHeaderBuilder(item)
          }) {
            Repeat<ContactSingleModel>(this.phoneContactVM.localContactMap.get(item))
              .each((ri: RepeatItem<ContactSingleModel>) => {
                ListItem() {
                  PhoneContactRow({
                    contactVM: ri.item,
                    onContactClick: this.onContactClick,
                    onAddFriendClick: this.onAddFriendClick
                  });
                }
              })
              .key((item: ContactSingleModel, index: number): string => item.userId.toString() + index)
              .virtualScroll({
                totalCount: this.phoneContactVM.localContactMap.get(item)?.length
              })
              .templateId((_groupInfoVM: ContactSingleModel): string => {
                return '';
              })
          }
          .divider({
            strokeWidth: '1px',
            color: $r('sys.color.comp_divider')
          })
        }, (item: string, index: number) => item + '_' + index)
        ListItem().height(BarVM.instance.aiBarH)
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}

