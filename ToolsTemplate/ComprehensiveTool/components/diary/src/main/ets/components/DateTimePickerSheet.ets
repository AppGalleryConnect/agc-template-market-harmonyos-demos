import { dateTimePickerBuilderParams, DateTimePickerResult } from '../commons/Interface'
import { BasePickerHeader } from './BasePickerHeader'

export interface DateTimePickerBuilderParams {
  date: string
  title: string
  contentBuilder: WrappedBuilder<[dateTimePickerBuilderParams]>
  confirm: (time: DateTimePickerResult) => void
  cancel: () => void
}

@Builder
export function dateTimePickerBuilder(params: DateTimePickerBuilderParams) {
  DateTimePickerSheet({
    date: params.date,
    title: params.title,
    contentBuilder: params.contentBuilder,
    confirm: params.confirm,
    cancel:params.cancel
  })
}

@ComponentV2
export struct DateTimePickerSheet {
  @Param date: string = '';
  @Param title: string = '';
  @Param contentBuilder: WrappedBuilder<[dateTimePickerBuilderParams]> | undefined = undefined
  @Event cancel: () => void = () => {}
  @Event confirm: (dateTime: DateTimePickerResult) => void = (dateTime: DateTimePickerResult) => {}
  @Local selectedDateTime: DateTimePickerResult = '';

  aboutToAppear(): void {
    this.selectedDateTime = this.date;
  }

  build() {
    Column() {
      // 标题
      BasePickerHeader({
        title: this.title,
        confirm: () => {
          this.confirm?.(this.selectedDateTime);
        },
        cancel: () => {
          this.cancel?.()
        }
      })

      // 内容
      this.contentBuilder?.builder({
        date: this.date,
        change: (value: DateTimePickerResult) => {
          this.selectedDateTime = value
        }
      })
    }
    .height('100%')
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}