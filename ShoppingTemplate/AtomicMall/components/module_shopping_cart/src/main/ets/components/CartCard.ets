import { WindowUtil } from 'lib_foundation';
import { ProductModel } from '../commons/Model';
import { NumberStepper } from './basic/NumberStepper';

@ComponentV2
export struct CartCard {
  // 卡片数据
  @Param data: ProductModel = new ProductModel();
  // 是否编辑态
  @Param isEdit: boolean = false;
  // 购物车商品数量变化的事件回调
  @Event onChangeCount: (skuCode: string) => void = (skuCode: string) => {
  };
  // 商品卡片事件回调
  @Event onCardClick: () => void = () => {
  };
  // 管理态，点击删除图标
  @Event onDelete: (skuCode: string) => void = (skuCode: string) => {
  };
  // 点击规格行事件回调
  @Event onSpecClick: () => void = () => {
  };

  build() {
    Row({ space: 8 }) {
      this.checkboxBuilder();
      this.cardImgBuilder();
      this.cardInfoBuilder();
    }
    .alignItems(VerticalAlign.Top)
    .backgroundColor($r('app.color.background_color_primary'))
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .borderRadius(16)
    .onClick(() => {
      this.onCardClick && this.onCardClick();
    })
  }

  @Builder
  checkboxBuilder() {
    Row() {
      Checkbox({ group: 'checkboxGroup', name: this.data.skuCode })
        .selectedColor('#FFE64566')
        .unselectedColor($r('app.color.font_color_level2'))
        .size({ width: 20, height: 20 })
        .shape(CheckBoxShape.CIRCLE)
        .select(this.data.isSelected)
        .onChange((value: boolean) => {
          this.data.isSelected = value;
        })
    }
    .alignSelf(ItemAlign.Stretch)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  cardImgBuilder() {
    Image(this.data.banner)
      .width(86)
      .height(86)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
  }

  @Builder
  cardInfoBuilder() {
    Column() {
      Row() {
        if (this.data.slotId) {
          Text(' 秒杀 ')
            .fontSize(10)
            .fontColor($r('app.color.font_color_level1_invert'))
            .backgroundColor($r('app.color.theme_color'))
            .padding(2)
            .borderRadius(2)
            .margin({ right: 2 })
        }
        Text(this.data.title)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(14)
          .fontColor($r('app.color.font_color_level1'))
          .layoutWeight(1)
      }

      Text(this.data.serviceDesc)
        .fontColor($r('app.color.font_color_level2'))
        .fontSize(12)
        .margin({ top: 2 })

      Row({ space: 4 }) {
        Text(this.data.skuDesc)
          .fontColor($r('app.color.font_color_level2'))
          .fontSize(10)
        Image($r('app.media.ic_left_arrow'))
          .height(11)
          .objectFit(ImageFit.Contain)
          .rotate({ angle: -90 })
          .fillColor($r('app.color.font_color_level2'))
          .draggable(false)
      }
      .borderRadius(4)
      .margin({ top: 4 })
      .padding({
        top: 2,
        bottom: 2,
        left: 8,
        right: 8,
      })
      .backgroundColor($r('app.color.background_color_button_grey'))
      .onClick(() => {
        this.onSpecClick && this.onSpecClick();
      })

      Row() {
        Text() {
          Span('¥').fontSize(10).fontColor($r('app.color.theme_color'))
          Span(this.data.price.toString()).fontSize(16).fontColor($r('app.color.theme_color'))

          if (this.data.dashPrice) {
            Span(' ').letterSpacing(2)
            Span('¥')
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('app.color.font_color_level3'),
              })
            Span(this.data.dashPrice.toString())
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('app.color.font_color_level3'),
              })
          }
        }
        .fontSize(10)
        .fontColor($r('app.color.font_color_level3'))

        if (this.isEdit) {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.ic_delete')).fillColor(Color.White).width(14).height(14)
          }
          .padding(4)
          .backgroundColor($r('app.color.theme_color'))
          .borderRadius(4)
          .onClick(() => {
            this.onDelete && this.onDelete(this.data.skuCode);
          })
        } else {
          NumberStepper({
            value: this.data.count,
            max: this.data.slotId ? 1 : this.data.stock,
            buttonType: ButtonType.Circle,
            onChange: (value) => {
              if (value <= 0) {
                WindowUtil.toast('宝贝数量不能再减少了~');
                return;
              }
              if (value > this.data.stock) {
                WindowUtil.toast('数量不能再增加了，超出库存限制！');
                return;
              }
              this.data.count = value;
              this.onChangeCount && this.onChangeCount(this.data.skuCode);
            },
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 12 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
  }
}