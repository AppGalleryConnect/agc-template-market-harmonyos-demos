import { AppStorageV2, NavDestinationModifier, window } from '@kit.ArkUI';
import { Header } from '../component/Header';
import { fileSelect } from '@agctemplate/feed_back';
import { AccountUtil, AppStorageKeys, BarVM, BreakPoint, BreakPointValue } from '@agctemplate/widgets';
import { UserInfoRow } from '../component/UserInfoRow';
import { camera } from '@kit.CameraKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { cameraPicker as picker } from '@kit.CameraKit'
import { UserInfo } from 'live_interaction'

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

@ComponentV2
export struct EditPersonalCenter {
  @Local textName: string = '';
  @Local textBio: string = '';
  @Local sex: string = '';
  @Param message: string = 'Hello World';
  @Param iconSheetHeight: number = 287;
  @Param nicknameSheetHeight: number = 744;
  @Local isShowIcon: boolean = false;
  @Local isShowNick: boolean = false;
  @Local isShowSex: boolean = false;
  @Local isShowBio: boolean = false;
  @Local keyboardHeight: number = 0;
  @Local logoUser: UserInfo = AccountUtil.getUserInfo();
  @Local imageUri: Array<string> = [];
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  private uiContext: UIContext = this.getUIContext();
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier()

  aboutToAppear(): void {
    this.sex = this.logoUser.sex
    this.textBio = this.logoUser.bio
    this.textName = this.logoUser.name
    try {
      window.getLastWindow(this.uiContext.getHostContext()).then(currentWindow => {
        // 监视软键盘的弹出和收起
        currentWindow.on('avoidAreaChange', async data => {
          if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
            return;
          }
          this.keyboardHeight = this.uiContext.px2vp(data.area.bottomRect.height);
        })
      })
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
  }

