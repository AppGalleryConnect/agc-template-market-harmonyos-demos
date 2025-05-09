import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { LengthMetrics, LengthUnit } from '@kit.ArkUI';

const builders: Map<string, WrappedBuilder<[ResourceStr]>> = new Map([
  ['primary', wrapBuilder(buildPrimaryText)],
  ['secondary', wrapBuilder(buildSecondaryText)],
  ['snow', wrapBuilder(buildSnowText)],
  ['leaf', wrapBuilder(buildLeafText)],
  ['price', wrapBuilder(buildPriceText)],
  ['dashPrice', wrapBuilder(buildDashPriceText)]
]);

export class TextContentWrapper {

  public static create(styleId: string, content: ResourceStr): ComponentEntryProxy | null {
    const wrappedBuilder: WrappedBuilder<[ResourceStr]> | undefined = builders.get(styleId);
    if (wrappedBuilder) {
      return new ComponentEntry(wrappedBuilder, [content]);
    } else {
      return null;
    }
  }
}

@Builder
function buildPriceText(content: ResourceStr) {
  Span('¥')
    .fontColor('#FFE84026')
    .lineHeight(18)
    .fontSize(11)
    .fontWeight(600)
  Span(content)
    .fontColor('#FFE84026')
    .lineHeight(18)
    .fontSize(15)
    .fontWeight(600)
}

@Builder
function buildDashPriceText(content: ResourceStr) {
  Span('¥')
    .fontColor('#FF888888')
    .lineHeight(18)
    .fontSize(11)
    .fontWeight(400)
    .decoration({
      type: TextDecorationType.LineThrough,
      color: '#66000000'
    })
  Span(content)
    .fontColor('#FF888888')
    .lineHeight(18)
    .fontSize(11)
    .fontWeight(400)
    .decoration({
      type: TextDecorationType.LineThrough,
      color: '#66000000'
    })
}

@Builder
function buildPrimaryText(content: ResourceStr) {
  Span(content)
    .fontColor('#FF111111')
    .lineHeight(18)
    .fontSize(13)
    .fontWeight(500)
    .baselineOffset(new LengthMetrics(0.4, LengthUnit.VP))
}

@Builder
function buildSecondaryText(content: ResourceStr) {
  Span(content)
    .fontColor('#FF888888')
    .fontSize(12)
    .lineHeight(16.5)
    .fontWeight(400)
}

@Builder
function buildSnowText(content: ResourceStr) {
  Span(content)
    .fontColor('#FF0096FA')
    .fontSize(12)
    .lineHeight(16.5)
    .fontWeight(400)
}

@Builder
function buildLeafText(content: ResourceStr) {
  Span(content)
    .fontColor('#FF827CFB') // '#FF0FB12C'
    .fontSize(12)
    .lineHeight(16.5)
    .fontWeight(400)
}
