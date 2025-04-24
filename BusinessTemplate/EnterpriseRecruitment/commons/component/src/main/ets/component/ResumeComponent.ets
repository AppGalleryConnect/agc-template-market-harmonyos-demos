import { filePreview } from '@kit.PreviewKit';
import { CommonConstants } from '../constants/CommonConstants';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { ResumeEntity } from '../../../../Index';
import { AvoidArea } from '../clazz/AvoidArea';
import { LeftReturnComponent } from './LeftReturnComponent';
import { getCurrentLocalTime } from '../utils/DateUtil';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct ResumeComponent {
  @Param @Require resume: ResumeEntity = CommonConstants.RESUMES[0];
  @Event remove: () => void = () => {
  }
  @Local isHalfShow: boolean = false;
  @Local isFullShow: boolean = false;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local newResumeName: string = ''
  context: Context = getContext();
  displayInfo: filePreview.DisplayInfo = {
    x: 100,
    y: 100,
    width: 800,
    height: 800
  };

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_resume'))
          .height(70)
          .width(70)

        Column() {
          Text(this.resume.name + this.resume.suffix)
            .fontWeight(FontWeight.Medium)
            .width('70%')
          Row() {
            Text(this.resume.size)
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.common_gray_light'))
            Text('  ')
            Text('更新于')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.common_gray_light'))
            Text(this.resume.updateTime)
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.common_gray_light'))
          }
          .margin({ top: 5 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .height('100%')
        .onClick(async () => {
          // sandbox path to uri
          let uri = fileUri.getUriFromPath(this.resume.uri)

          let fileInfo: filePreview.PreviewInfo = {
            title: this.resume.name,
            uri: uri,
            mimeType: 'application/pdf'
          };

          filePreview.openPreview(getContext(this), fileInfo, this.displayInfo).then(() => {
            console.info('Succeeded in opening preview');
          }).catch((err: BusinessError) => {
            console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
          });
        })
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Blank()

      Image($r('app.media.ic_three_point'))
        .height(20)
        .width(20)
        .margin({ right: 15 })
        .onClick(() => {
          this.isHalfShow = !this.isHalfShow
        })
        .bindSheet($$this.isHalfShow, this.MySelectBuilder(), {
          height: 180,
        })
    }
    .padding({ right: 10 })
    .alignItems(VerticalAlign.Center)
    .bindContentCover($$this.isFullShow, this.MyRenameBuilder(), {})
    .borderRadius(20)
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
  }

  @Builder
  MySelectBuilder() {
    Column() {
      Row() {
        Button('重命名')
          .fontSize($r('app.float.font_size_20'))
          .height(55)
          .width(180)
          .fontColor($r('app.color.common_blue'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isHalfShow = !this.isHalfShow
        this.isFullShow = !this.isFullShow
      })

      Row() {
        Button('删除')
          .fontSize($r('app.float.font_size_20'))
          .height(55)
          .width(180)
          .fontColor(Color.Red)
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        fs.unlinkSync(this.resume.uri)
        this.remove()
      })

      Row() {
        Button('取消')
          .fontSize($r('app.float.font_size_20'))
          .height(55)
          .width(180)
          .fontColor($r('app.color.common_blue'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isHalfShow = false
      })

    }
    .height('30%')
    .width('80%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  MyRenameBuilder() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            this.isFullShow = false
          })
      }
      .width('100%')

      Column() {
        Text('简历重命名')
          .fontSize($r('app.float.font_size_18'))
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 50 })
        Text('命名规范建议：姓名-应聘岗位-工作经验')
          .fontSize($r('app.float.font_size_16'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.common_gray_light'))
          .width('100%')
          .margin({ top: 15, left: 3 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)


      Row() {
        TextInput({ text: this.resume.name, placeholder: 'input your resume...'})
          .type(InputType.Normal)
          .fontSize($r('app.float.font_size_20'))
          .backgroundColor(Color.Transparent)
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .textAlign(TextAlign.Start)
          .border({ width: 0 })
          .borderRadius(0)
          .onChange((input: string) => {
            this.newResumeName = input
          })
          .width('80%')
          .height('100%')
          .maxLength(18)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: $r('app.float.font_size_16'), weight: CommonConstants.FONT_WEIGHT_400 })
          .showCounter(true,
            { thresholdPercentage: 80, highlightBorder: true })
        Text(this.resume.suffix)
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .width('20%')
          .height('100%')
      }
      .margin({ top: 30, bottom: -20 })
      .height('6%')
      .alignItems(VerticalAlign.Center)

      Column() {
        Divider()
          .width('80%')
          .height(20)
          .strokeWidth(0.5)
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_light'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)


      Blank()

      Button('保存')
        .width('80%')
        .margin({ bottom: 30 })
        .backgroundColor($r('app.color.common_blue'))
        .onClick(() => {
          // do rename operation
          this.resume.name = this.newResumeName
          this.resume.updateTime = getCurrentLocalTime();
          this.isFullShow = !this.isFullShow
        })
    }
    .backgroundColor($r('app.color.common_background'))
    .justifyContent(FlexAlign.Start)
    .padding({
      left: '4%',
      right: '4%',
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight)
    })
    .height('100%')
    .width('100%')
  }
}