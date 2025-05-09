import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { iResourceMgr } from '@common/resource';
import { IRow } from '@components/irow';

import { ProductCardModel, ProductCardContents, CardContent } from '../model/ProductCardModel';
import { TextContentWrapper } from '../wrapper/TextContentWrapper';
import { ImageContentWrapper } from '../wrapper/ImageContentWrapper';
import { TagContentWrapper } from '../wrapper/TagContentWrapper';

@ObservedV2
export class ProductCardLogic {

  @Trace
  public viewData: ComponentEntryProxy[] = [];

  public isVertical: boolean = true;

  private onClickCallback: (productId: string) => void = () => {};

  private productId: string = '';

  public setData(data: ProductCardModel): void {
    const viewData: ComponentEntryProxy[] = [];
    const contents: ProductCardContents = data.contents;
    this.productId = data.productId;
    this.loadingViewData(viewData, contents.banner, wrapBuilder(buildBanner));
    this.loadingViewData(viewData, contents.title, wrapBuilder(buildTitle));
    this.loadingViewData(viewData, contents.label, wrapBuilder(buildLabel));
    this.loadingViewData(viewData, contents.promotion, wrapBuilder(buildPromotion));
    this.loadingViewData(viewData, contents.price, wrapBuilder(buildPrice));
    this.viewData = viewData;
  }

  private loadingViewData(viewData: ComponentEntryProxy[], contents: CardContent[],
    wrappedBuilder: WrappedBuilder<[ComponentEntryProxy[], boolean]>) {
    if (contents && contents.length > 0) {
      const subViewData: ComponentEntryProxy[] = [];
      for (let content of contents) {
        const wrapper: ComponentEntryProxy | null = this.contentToWrapper(content);
        if (wrapper) {
          subViewData.push(wrapper);
        }
      }
      if (subViewData.length > 0) {
        viewData.push(new ComponentEntry(wrappedBuilder, [subViewData, this.isVertical]));
      }
    }
  }

  private contentToWrapper(content: CardContent): ComponentEntryProxy | null {
    switch (content.constructionType) {
      case 'Text':
        return TextContentWrapper.create(content.preset, content.data);
      case 'Image':
        return ImageContentWrapper.create(content.preset, iResourceMgr.resolveUri(content.data));
      case 'Tag':
        return TagContentWrapper.create(content.preset, content.data);
      default:
        return null;
    }
  }

  public setOnClickCallback = (callback: (productId: string) => void): void => {
    this.onClickCallback = callback;
  }

  public readonly onClick = (): void => {
    this.onClickCallback(this.productId);
  }
}

@Builder
function buildBanner(viewData: ComponentEntryProxy[], isVertical: boolean): void {
  ForEach(viewData, (v: ComponentEntryProxy, index: number) => {
    if (index === 0) {
      v.wrappedBuilder.builder(...v.args)
    }
  })
}

@Builder
function buildTitle(viewData: ComponentEntryProxy[], isVertical: boolean): void {
  Text() {
    ForEach(viewData, (v: ComponentEntryProxy, index: number) => {
      if (index > 0) {
        ImageSpan('')
          .width(3)
      }
      v.wrappedBuilder.builder(...v.args)
    })
  }
  .halfLeading(true)
  .padding({ left: 6, right: 6 })
  .margin(isVertical ? { top: 5 } : {})
  .width('100%')
}

@Builder
function buildLabel(viewData: ComponentEntryProxy[], isVertical: boolean): void {
  Text() {
    ForEach(viewData, (v: ComponentEntryProxy, index: number) => {
      if (index > 0) {
        Span('｜')
          .fontColor('#FF888888')
          .fontSize(12)
          .lineHeight(16.5)
          .fontWeight(400)
      }
      v.wrappedBuilder.builder(...v.args)
    })
  }
  .width('100%')
  .maxLines(1)
  .halfLeading(true)
  .padding({ left: 6, right: 6 })
  .margin({ top: 2 })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Builder
function buildPromotion(viewData: ComponentEntryProxy[], isVertical: boolean): void {
  IRow({
    viewData: viewData,
    spacing: 3,
    singleComponentMinWidth: 20
  })
    .margin({ top: 3 })
    .padding(isVertical ? { left: 6, right: 6 } : { left: 3, right: 6 })
    .width('100%')
}

@Builder
function buildPrice(viewData: ComponentEntryProxy[], isVertical: boolean): void {
  Text() {
    ForEach(viewData, (v: ComponentEntryProxy, index: number) => {
      if (index > 0) {
        ImageSpan('')
          .width(3)
      }
      v.wrappedBuilder.builder(...v.args)
    })
  }
  .halfLeading(true)
  .padding({ left: 6, right: 6 })
  .margin({ top: 10, bottom: 10 })
  .width('100%')
}
