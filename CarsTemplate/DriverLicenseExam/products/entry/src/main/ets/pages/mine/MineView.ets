import { COMMON_SERVICE } from '@ohos_agcit/driver_license_exam_datasource/src/main/ets/Data';
import {  MinePageCommonService } from '@ohos_agcit/driver_license_exam_datasource/src/main/ets/Model';

import {   showToast, AccountUtil, StringUtil, CommonConstants,
  CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { ExamService } from '@ohos_agcit/driver_license_exam_datasource'
import { GuideService, licenseTypeName } from '@ohos_agcit/driver_license_exam_guide'
import { JSON } from '@kit.ArkTS';
import { FeedbackTrigger } from 'feedback';
import { CustomWindowModel } from 'app_setting';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MineViewBuilder() {
  MineView();
}

class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}

@ComponentV2
export struct MineView {
  @Param didCount: number = 0;
  @Param accuracyRate: number = 0;
  @Param averageScore: number = 0;
  @Local currentTab: number = 0; // 0-科目一，1-科目四
  examService: ExamService= ExamService.instance(this.getUIContext().getHostContext() as Context);
  guideService: GuideService = GuideService.instance;
  logTag: string = 'PrepareLoginPage';
  domainId: number = 0x0000;
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;
  bottomRectHeight:number = AppStorage.get('bottomRectHeight') || 0;
  scroller: Scroller = new Scroller();
  vm: CommonModel = CommonModel.instance;
  @Local egDivider: DividerTmp = new DividerTmp(1, 40, 0, '#ffe9f0f0');

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  // 构建题库切换模块
  @Builder
  ExamSwitchModule() {
    Row() {
      Text('切换题库：')
        .fontSize(14)
        .maxFontScale(1)
      Text( this.guideService.guideData.licenseType !== undefined?licenseTypeName[this.guideService.guideData.licenseType]:'')
        .fontSize(14)
        .fontColor('#64BB5C')
        .maxFontScale(1)
      Image($r('app.media.right_triangle'))
        .width(16)
        .height(16)
        .fillColor($r('sys.color.icon_primary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.vm.navStack.pushPathByName('guidePage', true)
    })
  }

  // 构建统计模块
  @Builder
  StatsModule() {
    Row({ space: 12 }) {
      // 左侧统计
      Column({space:4}) {
        Text('已做题')
          .fontSize(14)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxFontScale(1)
        Text(String(this.didCount))
          .fontSize(24)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .height(32)
          .textAlign(TextAlign.Center)
          .maxFontScale(1)
        Text(`正确率${this.accuracyRate}%`)
          .fontSize(12)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
      }
      .width(78)
      .height(99)
      .borderRadius(8)
      .padding(12)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      // 右侧统计
      Column({space:4}) {
        Text('模拟考试平均分')
          .fontSize(14)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxFontScale(1)
        Text(String(this.averageScore))
          .fontSize(24)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .height(32)
          .textAlign(TextAlign.Center)
          .maxFontScale(1)
        Text(`累计考试 ${this.examService.mockExamCount} 次`)
          .fontSize(12)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
      }
      .width(122)
      .height(99)
      .borderRadius(8)
      .padding(12)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(99)
    .justifyContent(FlexAlign.Start)
  }

  // 跳转登录页面
  private jumpLoginPage(quickLoginAnonymousPhone: string | undefined) {
    if (quickLoginAnonymousPhone) {
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      this.vm.navStack.pushPathByName('QuickLoginPage', params, true);
    } else {
      const hint: string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.get_mobile_number_error').id);
      showToast(hint, this.getUIContext());
    }
  }

  // 显示开发中提示
  private showDevelopingToast() {
    showToast('此功能开发中', this.getUIContext());
  }

  @Builder
  Feedback(commonService: MinePageCommonService) {
    FeedbackTrigger() {
      Row() {
        Image($r(commonService.icon))
          .width(24)
          .height(24)
          .margin({ left: 12 })
        Text(commonService.label)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
          .maxFontScale(1)
        Blank()
        Image($r('app.media.ic_right_arrow_lined'))
          .width(7)
          .height(14)
          .fillColor($r('app.color.icon_secondary'))
          .margin({ right: 12 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(46)
      .justifyContent(FlexAlign.Start)
    }
  }

  // 构建功能模块项
  @Builder
  FunctionItem(commonService: MinePageCommonService) {
    Row() {
      Image($r(commonService.icon))
        .width(24)
        .height(24)
        .margin({ left: 12 })
      Text(commonService.label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16 })
        .maxFontScale(1)
      Blank()
      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor($r('app.color.icon_secondary'))
        .margin({ right: 12 })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(46)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (StringUtil.isEmpty(commonService.nextPage)) {
        this.showDevelopingToast();
        return;
      }
      if (AccountUtil.getAccountInfo().idToken === '') {
        // 真实登录，mock场景先注释
        AccountUtil.quickLogin();
        // this.jumpLoginPage(AccountUtil.getAccountInfo().quickLoginAnonymousPhone);
        // mock登录，真实使用场景需删除
        this.jumpLoginPage('a000******00');
      } else {
        this.vm.navStack.pushPathByName(commonService.nextPage, undefined);
      }
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          this.topArea();
          // 用户信息模块
          Column() {
            Row() {
              Image(AccountUtil.getUserInfo().avatar)
                .width(56)
                .height(56)
                .borderRadius(28)

              Column({space:4}) {
                Text(AccountUtil.getUserInfo().nickname)
                  .fontSize(18)
                  .fontFamily('鸿蒙黑体')
                  .fontWeight(FontWeight.Medium)
                  .maxFontScale(1)

                if (AccountUtil.getUserInfo().phone) {
                  Row() {
                    Image($r('app.media.ic_public_mobilephone'))
                      .width(16)
                      .height(16)
                      .margin({
                        right:8
                      })

                    Text(AccountUtil.getUserInfo().phone)
                      .fontFamily('HarmonyHeiTi')
                      .fontColor($r('app.color.font_primary'))
                      .fontSize(12)
                      .fontWeight(400)
                      .lineHeight(16)
                      .maxFontScale(1)
                  }
                }
              }
              .alignItems(HorizontalAlign.Start)
              .margin({
                left:16
              })

              Blank()
              if (!AccountUtil.getUserInfo().phone) {
                Image($r('app.media.ic_right_arrow_lined'))
                  .width(7)
                  .height(18)
                  .fillColor($r('app.color.icon_secondary'))
              }

            }
            .width(CommonConstants.FULL_PERCENT)
            .onClick(async () => {
              if (AccountUtil.getAccountInfo().idToken === '') {
                // 真实登录，mock场景先注释
                // AccountUtil.quickLogin();
                // this.jumpLoginPage(AccountUtil.getAccountInfo().quickLoginAnonymousPhone);
                // mock登录，真实使用场景需删除
                this.jumpLoginPage('a000******00');
              }else {
                this.vm.navStack.pushPathByName('PersonalInfo', undefined)
              }
            });
            Divider()
              .margin({
                top:12,
                bottom:12
              })
            Row() {
              Text('会员中心')
                .width(72)
                .height(28)
                .fontSize(14)
                .borderRadius(14)
                .fontColor('#fff')
                .backgroundColor('rgba(100, 187, 92, 1)')
                .textAlign(TextAlign.Center)
                .maxFontScale(1)
                .onClick(() => {
                  if (AccountUtil.getAccountInfo().idToken === '') {
                    // 真实登录，mock场景先注释
                    // AccountUtil.quickLogin();
                    // this.jumpLoginPage(AccountUtil.getAccountInfo().quickLoginAnonymousPhone);
                    // mock登录，真实使用场景需删除
                    this.jumpLoginPage('a000******00');
                  }else {
                    this.vm.navStack.pushPathByName('membership', true)
                  }
                })

            }
            .justifyContent(FlexAlign.End)
            .width('100%')
          }
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .margin({ top: 5 })
          .padding(12)


          // 新增题库模块
          Column({space:12}) {
            this.ExamSwitchModule()
            this.StatsModule()
          }
          .width(CommonConstants.FULL_PERCENT)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .margin({ top: 12 })
          .padding(12)

          List(){
            ForEach(COMMON_SERVICE, (item: MinePageCommonService) => {
              ListItem(){
                Column() {
                  if (item.label === '意见反馈') {
                    this.Feedback(item)
                  } else {
                    this.FunctionItem(item)
                  }

                }
                .width(CommonConstants.FULL_PERCENT)
                .height(46)

              }
            }, (item: MinePageCommonService) => {
              try {
                return JSON.stringify(item.label)
              } catch (err) {
                return ''
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .divider({
            strokeWidth:0.5,
            color:$r('sys.color.comp_divider'),
            startMargin:12,
            endMargin:12
          })
          .borderRadius(16)
          .margin({
            top:12
          })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .padding({
          left:16,
          right:16,
          top: this.getUIContext().px2vp(this.topRectHeight) + 10,
        })
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor($r('sys.color.background_secondary'))

  }

  @Builder
  topArea() {
    Row() {
      Text($r('app.string.mine'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .maxFontScale(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 12,
      bottom: 12,
    });
  }
}
