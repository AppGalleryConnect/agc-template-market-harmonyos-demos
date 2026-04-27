import { CommonConstants } from '../constants/CommonConstants'
import { GridRowColSetting } from '../constants/GridRowColSetting'
import { PopViewUtils } from '../utils/PopViewUtils'

export interface CommonSelectDialogParam {
  list: string[]
  submit: (index: number) => void
  cancel?: () => void
}

@Builder
export function commonSelectDialogBuilder(params: CommonSelectDialogParam) {
  CommonSelectDialogView({ params })
}

@ComponentV2
export struct CommonSelectDialogView {
  @Require @Param params: CommonSelectDialogParam;
  @Local selectIndex: number = -1;

  build() {
    Column() {
      Column({ space: CommonConstants.PADDING_S }) {
        Column() {
          ForEach(this.params.list, (item: string, index: number) => {
            Column() {
              Row() {
                Text(item).fontSize(16).fontColor($r('sys.color.font_primary'))
                Radio({
                  group: 'group',
                  value: item,
                })
                  .onChange((isChecked) => {
                    if (isChecked) {
                      this.selectIndex = index;
                    }
                  })
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(48)
              .justifyContent(FlexAlign.SpaceBetween)

              if (index !== this.params.list.length - 1) {
                Divider()
              }
            }
          }, (item: string) => item)
        }

        Row() {
          Button('取消')
            .width(CommonConstants.HALF_PERCENT)
            .height(40)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick(() => {
              this.params.cancel?.();
            })
          Button('提交')
            .width(CommonConstants.HALF_PERCENT)
            .height(40)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .enabled(this.selectIndex !== -1)
            .onClick(() => {
              this.params.submit(this.selectIndex);
            })
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
      .borderRadius(32)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding({
        left: CommonConstants.PADDING_XXL,
        right: CommonConstants.PADDING_XXL,
        top: CommonConstants.PADDING_XXL,
        bottom: CommonConstants.PADDING_L,
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_L,
      right: CommonConstants.PADDING_L,
    })
  }
}

/**
 * 通用选择弹窗
 */
export class CommonSelectDialog {
  /**
   * 打开弹窗
   * @param param
   */
  public static show(param: CommonSelectDialogParam) {
    PopViewUtils.showPopView<CommonSelectDialogParam>(wrapBuilder(commonSelectDialogBuilder), {}, param);
  }
}