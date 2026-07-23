import { fp2pxUtil } from '@agctemplate/widgets'
import { BulletItem } from '../models/BulletItem'

@ComponentV2
export struct BulletView {

  @Param @Require bulletComments: Array<BulletItem>
  @Param @Require xTrans: Array<number>

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(
        this.bulletComments,
        (item: BulletItem, index) => {
          if(item.isUser) {
            Text(item.content)
              .fontSize(fp2pxUtil(item.size))
              .fontColor('#fff')
              .translate({ x: `${this.xTrans[index]}vp`, y: 0 })
              .position({ y: `${item.positionY}` })
              .borderRadius(999)
              .padding({
                top: 4,
                left: 8,
                bottom: 4,
                right: 8
              })
              .border({ width: 1, color: '#fff' })
              .opacity(item.opacity)
          }else {
            Text(item.content)
              .fontSize(fp2pxUtil(item.size))
              .fontColor('#fff')
              .translate({ x: `${this.xTrans[index]}vp`, y: 0 })
              .position({ y: `${item.positionY}` })
              .borderRadius(999)
              .padding({
                top: 4,
                left: 8,
                bottom: 4,
                right: 8
              })
              .opacity(item.opacity)
          }
        },
        (item: BulletItem, index: number) => item.content.toString() + '_' + index.toString()
      )
    }
    .width('100%')
  }
}