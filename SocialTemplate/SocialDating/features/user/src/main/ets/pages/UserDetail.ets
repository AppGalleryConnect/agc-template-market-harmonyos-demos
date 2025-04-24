import {
  CommonUtils,
  DateUtils,
  Constants,
  UiUtils,
  CommonRsp,
  NavigationTitleBuilder,
  PhotoPickerPageParam,
  GetUserResponse,
  UserFullInfo,
  MateSelectionCriteria,
  UserInfo,
  getPicResult
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { buildTextPickerDialogOption } from './UserSearchPage';
import { camera, cameraPicker as picker } from '@kit.CameraKit'
import { fileIo } from '@kit.CoreFileKit'
import { EditFieldPageParam } from '../model/EditFieldPageParam';
import UserService from '../service/UserService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Builder
export function MyDetailPageBuilder() {
  MyDetailPage()
}

@Component
export struct MyDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller: TextInputController = new TextInputController()
  @State userFullInfo: UserFullInfo = new UserFullInfo();
  @State selfIntroInput: string = '';
  @State inputValue: string = '';
  @State marriageStatus: string = Constants.TO_BE_SET;
  @State monthlyIncome: string = Constants.TO_BE_SET;
  @State edu: string = Constants.TO_BE_SET;
  @State gender: string = '';
  @State hasChildren: string = Constants.TO_BE_SET;
  @State expectationOfChildren: string = Constants.TO_BE_SET;
  @State smoking: string = Constants.TO_BE_SET;
  @State drinking: string = Constants.TO_BE_SET;
  @State hasBuyCar: string = Constants.TO_BE_SET;
  @State hasBuyHouse: string = Constants.TO_BE_SET;
  @State whenToMarry: string = Constants.TO_BE_SET;
  @State heightStr: string = '';
  @State weightStr: string = '';
  @State member: boolean = false;
  @State userInfo: UserInfo = new UserInfo();
  @State mateCriteria: MateSelectionCriteria = new MateSelectionCriteria();
  @State hasReadAgreement: boolean = false;
  @State isShowUploadProfilePicDialog: boolean = false;
  @State profileImage: string = 'app.media.head_image_default';
  @State isShowAlbumImageDialog: boolean = false;
  @State selectedBirth: Date = DateUtils.getYearsBefore(Constants.DATE_PICKER_DEFAULT);

  aboutToAppear(): void {
    UserService.getUserFullInfoByUnionId(AppStorage.get(Constants.UNION_ID)).then((data: GetUserResponse | null) => {
      if (data != null && data.userFullInfo != null) {
        this.userFullInfo = data.userFullInfo;
        if (this.userFullInfo.userInfo != null) {
          this.userInfo = this.userFullInfo.userInfo;
        }
        if (this.userFullInfo.mateSelectionCriteria != null) {
          this.mateCriteria = this.userFullInfo.mateSelectionCriteria;
        }
      } else {
        this.userFullInfo = new UserFullInfo();
      }
      this.initialiseEnumField();
      this.userInfo = this.userFullInfo?.userInfo ? this.userFullInfo.userInfo : new UserInfo();
      this.initialiseUserInfoTextField();
    });
  }

  private initialiseEnumField() {
    this.gender = valueHasBeenSet(this.userFullInfo?.userInfo?.gender) ?
    Constants.getGenderDisplayValue(this.userFullInfo?.userInfo?.gender) : Constants.TO_BE_SET;
    this.edu = valueHasBeenSet(this.userFullInfo?.userInfo?.education) ?
    Constants.getEducationDisplayValue(this.userFullInfo?.userInfo?.education) : Constants.TO_BE_SET;
    this.monthlyIncome = valueHasBeenSet(this.userFullInfo?.userInfo?.monthlyIncome) ?
    Constants.getMonthlyIncomeDisplayValue(this.userFullInfo?.userInfo?.monthlyIncome) : Constants.TO_BE_SET;
    this.marriageStatus = valueHasBeenSet(this.userFullInfo?.userInfo?.marriageStatus) ?
    Constants.getMarriageStatusDisplayValue(this.userFullInfo?.userInfo?.marriageStatus) : Constants.TO_BE_SET;
    this.hasChildren = valueHasBeenSet(this.userFullInfo?.userInfo?.hasChildren) ?
    Constants.getHasChildrenDisplayValue(this.userFullInfo?.userInfo?.hasChildren) : Constants.TO_BE_SET;
    this.expectationOfChildren = valueHasBeenSet(this.userFullInfo?.userInfo?.expectationOfChildren) ?
    Constants.getExpectationOfChildrenDisplayValue(this.userFullInfo?.userInfo?.expectationOfChildren) :
    Constants.TO_BE_SET;
    this.smoking = valueHasBeenSet(this.userFullInfo?.userInfo?.smoking) ?
    Constants.getSmokingDisplayValue(this.userFullInfo?.userInfo?.smoking) : Constants.TO_BE_SET;
    this.drinking = valueHasBeenSet(this.userFullInfo?.userInfo?.drinking) ?
    Constants.getDrinkingDisplayValue(this.userFullInfo?.userInfo?.drinking) : Constants.TO_BE_SET;
    this.hasBuyCar = valueHasBeenSet(this.userFullInfo?.userInfo?.hasBuyCar) ?
    Constants.getHasBuyCarDisplayValue(this.userFullInfo?.userInfo?.hasBuyCar) : Constants.TO_BE_SET;
    this.hasBuyHouse = valueHasBeenSet(this.userFullInfo?.userInfo?.house) ?
    Constants.getHouseDisplayValue(this.userFullInfo?.userInfo?.house) : Constants.TO_BE_SET;
    this.whenToMarry = valueHasBeenSet(this.userFullInfo?.userInfo?.whenToMarry) ?
    Constants.getWhenToMarryDisplayValue(this.userFullInfo?.userInfo?.whenToMarry) : Constants.TO_BE_SET;
  }

  private initialiseUserInfoTextField() {
    if (this.userInfo.currentResidence == null) {
      this.userInfo.currentResidence = Constants.TO_BE_SET;
    }
    if (this.userInfo.originFrom == null) {
      this.userInfo.originFrom = Constants.TO_BE_SET;
    }
    if (this.userInfo.ethnicGroup == null) {
      this.userInfo.ethnicGroup = Constants.TO_BE_SET;
    }
    if (this.userInfo.job == null) {
      this.userInfo.job = Constants.TO_BE_SET;
    }
    if (this.userInfo.weixinNo == null) {
      this.userInfo.weixinNo = Constants.TO_BE_SET;
    }
    if (this.userInfo.hobbies == null) {
      this.userInfo.hobbies = Constants.TO_BE_SET;
    }
    if (this.userInfo.selfIntroduction != null) {
      this.selfIntroInput = this.userInfo.selfIntroduction;
    }
    if (this.userInfo.height != null) {
      this.heightStr = this.userInfo.height.toString();
    }
    if (this.userInfo.weight != null) {
      this.weightStr = this.userInfo.weight.toString();
    }
    if (this.userInfo.profilePictureUrl != null && !CommonUtils.isBlank(this.userInfo.profilePictureUrl)) {
      this.profileImage = this.userInfo.profilePictureUrl;
    }
    if (this.userInfo.birth != null) {
      this.selectedBirth = new Date(this.userInfo.birth)
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildHeadImg()
          // this.buildImageArea()
          this.buildSelfIntro()
          this.buildUserDetailInfoArea()
          this.buildSaveButtonRow()
        }
      }.scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('基本信息'))
  }

  @Builder
  buildHeadImg() {
    Row() {
      Column() {
        Image(`${this.profileImage}`.startsWith('app.media') ? $r(`${this.profileImage}`) : `${this.profileImage}`)
          .width(40)
          .height(40)
          .clipShape(new Circle({ width: 40, height: 40 })).margin({ bottom: 8 })

        Text('修改头像')
          .fontSize($r('sys.float.Body_M'))
          .fontColor('#FF333333')
          .fontFamily(Constants.HARMONY_HEITI)
          .fontWeight(FontWeight.Regular)
      }.onClick(() => {
        this.isShowUploadProfilePicDialog = !this.isShowUploadProfilePicDialog;
      })
      .bindSheet($$this.isShowUploadProfilePicDialog, this.UploadProfilePicDialogBuilder(), {
        detents: [360],
        preferType: SheetType.BOTTOM,
        title: this.uploadProfilePicTitle()
      })
    }
    .width('92%')
    .height(100)
    .borderRadius(16)
    .margin({ top: 20, bottom: 16 })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
  }

  @Builder
  uploadProfilePicTitle(): CustomBuilder {
    Text('请上传本人近期正面照').fontSize($r('sys.float.Body_L')).textAlign(TextAlign.Center).width('100%')
  }

  @Builder
  buildSaveButtonRow() {
    Row() {
      Button('确认')
        .width('92%')
        .backgroundColor($r('app.color.button_background_color'))
        .margin({ top: 24 })
        .enabled(this.isMandatoryFieldsAllSet())
        .onClick(() => {
          this.fillUserFullInfo();
          this.checkParam();
          Logger.debug('userDetail=' + JSON.stringify(this.userFullInfo))
          UserService.updateUser(this.userFullInfo).then((data: CommonRsp | null) => {
            Logger.debug('update user rsp=' + JSON.stringify(data))
          })
          this.pageStack.pop(this.userFullInfo, false);
        })
    }
  }

  private fillUserFullInfo() {
    if (this.userFullInfo.userInfo != null) {
      this.userFullInfo.userInfo = this.userInfo;
      this.userFullInfo.userInfo.profilePictureUrl = this.profileImage;
      this.userFullInfo.userInfo.selfIntroduction = this.selfIntroInput;
      this.userFullInfo.userInfo.monthlyIncome =
        Constants.getIndex(this.monthlyIncome, Constants.MONTHLY_INCOME_DISPLAY_VALUES);
      this.userFullInfo.userInfo.marriageStatus =
        Constants.getIndex(this.marriageStatus, Constants.MARRIAGE_STATUS_DISPLAY_VALUES);
      this.userFullInfo.userInfo.education = Constants.getIndex(this.edu, Constants.EDUCATION_DISPLAY_VALUES);
      this.userFullInfo.userInfo.hasBuyCar = Constants.getIndex(this.hasBuyCar, Constants.HAS_CAR_VALUES);
      this.userFullInfo.userInfo.house = Constants.getIndex(this.hasBuyHouse, Constants.HOUSE_DISPLAY_VALUES);
      this.userFullInfo.userInfo.hasChildren =
        Constants.getIndex(this.hasChildren, Constants.HAS_CHILDREN_DISPLAY_VALUES);
      this.userFullInfo.userInfo.expectationOfChildren =
        Constants.getIndex(this.expectationOfChildren, Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES);
      this.userFullInfo.userInfo.smoking = Constants.getIndex(this.smoking, Constants.SMOKING_DISPLAY_VALUES);
      this.userFullInfo.userInfo.drinking =
        Constants.getIndex(this.drinking, Constants.DRINKING_DISPLAY_VALUES);
      this.userFullInfo.userInfo.whenToMarry =
        Constants.getIndex(this.whenToMarry, Constants.WHEN_TO_MARRY_DISPLAY_VALUES);
    }
  }

  isMandatoryFieldsAllSet(): boolean {
    return this.userInfo.nickName !== Constants.TO_BE_SET && this.gender !== Constants.TO_BE_SET &&
      this.marriageStatus !== Constants.TO_BE_SET && this.userInfo.birth != null
  }

  @Builder
  buildUserDetailInfoArea() {
    Column() {
      this.buildSecondLevelTitle('详细信息')
      Column() {
        this.buildNickName();
        Divider().strokeWidth('1px').width('92%')
        this.buildGenderRow();
        Divider().strokeWidth('1px').width('92%')
        this.buildBirthDateRow();
        Divider().strokeWidth('1px').width('92%')
        this.buildCurrentResidence();
        Divider().strokeWidth('1px').width('92%')
        this.buildMonthlyIncome();
        Divider().strokeWidth('1px').width('92%')
        this.buildEdu();
        Divider().strokeWidth('1px').width('92%')
        this.buildMarriageStatus();
        Divider().strokeWidth('1px').width('92%')
        this.buildOriginFrom();
        Divider().strokeWidth('1px').width('92%')

        this.buildEthnicGroup();
        Divider().strokeWidth('1px').width('92%')

        this.buildJobRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildHasChildrenRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildExpectationOfChildren();
        Divider().strokeWidth('1px').width('92%')

        this.buildHasHouseRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildHasBuyCarRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildIsSmokingRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildIsDrinkingRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildWhenToMarryRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildHeightRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildWeightRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildHobbiesRow();
        Divider().strokeWidth('1px').width('92%')

        this.buildWeixinNoRow();
      }
    }.borderRadius(16).width('92%').backgroundColor(Color.White)
  }

  @Builder
  buildHobbiesRow() {
    Row() {
      this.buildItemTitle('兴趣爱好')
      Text(`${this.userInfo?.hobbies}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 }).onClick(() => {
        this.pageStack.pushPathByName('EditFieldPage', new EditFieldPageParam('设置兴趣爱好', this.userInfo?.hobbies,
          Constants.HOBBIES_MAX_LENGTH),
          (popInfo: PopInfo) => {
            this.userInfo.hobbies = popInfo.result as string;
          })
      })
    }.width('92%').margin({ top: 10, bottom: 10 }).height('6%').alignItems(VerticalAlign.Center)
  }

  @Builder
  buildHeightRow() {
    Row() {
      this.buildItemTitle('身高')
      Text(`${this.heightStr}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPathByName('EditFieldPage',
        new EditFieldPageParam('设置身高（单位：厘米）', this.userInfo.height + '',
          Constants.NUMBER_MAX_LENGTH_THREE, InputType.Number, (input: string) => {
            let inputVal = parseInt(input);
            if (inputVal < Constants.MIN_HEIGHT || inputVal > Constants.MAX_HEIGHT) {
              return '输入身高无效, 当前仅支持[140,239]范围'
            }
            return '';
          }),
        (popInfo: PopInfo) => {
          this.heightStr = popInfo.result as string;
          this.userInfo.height = parseInt(this.heightStr)
        })
    })
  }

  @Builder
  buildWeightRow() {
    Row() {
      this.buildItemTitle('体重')
      Text(`${this.weightStr}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPathByName('EditFieldPage',
        new EditFieldPageParam('设置体重（单位：千克）', this.userInfo.weight + '',
          Constants.NUMBER_MAX_LENGTH_THREE, InputType.Number, (input: string) => {
            let inputVal = parseInt(input);
            if (inputVal < Constants.MIN_WEIGHT || inputVal > Constants.MAX_WEIGHT) {
              return '输入体重无效, 当前仅支持[30,140]范围'
            }
            return '';
          }),
        (popInfo: PopInfo) => {
          this.weightStr = popInfo.result as string;
          this.userInfo.weight = parseInt(this.weightStr)
        })
    })
  }

  @Builder
  buildWeixinNoRow() {
    Row() {
      this.buildItemTitle('微信号')
      Text(`${this.userInfo?.weixinNo}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPathByName('EditFieldPage', new EditFieldPageParam('设置微信号', this.userInfo?.weixinNo,
        Constants.WEIXIN_NO_MAX_LENGTH),
        (popInfo: PopInfo) => {
          this.userInfo.weixinNo = popInfo.result as string;
        })
    })
  }

  @Builder
  buildWhenToMarryRow() {
    Row() {
      this.buildItemTitle(Constants.WHEN_TO_MARRY_PREFIX)

      Text(`${this.whenToMarry}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.WHEN_TO_MARRY_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.whenToMarry = pickResult.value as string
        }
      ))
    })

  }

  @Builder
  buildIsDrinkingRow() {
    Row() {
      this.buildItemTitle(Constants.DRINKING_PREFIX)

      Text(`${this.drinking}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.DRINKING_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.drinking = pickResult.value as string
        }
      ))
    })
  }

  @Builder
  buildIsSmokingRow() {
    Row() {
      this.buildItemTitle(Constants.SMOKING_PREFIX)

      Text(`${this.smoking}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.SMOKING_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.smoking = pickResult.value as string
        }
      ))
    })
  }

  @Builder
  buildExpectationOfChildren() {
    Row() {
      this.buildItemTitle(Constants.EXPECTATION_OF_CHILDREN)

      Text(`${this.expectationOfChildren}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.expectationOfChildren = pickResult.value as string
        }
      ))
    });
  }

  @Builder
  buildNickName() {
    Row() {
      this.buildItemTitle('昵称', true)
      Text(`${this.userInfo?.nickName}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPathByName('EditFieldPage',
        new EditFieldPageParam('修改昵称', this.userInfo.nickName, Constants.NICK_NAME_MAX_LENGTH),
        (popInfo: PopInfo) => {
          this.userInfo.nickName = popInfo.result as string;
        })
    })
  }

  @Builder
  buildSelfIntro() {
    Column() {
      this.buildSecondLevelTitle('内心独白')
      Row() {
        TextArea({ text: this.selfIntroInput, placeholder: this.getSelfIntro(), controller: this.controller })
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: 14, weight: FontWeight.Regular })
          .caretColor($r('sys.color.font_emphasize'))
          .height('auto')
          .borderRadius(8)
          .fontSize(14)
          .fontColor($r('app.color.text_font_color_black'))
          .wordBreak(WordBreak.BREAK_ALL)
          .showCounter(true)
          .maxLength(100)
          .backgroundColor('#0D000000')
          .onChange((value: string) => {
            this.selfIntroInput = value;
          })
      }.width('92%').margin({ bottom: 12 })
    }.borderRadius(16).width('92%').backgroundColor(Color.White).margin({ bottom: 12 })
  }

  @Builder
  EditIconBuilder(resource: Resource): CustomBuilder {
    Image(resource).width(16).height(20)
  }

  @Builder
  ShowAlbumImageBuilder(img: string): CustomBuilder {
    Image($r(img)).width('90%')
  }

  @Builder
  UploadProfilePicDialogBuilder(): CustomBuilder {
    Column() {
      Row() {
        Column() {
          Image($r('app.media.head_image_1_r'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .margin({ left: '6vp', top: '6vp', })
            .borderRadius(8)
            .overlay(this.EditIconBuilder($r('app.media.right')), { align: Alignment.BottomEnd })
          Text('五官清晰').fontSize($r('sys.float.Body_M'))
        }

        Column() {
          Image($r('app.media.invalid_head_image1'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .margin({ left: '6vp', top: '6vp', })
            .borderRadius(8)
            .overlay(this.EditIconBuilder($r('app.media.cross')), { align: Alignment.BottomEnd })
          Text('面部遮挡').fontSize($r('sys.float.Body_M')).fontColor(Color.Gray)
        }

        Column() {
          Image($r('app.media.invalid_head_image2'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .margin({ left: '6vp', top: '6vp', })
            .borderRadius(8)
            .overlay(this.EditIconBuilder($r('app.media.cross')), { align: Alignment.BottomEnd })
          Text('看不到脸').fontSize($r('sys.float.Body_M')).fontColor(Color.Gray)
        }

        Column() {
          Image($r('app.media.invalid_head_image3'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .margin({ left: '6vp', top: '6vp', })
            .borderRadius(8)
            .overlay(this.EditIconBuilder($r('app.media.cross')), { align: Alignment.BottomEnd })
          Text('非单人照').fontSize($r('sys.float.Body_M')).fontColor(Color.Gray)
        }
      }.margin({ top: 10 })

      Blank().height(30)

      Row() {
        Button('从相册选取')
          .width('60%')
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_M'))
          .onClick(
            () => {
              this.isShowUploadProfilePicDialog = !this.isShowUploadProfilePicDialog;
              this.pageStack.pushPathByName('CommonPhotoPicker',
                new PhotoPickerPageParam(1, photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE), (popInfo: PopInfo) => {
                  let tmp: Array<string> = popInfo.result as Array<string>;
                  Logger.debug('---------------  on pop selectUris=' + JSON.stringify(tmp))
                  if (tmp.length > 0) {
                    this.profileImage = tmp[0];
                    //TODO upload图像到后端获取到url
                  }
                })
            }
          )
      }.margin({ top: 10, bottom: 10 })

      Row() {
        Button('拍照')
          .width('60%')
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_M'))
          .onClick(
            async () => {
              this.isShowUploadProfilePicDialog = !this.isShowUploadProfilePicDialog;
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
                  //TODO 上传头像文件到后端获取到profileUrl
                  this.profileImage = result.resultUri;
                }
              }
            }
          )
      }.margin({ top: 10, bottom: 10 })
    }
  }

  @Builder
  buildSecondLevelTitle(name: string) {
    Row() {
      Text(name)
        .fontSize(14)
        .fontColor($r('app.color.text_font_color_black'))
        .textAlign(TextAlign.Start)
        .fontFamily(Constants.HARMONY_HEITI)
        .margin({ left: 12, top: 12, bottom: 12 })
        .width('95%')
    }
  }

  checkParam() {
    if (this.userInfo?.nickName === Constants.TO_BE_SET) {
      this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置昵称'))
    }
    if (this.gender === Constants.TO_BE_SET) {
      this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置性别'))
    }
    if (this.marriageStatus === Constants.TO_BE_SET) {
      this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置婚姻状态'))
    }
    if (this.userInfo.birth == null) {
      this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置出生日期'))
    }
  }

  @Builder
  buildBirthDateRow() {
    Row() {
      this.buildItemTitle('出生日期', true)

      Text(`${this.userInfo.birth}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10, right: 16 })

    }.width('92%').margin({ top: 10, bottom: 10 }).height('6%').onClick(() => {
      DatePickerDialog.show({
        start: DateUtils.getYearsBefore(Constants.MAX_AGE),
        end: DateUtils.getYearsBefore(Constants.ADULT_AGE),
        selected: this.selectedBirth,
        disappearTextStyle: { color: Color.Gray, font: { size: '16fp', weight: FontWeight.Bold } },
        textStyle: { color: '#ff182431', font: { size: '18fp', weight: FontWeight.Normal } },
        selectedTextStyle: {
          color: $r('app.color.button_background_color'), font: {
            size: '20',
            weight: FontWeight.Regular,
            family: 'HarmonyOS Sans',
            style: FontStyle.Normal
          }
        },
        acceptButtonStyle: { fontColor: $r('app.color.button_background_color') },
        cancelButtonStyle: { fontColor: $r('app.color.button_background_color') },
        onDateAccept: (value: Date) => {
          this.selectedBirth = value;
          this.userInfo.birth = DateUtils.formatDateStr(value);
          Logger.debug('--------------onDateAccept ' + DateUtils.formatDateStr(value))
        }
      })
    })
  }

  @Builder
  buildGenderRow() {
    Row() {
      this.buildItemTitle('性别', true)
      Text(`${this.gender}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)
      Blank().width('5%')
    }.width('92%').margin({ top: 10, bottom: 10 }).height('6%')
  }

  @Builder
  buildOriginFrom() {
    Row() {
      this.buildItemTitle('籍贯地')

      Text(`${this.userInfo.originFrom}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }.width('92%').margin({ top: 10, bottom: 10 }).height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.CITY_PICKER,
        (result: TextPickerResult) => {
          Logger.debug('buildOriginFrom enter onAccept')
          let newVal = getPicResult(result)
          this.userInfo.originFrom = newVal;
        }))
    })
  }

  @Builder
  buildCurrentResidence() {
    Row() {
      this.buildItemTitle('现居地')

      Text(`${this.userInfo.currentResidence}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }.width('92%').margin({ top: 10, bottom: 10 }).height('6%').onClick(() => {
      try {
        TextPickerDialog.show(buildTextPickerDialogOption(
          Constants.CITY_PICKER,
          (result: TextPickerResult) => {
            let newResidence = getPicResult(result);
            this.userInfo.currentResidence = newResidence;
          }
        ))
      } catch (e) {
        Logger.error('set currentResidence exception occurred' + JSON.stringify(e))
      }
    })
  }

  @Builder
  buildMonthlyIncome() {
    Row() {
      this.buildItemTitle('月收入')

      Text(`${this.monthlyIncome}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.MONTHLY_INCOME_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.monthlyIncome = pickResult.value as string
        }
      ))
    });
  }

  @Builder
  buildMarriageStatus() {
    Row() {
      this.buildItemTitle('婚姻状况', true)

      Text(`${this.marriageStatus}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })

    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.MARRIAGE_STATUS_DISPLAY_VALUES,
        (pickRes: TextPickerResult) => {
          let newValue = pickRes.value as string
          this.marriageStatus = newValue;
        }
      ))
    });
  }

  @Builder
  buildItemTitle(name: string, isRequired?: boolean) {
    if (isRequired) {
      Image($r('app.media.ic_red_dot')).width(4).height(4)
    }
    Text(name)
      .fontSize($r('sys.float.Body_M'))
      .textAlign(TextAlign.Start)
      .fontWeight(FontWeight.Regular)
      .fontFamily(Constants.HARMONY_HEITI)
      .fontColor($r('app.color.user_detail_item_name'))
      .margin({ left: isRequired ? 4 : 12, top: 5, bottom: 5 })
      .width('28%')
  }

  @Builder
  buildEdu() {
    Row() {
      this.buildItemTitle('学历')
      Text(`${this.edu}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.EDUCATION_DISPLAY_VALUES,
        (picResult: TextPickerResult) => {
          this.edu = picResult.value as string;
        }
      ))
    });
  }

  @Builder
  buildHasBuyCarRow() {
    Row() {
      this.buildItemTitle(Constants.CAR_PREFIX)
      Text(`${this.hasBuyCar}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.HAS_CAR_VALUES,
        (pickResult: TextPickerResult) => {
          this.hasBuyCar = pickResult.value as string
        }
      ))
    });
  }

  @Builder
  buildHasHouseRow() {
    Row() {
      this.buildItemTitle(Constants.HOUSE_PREFIX)
      Text(`${this.hasBuyHouse}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.HOUSE_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.hasBuyHouse = pickResult.value as string
        }))
    });
  }

  @Builder
  buildHasChildrenRow() {
    Row() {
      this.buildItemTitle(Constants.HAS_CHILDREN_PREFIX)
      Text(`${this.hasChildren}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.HAS_CHILDREN_DISPLAY_VALUES,
        (pickResult: TextPickerResult) => {
          this.hasChildren = pickResult.value as string
        }))
    });
  }

  @Builder
  buildJobRow() {
    Row() {
      this.buildItemTitle(Constants.WORK_PREFIX)

      Text(`${this.userInfo.job}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.WORK_DISPLAY_VALUES,
        (result: TextPickerResult) => {
          if (typeof result.value === 'string') {
            this.userInfo.job = result.value;
          }
        }
      ))
    })
  }

  @Builder
  buildEthnicGroup() {
    Row() {
      this.buildItemTitle(Constants.ETHNIC_GROUP_PREFIX)
      Text(`${this.userInfo.ethnicGroup}`)
        .fontSize($r('sys.float.Body_M'))
        .width('60%')
        .fontColor($r('app.color.text_font_color_black'))
        .fontWeight(FontWeight.Regular)
        .fontFamily(Constants.HARMONY_HEITI)
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }
    .width('92%')
    .margin({ top: 10, bottom: 10 })
    .height('6%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.ETHNIC_GROUPS,
        (result: TextPickerResult) => {
          if (typeof result.value === 'string') {
            this.userInfo.ethnicGroup = result.value
          }
        }))
    })
  }

  getSelfIntro(): string {
    if (this.userFullInfo == null || this.userFullInfo.userInfo == null ||
      this.userFullInfo.userInfo.selfIntroduction == null) {
      return Constants.DEFAULT_SELF_INTRO;
    }
    return this.userFullInfo.userInfo.selfIntroduction;
  }
}


export function valueHasBeenSet(val: number | null | undefined): boolean {
  if (val == null || val === undefined) {
    return false;
  }
  return true;
}