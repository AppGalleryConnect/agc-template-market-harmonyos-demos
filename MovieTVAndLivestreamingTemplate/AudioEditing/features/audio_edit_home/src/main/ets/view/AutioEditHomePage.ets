/**
 * @usage: 音频编辑首页,作为音频编辑模块的一级页面,展示音频剪辑、调速、调节、合成、提取、
 * 格式转换、降噪等功能入口。支持登录状态检测、VIP权益校验、音频提取次数限制等功能。
 * 用户可以选择不同的音频处理功能进行操作,未登录用户点击功能时会引导至登录页面。
 * @layout: 页面采用Stack堆叠布局,背景图片铺满全屏,内容区域使用Column垂直布局。
 * 顶部为用户信息卡片(perMine),中间为音频剪辑卡片,
 * 下方为音频合成和音频调节的功能卡片,底部为更多功能卡片(音频调速、
 * 音频提取、格式转换、降噪处理等)。VIP权益弹窗采用蒙层+居中弹窗的形式。
 * @constraints: 音频提取功能需要VIP权限,普通用户无提取次数直接引导充值,
 * VIP用户每日10次限制,超级VIP不受限制。所有音频处理功能需要先登录才能使用。
 * @modifiable: 用户信息卡片，音频剪辑卡片，音频合成和音频调节的功能卡片，更多功能卡片可供定制。其中音频剪辑卡片必选。
 * @domain: 音频编辑
 * @zhName: 音频编辑首页
 * @fileType: page
 * @isGen: true
 * @subPage: SelectPage,AudioExtractionHomePage,AudioSynthesisPage,AudioAdjustPage,AudioFormatConversionPage,
 * LoginPage,EditPersonalCenterPage,VipCenterPage
 * @component: AudioEditWidget,VipRightsDialog
 * @image: screenshots/audioEditHome/audioEditHomePage_edit.jpg
 */
import { AudioEditWidget } from '../components/AudioEditWidget'
import { moreSkillData, MoreSkillModel } from '../model/CommonModel'
import { phoneRouterControl } from 'oh_router'
import { RouterMap, UserInfo } from 'common'
import { SelectPageBuilder } from './SelectPage'
import { common } from '@kit.AbilityKit'
import { AudioExtractionUsage } from 'audio_extraction'
import { PersistenceV2 } from '@kit.ArkUI'
import { VipRightsDialog } from '../components/VipRightsDialog'
import { VipCenterPageBuilder } from 'person'
import { LoginPageBuilder } from 'person/src/main/ets/views/LoginPage'
import { EditPersonalCenterBuilder } from 'person/src/main/ets/views/EditPersonalCenterPage'


@ComponentV2
export struct AutioEditHomePage {
  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local usage: AudioExtractionUsage = PersistenceV2.connect(AudioExtractionUsage, () => new AudioExtractionUsage())!;
  @Local showVipDialog: boolean = false;
  @Local vipDialogType: 'charge' | 'upgrade' = 'charge';

  // 检查音频提取权益
  checkAudioExtractionRights(): boolean {
    const today = new Date().toDateString();

    let currentCount = this.usage.count;
    let freeCount = this.usage.freeCount;
    let vipCount = this.usage.vipCount;

    if (this.usage.lastExtractDate !== today) {
      currentCount = 0;
      freeCount = 0;
      vipCount = 0;
    }

    const vipLevel = this.userInfo.vipLevel;

    if (vipLevel >= 2) {
      // 超级VIP: 不受限制
      return true;
    } else if (vipLevel === 1) {
      // VIP: 每日10次
      if (vipCount >= 10) {
        this.vipDialogType = 'upgrade';
        this.showVipDialog = true;
        return false;
      }
    } else {
      // 普通用户: 无提取次数，直接引导去升级
      this.vipDialogType = 'charge';
      this.showVipDialog = true;
      return false;
    }
    return true;
  }

  //登录校验
  checkLogin() {
    if (!this.userInfo.isLogin) {
      //跳转到登录页面
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
      return false
    }
    return true
  }

  @Builder
  textBlock(str: string) {
    Text(str)
      .width(64)
      .height(24)
      .borderRadius(4)
      .border({ width: 1, color: Color.White })
      .fontColor(Color.White)
      .fontSize(12)
      .margin({ right: 8 })
      .textAlign(TextAlign.Center)
  }

  // 获取头像资源
  getAvatarSource(): ResourceStr {
    if (!this.userInfo.isLogin) {
      return $r('app.media.person');
    }
    if (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') {
      return this.userInfo.avatarUrl;
    }
    return $r('app.media.path2x');
  }

  // 获取VIP文本
  getVipText(): string {
    const level = this.userInfo?.vipLevel ?? 0;
    if (level === 1) {
      return 'VIP用户';
    } else if (level === 2) {
      return '超级VIP用户';
    }
    return '普通用户';
  }

