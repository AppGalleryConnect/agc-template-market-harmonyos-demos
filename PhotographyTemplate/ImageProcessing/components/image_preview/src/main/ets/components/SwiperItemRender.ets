import { ImagePreviewPip } from '../Imagepip/ImagePreviewPip'
import { ImagePreviewOptions } from '../models/ImagePreviewOptions'
import { PreviewComponentInfo, SourceImageModel } from '../models/PreviewModel'
import { PreviewUtils } from '../utils/Utils'
import { PreviewViewModel } from '../viewmodel/PreviewViewModel'
import { SwiperImageItem } from './SwiperImageItem'
import { SwiperMovingPhotoItem } from './SwiperMovingPhotoItem'

@ComponentV2
export struct SwiperItemRender {
  vm: PreviewViewModel = new PreviewViewModel(this.getUIContext())
  @Param @Require startIndex: number
  @Param @Require params: ImagePreviewOptions
  @Param @Require imageSrc: SourceImageModel
  @Param @Require index: number
  @Param longTakeEffectMap: Map<number, PreviewComponentInfo> = new Map()
  @Local uniId: number = 0
  @Event onDisabledSwiper: (val: boolean) => void = () => {
  }
  @Event onLoadingStatus: (val: number, index: number) => void = () => {
  }

  aboutToAppear(): void {
    this.uniId = this.getUniqueId()
    this.vm.setOptions(this.params)
    this.vm.setUniId(this.uniId)
    this.vm.setEvent(this.onDisabledSwiper)
    this.vm.setCurrentIndex(this.startIndex)
  }

  // 重置
  @Monitor('startIndex')
  reset() {
    this.vm.setParams(1)
    this.vm.showThumbnailChange(false)
    this.vm.setCurrentIndex(this.startIndex)
  }

  build() {
    Stack({ alignContent: this.vm.imageRatio < 1 ? Alignment.Bottom : Alignment.End }) {
      if (!PreviewUtils.isMovingPhoto(this.imageSrc)) {
        /**
         * 静态图片
         * */
        SwiperImageItem({
          startIndex: this.startIndex,
          params: this.params,
          vm: this.vm,
          longTakeEffectMap: this.longTakeEffectMap,
          imageUrl: this.imageSrc.imageUrl,
          uniId: this.uniId,
          index: this.index,
          onLoadingStatus: (val, index) => {
            this.onLoadingStatus(val, index)
          },
        })
      } else {
        /**
         * 动态图片
         * */
        SwiperMovingPhotoItem({
          startIndex: this.startIndex,
          params: this.params,
          imageSrc: this.imageSrc,
          vm: this.vm,
          longTakeEffectMap: this.longTakeEffectMap,
          uniId: this.uniId,
          index: this.index,
          onLoadingStatus: (val, index) => {
            this.onLoadingStatus(val, index)
          },
        })
      }

      /**
       * 缩略图
       * */
      ImagePreviewPip({ imageUrl: this.imageSrc.imageUrl, viewModel: this.vm })
    }
  }
}