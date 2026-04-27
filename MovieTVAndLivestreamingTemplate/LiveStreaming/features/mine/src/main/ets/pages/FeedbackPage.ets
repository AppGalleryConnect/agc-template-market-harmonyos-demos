import { Feedback, FeedbackItemType } from '@agctemplate/feed_back';
import { Header } from '../component/Header';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { BarVM } from '@agctemplate/widgets';

@ComponentV2
export struct FeedbackPage {
  // 接收意见反馈har返回来的数据
  @Local feedList: FeedbackItemType = {
    description: '',
    stageImageUris: [],
    phone: '',
    time: ''
  }

  build() {
    NavDestination() {
      Column() {
        Header({
          title: '意见反馈',
          rightImageRes: $r('sys.symbol.doc_plaintext'),
          fontWightParam: 700,
          rightOnClick: () => {
            RouterModule.push({ url: RouterMap.FEEDBACK_RECORD_PAGE })
          }
        })
        Feedback({
          des: 100,
          num: 5,
          butOnClick: (val: FeedbackItemType) => {
            this.feedList = val;
            let info =
              PreferenceUtil.getInstance(this.getUIContext().getHostContext())
                .get(PreferConstant.FEEDBACK_RECORD, []) as FeedbackItemType[]
            let arr: FeedbackItemType[] = []
            info.forEach((model: FeedbackItemType) => {
              arr.push(model)
            })
            arr.unshift(this.feedList)
            PreferenceUtil.getInstance(this.getUIContext().getHostContext()).put(PreferConstant.FEEDBACK_RECORD, arr)
            this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
            RouterModule.pop()
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))

      // .padding({ bottom: BarVM.instance.aiBarH })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    .hideTitleBar(true)
  }
}

@Builder
export function FeedbackPageBuilder() {
  FeedbackPage()
}
