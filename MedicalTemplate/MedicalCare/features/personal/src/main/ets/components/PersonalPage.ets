import { CommonNavDestination, LoadingDialogUtil, RouterUtil, ToastUtil } from 'common';
import { UserViewModel } from '../viewmodel/UserViewModel';
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';

@Builder
export function PersonalPageBuilder() {
  CommonNavDestination({ title: '编辑资料', enableScroll: true }) {
    PersonalPage()
  }
}

interface PersonalInfoBuilderParam {
  title: string
  content?: string
  image?: ResourceStr
  onClick?: () => void
  showArrow?: boolean
  isEdited?: boolean
  onInputChange?: EditableTextOnChangeCallback
  onImageError?: () => void
}

@ComponentV2
@Preview
export struct PersonalPage {
  @Local viewModel: UserViewModel = UserViewModel.getInstance()
  private defaultItemHeight = 56

  build() {
    Column({ space: 16 }) {
      List() {
        ListItem() {
          Stack() {
            this.personalInfoBuilder({
              title: '头像',
              image: this.viewModel.userModelEdited.userHeadImg || $r('app.media.ic_profile'),
              onImageError: () => {
                this.viewModel.userModelEdited.userHeadImg = $r('app.media.ic_profile')
              }
            })

            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                label: '',
                styleOption: {
                  styleConfig: new functionalButtonComponentManager.ButtonConfig()
                    .type(ButtonType.Normal)
                    .backgroundColor(Color.Transparent)
                    .width('100%')
                    .height(this.defaultItemHeight)
                    .stateEffect(false)
                },
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
                data) => {
                LoadingDialogUtil.close();
                if (err) {
                  if (err.code !== 1001600005) {
                    ToastUtil.showToast(`获取头像失败：${err.message}`)
                  }
                  return;
                }
                this.viewModel.userModelEdited.userHeadImg = data.avatarUri!;
              })
            }).onClick(() => {
              LoadingDialogUtil.openLoadingDialog();
            })
          }
        }

        ListItem() {
          Stack() {
            this.personalInfoBuilder({
              title: '手机号',
              content: this.viewModel.getUserPhone(true),
              isEdited: false,
              showArrow: false
            })
          }
        }

        ListItem() {
          this.personalInfoBuilder({
            title: '姓名',
            content: this.viewModel.getUserName(true),
            onInputChange: (text) => {
              this.viewModel.userModelEdited.name = text
            }
          })
        }
      }
      .divider({
        strokeWidth: 1,
        color: $r('sys.color.ohos_id_color_list_separator')
      })
      .layoutWeight(1)

      Button('保存')
        .width('90%')
        .height(40)
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .fontSize(16)
        .margin({ bottom: 66 })
        .onClick(() => {
          this.viewModel.saveUser()
          RouterUtil.back()
        })
    }
    .height('100%')
  }

  @Builder
  personalInfoBuilder(param: PersonalInfoBuilderParam) {
    Row() {
      Text(param.title)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .layoutWeight(1)

      if (param.image) {
        Image(param.image)
          .borderRadius(50)
          .width(44)
          .height(44)
          .onError(() => {
            param.onImageError?.()
          })
      } else {
        TextInput({ text: param.content ?? '' })
          .onClick(() => {
            param.onClick?.()
          })
          .enabled(param.isEdited === undefined ? true : param.isEdited)
          .padding(0)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .borderRadius(0)
          .textAlign(TextAlign.End)
          .onChange(param.onInputChange)
      }

      if (param.showArrow) {
        Image($r('app.media.icon_chevron_right_gray'))
          .width(12)
          .height(12)
          .margin({
            left: 2
          })
      }
    }
    .width('100%')
    .height(this.defaultItemHeight)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }
}
