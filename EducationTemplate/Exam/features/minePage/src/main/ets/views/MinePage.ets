/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { FeedbackVM } from 'feedback';
import { UserInfo } from 'login_info';
import { BreakpointType, RouterMap, RouterModule } from 'commonlib';
import { NumbObj } from '../viewModel/MessageModel';
import { MineItem } from '../viewModel/MineModel';
import { MineVM } from '../viewModel/MineVM';
import { MemberStatusUtil } from 'membership';
import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@ComponentV2
struct UserItem {
  @Param title: string = '';
  @Param image: ResourceStr = '';
  @Param url: string = '';

  build() {
    Row() {
      Image(this.image)
        .size({ width: 24, height: 24 });
      Text(this.title)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 12 });
      Blank();
      Image($r('app.media.iconRight'))
        .size({ width: 18, height: 18 });
    }
    .size({ width: '100%', height: 48 })
    .padding({ left: 10, right: 10 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16);
  }
}

@ComponentV2
export struct MinePage {
  @Local isOpen: boolean = false;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local propNumber: NumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
  @Local mineArr: MineItem[] = [
    new MineItem('练习记录', $r('app.media.icon_practice'), RouterMap.PRACTICE_RECORDS_PAGE),
    new MineItem('浏览记录', $r('app.media.ic_ict_configuration_history'), RouterMap.BROWSING_HISTORY_PAGE),
    new MineItem('我的下载', $r('app.media.ic_download'), RouterMap.MY_DOWNLOAD_PAGE),
    new MineItem('联系客服', $r('app.media.ic_public_headphones_mic'), ''),
    new MineItem('意见反馈', $r('app.media.ic_feedback'), RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), RouterMap.SET_UP_PAGE)
  ];
  @Local isCustom: boolean = false;
  feedBackVM: FeedbackVM = FeedbackVM.instance;
  mineVM: MineVM = MineVM.instance;

  @Monitor('logoUser.isLogin')
  changeLogin(monitor: IMonitor) {
    this.queryMemberStatus();
  }

  queryMemberStatus() {
    if(this.logoUser.isLogin) {
      MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
        let autoRenewPurchasedList = res.renewList;
        let nonAutoRenewPurchasedList = res.nonRenewList;

        if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
          this.logoUser.isMembership = true;
        } else {
          this.logoUser.isMembership = false;
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(0xFF00, 'MemberShip',
          `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      });
    } else {
      this.logoUser.isMembership = false;
    }
  }

  @Builder
  perMine() {
    Row() {
      Row() {
        Column() {
          Row() {
            Image(this.logoUser.isLogin ?
              (this.logoUser.avatar && this.logoUser.avatar !== '') ? this.logoUser.avatar : $r('app.media.path2x') :
              $r('app.media.person'))
              .borderRadius(40)
              .width(48)
              .aspectRatio(1)
              .onClick(() => {
              });
            Column() {
              Row() {
                Text(this.logoUser.isLogin ? this.logoUser.name : '点击登录')
                  .height(24)
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 16, bottom: 2 })
                  .onClick(() => {
                    if (!this.logoUser.isLogin) {
                      RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true });
                    }
                  });

                SymbolGlyph($r('sys.symbol.v_diamond_fill'))
                .fontColor([this.logoUser.isMembership ? '#D3B685' :
                  $r('sys.color.font_tertiary')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize(16)
                  .margin({
                    left: 2,
                  })
                Text('会员')
                  .fontSize(12)
                  .fontColor($r('sys.color.font_tertiary'))
                  .fontColor(this.logoUser.isMembership ? $r('sys.color.font_primary') :
                    $r('sys.color.font_tertiary'))
                  .fontWeight(FontWeight.Regular)
                  .margin({
                    left: 2,
                  })
              }
              Row() {
                if (this.logoUser.isLogin) {
                  Image($r('app.media.iphone')).height(14).width(10).margin({ right: 10 });
                }
                Text(this.logoUser.isLogin ? this.logoUser.cellphone : '登录后享受更多服务')
                  .height(16)
                  .textAlign(TextAlign.Center)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Regular);
              }
              .margin({ left: 16 })
              .height(16);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Image($r('app.media.iconRight'))
              .width(18)
              .aspectRatio(1)
              .margin({ right: 2 })
              .onClick(() => {
                if (this.logoUser.isLogin) {
                  RouterModule.push({ url: RouterMap.PERSONAL_CENTER_PAGE });
                } else {
                  RouterModule.push({ url: RouterMap.LOGIN_PAGE });
                }
              });
          }

          if(this.logoUser.isLogin) {
            Divider().width('100%')
              .margin({top: 12, bottom: 4})
              .backgroundColor($r('sys.color.comp_divider'))
              .padding({left: 8, right: 16})
            Row() {
              Text(this.logoUser.isMembership ? '请查看您的会员权益' : '开通会员享受更多权益')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
              Button('会员中心')
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor('#D3B685')
                .height(28)
                .onClick(() => {
                  if (this.logoUser.isLogin) {
                    RouterModule.push({url: RouterMap.MEMBER_CENTER_PAGE});
                  } else {
                    RouterModule.push({ url: RouterMap.LOGIN_PAGE });
                  }
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(8)
          }
        }
        .alignItems(HorizontalAlign.Start);
      }
      .layoutWeight(1);
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16);
  }

  @Builder
  minMine() {
    Row() {
      Column() {
        Image($r('app.media.icon_order'))
          .width(24)
          .aspectRatio(1);
        Text('我的订单')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 4 });
      }
      .width('25%')
      .onClick(() => {
        if (this.logoUser.isLogin) {
          RouterModule.push({ url: RouterMap.MY_ORDER_PAGE });
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE });
        }
      });

      Column() {
        Image($r('app.media.icon_my_wrong_question'))
          .width(24)
          .aspectRatio(1);
        Text('我的课程')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 4 });
      }
      .width('25%')
      .onClick(() => {
        if (this.logoUser.isLogin) {
          RouterModule.push({ url: RouterMap.COURSE_PAGE });
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE });
        }
      });

      Column() {
        Image($r('app.media.star'))
          .width(24)
          .aspectRatio(1);
        Text('我的收藏')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 4 });
      }
      .width('25%')
      .onClick(() => {
        if (this.logoUser.isLogin) {
          RouterModule.push({ url: RouterMap.COLLECTION_PAGE });
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE });
        }
      });

      Column() {
        if (this.logoUser.isLogin) {
          Badge({
            count: this.propNumber.listArr.length,
            style: { fontSize: 10, fontWeight: 'regular', badgeSize: 16 }
          }) {
            Image($r('app.media.ic_public_message_point'))
              .width(24)
              .aspectRatio(1);
          };
        } else {
          Image($r('app.media.ic_public_message_point'))
            .width(24)
            .aspectRatio(1);
        }
        Text('消息通知')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 4 });
      }
      .width('25%')
      .onClick(() => {
        if (this.logoUser.isLogin) {
          RouterModule.push({ url: RouterMap.MESSAGE_CENTER_PAGE });
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE });
        }
      });
    }
    .width('100%')
    .height(76)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16);
  }

  @Builder
  buildServiceComponent() {
    Column() {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.ic_call'))
              .height(48)
              .width(48)
              .objectFit(ImageFit.Contain)
            Text('电话客服')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(600)
              .margin({left: 16})
          }
          Image($r('app.media.icon_right'))
            .height(24)
            .width(12)
        }
        .width('100%')
        .height(40)
        .justifyContent(FlexAlign.SpaceBetween)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .bindSheet($$this.isCustom, this.buildMakeCallComponent(), {
          height: 270, // 半模态高度
          title: this.buildTitle('电话客服'),
          dragBar: true, // 是否显示控制条
          showClose: true, // 是否显示关闭图标
          maskColor: $r('sys.color.ohos_id_color_mask_thin'),
          blurStyle: BlurStyle.Regular,
          preferType: SheetType.CENTER,
          backgroundColor: 'rgba(0, 0, 0, 0.05)',
          shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
            sheetDismiss.dismiss();
          })
        })
        .onClick(() => {
          this.isCustom = true;
        });

        Divider()
          .color($r('sys.color.comp_divider'))
          .margin({left: 60})

        Row() {
          Row() {
            Image($r('app.media.ic_help'))
              .height(48)
              .width(48)
              .objectFit(ImageFit.Contain)
            Text('在线客服')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(600)
              .margin({left: 16})
          }
          Image($r('app.media.icon_right'))
            .height(24)
            .width(12)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(40)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => {
          RouterModule.push({ url: RouterMap.CUSTOM_SERVICE_PAGE })
          this.isOpen = false;
        });
      }
      .width('100%')
      .height(170)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceEvenly);
    }
    .width('100%')
    .height(170)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 16,
      right: 16,
      bottom: 16,
      top: 8
    })

  }

  @Builder
  buildMakeCallComponent() {
    Column() {
      Column() {
        Text('0000-00000000')
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(30)
          .halfLeading(true);
        Button() {
          Row() {
            Image($r('app.media.path_1'))
              .height(14)
              .objectFit(ImageFit.Contain)
              .margin({ right: 5 });
            Text('一键拨号')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(600);
          };
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor('#4c5dc4')
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            try {
              call.makeCall('0000-00000000');
            } catch (e) {
            }
          }
          this.isCustom = false;
        });

        Button() {
          Text('取消')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(600);
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => this.isOpen = false);
      }
      .width('100%')
      .height(170)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceEvenly);
    }
    .width('100%')
    .height(170)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 16,
      right: 16,
      bottom: 16,
      top: 8
    })
  }

  @Builder
  buildTitle(val: string) {
    Text(val)
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Medium);
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Text('我的')
          .size({ width: 328, height: 32 })
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 12, bottom: 12 });
      };

      Scroll() {
        Column({ space: 12 }) {
          this.perMine();
          this.minMine();
          Text('常用服务').fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Medium);
          Grid() {
            ForEach(this.mineArr, (item: MineItem) => {
              GridItem() {
                if (item.titleName === '联系客服') {
                  UserItem({ title: item.titleName, image: item.icon, url: item.url })
                    .bindSheet($$this.isOpen, this.buildServiceComponent(), {
                      height: 270, // 半模态高度
                      title: this.buildTitle('联系客服'),
                      dragBar: true, // 是否显示控制条
                      showClose: true, // 是否显示关闭图标
                      maskColor: $r('sys.color.ohos_id_color_mask_thin'),
                      backgroundColor: 'rgba(0, 0, 0, 0.05)',
                      blurStyle: BlurStyle.Regular,
                      preferType: SheetType.CENTER,
                      shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
                        sheetDismiss.dismiss();
                      })
                    })
                    .onClick(() => {
                      if (!this.logoUser.isLogin) {
                        RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true });
                        return;
                      }
                      this.isOpen = true;
                    });
                } else {
                  UserItem({ title: item.titleName, image: item.icon, url: item.url })
                    .onClick(() => {
                      if (this.logoUser.isLogin && item.url &&
                        (item.titleName === '浏览记录' || item.titleName === '练习记录' || item.titleName === '我的下载')) {
                        RouterModule.push({ url: item.url, param: this.logoUser });
                      } else if (this.logoUser.isLogin && item.url && (item.titleName === '设置')) {
                        RouterModule.push({ url: item.url });
                      } else if (this.logoUser.isLogin && item.url) {
                        this.feedBackVM.navPathStack = RouterModule.stack;
                        RouterModule.push({ url: item.url });
                      } else {
                        RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: RouterModule.stack });
                      }
                    });
                }
              }
            }, (item: MineItem) => JSON.stringify(item));
          }
          .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2
          }).getValue(this.mineVM.breakPointModel.currentBreakpoint)))
          .columnsGap($r('app.float.vp_12'))
          .rowsGap($r('app.float.vp_12'))
          .borderRadius(16);

          Blank()
            .layoutWeight(1);
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ bottom: 12 });

      }
      .alignSelf(ItemAlign.Start)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1);
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 });
  }
}

