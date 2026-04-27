import { LiveMsgModel } from '../models/LiveModel'
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { LengthUnit } from '@kit.ArkUI';
import { PickerUtil } from 'module_base'
import { fileIo } from '@kit.CoreFileKit';
import { camera, cameraPicker as picker } from '@kit.CameraKit';

@Preview
@ComponentV2
export struct BigCard {
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  context: common.UIAbilityContext =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  @Param getLocation: () => void = () => {
  }
  @Local isShow: boolean = false
  @Local changeName: string = ''
  @Local isShowPicture: boolean = false
  @Consumer('isLocated') isLocated: boolean = !!this.liveStreamer.location

  aboutToAppear(): void {
    this.getLocation()
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.liveStreamer.cover)
          .width(80)
          .height(80)
          .border({ radius: 16 })

        Text('更改封面')
          .fontColor('rgba(255, 255, 255, 1)')
          .fontWeight(400)
          .fontSize(12)
          .lineHeight(16)
          .textAlign(TextAlign.Center)
          .width(80)
          .height(24)
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      }
      .onClick(() => {
        this.isShowPicture = true
      })
      .bindSheet($$this.isShowPicture, this.chooseIdCardPicDialogBuilder(), {
        detents: [300],
        preferType: SheetType.BOTTOM,
      })

      Column() {
        Row() {
          Text(this.liveStreamer.title)
            .width(158)
            .padding({ top: 1.5, bottom: 1.5 })
            .fontColor('rgba(255, 255, 255, 1)')
            .fontWeight(700)
            .fontSize(16)
            .lineHeight(21)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        }

        Row() {
          SymbolGlyph($r('sys.symbol.exclamationmark_circle_fill'))
            .fontSize(16)
            .fontColor(['#99FFFFFF'])
          Text('直播间命名限制15字符以内')
            .fontColor('rgba(255, 255, 255, 0.6)')
            .fontWeight(400)
            .fontSize(12)
            .lineHeight(16)
            .margin({ left: 3 })
        }
        .margin({ top: 4 })

        Blank()
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.local'))
              .fontSize(16)
              .fontColor(['#E6FFFFFF'])
            Text(this.isLocated ? this.liveStreamer.location : '开启位置')
              .margin({ left: 4 })
              .fontColor('rgba(255, 255, 255, 1)')
              .fontWeight(400)
              .fontSize(12)
              .lineHeight(16)
          }
          .onClick(() => {
            this.getLocation()
          })
        }
      }
      .height(80)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Column(){
        SymbolGlyph($r('sys.symbol.square_and_pencil_fill'))
          .fontSize(24)
          .fontColor(['#E6FFFFFF'])
          .onClick(() => {
            this.isShow = true
          })
          .bindSheet($$this.isShow, this.setLiveName(), {
            preferType: SheetType.CENTER,
            detents: [252],
            title: { title: '直播间命名' }
          })
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(16)
          .fontColor(['#E6FFFFFF'])
          .onClick(() => {
            this.getLocation()
          })

      }
      .height(80)
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.SpaceBetween)
    }

    .backgroundColor('rgba(0, 0, 0, 0.6)')
    .width('100%')
    .height(104)
    .border({ radius: 20 })
    .padding({left:12,right:12})
  }

  @Builder
  chooseIdCardPicDialogBuilder(): CustomBuilder {
    Column() {
      Blank().height(60)
      Row() {
        Button('从相册选取')
          .width('92%')
          .backgroundColor('#FFFE4F35')
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            PickerUtil.selectPhoto({
              maxSelectNumber: 1,
            })
              .then((uris) => {
                if (uris.length > 0) {
                  this.liveStreamer.cover = uris[0]
                  this.isShowPicture = false
                }
              });
          })
      }.margin({ top: 10, bottom: 10 })

      Row() {
        Button('拍照')
          .width('92%')
          .backgroundColor('#FFFE4F35')
          .fontSize($r('sys.float.Body_L'))
          .onClick(
            async () => {
              let pathDir = (this.getUIContext().getHostContext() as common.UIAbilityContext).filesDir;
              let fileName = `${new Date().getTime()}`
              let filePath = pathDir + `/${fileName}.tmp`
              fileIo.open(filePath, fileIo.OpenMode.CREATE);
              let pickerProfile: picker.PickerProfile = {
                cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT,
              };
              let result: picker.PickerResult =
                await picker.pick(this.getUIContext().getHostContext(), [picker.PickerMediaType.PHOTO],
                  pickerProfile);
              if (result.resultCode === 0) {
                if (result.mediaType === picker.PickerMediaType.PHOTO) {
                  this.liveStreamer.cover = result.resultUri
                  this.isShowPicture = false
                }
              }
            },
          )
      }.margin({ top: 10, bottom: 10 })
    }
  }

  @Builder
  setLiveName() {
    Column() {
      TextArea({ text: this.liveStreamer.title })
        .caretColor('#EE5D1A')
        .selectedBackgroundColor('#EE5D1A')
        .width('90%')
        .height(72)
        .margin({ top: 8 })
        .borderRadius(16)
        .maxLength(15)
        .showCounter(true, { thresholdPercentage: 1 })
        .onChange((value: string) => {
          this.changeName = value
        })
      Blank()
      Button('确定')
        .width('90%')
        .height(40)
        .fontWeight(500)
        .backgroundColor('rgba(238, 93, 26, 1)')
        .borderRadius(20)
        .margin({ top: 24, bottom: 44 })
        .onClick(() => {
          this.liveStreamer.title = this.changeName
          this.isShow = false
        })
    }
    .height('100%')
  }
}