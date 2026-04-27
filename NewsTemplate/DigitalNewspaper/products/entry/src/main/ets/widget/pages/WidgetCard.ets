import { FormItemModel } from '../common/Types';
import { Constants } from '../common/Constants';

const storageWidget = new LocalStorage();

@Entry(storageWidget)
@Component
struct WidgetCard {
  @LocalStorageProp('data') @Watch('onDataUpdated') data: string = '[]';
  @State list: FormItemModel =
    new FormItemModel('article_digital_1', '人工智能助力教育公平：偏远地区学生迎来优质教育资源', 1751089800000);
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';

  onDataUpdated() {
    try {
      this.list = JSON.parse(this.data) as FormItemModel;
    } catch (e) {
      this.list =
        new FormItemModel('article_digital_1', '人工智能助力教育公平：偏远地区学生迎来优质教育资源', 1751089800000);
    }
  }

  formatDate() {
    const date = new Date(this.list.createTime)
    return `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate()
      .toString().padStart(2, '0')}`
  }

  build() {
    Column() {
      this.titleBuilder()
      this.contentBuilder()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .padding(Constants.PADDING_M)
    .backgroundImage($r('app.media.widget_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .onClick(() => {
      // 拉起应用
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
      });
    })
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('数字报')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
      Image($r('app.media.startIcon'))
        .width(Constants.APP_ICON_W)
        .aspectRatio(1)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constants.FULL_PERCENT)
  }

  @Builder
  contentBuilder() {
    Column({ space: Constants.SPACE_XXS }) {
      Text(this.formatDate())
        .fontSize($r('sys.float.Caption_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
      Text(this.list.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(Constants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      // 跳转新闻详情页
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          source: Constants.SOURCE,
          pageUrl: Constants.NEWS_DETAIL_PAGE,
          newsId: this.list.id,
          newsTitle: this.list.title,
        },
      });
    })
  }
}