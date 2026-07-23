import { common } from '@kit.AbilityKit';
import { Constants, NavPathName, OtherTabNavModel } from 'constant';
import { OrderParam, PersonalInfo } from 'type';
import { CommonHeader } from 'component';
import { AccountUtil } from 'util';
import { goToAddressListPage } from 'address_management';
import { DialPanel } from 'dial_panel';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';
import { PersonalPopInfo, TenantInfo } from '../model/Index';

interface MenuItem {
  title: string;
  icon: ResourceStr;
  action: () => void;
}

@Builder
export function PersonalBuilder() {
  Personal();
}

@ComponentV2
export struct Personal {
  vm: PersonalInfoVM = PersonalInfoVM.instance;
  @Local personalInfo: PersonalInfo = AccountUtil.getPersonalInfo();
  @Local userId: string = AccountUtil.getUserId();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local showContactSheet: boolean = false;
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  controller: TabsController = new TabsController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private dialPanel: DialPanel = new DialPanel(this.getUIContext())
    .setTitle('电话客服')
    .setPhoneNumber(this.tenantInfo?.phone ?? '');

  getAnonymousPhone(): string {
    const phone = this.personalInfo.phone;
    if (phone && phone.length >= 11) {
      return phone.slice(0, 3) + '****' + phone.slice(7);
    }
    return phone;
  }

  private readonly quickMenuItems: MenuItem[] = [
    {
      title: '订单管理',
      icon: $r('app.media.icon_my_order'),
      action: () => {
        const param: OrderParam = { orderStatus: 0, orderType: 0 };
        this.mainPathStack.pushPathByName(NavPathName.ORDER_LIST, param);
      }
    },
    {
      title: '我的收藏',
      icon: $r('app.media.icon_my_collection'),
      action: () => {
        this.mainPathStack.pushPathByName(NavPathName.MY_FAVORITES, null);
      }
    },
    {
      title: '地址管理',
      icon: $r('app.media.icon_my_address'),
      action: () => {
        goToAddressListPage(this.mainPathStack);
      }
    },
    {
      title: '浏览记录',
      icon: $r('app.media.icon_my_history'),
      action: () => {
        this.mainPathStack.pushPathByName(NavPathName.BROWSE_HISTORY, null);
      }
    },
  ];

  private readonly serviceMenuItems: MenuItem[] = [
    {
      title: '常用旅客信息',
      icon: $r('app.media.icon_passenger'),
      action: () => {
        this.mainPathStack.pushPathByName(NavPathName.GUESTS, null);
      }
    },
    {
      title: '联系客服',
      icon: $r('app.media.icon_customer_service'),
      action: () => {
        this.showContactSheet = true;
      }
    },
    {
      title: '意见反馈',
      icon: $r('app.media.icon_feedback'),
      action: () => {
        this.mainPathStack.pushPathByName('FeedbackSubmitPage', null);
      }
    },
    {
      title: '设置',
      icon: $r('app.media.icon_setting'),
      action: () => {
        this.mainPathStack.pushPathByName(NavPathName.ABOUT, null, (popInfo: ESObject) => {
          const result = popInfo.result as PersonalPopInfo;
          if (result && result.type === 1) {
            this.personalInfo.avatar = '';
            this.personalInfo.nickName = '';
            this.personalInfo.phone = '';
            this.userId = '';
          }
        });
      }
    },
  ];

  routeByIndex(value: number) {
    const navItem = Constants.OTHER_NAV_TABLE.find((item: OtherTabNavModel) => item.index === value);
    const onPopCallback = (popInfo: ESObject) => {
      const result = popInfo.result as PersonalPopInfo;
      if (result) {
        this.personalInfo.avatar = result.avatar ? result.avatar : this.personalInfo.avatar;
        this.personalInfo.nickName = result.nickname ? result.nickname : this.personalInfo.nickName;
        this.userId = (result.type === 0 ? this.userId : '');
      }
    };
    this.mainPathStack.pushPathByName(navItem?.page, null, onPopCallback);
  }

