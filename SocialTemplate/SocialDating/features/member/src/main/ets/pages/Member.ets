import { BasicUserInfo, CommonRsp, Constants } from 'commons';
import { call } from '@kit.TelephonyKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import Logger from 'commons/src/main/ets/utils/Logger';
import MatchMakerService from '../service/MatchMakerService';
import MemberService from '../service/MemberService';
import { MemberShip } from '../model/QueryMemberShipResponse';
import { MemberPageParam } from '../model/MemberPageParam';
import { Matchmaker } from '../model/Matchmaker';

@Builder
export function MemberPageBuilder() {
  MemberPage()
}

@Component
@Preview
export struct MemberPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State isMember: boolean = false;
  @State isShowSubscribeMember: boolean = false;
  @State selectedIdx: number | null = 0;
  @State isShowContactMatchmaker: boolean = false;
  @State isRenewSubscribe: boolean = false;
  @Prop @Watch('onChange') index: number = 0;

  private currentUser: BasicUserInfo | null = null;
  private memberService1: string[] =
    ['app.media.img_member_1', '只认识对的人', '更高效更专注', '一对一牵线', '精准匹配', '高级搜索']
  private memberService2: string[] =
    ['app.media.img_member_2', '专业数据分析', '为你找到唯一', '专业红娘为你匹配', '专业情感指导服务']
  private memberService3: string[] =
    ['app.media.img_member_3', '时刻为你服务', '倾听你的诉求', '专属红娘为你服务', '及时反馈结果']
  private matchMaker: Matchmaker | null = null;
  private memberShips: MemberShip[] = [];

  aboutToAppear(): void {
    this.getCurrentUserFromAppStorage();
    let params: MemberPageParam[] = this.pageStack.getParamByName('Member') as MemberPageParam[];
    if (params != null && params.length > 0) {
      if (params[0] != null) {
        this.isRenewSubscribe = params[0].isRenewSubscribe;
      }
    }

    this.getMatchMaker();
    this.getMembershipList()
  }

  private getCurrentUserFromAppStorage() {
    let currentUser: BasicUserInfo | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    if (currentUser != null && currentUser !== undefined) {
      this.currentUser = currentUser;
      this.isMember = currentUser.isVip === Constants.YES;
    }
  }

  onChange() {
    if (this.index === Constants.PAGE_INDEX_MEMBER) {
      this.getCurrentUserFromAppStorage();
    }
  }
  build() {
    NavDestination() {
      Column() {
        Blank().height(10)
        this.buildMemberServiceItem(this.memberService1, true);
        this.buildMemberServiceItem(this.memberService2, false);
        this.buildMemberServiceItem(this.memberService3, true);

        Blank().height('6%')
        if ((!this.isMember) || this.isRenewSubscribe) {
          this.buildSubscribeMemberButton()
        } else {
          this.buildContactMatchMakerButton()
        }
      }
    }.backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  buildMemberServiceItem(memberService: string[], textOnRight: boolean) {
    Row() {
      if (textOnRight) {
        this.showMemberServiceImg(memberService[0])
        this.showDescInfo(memberService);
      } else {
        this.showDescInfo(memberService);
        this.showMemberServiceImg(memberService[0])
      }
    }
    .width('92%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 16 })
    .height('22%')

  }

  @Builder
  showMemberServiceImg(img: string) {
    Column() {
      Image($r(img)).width(190).height(120)
    }.width(190)
  }

  @Builder
  showDescInfo(memberService: string[]) {
    Column() {
      Text(memberService[1])
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .margin({ bottom: 4 })
      Text(memberService[2])
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .margin({ bottom: 4 })
      ForEach(memberService.filter(((value: string, index: number, memberServiceDetailItems: string[]) => {
        return index >= 3
      })), (item: string) => {
        Text(item)
          .fontSize(10)
          .fontColor($r('app.color.text_font_color_gray'))
          .fontWeight(FontWeight.Regular)
          .fontFamily(Constants.HARMONY_HEITI)
          .margin({ bottom: 4 })
      }, (item: string) => item)
    }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start).margin({ left: 16, right: 16 })
  }

  @Builder
  buildSubscribeMemberButton() {
    Row() {
      Button(this.isRenewSubscribe ? '续费' : '开通会员')
        .height(40)
        .width('92%')
        .fontSize($r('sys.float.Body_L'))
        .borderRadius(20)
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.button_background_color'))
        .onClick(() => {
          this.isShowSubscribeMember = !this.isShowSubscribeMember;
        })
        .bindSheet($$this.isShowSubscribeMember, this.subscribeMemberBuilder(this.memberShips), {
          detents: [320],
          preferType: SheetType.BOTTOM,
          title: bindSheetTitleBuilder('会员套餐')
        })
    }.margin({ top: 10, bottom: 10 })
  }

  @Builder
  subscribeMemberBuilder(membershipList: Array<MemberShip>): CustomBuilder {
    Column() {
      Row() {
        ForEach(membershipList, (item: MemberShip, index: number) => {
          Column() {
            Text(item.name).fontSize($r('sys.float.Body_M')).margin({ top: 16, bottom: 16 });
            Text() {
              Span('¥')
                .fontSize($r('sys.float.Body_M'))
              Span(item.fee.toString())
                .fontSize(30)
            }.height(40).fontWeight(FontWeight.Bold)
            .fontFamily(Constants.HARMONY_HEITI)
            .fontColor((this.selectedIdx == null || index !== this.selectedIdx) ?
            $r('app.color.text_font_color_black') : $r('app.color.button_background_color'))

            Text(item.desc)
              .fontSize(10)
              .margin({ top: 18, bottom: 10 })
              .fontColor((this.selectedIdx == null || index !== this.selectedIdx) ?
              $r('app.color.text_font_color_black') : '#FF562E15')
          }
          .width(88)
          .height(124)
          .backgroundImage((this.selectedIdx == null || index !== this.selectedIdx) ?
          $r('app.media.img_membership_1') : $r('app.media.img_membership_0'))
          .backgroundImageSize(ImageSize.FILL)
          .borderRadius(8)
          .margin({ left: 10, right: 10, top: 16 })
          .onClick(() => {
            this.selectedIdx = index;
          })
        }, (item: MemberShip, index: number) => JSON.stringify(item))
      }.padding({ left: 12, right: 12 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      Row() {
        Button('升级VIP')
          .height(40)
          .width('92%')
          .backgroundColor($r('app.color.button_background_color'))
          .enabled(this.selectedIdx != null)
          .onClick(() => {
            if (this.currentUser != null && this.currentUser.uid != null && this.selectedIdx != null &&
              this.memberShips[this.selectedIdx] != null) {
              MemberService.subscribeMember(this.currentUser.uid, this.memberShips[this.selectedIdx].id,
                new Date().getTime())
                .then((data: CommonRsp | null) => {
                  if (data == null || data.retCode !== Constants.RET_SUCCESS_CODE) {
                    Logger.error('subscribeMember failed, rsp=' + JSON.stringify(data) + ', currentUser=' +
                    JSON.stringify(this.currentUser));
                    return;
                  }
                  this.isMember = true;
                  if (this.currentUser != null) {
                    this.currentUser.isVip = Constants.YES;
                    AppStorage.setOrCreate(Constants.CURRENT_USER_BASIC, this.currentUser);
                  }
                  this.pageStack.pop(this.currentUser, false);
                })
            }
          });
      }.margin({ top: 4, bottom: 32 })
    }.width('92%').backgroundColor(Color.White).borderRadius(16)
  }

  @Builder
  buildContactMatchMakerButton() {
    Row() {
      Button('联系您的专属红娘')
        .height(40)
        .width('92%')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .borderRadius(18)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('app.color.button_background_color'))
        .onClick(() => {
          this.isShowContactMatchmaker = !this.isShowContactMatchmaker;
        })
        .bindSheet($$this.isShowContactMatchmaker, contactMatchmakerBuilder(this.matchMaker, () => {
          this.isShowContactMatchmaker = !this.isShowContactMatchmaker
        }), {
          detents: [360],
          preferType: SheetType.BOTTOM,
          title: bindSheetTitleBuilder('联系红娘')
        })
    }.margin({ top: 10, bottom: 10 })
  }

  getMembershipList() {
    MemberService.queryMembership().then((data: MemberShip[]) => {
      this.memberShips = data;
    })
  }

  getMatchMaker() {
    MatchMakerService.queryMatchMaker().then((data: Matchmaker[]) => {
      this.matchMaker = data[0];
    })
  }
}

@Builder
export function bindSheetTitleBuilder(title: string): CustomBuilder {
  Text(title)
    .fontSize(20)
    .fontColor($r('app.color.text_font_color_black'))
    .fontWeight(FontWeight.Medium)
    .margin({ top: 16, bottom: 16 })
    .width('92%')
}

@Builder
export function contactMatchmakerBuilder(matchMaker: Matchmaker | null, cancelCalled: () => void): CustomBuilder {
  Column() {
    if (matchMaker != null) {
      Row() {
        Image(matchMaker.profilePictureUrl == null ? $r('app.media.head_image_default') :
          (matchMaker.profilePictureUrl.startsWith('app.media') ? $r(matchMaker.profilePictureUrl) :
          matchMaker.profilePictureUrl))
          .width(72)
          .height(72)
          .objectFit(ImageFit.Cover)
          .margin({ left: '5vp', top: '5vp', })
          .clipShape(new Circle({ width: 72, height: 72 }))
          .borderRadius(16)
      }.margin({ top: 12 })

      Row() {
        Text('微信号：' + matchMaker.weixinNo)
          .fontSize(18)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontColor($r('app.color.text_font_color_black'))
          .copyOption(CopyOptions.LocalDevice)
        Image($r('app.media.ic_public_power_duplicating')).width(16).height(16).margin({ left: 4 }).onClick(() => {
          let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
          let pasteData: pasteboard.PasteData =
            pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, matchMaker.weixinNo)
          systemPasteboard.setData(pasteData)
        })
      }.margin({ top: 16, bottom: 16 })

      Row() {
        Text('电话号码：' + desensitizePhoneNumber(matchMaker.phoneNo))
          .fontSize(18)
          .fontFamily(Constants.HARMONY_HEITI)
          .fontColor($r('app.color.text_font_color_black'))
          .copyOption(CopyOptions.LocalDevice)
      }.margin({ bottom: 16 })

      Row() {
        Image($r('app.media.ic_phone_highlight')).width(24).height(24).margin({ right: 8 })
        Text('一键拨号')
          .fontFamily(Constants.HARMONY_HEITI)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .width('85%')
      .borderRadius(20)
      .backgroundColor($r('app.color.button_background_color'))
      .justifyContent(FlexAlign.Center)
      .height(40)
      .margin({ bottom: 16 })
      .onClick(() => {
        call.makeCall(matchMaker.phoneNo, (err: BusinessError) => {
          if (err) {
            Logger.error(`makeCall fail, err->${JSON.stringify(err)}`);
          } else {
            Logger.info('makeCall success');
          }
        });
      })

      Row() {
        Text('取消')
          .fontFamily(Constants.HARMONY_HEITI)
          .fontSize($r('sys.float.Body_L'))
          .fontColor('#66000000')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            cancelCalled()
          })
      }
      .borderRadius(20)
      .height(40)
      .margin({ bottom: 16 })
      .width('85%')
      .backgroundColor('#0D000000')
      .justifyContent(FlexAlign.Center)
    }
  }.borderRadius(16).backgroundColor(Color.White).width('92%')
}


function desensitizePhoneNumber(phone: string): string {
  if (!phone || typeof phone !== 'string') {
    return '';
  }
  const cleanedPhone = phone.trim().replace(/\s/g, '');
  if (!/^\d{11}$/.test(cleanedPhone)) {
    return phone; // 返回原始值或根据需求改为返回空
  }
  return cleanedPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}

