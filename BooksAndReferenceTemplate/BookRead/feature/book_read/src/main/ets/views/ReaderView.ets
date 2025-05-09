import { BookCoverCard } from '../comps/BookCoverCard';
import { ReaderToolCard } from '../comps/ReaderToolCard';
import { ReaderController } from '../controller/ReaderController';
import { TextNodeController } from '../node/TextNodeController';
import { emitter } from '@kit.BasicServicesKit';
import { ReaderTopCard } from '../comps/ReaderTopCard';
import { Constants, WindowUtils } from 'common';

@ComponentV2
export struct ReaderView {
  @Local fontSize: number = 70;
  @Local curPageNum: number = 0;
  @Local curSwiperIndex: number = 1;
  @Param @Require readController: ReaderController;
  @Local toolShowFlag: boolean = false;
  @Local totalNum: number = 0;
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear(): void {
    emitter.on(Constants.SWIPER_CHANGE, (eventData: emitter.EventData) => {
      this.toolShowFlag = false;
      this.curPageNum = eventData.data?.index
      this.swiperController.changeIndex(eventData.data?.index);
    });

    emitter.on(Constants.FONT_CHANGE, (eventData: emitter.EventData) => {
      this.totalNum = this.readController.getTotalNum();
    })

    this.foldInit();
    this.totalNum = this.readController.getTotalNum();
  }

  foldInit() {
    WindowUtils.getMainWindow().on('windowSizeChange', () => {
      WindowUtils.resize();
      this.readController.modifyWindowSize(WindowUtils.getWindowHeight(), WindowUtils.getWindowWidth(),
        this.curPageNum);
      this.totalNum = this.readController.getTotalNum();
    })
  }

  build() {
    Stack() {
      Swiper(this.swiperController) {
        BookCoverCard({ book: this.readController.getBook() });
        LazyForEach(this.readController.getNodeController(), (vm: TextNodeController, index) => {
          Stack() {
            NodeContainer(vm)
              .width(Constants.FULL_SIZE)
              .height(Constants.FULL_SIZE)
              .onAppear(() => {
                this.readController.loadTextNode(vm, index + 1);
              })
              .padding({ top: 20 })
            Text(`${this.curPageNum}/${this.totalNum}`)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .padding({ bottom: 40, left: 18 })
          }
          .alignContent(Alignment.BottomStart)
        },(item: string) => new Date().toString())
      }
      .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
        this.curPageNum = targetIndex;
      })
      .indicator(false)
      .loop(false);

      if (this.toolShowFlag) {
        ReaderTopCard({ readController: this.readController });
        ReaderToolCard({ fontSize: this.fontSize, curPageNum: this.curPageNum, readController: this.readController });
      }
    }
    .alignContent(Alignment.BottomStart)
    .onClick(() => {
      // 已有工具栏，优先换页
      if (!this.toolShowFlag) {
        this.swiperController.showNext();
      }
      this.toolShowFlag = false;
    })
    .gesture(GestureGroup(GestureMode.Parallel,
      LongPressGesture()
        .onAction((event: GestureEvent) => {
          this.toolShowFlag = !this.toolShowFlag;
        })
    ))
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }
}