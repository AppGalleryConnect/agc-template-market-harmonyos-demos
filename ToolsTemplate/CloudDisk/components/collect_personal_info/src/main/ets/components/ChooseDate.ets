import { AppStorageV2 } from '@kit.ArkUI';
import { intl } from '@kit.LocalizationKit';
import { ConfigInfo } from '../common/ConfigModel';
import { Constants } from '../common/Constant';
import { SheetColumnModifier } from '../common/CustomModifier';


/**
 * @usage: 用于日期选择场景。提供日期选择器，显示选中日期的格式化文本和星期，支持取消和确定操作。
 * 关键数据结构：date（初始日期Date对象或null）、onDateSelected（日期选择回调函数，参数为Date对象）、
 * onClose（关闭回调函数）、ConfigInfo（配置信息，包含themeColor主题色）。
 * 包含日期格式化逻辑：使用intl.DateTimeFormat格式化日期和星期。
 * @layout: 垂直布局。顶部为日期和星期文本（居中对齐，加粗），中间为DatePicker日期选择器，
 * 底部为按钮行（取消和确定按钮横向排列，均分宽度）。
 * @constraints: date初始日期可为null（默认当前日期），日期范围限制为1900-02-01到当前日期，
 * onDateSelected回调函数必须正确处理选中的日期，onClose回调函数必须正确关闭半模态
 * @isGen: true
 * @fileType: component
 * @zhName: 日期选择组件
 */
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