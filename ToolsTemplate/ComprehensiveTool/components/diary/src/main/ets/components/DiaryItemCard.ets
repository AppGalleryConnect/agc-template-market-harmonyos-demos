import { Diary } from '../models/Diary';
import { BaseDiaryMeta } from './BaseDiaryMeta';
import { TextSelectView } from './TextSelectView';

@ComponentV2
export struct DiaryItemCard {
  @Param @Require item: Diary;
  @Event onClickAction: () => void = () => {};
  @Event onDeleteAction: () => void = () => {};
  @Event onHandlePrivacyAction: () => void = () => {};
  @Local diaryCreateTime: Date = new Date();

  @Computed
  get diaryContent() {
    if (this.item.isPrivacy) {
      let str: string[] = Array.from(this.item.textContent);
      return str.map(() => '*').join('');
    }
    // 剔除开头的空格和换行
    const content = this.item.textContent.replace(/^(\s*\n)+/, '');
    return content;
  }

  aboutToAppear(): void {
    this.diaryCreateTime = new Date(Number(this.item.updateTime))
  }

  build() {
    Column({ space: 8 }) {
      BaseDiaryMeta({
        date: this.diaryCreateTime,
        isPrivacy: this.item.isPrivacy
      })

      Row() {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            TextSelectView({
              value: this.item.weatherText,
              icon: this.item.weatherIcon,
              type: 'weather',
              showFlag: true,
              paddingLeft: 8,
              paddingTop: 4
            })

            TextSelectView({
              value: this.item.moodText,
              icon: this.item.moodIcon,
              type: 'mood',
              showFlag: true,
              paddingLeft: 8,
              paddingTop: 4
            })
          }

          Text(this.diaryContent)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .layoutWeight(1)

        Column() {
          if (this.item.firstImage) {
            Image(this.item.firstImage)
              .width(76).height(76).objectFit(ImageFit.Cover)
              .borderRadius(16)
          }
        }
        .height(76)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding(12)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onClickAction?.()
    })
    .bindContextMenu(
      this.MenuBuilder,
      ResponseType.LongPress,
      {
        transition: TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Ease }),
        preview: this.MyPreview,
        placement: Placement.BottomLeft,
        offset: { x: -8, y: 8 }
      }
    )
  }

  @Builder
  MenuBuilder() {
    Column({ space: 16 }) {
      MenuListItem({
        symbol: this.item.isPrivacy ? 'sys.symbol.lock_open_fill' : 'sys.symbol.lock_fill',
        text: this.item.isPrivacy ? '取消私密' : '设为私密',
        onClickAction: () => {
          setTimeout(() => {
            this.onHandlePrivacyAction?.()
          }, 220)
        }
      })

      MenuListItem({
        symbol: 'sys.symbol.trash_fill',
        text: '删除日记',
        symbolColor: $r('sys.color.warning'),
        fontColor: $r('sys.color.warning'),
        onClickAction: () => {
          this.onDeleteAction?.()
        }
      })
    }
    .padding({ top:16, bottom: 16 })
  }

  @Builder
  MyPreview() {
    Column() {
      Text(this.diaryContent)
        .constraintSize({ maxWidth: 140 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(14)
        .lineHeight(19)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
  }
}


@ComponentV2
struct MenuListItem {
  @Param symbol: string = '';
  @Param text: string = '';
  @Param symbolColor: ResourceStr = $r('sys.color.font_tertiary');
  @Param fontColor: ResourceStr = $r('sys.color.font_primary')
  @Event onClickAction: () => void = () => {}

  build() {
    Row({space: 8 }) {
      SymbolGlyph($r(this.symbol))
        .fontColor([this.symbolColor])
        .fontSize(20)
      Text(this.text)
        .fontSize(14)
        .fontColor(this.fontColor)
        .offset({ y: 2 })
    }
    .padding({left: 12, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onClickAction?.()
    })
  }
}