import { camera, cameraPicker as picker } from '@kit.CameraKit';
import { fileIo } from '@kit.CoreFileKit';
import { PickerUtil } from 'module_base';
import { BasicUserInfo } from '../types';
import { RealNameAuthPageVM } from '../viewmodel/RealNameAuthPageVM';
import { common } from '@kit.AbilityKit';


@Builder
export function RealNameAuthPageBuilder() {
  RealNameAuthPage()
}

const ID_CARD_PIC_NAME_1 = '头像面';
const ID_CARD_PIC_NAME_2 = '国徽面';
const ID_CARD_PIC_NAME_3 = '手持 身份证 照片';

@Entry
@ComponentV2
export struct RealNameAuthPage {
  vm: RealNameAuthPageVM = RealNameAuthPageVM.instance
  @Local context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              this.buildTipInfo()
              this.buildIdCardPic1();
              this.buildIdCardPic2();
              this.buildIdCardPic3();
              Blank().height(4)
            }.width('92%').backgroundColor(Color.White).borderRadius(16)
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .layoutWeight(1)

        this.buildButtonRow()
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .backgroundColor('#f1f3f5')
    .title('实名认证')
    .onReady((context) => {
      this.vm.stack = context.pathStack
    })
  }

  @Builder
  buildIdCardPic1() {
    Row() {
      this.buildPicInfo(ID_CARD_PIC_NAME_1)

      Column() {
        Image(`${this.vm.idCardPic1}`.startsWith('app.media') ? $r(`${this.vm.idCardPic1}`) : `${this.vm.idCardPic1}`)
          .width(220)
          .height(136)
          .onError(() => {
            this.vm.idCardPic1 = 'app.media.id_card_pic_1'
          })
          .onClick(() => {
            this.vm.isShowIdCard1Sheet = !this.vm.isShowIdCard1Sheet;
            this.vm.currentIdx = 0;
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.vm.isShowIdCard1Sheet, this.chooseIdCardPicDialogBuilder(), {
        detents: [300],
        preferType: SheetType.BOTTOM,
      })
    }.width('92%').backgroundColor('#FFF1F3F5').margin({ bottom: 12 }).borderRadius(8)
  }

  @Builder
  buildIdCardPic2() {
    Row() {
      this.buildPicInfo(ID_CARD_PIC_NAME_2)

      Column() {
        Image(`${this.vm.idCardPic2}`.startsWith('app.media') ? $r(`${this.vm.idCardPic2}`) : `${this.vm.idCardPic2}`)
          .width(220)
          .height(136)
          .onError(() => {
            this.vm.idCardPic2 = 'app.media.id_card_pic_2'
          })
          .onClick(() => {
            this.vm.isShowIdCard2Sheet = !this.vm.isShowIdCard2Sheet;
            this.vm.currentIdx = 1
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.vm.isShowIdCard2Sheet, this.chooseIdCardPicDialogBuilder(), {
        detents: [300],
        preferType: SheetType.BOTTOM,
      })
    }.width('92%').backgroundColor('#FFF1F3F5').margin({ bottom: 12 }).borderRadius(8)
  }

  @Builder
  buildIdCardPic3() {
    Row() {
      this.buildPicInfo(ID_CARD_PIC_NAME_3)

      Column() {
        Image(`${this.vm.idCardPic3}`.startsWith('app.media') ? $r(`${this.vm.idCardPic3}`) : `${this.vm.idCardPic3}`)
          .width(220)
          .height(136)
          .onError(() => {
            this.vm.idCardPic3 = 'app.media.id_card_pic_3'
          })
          .onClick(() => {
            this.vm.isShowIdCard3Sheet = !this.vm.isShowIdCard3Sheet;
            this.vm.currentIdx = 2
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.vm.isShowIdCard3Sheet, this.chooseIdCardPicDialogBuilder(), {
        detents: [300],
        preferType: SheetType.BOTTOM,
      })
    }.width('92%').backgroundColor('#FFF1F3F5').margin({ bottom: 12 }).borderRadius(8)
  }

  @Builder
  buildPicInfo(msg: string) {
    Column() {
      ForEach(msg.split(' '), (item: string, idx: number) => {
        Text(item)
          .width(48)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
      }, (item: string, idx: number) => item)
    }
    .width(48)
    .height(136)
    .margin({ left: 12, top: 12, right: 12 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTipInfo() {
    Column() {
      Text('请拍照或上传身份证正反面')
        .fontSize(16)
        .fontColor('#E6000000')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 })
      Text('正面为头像面，反面为国徽面')
        .fontSize(12)
        .fontColor('#FFFE4F35')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
    }.width('92%').justifyContent(FlexAlign.Start).margin({ top: 12, bottom: 12 }).alignItems(HorizontalAlign.Start)
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
                  this.setResult(uris[0])
                  this.vm.isShowIdCard1Sheet = false
                  this.vm.isShowIdCard2Sheet = false
                  this.vm.isShowIdCard3Sheet = false
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
              let pathDir = this.context.filesDir;
              let fileName = `${new Date().getTime()}`
              let filePath = pathDir + `/${fileName}.tmp`
              fileIo.open(filePath, fileIo.OpenMode.CREATE);
              let pickerProfile: picker.PickerProfile = {
                cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT,
              };
              let result: picker.PickerResult =
                await picker.pick(this.context, [picker.PickerMediaType.PHOTO],
                  pickerProfile);
              if (result.resultCode === 0) {
                if (result.mediaType === picker.PickerMediaType.PHOTO) {
                  this.setResult(result.resultUri)
                  this.vm.isShowIdCard1Sheet = false
                  this.vm.isShowIdCard2Sheet = false
                  this.vm.isShowIdCard3Sheet = false
                }
              }
            },
          )
      }.margin({ top: 10, bottom: 10 })
    }
  }

  setResult(resultUri: string) {
    if (this.vm.currentIdx === 0) {
      this.vm.idCardPic1 = resultUri
    } else if (this.vm.currentIdx === 1) {
      this.vm.idCardPic2 = resultUri
    } else {
      this.vm.idCardPic3 = resultUri
    }
  }

  @Builder
  buildButtonRow() {
    Row() {
      Button('确认')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#FFFE4F35')
        .width('100%')
        .enabled(this.allPicChosen())
        .onClick(() => {
          // TODO 调用后端接口进行图片上传和实名认证
          let currentUser: BasicUserInfo | undefined = AppStorage.get('currentUserBasic');
          if (currentUser !== null && currentUser !== undefined) {
            currentUser.realNameAuthFlag = 1;
          }
          if (this.vm.userInfoModel) {
            this.vm.userInfoModel.realNameAuthFlag = 1;
            this.vm.update()
            this.vm.stack.pop()
          }
        })
    }.width('92%').margin({ top: 39 }).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }

  allPicChosen(): boolean {
    return this.vm.idCardPic1 !== 'app.media.id_card_pic_1' && this.vm.idCardPic2 !== 'app.media.id_card_pic_2' &&
      this.vm.idCardPic3 !== 'app.media.id_card_pic_3'
  }
}