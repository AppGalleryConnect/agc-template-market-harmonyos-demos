import { BalanceChangeType } from '../commons/Enums';

@ComponentV2
export struct BalanceTypeSelection {
  @Param
  expenseLabel: string = '支出';
  @Param
  incomeLabel: string = '收入';
  @Param
  curType: BalanceChangeType = BalanceChangeType.EXPENSE;
  @Event
  changeType: (type: BalanceChangeType) => void;

  build() {
    Row() {
      Text(this.expenseLabel)
        .labelStyle(this.curType === BalanceChangeType.EXPENSE)
        .onClick(() => {
          this.changeType?.(BalanceChangeType.EXPENSE);
        });
      Text(this.incomeLabel)
        .labelStyle(this.curType === BalanceChangeType.INCOME)
        .onClick(() => {
          this.changeType?.(BalanceChangeType.INCOME);
        });
    }
    .width($r('app.string.width_percent_full'))
    .height(40)
    .padding(2)
    .borderRadius($r('app.string.border_radius_capsule'))
    .backgroundColor($r('app.color.system_color_background_grey_level2'));
  }
}

@Extend(Text)
function labelStyle(isChecked: boolean) {
  .fontColor($r('app.color.font_color_level1'))
  .fontSize($r('app.string.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .width($r('app.string.width_percent_half'))
  .height($r('app.string.height_percent_full'))
  .borderRadius($r('app.string.border_radius_capsule'))
  .backgroundColor(isChecked ? $r('app.color.system_color_background_white') : Color.Transparent);
}