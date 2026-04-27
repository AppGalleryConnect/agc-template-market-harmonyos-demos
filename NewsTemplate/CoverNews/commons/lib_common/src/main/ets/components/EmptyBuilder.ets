import { CommonConstants } from '../constants/CommonConstants'

/**
 * 空白builder参数
 */
export interface EmptyBuilderParams {
  text?: string
  img?: ResourceStr
  fontSizeRatio?: number
  space?: number
}

@Builder
export function emptyBuilder(params?: EmptyBuilderParams) {
  Column({ space: params?.space ?? CommonConstants.SPACE_S }) {
    Image(params?.img ?? $r('app.media.ic_empty_content'))
      .width(120)
      .draggable(false)
    Text(params?.text ?? '暂无内容')
      .fontSize(14 * (params?.fontSizeRatio ?? 1))
      .fontColor($r('sys.color.font_secondary'))
  }
  .width(CommonConstants.FULL_PERCENT)
  .height(CommonConstants.FULL_PERCENT)
  .justifyContent(FlexAlign.Center)
}