import { util } from '@kit.ArkTS'

@ObservedV2
export class FloatText {
  @Trace id: string = util.generateRandomUUID(true)
  @Trace text: string = '功德值+1'
  @Trace translateOptions: TranslateOptions = {
    y: 0,
  }
  @Trace opacity: number = 1
  @Trace fontSize: Resource | number | string = 24
  @Trace fontColor: ResourceColor = $r('sys.color.font_on_primary')
  @Trace isShow: boolean = true
}