  @Builder
  perMine() {
    Row() {
      Image(this.getAvatarSource())
        .borderRadius(50)
        .width(50)
        .aspectRatio(1)

      Row() {
        Column() {
          Row() {
            Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '未登录')
              .height(24)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 16, bottom: 2 })
            if (this.userInfo?.isLogin && this.userInfo?.vipLevel !== 0) {
              Image($r('app.media.icon_vip_mini'))
                .width(16)
                .height(16)
                .margin({ left: 12 })

            }
          }

          if (this.userInfo?.isLogin) {
            Text(this.getVipText())
              .fontSize(14)
              .fontWeight(400)
              .fontColor('#FFFFFF')
              .margin({ left: 16 })
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(72)
    .padding(12)
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PERSONAL_CENTER_PAGE,
          builder: wrapBuilder(EditPersonalCenterBuilder)
        })
      }
    })
  }

  @Builder
  imageTextBlock(item: MoreSkillModel) {
    Column() {
      Stack() {
        Image(item.src).width(29).height(28)
        if (item.vipIcon) {
          Image(item.vipIcon).width(12).height(12)
        }
      }.width(29).height(28).alignContent(Alignment.TopEnd)

      Text(item.title).fontSize(12).fontColor('#E6FFFFFF').margin({ top: 4 })
    }
    .onClick(() => {
      //登录校验
      if (!this.checkLogin()) {
        return
      }
      // 如果是音频提取页面，进行权限拦截
      if (item.pageName === RouterMap.AUDIO_EXTRACTION_PAGE) {
        if (!this.checkAudioExtractionRights()) {
          return;
        }
      }

      phoneRouterControl.jumpPage({
        pageName: item.pageName,
        builder: item.builder,
        param: item.param
      })
    })
    .width('33.3333333333333%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .flexShrink(0)
    .margin({ top: 24 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.audio_bg_zhiban')).width('100%')

        Column() {
          Row() {
            // 用户信息卡片
            this.perMine()
          }.width('100%')

          // 音频剪辑卡片
          Column() {
            Row() {
              Row() {
                Image($r('app.media.icon_jiandao')).width(44).height(44)
                Text('音频剪辑').fontSize(24).fontColor(Color.White).margin({ left: 12 })
              }

              Text() {
                Span('立即体验').fontSize(14).fontColor(Color.White)
                ImageSpan($r('app.media.icon_right_white')).width(16).height(16)
              }
              .width(88)
              .height(32)
              .borderRadius(22)
              .backgroundColor('rgba(255,255,255,0.2)')
              .textAlign(TextAlign.Center)
              .align(Alignment.Center)
            }.justifyContent(FlexAlign.SpaceBetween).width('100%')

            Row() {
              this.textBlock('音频编辑')
              this.textBlock('音频调节')
              this.textBlock('剪片段')
            }.width('100%')
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .height(148)
          .padding({
            top: 10,
            bottom: 15,
            left: 16,
            right: 12
          })
          .borderRadius(16)
          .margin({ top: 24 })
          .linearGradient({
            angle: 360, // 渐变方向
            colors: [['#CC01A8FE', 0.0], ['#CC000000', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .onClick(() => {
            //登录校验
            if (!this.checkLogin()) {
              return
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.SELECT_PAGE,
              builder: wrapBuilder(SelectPageBuilder)
            })
          })

          // 音频合成和音频调节的功能卡片
          Row() {
            Row() {
              AudioEditWidget({
                title: '音频合成',
                iconSrc: $r('app.media.icon_hecheng_white'),
                tag: '歌曲串烧',
                angle: 132,
                colors: [['#C707FF', 0], ['#01A8FE', 1]],
                turnPage: (() => {
                  //登录校验
                  if (!this.checkLogin()) {
                    return
                  }
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.SELECT_PAGE,
                    builder: wrapBuilder(SelectPageBuilder),
                    param: {
                      'pageType': 'audioSynthesis',
                      'headTitle': '选择音频',
                      'listMode': 'checkBox'
                    } as Record<string, string>
                  })
                })
              }).layoutWeight(1)
            }
            .layoutWeight(1)

            Divider().height(10).width(8)
            Row() {
              AudioEditWidget({
                title: '音频调节',
                iconSrc: $r('app.media.icon_tiaojie_white'),
                tag: '升调降调',
                angle: 132,
                colors: [['#01A8FE', 0], ['#01FCEA', 1]],
                turnPage: (() => {
                  //登录校验
                  if (!this.checkLogin()) {
                    return
                  }
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.SELECT_PAGE,
                    builder: wrapBuilder(SelectPageBuilder),
                    param: { 'pageType': 'audioAdjustTone', 'headTitle': '选择音频' } as Record<string, string>
                  })
                })
              }).layoutWeight(1)
            }.layoutWeight(1)
          }.width('100%')
          .margin({ top: 12 })

          // 更多功能卡片
          Column() {
            Row() {
              Text('更多功能').fontSize(16).fontColor('#D9FFFFFF')
            }.width('100%').margin({ bottom: 1 })

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(moreSkillData, (item: MoreSkillModel) => {
                this.imageTextBlock(item)
              },(item: MoreSkillModel,index: number)=>index.toString())
            }.width('100%')
          }.width('100%').margin({ top: 38 })
        }.width('100%').padding({ left: 16, right: 16 })
        .margin({ top: 24 })

        // VIP 权益弹窗
        if (this.showVipDialog) {
          Stack() {
            // 蒙层
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0,0,0,0.6)')
              .onClick(() => {
                this.showVipDialog = false;
              })

            // 弹窗
            VipRightsDialog({
              type: this.vipDialogType,
              onCancel: () => {
                this.showVipDialog = false;
              },
              onConfirm: () => {
                this.showVipDialog = false;
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.VIP_CENTER_PAGE,
                  builder: wrapBuilder(VipCenterPageBuilder),
                  onPop: (popInfo: PopInfo) => {
                    // 暂时不需要特殊处理，但可以保留结构以备后用
                  }
                });
              }
            })
          }
          .width('100%')
          .height('100%')
          .zIndex(1001)
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
        }
      }.height('100%').width('100%')
    }
    .backgroundColor('#0A0D1E')
  }
}