  aboutToDisappear(): void {
    this.context.eventHub.off('reLogin');
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '我的' });

        Scroll() {
          Column({ space: 12 }) {
            this.userInfoCard();

            this.quickMenuCard();

            this.serviceMenuCard();

            Blank().layoutWeight(1);
          }
          .padding({ left: 16, right: 16, top: 12 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .backgroundColor($r('sys.color.background_secondary'))
      .bindSheet($$this.showContactSheet, this.contactSheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        showClose: true,
        dragBar: false,
        onWillDismiss: (action: DismissSheetAction) => {
          this.showContactSheet = false;
        }
      })
    }.hideTitleBar(true);
  }

  @Builder
  userInfoCard() {
    Column() {
      Row() {
        Image(this.userId ? this.personalInfo.avatar : $r('app.media.default_avatar'))
          .width(48)
          .height(48)
          .draggable(false)
          .margin({ right: 16 });

        Column() {
          Text(this.userId ? this.personalInfo.nickName : '未登录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          if (this.userId) {
            Row() {
              Image($r('app.media.icon_public_mobilephone'))
                .width(12)
                .height(12)
                .margin({ right: 4 });

              Text(this.getAnonymousPhone())
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .margin({ top: 4 })
            .alignItems(VerticalAlign.Center);
          } else {
            Text('登录后享受更多服务')
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
              .maxLines(1);
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceAround);

        Image($r('app.media.icon_direction_right_small'))
          .width(12)
          .height(24);
      }
      .width(Constants.FULL_SCREEN)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (!this.userId) {
          this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
            this.personalInfo.avatar = this.personalInfo.avatar ? this.personalInfo.avatar : $r('app.media.avatar');
            this.personalInfo.nickName = this.personalInfo.nickName ? this.personalInfo.nickName : '华为用户';
            this.userId = popInfo.result;
          });
        } else {
          this.mainPathStack.pushPathByName(NavPathName.PERSONAL_INFO, null, (popInfo: ESObject) => {
            const result = popInfo.result as PersonalPopInfo;
            if (result) {
              this.personalInfo.avatar = result.avatar ? result.avatar : this.personalInfo.avatar;
              this.personalInfo.nickName = result.nickname ? result.nickname : this.personalInfo.nickName;
              this.userId = (result.type === 0 ? this.userId : '');
            }
          });
        }
      });
    }
    .width(Constants.FULL_SCREEN)
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(20);
  }

  @Builder
  quickMenuCard() {
    Row() {
      ForEach(this.quickMenuItems, (item: MenuItem) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain);

          Text(item.title)
            .fontSize(12)
            .margin({ top: 8 })
            .fontColor($r('sys.color.font_primary'));
        }
        .layoutWeight(1)
        .onClick(() => {
          item.action();
        });
      }, (item: MenuItem) => item.title);
    }
    .width(Constants.FULL_SCREEN)
    .padding({ top: 16, bottom: 16, left: 8, right: 8 })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16);
  }

  @Builder
  serviceMenuCard() {
    Column() {
      ForEach(this.serviceMenuItems, (item: MenuItem, index?: number) => {
        Row() {
          Image(item.icon)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
            .margin({ right: 12 });

          Text(item.title)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1);

          Image($r('app.media.icon_direction_right_small'))
            .width(12)
            .height(24);
        }
        .width(Constants.FULL_SCREEN)
        .padding({ top: 14, bottom: 14 })
        .onClick(() => {
          item.action();
        });

        if (index !== undefined && index < this.serviceMenuItems.length - 1) {
          Divider().color($r('sys.color.comp_divider')).margin({ left: 36 });
        }
      }, (item: MenuItem) => item.title);
    }
    .width(Constants.FULL_SCREEN)
    .padding({ left: 12, right: 12, top: 16, bottom: 16 })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16);
  }

  @Builder
  contactSheetBuilder() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.icon_customer_service_dial'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain);

          Text('电话客服')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 });

          Image($r('app.media.icon_direction_right_small'))
            .width(12)
            .height(24);
        }
        .width(Constants.FULL_SCREEN)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.showContactSheet = false;
          this.dialPanel.open();
        });

        Divider().color($r('sys.color.comp_divider'));

        Row() {
          Image($r('app.media.icon_customer_service_chat'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain);

          Text('在线客服')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 });

          Image($r('app.media.icon_direction_right_small'))
            .width(12)
            .height(24);
        }
        .width(Constants.FULL_SCREEN)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.showContactSheet = false;
          this.mainPathStack.pushPathByName('Customer', null);
        });
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .padding(12)
    }
    .margin({ top: 64 })
    .width(Constants.FULL_SCREEN)
    .padding({ left: 16, right: 16, bottom: 28 })
  }
}
