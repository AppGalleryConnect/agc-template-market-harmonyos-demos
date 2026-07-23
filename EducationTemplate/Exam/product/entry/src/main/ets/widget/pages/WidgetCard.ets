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
      Column() {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.startIcon')).width(20).height(20).borderRadius(4)
              Text('备考模板')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 6 })
            }

            Image($r('app.media.ic_widget_home')).width(20).height(20).borderRadius(10).onClick(() => {
              postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: {
                  url: 'MainPage',
                },
              })
            })
          }.width(this.fullWidthPercent).justifyContent(FlexAlign.SpaceBetween)

          Column() {
            Row() {
              Image($r('app.media.icon_msg')).width(16).height(16)
                .margin({ top: 4, left: 4 });
              Text('热门活动')
                .fontColor($r('sys.color.font_primary'))
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .margin({ top: 9, left: 4 });
            }
            .width('100%')
            Text('端午佳节 更多活动惊喜等着你！')
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(8)
              .margin({top: 6, left: 20, right: 4})
          }
          .width(128)
          .height(38)
          .backgroundColor('rgba(75, 92, 196, 0.05)')
          .margin({ top: 8})
          .borderRadius(4)
          .onClick(() => {
            postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: {
                  url: 'MessageCenterPage',
                },
              })
            })
        }
        .alignItems(HorizontalAlign.Start)

        Row({ space: 22 }) {
          Column() {
            Image($r('app.media.ic_widget_recommend')).width(32).height(32)
            Text('精选课程')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 4 })
          }.onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                url: 'FeatureCourses',
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
                url: 'CollectionPage',
              },
            })
          })
        }
      }
      .width(this.fullWidthPercent)
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