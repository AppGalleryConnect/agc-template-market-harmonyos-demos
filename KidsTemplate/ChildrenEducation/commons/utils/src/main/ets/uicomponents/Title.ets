@Builder
export function Title(text: string | Resource) {
  Row() {
    Text(text)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .margin({
        left: 8
      })
  }
  .height(56)
}