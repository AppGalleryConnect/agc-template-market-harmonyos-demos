import { Constants } from '../common/Constants';
import { FormItemModel } from '../common/Types';

const storageWidget = new LocalStorage();

@Entry(storageWidget)
@Component
struct WidgetCard {
  @LocalStorageProp('data') @Watch('onDataUpdated') data: string = '[]';
  @State list: FormItemModel[] = [];
  readonly actionType: string = 'router';
  readonly abilityName: string = 'PhoneAbility';

  onDataUpdated() {
    try {
      this.list = JSON.parse(this.data) as FormItemModel[];
    } catch (e) {
      this.list = [];
    }
  }

  build() {
    Column() {
      this.titleBuilder()
      this.listBuilder()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
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
    Row({ space: Constants.SPACE_XS }) {
      Image($r('app.media.startIcon'))
        .width(Constants.APP_ICON_W)
        .aspectRatio(1)
      Text('新闻阅读')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .width(Constants.FULL_PERCENT)
    .padding({
      left: Constants.PADDING_M,
      right: Constants.PADDING_M,
      top: Constants.PADDING_M,
      bottom: Constants.PADDING_S,
    })
    .backgroundColor($r('app.color.widget_title_bg'))
  }

  @Builder
  listBuilder() {
    Column({ space: Constants.SPACE_M }) {
      ForEach(this.list, (v: FormItemModel, index: number) => {
        Row() {
          Text() {
            Span((index + 1).toString() + '.')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.warning'))
              .fontWeight(FontWeight.Medium)
            Span(' ').letterSpacing(Constants.SPACE_XXS)
            Span(v.title)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
          }
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width(Constants.FULL_PERCENT)
        .onClick(() => {
          // 跳转新闻详情页
          postCardAction(this, {
            action: this.actionType,
            abilityName: this.abilityName,
            params: {
              source: Constants.SOURCE,
              pageUrl: Constants.NEWS_DETAIL_PAGE,
              newsId: v.id,
              newsType: v.type,
            },
          });
        })
      }, (v: FormItemModel) => v.id)
    }
    .width(Constants.FULL_PERCENT)
    .padding({
      left: Constants.PADDING_M,
      right: Constants.PADDING_M,
      top: Constants.PADDING_M,
    })
  }
}