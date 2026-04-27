import { common } from '@kit.AbilityKit';
import { Constants, NavPathName, OrderTextModel, OtherTabNavModel } from 'constant';
import { OrderParam, PersonalInfo } from 'type';
import { TitleBar } from 'component';
import { AccountUtil } from 'util';
import { PersonalInfoVM } from '../viewmodel/PersonalInfoVM';

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
  controller: TabsController = new TabsController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  routeByIndex(value: number) {
    const navItem = Constants.OTHER_NAV_TABLE.find((item: OtherTabNavModel) => item.index === value);
    this.mainPathStack.pushPathByName(navItem?.page, null);
  }

  aboutToDisappear(): void {
    this.context.eventHub.off('reLogin');
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '我的', clickEvent: () => {
            this.mainPathStack.pop();
          },
        }).backgroundColor('#5c6383');

        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }.height(120).width(Constants.FULL_SCREEN).backgroundColor('#5c6383');

          Row() {
            Image(this.userId ? this.personalInfo.avatar : $r('app.media.default_avatar'))
              .width(52)
              .height(52)
              .borderRadius(26)
              .aspectRatio(1);
            Text(this.userId ? this.personalInfo.nickName : '立即登录')
              .fontSize(15)
              .fontColor(Color.White)
              .margin({ left: 12 })
              .fontWeight(600);
          }.padding(16).width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start).onClick(() => {
            if (!this.userId) {
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.personalInfo.avatar = this.personalInfo.avatar ? this.personalInfo.avatar : $r('app.media.avatar');
                this.personalInfo.nickName = this.personalInfo.nickName ? this.personalInfo.nickName : '华为用户';
                this.userId = popInfo.result;
              });
            }
          });
        };

        Column() {
          Column() {
            Column() {
              Text('我的订单').fontSize(14).width(Constants.FULL_SCREEN).textAlign(TextAlign.Start);

              Grid() {
                ForEach(Constants.orderText, (item: OrderTextModel) => {
                  GridItem() {
                    Column() {
                      Image($r(`${item.icon}`)).size({ width: 24, height: 24 });

                      Text(`${item.title}`).fontSize(12).margin({ top: 6 });
                    }.onClick(() => {
                      this.mainPathStack.pushPathByName(NavPathName.ORDER_LIST, {
                        orderStatus: item.value,
                        orderType: 0,
                      } as OrderParam);
                    });
                  };
                }, (item: OrderTextModel) => item.title);
              }
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .margin({ top: 16 });
            };
          }
          .height(120)
          .width(Constants.FULL_SCREEN)
          .margin({ top: 16 })
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8);

          Column() {
            Row() {
              Text('其他服务').fontSize(14);
            }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);

            Grid() {
              ForEach(Constants.COMMON_SERVICE_INFO,
                (item: OrderTextModel) => {
                  GridItem() {
                    Column() {
                      Image($r(`${item.icon}`)).size({ width: 24, height: 24 }).objectFit(ImageFit.Contain);

                      Text(`${item.title}`).fontSize(12).margin({ top: 6 });
                    };
                  }.onClick(() => {
                    this.routeByIndex(item.value);
                  });
                }, (item: OrderTextModel) => item.title);
              if (this.userId) {
                GridItem() {
                  Column() {
                    Image($r('app.media.icon_my_center')).size({ width: 24, height: 24 }).objectFit(ImageFit.Contain);

                    Text('个人中心').fontSize(12).margin({ top: 6 });
                  };
                }.onClick(() => {
                  this.mainPathStack.pushPathByName(NavPathName.PERSONAL_INFO, null, (popInfo: ESObject) => {
                    this.personalInfo.avatar = popInfo.result.avatar ? popInfo.result.avatar : this.personalInfo.avatar;
                    this.personalInfo.nickName =
                      popInfo.result.nickname ? popInfo.result.nickname : this.personalInfo.nickName;
                    this.userId = (popInfo.result.type === 0 ? this.userId : '');
                    this.context.eventHub.on('reLogin',
                      (uid: string) => {
                        this.userId = uid;
                        if (!this.personalInfo.avatar) {
                          AccountUtil.setAvatar($r('app.media.avatar'));
                          AccountUtil.setNickName('华为用户');
                        }
                      });
                  });
                });
              }
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width(Constants.FULL_SCREEN)
            .margin({ top: 16 });
          }
          .height(this.userId ? 172 : 120)
          .margin({ top: 16 })
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8);
        }.backgroundColor('#f5f6fa').padding({ left: 16, right: 16 }).height(Constants.FULL_SCREEN);
      };
    }.hideTitleBar(true);
  }
}