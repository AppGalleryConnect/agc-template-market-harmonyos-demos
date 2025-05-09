import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';

const builders: Map<string, WrappedBuilder<[ResourceStr]>> = new Map([
  ['banner', wrapBuilder(buildBannerImage)],
  ['tag1', wrapBuilder(buildTag1Image)]
]);

export class ImageContentWrapper {

  public static create(preset: string, content: ResourceStr): ComponentEntryProxy | null {
    const wrappedBuilder: WrappedBuilder<[ResourceStr]> | undefined = builders.get(preset);
    if (wrappedBuilder) {
      return new ComponentEntry(wrappedBuilder, [content]);
    } else {
      return null;
    }
  }
}

@Builder
function buildBannerImage(content: ResourceStr) {
  Image(content)
    .width('100%')
    .draggable(false)
    .objectFit(ImageFit.Contain)
    .borderRadius(8)
}

@Builder
function buildTag1Image(content: ResourceStr) {
  ImageSpan(content)
    .height(13.7)
    .draggable(false)
    .objectFit(ImageFit.Contain)
    .verticalAlign(ImageSpanAlignment.CENTER)
}