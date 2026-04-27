import { OHDialogModel } from 'common'

@Builder
export function commonDialogBuilder(vm: OHDialogModel) {
  Text(vm.subtitle)
    .fontSize($r('sys.float.Body_M'))
    .fontColor(Color.Black)
    .lineHeight($r('app.float.vp_22'))
    .maxLines(-1)

  Blank().height($r('app.float.vp_26'))
}