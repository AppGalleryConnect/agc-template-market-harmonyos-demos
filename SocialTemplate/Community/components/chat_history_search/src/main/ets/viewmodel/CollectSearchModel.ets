import { TEXT_CONTENT_DEFAULT_LINES } from '../constant/Constants';
import { TextUtil } from '../util/TextUtil';

@ObservedV2
export class CollectSearchModel {
  @Trace calcFinish: boolean = false;
  @Trace isExpand: boolean = false;
  @Trace showExpandButton: boolean = false;
  @Trace keyNum: number[] = [];
  @Trace message: string = '';
  @Trace messageShowing: string = '';
  @Trace messageLower: string = '';
  @Trace searchTextLower: string = '';
  @Trace textWidth: number = 0;

  calcLightIndex() {
    this.messageLower = this.messageShowing.toLowerCase();
    this.keyNum = [];
    let num = this.messageLower.split(this.searchTextLower).length - 1;
    let preLength = 0;
    for (let i = 0; i < num; i++) {
      let curIndex = this.messageLower.indexOf(this.searchTextLower, preLength);
      this.keyNum.push(curIndex);
      preLength = curIndex + this.searchTextLower.length;
    }
  }

  expandText(): void {
    this.isExpand = true;
    this.messageShowing = this.message;
    this.messageLower = this.messageShowing.toLowerCase();
    this.calcLightIndex();
  }

  //收起文本
  collapseText(): void {
    if (!this.showExpandButton) {
      this.showExpandButton =
        TextUtil.getNeedProcess(this.messageShowing, this.textWidth,
          $r('sys.float.Body_M'), TEXT_CONTENT_DEFAULT_LINES,
          $r('app.float.vp_22'), '...', '---展开');
    }
    if (this.showExpandButton) {
      this.messageShowing =
        TextUtil.getShortText(this.messageShowing, this.textWidth,
          $r('sys.float.Body_M'), TEXT_CONTENT_DEFAULT_LINES,
          $r('app.float.vp_22'), '...', '---展开');
      this.messageLower = this.messageShowing.toLowerCase();
      this.calcLightIndex();
      this.isExpand = false;
    }
  }

  onExpandTextSizeChange(newW: number) {
    if (this.textWidth !== newW) {
      this.textWidth = newW;
      this.showExpandButton = false;
      this.messageShowing = this.message;
      this.collapseText();
      this.calcFinish = true;
    }
  }
}
