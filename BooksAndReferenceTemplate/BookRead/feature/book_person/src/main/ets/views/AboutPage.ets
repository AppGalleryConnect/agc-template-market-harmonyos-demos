import { CustomContentDialog } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { baseActionSheet } from 'base_common';
import { UserInfo } from 'base_common';
import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants,
  FontModel,
  NavHeaderBar, TCRouter } from 'common';
import { AvatarIcon } from '../comp/SelectAvatarCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';


@ComponentV2
export struct AboutPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon | undefined = undefined;
  @Local isSelectCalendar: boolean = false;
  @Local isModifyNickName: boolean = false;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local isLatestVersion: boolean = false
  @Local updateProgress: number = 0
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  timerId?: number
  updateDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.updateDialogBuilder();
      },
      buttons: [
        {
          value: '以后再说',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked')
          }
        },
        {
          value: '立即更新',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.progressDialogController.open()
            this.update()
          }
        }
      ],
    }),
    alignment: DialogAlignment.Bottom
  });

  progressDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.progressDialogBuilder();
      },
    }),
    alignment: DialogAlignment.Bottom
  });

  update(){
    this.timerId= setInterval(() => {
      if(this.updateProgress<100) {
        this.updateProgress+=25
      } else {
        this.isLatestVersion=true
        this.progressDialogController.close()
      }
    }, 500)
  }

  stopUpdate(){
    clearInterval(this.timerId)
    this.progressDialogController.close()
    this.updateProgress=0
  }

  @Builder
  updateDialogBuilder() {
    Column() {
      Text('发现新版本')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width(Constants.FULL_SIZE)
        .padding({
          bottom:15
        })
      Column(){
        Row({space:8}){
          Text('应用')
          Text('阅读听书')
        }
        Row({space:8}){
          Text('版本')
          Text('1.0.00.000')
        }
        Row({space:8}){
          Text('大小')
          Text('50MB')
        }
      }
      .width(Constants.FULL_SIZE)
      .alignItems(HorizontalAlign.Start)
      .padding({
        top:12,
        bottom:12
      })
      Column(){
        Text('详情')
          .margin({bottom:12})
        Text('1、新增 发布添加表情自定义\n' +
          '2、优化 新闻阅读闪退问题\n' +
          '3、修复 若干bug')
      }
      .alignItems(HorizontalAlign.Start)
      .width(Constants.FULL_SIZE)
      .padding({
        top:12,
        bottom:12
      })
    }
    .width('100%')
  }

  @Builder
  progressDialogBuilder() {
    Row(){
      Column({space:12}){
        Row(){
          Text('正在更新')
            .fontSize(14)
          Text(this.updateProgress+'%')
            .fontSize(14)
        }
        .width(244)
        .justifyContent(FlexAlign.SpaceBetween)
        Progress({ value: this.updateProgress, total: 100, type: ProgressType.Linear })
          .width(244)
      }
      .width(244)
      Image($r('app.media.ic_public_close_circle'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .onClick(() => {this.stopUpdate()})
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constants.FULL_SIZE)
    .padding({
      left:4,
      right:4
    })
  }

  @Builder
  PhoneSheetBuilder() {
    Column({ space: 12 }) {
      Text('000000')
        .fontSize(18)
        .fontWeight('medium')
      Row({ space: 8 }) {
        Text('一键拨号')
          .fontSize(16)
          .fontWeight('medium')
          .fontColor($r('app.color.pure_white'))
      }
      .padding({ top: 10, bottom: 10 })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .backgroundColor('#E84026')
      .onClick(() => {
        try {
          call.makeCall('000000')
        } catch (err) {
          console.error(`makeCall fail, err->${JSON.stringify(err)}`);
        }
      })

      Row() {
        Text('取消')
          .fontSize(16)
          .fontWeight('medium')
          .fontColor('#ffffff')
      }
      .padding({ top: 10, bottom: 10 })
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .borderRadius(20)
      .backgroundColor(Color.Gray)
      .onClick(() => {
        baseActionSheet.close('PhoneSheetBuilder')
      })
    }
    .width('90%')
    .padding({
      left: 12,
      right: 12,
      bottom: 16,
      top: 16
    })
    .margin({ bottom: 40, left: 16, right: 16 })
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_bg'))
    .borderRadius(16)
  }

  @Builder
  aboutCardView(){
    Column({space : 10}){
      Row(){
        Column(){
          Row({space:8}) {
            Text('版本信息')
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(FontWeight.Normal)
              .height(22)
              .textAlign(TextAlign.Start)
            if (!this.isLatestVersion) {
              Image($r('app.media.red_dot'))
                .width(8)
                .height(8)
                .objectFit(ImageFit.Contain)
            }
          }
          .width(100)
          .justifyContent(FlexAlign.Start)
          Text($r('app.string.agcit_huawei_book_read'))
            .fontSize(this.fontModel.getFg(12))
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
        }
        Row({space:4}){
          Text(this.isLatestVersion? '检查更新': '待更新')
            .height(16)
            .fontSize(this.fontModel.getFg(12))
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_secondary'))
          Row(){
            Image($r('app.media.ic_arrow_right'))
              .width(8)
              .height(14)
              .objectFit(ImageFit.Contain)
          }
          .width(16)
          .height(16)
          .padding({
            top:1,
            bottom:1,
            left:4.5,
            right:4.5
          })
        }
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if(this.isLatestVersion) {
          this.getUIContext().getPromptAction().showToast({ message: '已是最新版本' })
        } else {
          this.updateDialogController.open()
        }
      })
      Divider()
        .width(Constants.FULL_SIZE)
        .height(0.5)
      Row(){
        Column(){
          Text('客服电话')
            .fontSize(this.fontModel.getFg(16))
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(22)
            .textAlign(TextAlign.Start)
          Text('000000')
            .fontSize(this.fontModel.getFg(12))
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
        }
        Row({space :4}){
          Row(){
            Image($r('app.media.ic_arrow_right'))
              .width(8)
              .height(14)
              .objectFit(ImageFit.Contain)
          }
          .width(16)
          .height(16)
          .padding({
            top:1,
            bottom:1,
            left:4.5,
            right:4.5
          })
        }
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => { baseActionSheet.show({
        id: 'PhoneSheetBuilder',
        title: { title: '联系客服' },
        height: SheetSize.FIT_CONTENT,
        preferType: SheetType.CENTER,
        backgroundColor: $r('sys.color.ohos_id_color_toolbar_bg'),
        customContent: () => {
          this.PhoneSheetBuilder()
        },
      })
      })
      Divider()
        .width(Constants.FULL_SIZE)
        .height(0.5)
      Row(){
        Text('个人信息收集清单')
          .fontSize(this.fontModel.getFg(16))
          .fontWeight(FontWeight.Normal)
          .height(22)
          .textAlign(TextAlign.Start)
        Row(){
          Image($r('app.media.ic_arrow_right'))
            .width(8)
            .height(14)
            .objectFit(ImageFit.Contain)
        }
        .width(16)
        .height(16)
        .padding({
          top:1,
          bottom:1,
          left:4.5,
          right:4.5
        })
      }
      .width(Constants.FULL_SIZE)
      .height(38)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        TCRouter.push(Constants.DATA_COLLECTION_ROUTE)
      })
      Divider()
        .width(Constants.FULL_SIZE)
        .height(0.5)
      Row(){
        Text('第三方共享信息清单')
          .fontSize(this.fontModel.getFg(16))
          .fontWeight(FontWeight.Normal)
          .height(22)
          .textAlign(TextAlign.Start)
        Row(){
          Image($r('app.media.ic_arrow_right'))
            .width(8)
            .height(14)
            .objectFit(ImageFit.Contain)
        }
        .width(16)
        .height(16)
        .padding({
          top:1,
          bottom:1,
          left:4.5,
          right:4.5
        })
      }
      .width(Constants.FULL_SIZE)
      .height(38)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        TCRouter.push(Constants.DATA_SHARING_ROUTE)
      })
    }
    .width(Constants.FULL_SIZE)
    .borderRadius(32)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      top:16,
      bottom:16,
      left:12,
      right:12
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '关于',
        hasBackButton: true,
        hasBgColor: false,
        isMainPage: false,
      })
      Column() {
        Column({space:70}){
          Column({space: 8}){
            Image($r('app.media.startIcon'))
              .width(72)
              .height(72)
              .borderRadius(16)
              .objectFit(ImageFit.Contain)
            Text('阅读模板')
              .width(328)
              .height(21)
              .fontSize(fp2pxUtil(16))
              .fontWeight(500)
              .textAlign(TextAlign.Center)
          }
          this.aboutCardView()
        }

        Column(){
          Text('XXXX备xxxxxxxx号-xxxx')
            .fontSize(fp2pxUtil(12))
            .fontColor('#0A59F7')
          Text('xxxx 版权所有 © xxxx-xxxx')
            .fontSize(fp2pxUtil(12))
            .fontColor($r('sys.color.font_secondary'))
          Text('技术支持：xxxxxxxx')
            .fontSize(fp2pxUtil(12))
            .fontColor($r('sys.color.font_secondary'))
        }
      }
      .padding({
        left:16,
        right:16,
        top:24,
        bottom:40
      })
      .width(this.curBreakpoint.value === BreakpointTypeEnum.LG?'70%':Constants.FULL_SIZE)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}