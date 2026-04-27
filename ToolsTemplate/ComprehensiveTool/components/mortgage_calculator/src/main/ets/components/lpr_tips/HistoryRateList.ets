import { LoanPrimeRate } from '../../types/Index';

@Extend(Text)
function gridItemText(value: FontWeight = FontWeight.Normal) {
  .fontWeight(value)
  .fontSize(12);
}

@Extend(GridItem)
function gridItemStyle(location = 'cell') {
  .padding({ top: 8, bottom: 8 })
  .backgroundColor(location === 'top' ? '#f7f7f7' : 'fff');
}

const labels = ['发布时间', '一年期', '五年期以上'];

@Builder
export function HistoryBuilder(data: Array<LoanPrimeRate>) {
  Column() {
    Row() {
      Text('贷款市场报价利率（LPR）').fontSize(16);
    }.margin({ bottom: 12 });

    Grid() {
      ForEach(labels, (label: string) => {
        GridItem() {
          Text(label).gridItemText(FontWeight.Bold);
        }.gridItemStyle('top');
      }, (label: string) => label);
      ForEach(data, (value: LoanPrimeRate) => {
        GridItem() {
          Text(value.date).gridItemText();
        }.gridItemStyle();

        GridItem() {
          Text(value.one + '%').gridItemText();
        }.gridItemStyle();

        GridItem() {
          Text(value.five + '%').gridItemText();
        }.gridItemStyle();
      }, (value: LoanPrimeRate) => value.date);
    }.columnsTemplate('1fr 1fr 1fr');
  }
  .width('80%')
  .backgroundColor('#fff')
  .padding(20)
  .height(400)
  .borderRadius(8);
}