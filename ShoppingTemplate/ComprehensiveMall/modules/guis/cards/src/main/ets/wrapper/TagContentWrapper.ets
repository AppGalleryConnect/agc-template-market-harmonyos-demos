import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';

const builders: Map<string, WrappedBuilder<[ResourceStr]>> = new Map([
  ['tag1', wrapBuilder(buildTag1)],
]);

export class TagContentWrapper {

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
function buildTag1(content: ResourceStr) {
  Text(content)
    .fontSize(8)
    .lineHeight(10)
    .fontWeight(400)
    .halfLeading(true)
    .fontColor('#FFFF2D19')
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .padding({ top: 0.5, bottom: 0.5, right: 3.5, left: 3.5 })
    .borderWidth(0.7)
    .borderRadius(2.5)
    .borderColor('#FFFF2D19')
}

