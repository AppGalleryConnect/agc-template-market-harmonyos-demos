import {
  Constants,
  NavigationTitleBuilder,
  BasicUserInfo,
  GetUserResponse,
  UserFullInfo,
  PhotoPickerPageParam
} from 'commons';
import { camera, cameraPicker as picker } from '@kit.CameraKit'
import { fileIo } from '@kit.CoreFileKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import UserService from '../service/UserService';

@Builder
export function RealNameAuthPageBuilder() {
  RealNameAuthPage()
}

const ID_CARD_PIC_NAME_1 = '头像面';
const ID_CARD_PIC_NAME_2 = '国徽面';
const ID_CARD_PIC_NAME_3 = '手持 身份证 照片';

@Component
export struct RealNameAuthPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State isShowIdCard1Sheet: boolean = false;
  @State isShowIdCard2Sheet: boolean = false;
  @State isShowIdCard3Sheet: boolean = false;
  @State idCardPic1: string = 'app.media.id_card_pic_1';
  @State idCardPic2: string = 'app.media.id_card_pic_2';
  @State idCardPic3: string = 'app.media.id_card_pic_3';
  @State currentIdx: number | null = null;
  private userFullInfo: UserFullInfo | null = null;

  build() {
    NavDestination() {
      Column() {
        this.buildTipInfo()
        this.buildIdCardPic1();
        this.buildIdCardPic2();
        this.buildIdCardPic3();
        Blank().height(4)
      }.width('92%').backgroundColor(Color.White).borderRadius(16)

      this.buildButtonRow()
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('实名认证'))
  }

  @Builder
  buildIdCardPic1() {
    Row() {
      this.buildPicInfo(ID_CARD_PIC_NAME_1)

      Column() {
        Image(`${this.idCardPic1}`.startsWith('app.media') ? $r(`${this.idCardPic1}`) : `${this.idCardPic1}`)
          .width(220)
          .height(136)
          .onClick(() => {
            this.isShowIdCard1Sheet = !this.isShowIdCard1Sheet;
            this.currentIdx = 0;
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.isShowIdCard1Sheet, this.chooseIdCardPicDialogBuilder(), {
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
        Image(`${this.idCardPic2}`.startsWith('app.media') ? $r(`${this.idCardPic2}`) : `${this.idCardPic2}`)
          .width(220)
          .height(136)
          .onClick(() => {
            this.isShowIdCard2Sheet = !this.isShowIdCard2Sheet;
            this.currentIdx = 1
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.isShowIdCard2Sheet, this.chooseIdCardPicDialogBuilder(), {
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
        Image(`${this.idCardPic3}`.startsWith('app.media') ? $r(`${this.idCardPic3}`) : `${this.idCardPic3}`)
          .width(220)
          .height(136)
          .onClick(() => {
            this.isShowIdCard3Sheet = !this.isShowIdCard3Sheet;
            this.currentIdx = 2
          })
      }
      .width(220)
      .height(136)
      .margin({ top: 12, bottom: 12, right: 12 })
      .bindSheet($$this.isShowIdCard3Sheet, this.chooseIdCardPicDialogBuilder(), {
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
          .fontColor($r('app.color.text_font_color_black'))
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
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 })
      Text('正面为头像面，反面为国徽面')
        .fontSize(12)
        .fontColor($r('app.color.button_background_color'))
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
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            this.pageStack.pushPathByName('CommonPhotoPicker',
              new PhotoPickerPageParam(1, photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE), (popInfo: PopInfo) => {
                let tmp: Array<string> = popInfo.result as Array<string>;
                if (tmp.length > 0) {
                  this.setResult(tmp[0])
                }
              })
          })
      }.margin({ top: 10, bottom: 10 })

      Row() {
        Button('拍照')
          .width('92%')
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_L'))
          .onClick(
            async () => {
              let pathDir = getContext().filesDir;
              let fileName = `${new Date().getTime()}`
              let filePath = pathDir + `/${fileName}.tmp`
              fileIo.open(filePath, fileIo.OpenMode.CREATE);
              let pickerProfile: picker.PickerProfile = {
                cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT,
              };
              let result: picker.PickerResult =
                await picker.pick(getContext(), [picker.PickerMediaType.PHOTO],
                  pickerProfile);
              if (result.resultCode === 0) {
                if (result.mediaType === picker.PickerMediaType.PHOTO) {
                  this.setResult(result.resultUri)
                }
              }
            }
          )
      }.margin({ top: 10, bottom: 10 })
    }
  }

  setResult(resultUri: string) {
    if (this.currentIdx === 0) {
      this.idCardPic1 = resultUri
    } else if (this.currentIdx === 1) {
      this.idCardPic2 = resultUri
    } else {
      this.idCardPic3 = resultUri
    }
  }

  @Builder
  buildButtonRow() {
    Row() {
      Button('确认')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.button_background_color'))
        .width('100%')
        .enabled(this.allPicChosen())
        .onClick(() => {
          // TODO 调用后端接口进行图片上传和实名认证
          let currentUser: BasicUserInfo | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
          if (currentUser != null && currentUser !== undefined) {
            currentUser.realNameAuthFlag = Constants.YES;
          }
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null) {
            this.userFullInfo.userInfo.realNameAuthFlag = Constants.YES;
            UserService.updateUser(this.userFullInfo);
            this.pageStack.pop(this.userFullInfo.userInfo, false)
          }
        })
    }.width('92%').margin({ top: 39 })
  }

  allPicChosen(): boolean {
    return this.idCardPic1 !== 'app.media.id_card_pic_1' && this.idCardPic2 !== 'app.media.id_card_pic_2' &&
      this.idCardPic3 !== 'app.media.id_card_pic_3'
  }

  aboutToAppear(): void {
    let currentUser: BasicUserInfo | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    UserService.getUserFullInfoByUnionId((currentUser != null && currentUser.hwUnionId != null) ?
    currentUser.hwUnionId : undefined).then((data: GetUserResponse | null) => {
      if (data != null && data.userFullInfo != null) {
        this.userFullInfo = data.userFullInfo;
      }
    })
  }
}