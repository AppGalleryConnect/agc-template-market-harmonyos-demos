@Builder
export function PlateType(text: string, color: string) {
  Text(text)
    .fontSize(10)
    .fontWeight(FontWeight.Regular)
    .fontColor(color)
    .textAlign(TextAlign.Center)
    .borderWidth(1)
    .borderColor(color)
    .borderRadius(5)
    .width(30)
    .height(15);
}