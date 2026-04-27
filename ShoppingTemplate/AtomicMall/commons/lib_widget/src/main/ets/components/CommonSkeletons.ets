import { SkeletonTheme, UISkeleton, SkeletonType } from '@hw-agconnect/ui-skeleton';
import { BreakpointSystem, BreakpointTypeEnum } from 'lib_foundation';

@ComponentV2
export struct ProductListSkeleton {
  @Param
  imageSize: Length = 100
  @Param
  isVertical: boolean = true
  @Param
  cardLineNum: number = 4

  @Computed
  get horizontalCardNum() {
    if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG) {
      return 4
    } else if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.MD) {
      return 3
    }
    return 2
  }

  @Computed
  get verticalCardNum() {
    return BreakpointSystem.isTablet ? 2 : 1
  }

  getCardList(): boolean[] {
    const arrNum = (this.isVertical ? this.verticalCardNum : this.horizontalCardNum) * this.cardLineNum
    return new Array(arrNum).fill(true)
  }

  build() {
    List({ space: 12 }) {
      Repeat<boolean>(this.getCardList())
        .each((ri: RepeatItem<boolean>) => {
          if (this.isVertical) {
            VerticalCard({imageSize:this.imageSize})
          } else {
            HorizontalCard({imageSize:this.imageSize})
          }
        })
    }
    .lanes(this.isVertical ? this.verticalCardNum : this.horizontalCardNum, 12)
    .layoutWeight(1)
    .expandSafeArea()
    .scrollBar(BarState.Off)
    .align(Alignment.Start)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

  }
}

@ReusableV2
@ComponentV2
struct VerticalCard {
  @Param
  imageSize: Length = 100

  build() {
    Row({ space: 8 }) {
      Column() {
        UISkeleton({ theme: SkeletonTheme.IMAGE }) {
        }
      }.width(this.imageSize).height(this.imageSize)

      Column() {
        UISkeleton({
          options: [{ width: '100%', height: 14 }, { width: '100%', height: 14 }, { width: '70%', height: 14 }],
          spaceCol: 8,
        })
      }.layoutWeight(1).height(96)
    }
  }
}

@ReusableV2
@ComponentV2
struct HorizontalCard {
  @Param
  imageSize: Length = 100

  build() {
    Column() {
      UISkeleton({
        options: [
          {
            type: SkeletonType.RECT,
            width: '100%',
            height: this.imageSize,
            radius: 16,
          },
          { width: '100%', height: 14 },
          { width: '100%', height: 14 },
          { width: '70%', height: 14 },
        ],
        spaceCol: 8,
      })
    }
    .height(200)
  }
}