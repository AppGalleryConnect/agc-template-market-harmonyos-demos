import { CommonNavDestination, ConfirmDialogUtil, RadioSheetBuilder, ResourceUtil } from 'common';
import { PatientViewModel } from '../viewmodel/PatientViewModel';

@Builder
export function PatientDetailPageBuilder() {
  CommonNavDestination({ title: '个人信息' }) {
    PatientDetailPage()
  }
}

interface ListItemParam {
  index: number,
  title: string,
  isInput: boolean, // 是否为输入框，true显示输入框，false点击后展开选择框
  placeholder: string, // 输入框和选择按钮的placeholder
  radioButtonData?: string[], // 选择框中的数据
  fillData?: string, // 展示的数据
  showDatePicker?: boolean,
  listener?: (data: string) => void // 输入框输入或者选择框中选中的数据的监听器
}

@ComponentV2
export struct PatientDetailPage {
  @Local isShowSheet: boolean = false
  @Local currentListItem: ListItemParam | null = null
  private patientViewModel: PatientViewModel = PatientViewModel.getInstance()

  build() {
    List() {
      ListItem() {
        this.ListItemBuilder({
          index: 0,
          title: '姓名',
          isInput: true,
          placeholder: '请输入',
          fillData: this.patientViewModel.patientDetailInfo.patientName,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.patientName = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 1,
          title: '性别',
          isInput: false,
          placeholder: '请选择',
          radioButtonData: ResourceUtil.readStringArray($r('app.strarray.sex')),
          fillData: this.patientViewModel.patientDetailInfo.sex,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.sex = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 2,
          title: '手机号',
          isInput: true,
          placeholder: '请输入',
          fillData: this.patientViewModel.patientDetailInfo.phone,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.phone = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 3,
          title: '证件类型',
          isInput: false,
          placeholder: '请选择',
          radioButtonData: ResourceUtil.readStringArray($r('app.strarray.id_card_type')),
          fillData: this.patientViewModel.patientDetailInfo.idCardType,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.idCardType = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 4,
          title: '证件号',
          isInput: true,
          placeholder: '请输入',
          fillData: this.patientViewModel.patientDetailInfo.idCard,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.idCard = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 5,
          title: '出生日期',
          isInput: false,
          placeholder: '请选择',
          fillData: this.patientViewModel.patientDetailInfo.birthday,
          showDatePicker: true,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.birthday = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 6,
          title: '常驻国家/地区',
          isInput: false,
          placeholder: '请选择',
          radioButtonData: ResourceUtil.readStringArray($r('app.strarray.country')),
          fillData: this.patientViewModel.patientDetailInfo.country,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.country = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 7,
          title: '常驻所在地',
          isInput: false,
          placeholder: '请选择',
          radioButtonData: ResourceUtil.readStringArray($r('app.strarray.city')),
          fillData: this.patientViewModel.patientDetailInfo.city,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.city = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 8,
          title: '详细地址',
          isInput: true,
          placeholder: '请输入',
          fillData: this.patientViewModel.patientDetailInfo.address,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.address = data
          }
        })
      }

      ListItem() {
        this.ListItemBuilder({
          index: 9,
          title: '医保类型',
          isInput: false,
          placeholder: '请选择',
          radioButtonData: ResourceUtil.readStringArray($r('app.strarray.insurance_type')),
          fillData: this.patientViewModel.patientDetailInfo.insuranceType,
          listener: (data) => {
            this.patientViewModel.patientDetailInfo.insuranceType = data
          }
        })
      }

      ListItem() {
        Column() {
          if (this.patientViewModel.isAddMode) {
            Button('添加')
              .width('100%')
              .height(40)
              .onClick(() => {
                this.patientViewModel.bindPatient()
              })
          } else {
            Button('保存')
              .width('100%')
              .height(40)
              .onClick(() => {
                this.patientViewModel.bindPatient()
              })

            Button('解绑')
              .width('100%')
              .height(40)
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .margin({
                top: 8
              })
              .onClick(() => {
                ConfirmDialogUtil.showConfirmDialog(
                  {
                    title: '确认解绑',
                    onConfirm: () => {
                      this.patientViewModel.unbindPatient()
                    }
                  }
                )
              })
          }
        }
        .margin({
          top: 15
        })

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator')
    })
    .padding({
      left: 20,
      right: 20
    })
    .bindSheet(this.isShowSheet, RadioSheetBuilder({
      title: this.currentListItem?.title ?? '',
      dataArray: this.currentListItem?.radioButtonData ?? [],
      checkedItem: this.currentListItem?.fillData ?? '',
      dataChangeListener: (_index, data) => {
        this.currentListItem?.listener?.(data)
        this.isShowSheet = false
      },
    }),
      {
        detents: [SheetSize.MEDIUM, 740],
        blurStyle: BlurStyle.Thick,
        showClose: true,
        onWillDisappear: () => {
          this.isShowSheet = false
        }
      }
    )
  }

  @Builder
  ListItemBuilder(param: ListItemParam) {
    Row() {
      Text(param.title)
        .fontSize(16)
        .fontWeight(500)

      Blank()

      if (param.isInput) {
        TextArea({ placeholder: param.placeholder, text: param.fillData ?? null })
          .borderRadius(0)
          .fontSize(16)
          .textAlign(TextAlign.End)
          .width(180)
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .padding({
            left: 3,
            right: 3,
            top: 0,
            bottom: 0
          })// .enableKeyboardOnFocus(false)
          .onFocus(() => {
            this.currentListItem = param
          })
          .onChange((data) => {
            this.currentListItem?.listener?.(data)
          })
      } else {
        Text(param.fillData?.length !== 0 ? param.fillData : param.placeholder)
          .fontSize(16)
          .fontColor(param.fillData ? $r('sys.color.ohos_id_color_text_primary') :
          $r('sys.color.ohos_id_color_text_hint_contrary'))
          .textAlign(TextAlign.End)
          .width(130)
        Image($r('app.media.icon_chevron_right_gray'))
          .width(15)
          .height(15)
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .margin({
            left: 6
          })
      }
    }
    .width('100%')
    .padding({
      top: 23,
      bottom: 13
    })
    .onClick(() => {
      this.currentListItem = param
      if (param.showDatePicker) {
        this.showDatePicker(value => {
          this.currentListItem?.listener?.(`${value.getFullYear()}-${value.getMonth() + 1}-${value.getDate()}`)
        })
      } else if (!param.isInput) {
        this.isShowSheet = true
      }
    })
  }

  showDatePicker(onDateAccept: (value: Date) => void) {
    this.getUIContext().showDatePickerDialog({
      start: new Date('1900-1-1'),
      end: new Date('2030-12-31'),
      selected: new Date(Date.now()),
      onDateAccept: (value: Date) => {
        onDateAccept(value)
      },
    })
  }
}

