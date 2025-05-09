interface Course {
  name: string;
  courseId: number;
  cover: ResourceStr;
}

let middleStorage = new LocalStorage();

@Entry(middleStorage)
@Component
export struct MiddleCard {
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  @LocalStorageProp('courseList') courseList: Course[] = [
    { name: '钢琴基础入门课程', courseId: 101, cover: $r('app.media.img_course_cover1') },
    { name: '吉他初学者进阶课程', courseId: 102, cover: $r('app.media.img_course_cover3') },
  ];

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_widget_home2')).height(20).width(20).margin({ right: $r('app.string.margin_xs') });
        Text('首页')
          .fontColor($r('app.color.font_color_level1'))
          .fontSize($r('app.string.font_size_14'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1);
        Image($r('app.media.ic_widget_right_arrow')).height(20).width(20)
          .onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                cardType: 'middle',
                message: 'home',
              },
            });
          });
      }
      .width($r('app.string.width_percent_full'));

      ForEach(this.courseList, (item: Course) => {
        Column() {
          Row() {
            Image($r('app.media.ic_widget_hot')).width(8).height(8).margin({ right: $r('app.string.margin_xs') });
            Text('推荐').fontSize($r('app.string.font_size_8')).fontColor($r('app.color.font_color_level1_invert'));
          }
          .padding({
            left: $r('app.string.padding_xs'),
            right: $r('app.string.padding_xs'),
            top: $r('app.string.padding_xxs'),
            bottom: $r('app.string.padding_xxs'),
          })
          .backgroundColor('#b3f40000')
          .borderRadius($r('app.string.border_radius_capsule'));

          Text(item.name)
            .fontSize($r('app.string.font_size_12'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1_invert'))
            .margin({ top: $r('app.string.margin_xs') })
            .width($r('app.string.width_percent_full'))
            .textAlign(TextAlign.Center);
        }
        .onClick(() => {
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: {
              cardType: 'middle',
              message: 'courseDetail',
              data: JSON.stringify({ courseId: item.courseId }),
            },
          });
        })
        .padding($r('app.string.padding_xs'))
        .alignItems(HorizontalAlign.Start)
        .backgroundImage(item.cover)
        .backgroundImageSize(ImageSize.Cover)
        .borderRadius($r('app.string.border_radius_8'))
        .height(45)
        .width($r('app.string.width_percent_full'));
      }, (item: Course) => JSON.stringify(item));

    }
    .padding($r('app.string.padding_s'))
    .width($r('app.string.width_percent_full'))
    .height($r('app.string.height_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween);
  }
}