export class MyRatingStyle implements ContentModifier<RatingConfiguration> {
  size: number = 20
  space: number = 12

  constructor(size: number, space: number = 12) {
    this.size = size
    this.space = space
  }

  applyContent(): WrappedBuilder<[RatingConfiguration]> {
    return wrapBuilder(buildRating);
  }
}

@Builder
function buildRating(config: RatingConfiguration) {
  Row() {
    ForEach([1, 2, 3, 4, 5], (item: number) => {
      Image(config.rating >= item ? $r('app.media.ic_star_filled') : $r('app.media.ic_star_grey'))
        .height('100%')
        .margin({ right: (config.contentModifier as MyRatingStyle).space})
        .onClick(() => {
          if (!config.indicator) {
            config.triggerChange(item)
          }
        })
    }, (item: number) => JSON.stringify(item))
  }
  .height((config.contentModifier as MyRatingStyle).size)
}