import {
  Constants,
  FeedbackItem,
  FeedbackRecord,
  TCRouter,
  NavHeaderBar,
  BreakpointTypeEnum,
  BreakpointSystem,
  BreakpointStorage,
  FontModel
} from 'common';
import { image } from '@kit.ImageKit';
import { fileSelect } from '../comp/FileSelect';
import { AppStorageV2 } from '@kit.ArkUI';
import { Logger } from '@hw-agconnect/ui-base';
import { inputMethod } from '@kit.IMEKit';
import { fp2pxUtil } from 'base_common';

@ComponentV2
export struct FeedbackPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local pixelMap: Array<image.PixelMap> = []
  private maxPhotoNum: number = 4
  private maxIssueCharNum: number = 100
  private maxPhoneCharNum: number = 11
  text: ResourceStr | undefined;
  @Local issueCharNum: number = 0
  @Local phoneCharNum: number = 0
  @Local feedbackItem: FeedbackItem = new FeedbackItem('', [], '')
  @Local feedbackRecord: FeedbackRecord =
    AppStorageV2.connect(FeedbackRecord, 'feedbackRecord', () => new FeedbackRecord())!
  @Local stageImageUris: Array<string> = [];
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  private imageUris: Array<string> = [];
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '意见反馈',
          hasBackButton: true,
          hasBgColor: true,
          isMainPage: false,
        })
        Column() {
          Column({ space: 12 }) {
            Row() {
              Text('问题描述')
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .textAlign(TextAlign.Start)
              Text(`${this.issueCharNum}/${this.maxIssueCharNum}`)
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.End)
            }
            .width(Constants.FULL_SIZE)
            .height(20)
            .justifyContent(FlexAlign.SpaceBetween)

            TextArea({ placeholder: '请输入问题描述' })
              .width('100%')
              .height(122)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .maxLength(100)
              .onChange((value: string) => {
                this.feedbackItem.description = value
                this.issueCharNum = value.length
              })
              .onTouch((event:TouchEvent) => {
                event.stopPropagation()
              })

            Row() {
              Text('问题截图（选填）')
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .textAlign(TextAlign.Start)
              Text(`${this.feedbackItem.stageImageUris.length}/${this.maxPhotoNum}`)
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.End)
            }
            .width(Constants.FULL_SIZE)
            .height(20)
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Scroll() {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.stageImageUris, (item: string, index: number) => {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      Image(item ? item : $r('app.media.ic_search'))
                        .width(80)
                        .height(80)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(5)
                        .margin(5)
                      Image($r('app.media.ic_public_close'))
                        .width(20)
                        .height(20)
                        .margin({ right: 5, top: 5 })
                        .onClick(() => {
                          this.stageImageUris.splice(index, 1)
                        })
                    }
                  }, (item: string) => item + new Date().toString())
                  if (this.stageImageUris.length < 4) {
                    Row() {
                      Image($r('app.media.ic_public_plus')).size({ height: 22, width: 22 })
                    }
                    .height(80)
                    .width(80)
                    .backgroundColor($r('sys.color.background_secondary'))
                    .margin({ left: 12 })
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      this.selectImage()
                    })
                  }
                }
              }
              .edgeEffect(EdgeEffect.Spring)
            }
            .width('100%')
            .height(104)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text('联系方式（选填）')
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .textAlign(TextAlign.Start)
              Text(`${this.phoneCharNum}/${this.maxPhoneCharNum}`)
                .fontSize(this.fontModel.getFg(14))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .textAlign(TextAlign.End)
            }
            .width(Constants.FULL_SIZE)
            .height(20)
            .justifyContent(FlexAlign.SpaceBetween)

            TextInput({ placeholder: '请填写联系手机', text: this.text })
              .backgroundColor($r('sys.color.comp_background_primary'))
              .type(InputType.Number)
              .maxLength(this.maxPhoneCharNum)
              .borderRadius(12)
              .onChange((value: string) => {
                this.feedbackItem.phone = value
                this.phoneCharNum = value.length
              })
              .onTouch((event:TouchEvent) => {
                event.stopPropagation()
              })
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)

          Button('提交')
            .borderRadius(20)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#E84026')
            .fontSize(fp2pxUtil(16))
            .fontWeight(FontWeight.Medium)
            .width(304)
            .height(40)
            .margin({ bottom: 40 })
            .onClick(async () => {
              if (this.feedbackItem.description.length!==0) {
                this.feedbackRecord.feedbackList.push(this.feedbackItem)
                TCRouter.pop()
              } else {
                const promptAction = this.getUIContext().getPromptAction();
                promptAction.showToast({ message: '请输入问题描述' })
              }
            })
        }
        .width(Constants.FULL_SIZE)
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 16,
          right: 16,
          top: 16
        })
        .onTouch(() => {
          try {
            inputMethod.getController().stopInputSession();
          } catch (error) {
            console.error('FeedbackPage', ` inputMethod error = ${JSON.stringify(error)}`)
          }
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  titleView(title: string, maxCharNum: number, currentCharNum: number) {
    Row() {
      Text(title)
        .fontSize(this.fontModel.getFg(14))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
      Text(`${currentCharNum}/${maxCharNum}`)
        .fontSize(this.fontModel.getFg(14))
        .fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
        .textAlign(TextAlign.End)
    }
    .width(Constants.FULL_SIZE)
    .height(20)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(async () => {
      Logger.info(`${currentCharNum}${title}${this.issueCharNum}`)
    })
  }

  async selectImage() {
    const uris = await fileSelect(this.imageUris)
    this.stageImageUris = uris
    this.imageUris = uris
    this.feedbackItem.stageImageUris = this.stageImageUris
  }
}
