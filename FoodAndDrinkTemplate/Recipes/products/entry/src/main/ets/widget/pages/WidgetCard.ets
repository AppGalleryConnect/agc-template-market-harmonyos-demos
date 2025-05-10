@Entry
@Component
struct WidgetCard {
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Stack() {
      Image($r('app.media.ic_widget_bg')).width(107).height(92)
      Column() {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.startIcon')).width(20).height(20).borderRadius(4)
              Text('菜谱模板')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 6 })
            }

            Image($r('app.media.ic_widget_home')).width(20).height(20).borderRadius(10).onClick(() => {
              postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: {
                  url: 'HomePage',
                },
              })
            })
          }.width(this.fullWidthPercent).justifyContent(FlexAlign.SpaceBetween)

          Text('享受烹饪带来的乐趣！').fontSize(10).fontColor($r('sys.color.font_primary')).margin({ top: 9 })
        }.alignItems(HorizontalAlign.Start)

        Row({ space: 22 }) {
          Column() {
            Image($r('app.media.ic_widget_recommend')).width(32).height(32)
            Text('精选推荐')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
          }.onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                url: 'HomePage',
              },
            })
          })

          Column() {
            Image($r('app.media.ic_widget_collection')).width(32).height(32)
            Text('我的收藏')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
          }.onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                url: 'MyCollection',
              },
            })
          })
        }
      }.width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(12)

    }
    .alignContent(Alignment.BottomEnd)
    .linearGradient({
      direction: GradientDirection.RightBottom, // 渐变方向
      repeating: false, // 渐变颜色是否重复
      colors: [['#FFFAFA', 0.0], ['#FFAFAF', 1]], // 数组末尾元素占比小于1时满足重复着色效果
    })
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
      });
    })
  }
}