  @Builder
  myBuilder() {
    Column() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(20)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .justifyContent(FlexAlign.Center)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.isShowIcon = false
        })
      }.size({ width: '100%', height: 56 })
      .padding({ top: 8, bottom: 8 })
      .justifyContent(FlexAlign.End)

      Column() {
        Row() {
          Image($r('app.media.Mask'))
            .size({ width: 40, height: 40 })
            .margin({ right: 12 })
          Text('使用华为账号头像')
            .height('app.float.vp_21')
            .width('app.float.vp_128')
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_tertiary')])
        }
        .size({ width: '100%', height: 40 })
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.logoUser.avatar = $r('app.media.Mask')
          this.isShowIcon = false
          this.showToast('头像修改成功');
        })

        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
          .margin({ top: 13, bottom: 13 })
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.picture'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_primary')])
              .fontWeight(500)
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ right: 12 })

          Text('从图库选择')
            .height(21)
            .width(128)
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_tertiary')])
        }
        .width('100%')
        .height(40)
        .padding({ left: 12, right: 12 })
        .onClick(async () => {
          let arr = await fileSelect(this.uiContext,this.imageUri, 1)
          if (arr.length === 1) {
            this.logoUser.avatar = arr[arr.length-1]
            this.isShowIcon = false
            this.showToast('头像修改成功');
          }
        })

        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
          .margin({ top: 13, bottom: 13 })
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.camera'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_primary')])
              .fontWeight(500)
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ right: 12 })

          Text('拍照')
            .size({ width: 128, height: 21 })
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_tertiary')])
        }
        .size({ width: '100%', height: 40 })
        .padding({ left: 12, right: 12 })
        .onClick(async () => {
          try {
            let pickerProfile: picker.PickerProfile = {
              cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
            }
            let pickerResult: picker.PickerResult = await picker.pick(this.uiContext.getHostContext(),
              [picker.PickerMediaType.PHOTO, picker.PickerMediaType.VIDEO], pickerProfile)
            if (pickerResult.resultUri && pickerResult.resultUri.length > 0) {
              this.logoUser.avatar = pickerResult.resultUri; // 获取第一个选中的文件 URI
              this.isShowIcon = false
              this.showToast('头像修改成功')
            }
            console.log('the pick pickerResult is:' + JSON.stringify(pickerResult))
          } catch (error) {
            let err = error as BusinessError
            console.error(`the pick call failed. error code: ${err.code}`)
          }
        })
      }
      .borderRadius(16)
      .padding({ top: 16, left: 12, right: 12 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.background_primary'))
      .size({ width: '98%', height: 202 })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .height('100%')
    .width('100%')
    .padding({ top: 8, left: 16, right: 16 })
  }

  @Builder
  myBuilder2() {
    Column() {
      Column() {
        Row() {
          Text('设置昵称')
            .width(80)
            .height(27)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))

          Row() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.isShowNick = false
          })
        }
        .size({ width: '100%', height: 56 })
        .margin({ top: 8, bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        TextInput({ text: this.textName, placeholder: '请输入不超过12位的新昵称' },)
          .caretColor('#EE5D1A')
          .backgroundColor($r('sys.color.comp_background_primary'))
          .type(InputType.Normal)
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: { size: 18, color: $r('sys.color.icon_primary') }
          })
          .onChange((value: string) => {
            this.textName = value;
          })
      }

      if (!this.keyboardHeight) {
        Blank()
      }

      Button('确定')
        .borderRadius(20)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#EE5D1A')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width(328)
        .height(40)
        .margin({ top: this.keyboardHeight ? 208 : '98%' })
        .onClick(() => {
          if (this.textName.trim() !== '' && this.textName.length <= 12) {
            this.logoUser.name = this.textName
            this.showToast('昵称修改成功');
            this.isShowNick = false
          } else if (this.textName.trim() === '') {
            this.showToast('您还未填写');
          } else {
            this.showToast('昵称禁止超过12位');
          }
        })
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 8,
      left: 16,
      right: 16,
      bottom: 16
    })
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
  }

  @Builder
  myBuilder3() {
    Column() {
      Row() {
        Text('选择性别')
          .width(80)
          .height(27)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(20)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .justifyContent(FlexAlign.Center)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.sex = this.logoUser.sex
          this.isShowSex = false
        })
      }
      .size({ width: '100%', height: 56 })
      .margin({ top: 8, bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Radio({ value: 'male', group: 'gender' })
          .checked(this.logoUser.sex === '男')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.sex = '男';
            }
          })
        Text('男')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ bottom: 12 })

      Row() {
        Radio({ value: 'female', group: 'gender' })
          .checked(this.logoUser.sex === '女')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.sex = '女';
            }
          })
        Text('女')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ bottom: 12 })

      Button('确定')
        .borderRadius(20)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#EE5D1A')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width(328)
        .height(40)
        .onClick(() => {
          this.logoUser.sex = this.sex
          this.isShowSex = false
        })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .height('100%')
    .width('100%')
    .padding({ top: 8, left: 16, right: 16 })
  }

  @Builder
  myBuilder4() {
    Column() {
      Column() {
        Row() {
          Text('个性签名')
            .width(80)
            .height(27)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))

          Row() {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.isShowBio = false
          })
        }
        .size({ width: '100%', height: 56 })
        .margin({ top: 8, bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        Stack({ alignContent: Alignment.BottomEnd }) {
          TextArea({ text: this.textBio, placeholder: '简单介绍一下自己吧~' })
            .caretColor('#EE5D1A')
            .selectedBackgroundColor('#EE5D1A')
            .size({ width: '100%', height: 156 })
            .maxLength(70)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onChange((value: string) => {
              this.textBio = value;
            })

          Text(`${this.textBio.length}/70`)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .translate({ x: -12, y: -24 })
        }
        .size({ width: '100%', height: 156 })
      }

      Button('确定')
        .borderRadius(20)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#EE5D1A')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width(328)
        .height(40)
        .margin({ top: this.keyboardHeight ? 52 : 324 })
        .onClick(() => {
          if (this.textBio.trim() !== '') {
            this.logoUser.bio = this.textBio
            this.showToast('个性签名设置成功');
            this.isShowBio = false
          } else {
            this.logoUser.bio = '暂无简介'
            this.isShowBio = false
          }
        })
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .width('100%')
    .height('100%')
    .padding({ top: 8, left: 16, right: 16 })
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
    }
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: '个人信息' })
        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('头像').size({ width: 120, height: 21 })
                Blank()

                Image(this.logoUser.isLogin ?
                  this.logoUser.avatar !== '' ? this.logoUser.avatar : $r('app.media.path2x') :
                  $r('app.media.person'))
                  .size({ width: 40, height: 40 })
                  .borderRadius(40)

                Image($r('app.media.iconRight'))
                  .size({ width: 24, height: 24 })
              }
              .size({ width: '100%', height: 56 })
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.isShowIcon = true;
              })
              .bindSheet($$this.isShowIcon, this.myBuilder(), {
                detents: [287],
                preferType: SheetType.CENTER,
                showClose: false,
                maskColor: $r('sys.color.mask_fourth'),
              })

              this.line()

              UserInfoRow({
                leftTitle: '昵称',
                rightContent: this.logoUser.name,
                rightOnClick: () => {
                  this.isShowNick = !this.isShowNick
                }
              })
                .bindSheet($$this.isShowNick, this.myBuilder2(), {
                  preferType: SheetType.CENTER,
                  height: this.nicknameSheetHeight,
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  maskColor: $r('sys.color.mask_fourth'),
                })

              this.line()

              UserInfoRow({
                leftTitle: '性别',
                rightContent: this.logoUser.sex,
                rightOnClick: () => {
                  this.isShowSex = !this.isShowSex
                }
              })
                .bindSheet($$this.isShowSex, this.myBuilder3(), {
                  preferType: SheetType.CENTER,
                  height: this.iconSheetHeight,
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  maskColor: $r('sys.color.mask_fourth'),
                  onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
                    this.sex = this.logoUser.sex
                    dismissSheetAction.dismiss();
                  }
                })

              this.line()

              UserInfoRow({
                leftTitle: '个性签名',
                rightContent: this.logoUser.bio || '暂无简介',
                rightOnClick: () => {
                  this.isShowBio = !this.isShowBio
                }
              })
                .bindSheet($$this.isShowBio, this.myBuilder4(), {
                  preferType: SheetType.CENTER,
                  height: this.nicknameSheetHeight,
                  backgroundColor: $r('sys.color.background_secondary'),
                  showClose: false,
                  maskColor: $r('sys.color.mask_fourth'),
                })
            }
            .width('100%')
            .borderRadius(16)
            .margin({ top: 8 })
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_list_card'))

            Row() {
              Text('手机号').size({ width: 120, height: 21 })
              Blank()
              Text(this.logoUser.cellphone)
                .size({ width: 80, height: 19 })
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ right: 8 })
            }
            .size({ width: '100%', height: 56 })
            .margin({ top: 12 })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding(12)
            .borderRadius(16)
          }
          .padding({ left: 16, right: 16 })
          .width(this.breakPoint.value === BreakPointValue.LG ? '70%' : '100%')
        }
        .height('100%')
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    .attributeModifier(this.navDestinationModifier)
  }
}

