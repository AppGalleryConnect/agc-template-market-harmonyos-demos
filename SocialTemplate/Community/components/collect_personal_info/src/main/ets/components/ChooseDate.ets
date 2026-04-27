import { AppStorageV2 } from '@kit.ArkUI';
import { intl } from '@kit.LocalizationKit';
import { ConfigInfo } from '../common/ConfigModel';
import { Constants } from '../common/Constant';
import { SheetColumnModifier } from '../common/CustomModifier';

@ComponentV2
export struct ChooseDate {
  // 初始化传入的日期
  @Once @Param date: Date | null = null;
  // 日期选择后的回调
  @Event onDateSelected: (date: Date) => void;
  // 关闭半模态
  @Event onClose: () => void = () => {
  };
  @Local configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!;
  @Local sheetColumn: SheetColumnModifier = new SheetColumnModifier();
  @Local tempDate: Date = new Date();
  private dateFormat = new intl.DateTimeFormat('zh-CN', { dateStyle: 'long' });
  private weekFormat = new intl.DateTimeFormat('zh-CN', { weekday: 'long' });

  aboutToAppear(): void {
    this.tempDate = this.date || new Date();
  }

  build() {
    Column({ space: Constants.PADDING_2XL }) {
      Text() {
        Span(this.dateStr)
        Span(' ')
        Span(this.weekStr)
      }
      .fontSize($r('sys.float.Title_S'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .padding(Constants.PADDING_L)

      DatePicker({
        selected: this.date,
        start: new Date('1900-02-01'),
        end: new Date(),
      })
        .selectedTextStyle({ color: this.configInfo.themeColor })
        .onDateChange((date: Date) => {
          this.tempDate = date;
        })

      Blank()

      Row({ space: Constants.SPACE_S }) {
        Button('取消')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .fontColor(this.configInfo.themeColor)
          .fontSize($r('sys.float.Body_L'))
          .layoutWeight(1)
          .onClick(() => {
            this.onClose();
          })
        Button('确定')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .fontColor(this.configInfo.themeColor)
          .fontSize($r('sys.float.Body_L'))
          .layoutWeight(1)
          .onClick(() => {
            this.onDateSelected(this.tempDate ?? new Date());
          })
      }
      .width(Constants.FULL_PERCENT)
    }
    .attributeModifier(this.sheetColumn)
  }

  @Computed
  get dateStr() {
    return this.dateFormat.format(this.tempDate);
  }

  @Computed
  get weekStr() {
    return this.weekFormat.format(this.tempDate);
  }
}