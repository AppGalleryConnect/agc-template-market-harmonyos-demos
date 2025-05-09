import { Catalog } from 'parse';
import { ReaderController } from '../controller/ReaderController';
import { emitter } from '@kit.BasicServicesKit';
import { Constants, LazyDataVM } from 'common';


@ComponentV2
export struct CatalogCard {
  @Param @Require cvm: LazyDataVM<Catalog>;
  @Param @Require curPageNum: number;
  @Param @Require readController: ReaderController;
  private preIndex: number = 0;

  @Builder
  buildCatalog(c: Catalog) {
    Column() {
      Row() {
        Text(c.title)
          .fontSize(18)
          .width('90%')
          .fontColor(this.isInCurCatalog(c.index) ? Color.Blue : Color.Black)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
        Text(c.index.toString())
          .fontColor(Color.Gray)
          .fontSize(15)
          .width('10%')
      }
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .margin({ top: 5 })
    }
    .margin({ left: 10, right: 10 })
    .onClick(() => {
      let eventData: emitter.EventData = {
        data: {
          index: c.index,
        }
      };
      emitter.emit(Constants.SWIPER_CHANGE, eventData);
    })
  }

  isInCurCatalog(index: number): boolean {
    if (this.curPageNum <= index - 1 && this.curPageNum >= this.preIndex - 1) {
      this.preIndex = index;
      return true;
    } else {
      this.preIndex = index;
      return false;
    }
  }

  build() {
    List({ space: 30 }) {
      LazyForEach(this.cvm, (c: Catalog) => {
        ListItem() {
          this.buildCatalog(c);
        }
      },(item: string) => new Date().toString())
    }.width('95%')
    .height('100%')
  }
}