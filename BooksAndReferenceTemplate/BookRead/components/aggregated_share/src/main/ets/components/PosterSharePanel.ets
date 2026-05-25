import { AppStorageV2 } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { ShareKinds, ShareViewData } from '../common/ShareParams'
import { CommonConstants } from '../common/Constants';
import { CustomScrollModifier } from '../common/Styles';
import { ShareConfigModel } from '../model/ShareConfigModel';
import { PanelItem } from './PanelItem';

@ComponentV2
export struct PosterSharePanel {
  @Require @Param data: ShareViewData;
  @Require @Param pixmap: image.PixelMap;
  @Require @Param shareList: ShareKinds[];
  @Local windowModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  @Local scrollModifier: CustomScrollModifier = new CustomScrollModifier();
  @Local maxWidth: Length = Infinity;
  @Local maxHeight: Length = Infinity;

  build() {
    Column({ space: CommonConstants.PADDING_XXL }) {
      Column() {
        Image(this.pixmap)
          .objectFit(ImageFit.Contain)
          .onComplete((event) => {
            if (event) {
              const aspectRatio = event.width / event.height;
              if (aspectRatio >= CommonConstants.DEFAULT_LONG_IMG_RATIO) {
                this.maxWidth = CommonConstants.DEFAULT_POSTER_MAX_WIDTH;
              } else {
                this.maxHeight = CommonConstants.DEFAULT_POSTER_MAX_HEIGHT;
              }
            }
          })
      }
      .constraintSize({
        maxWidth: this.maxWidth,
        maxHeight: this.maxHeight,
      })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.shareList, (value: ShareKinds) => {
            PanelItem({
              value: value,
              data: this.data,
              pixmap: this.pixmap,
            })
          }, (value: ShareKinds) => value.kindId)
        }
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
        })
      }
      .attributeModifier(this.scrollModifier)
      .padding({
        top: CommonConstants.PADDING_M,
        bottom: CommonConstants.PADDING_M,
      })
    }
  }
}
