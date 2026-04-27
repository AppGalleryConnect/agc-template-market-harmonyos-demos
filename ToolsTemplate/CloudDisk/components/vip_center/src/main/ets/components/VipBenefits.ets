import { BaseCell, getDataFromJSON } from 'base_apis';
import { Benefits } from '../model/Model';

/**
 * @usage: 用于VIP会员权益展示场景。提供会员权益列表展示，从JSON文件加载权益数据。
 * 关键数据结构：Benefits（权益类，包含icon图标、title标题）、benefitsList（权益列表数组）。
 * @layout: 使用BaseCell卡片布局。内部为Grid网格布局（4列），每个权益项垂直排列（圆形图标、标题文字）。
 * @constraints: Vip_Benefits.json文件必须存在且格式正确，benefitsList权益列表不能为空
 * @isGen: true
 * @fileType: component
 * @zhName: VIP会员权益组件
 */
@ComponentV2
export struct VipBenefits {
  @Local benefitsList: Benefits[] = []

  aboutToAppear(): void {
    this.benefitsList = getDataFromJSON<Benefits>('Vip_Benefits.json', this);
  }

  @Builder
  vipBenefits() {
    Grid() {
      ForEach(this.benefitsList, (item: Benefits, index: number) => {
        GridItem() {
          Column({ space: 5 }) {
            Row() {
              Image($r(item.icon)).width(24).height(24)
            }
            .padding(8)
            .borderRadius('50%')
            .backgroundColor('#FDF5E2')

            Text(item.title)
          }
        }
      },(item: Benefits) => JSON.stringify(item))
    }
    .maxCount(1)
    .margin({ top: 16 })
    .columnsTemplate('1fr 1fr 1fr 1fr')
  }

  build() {
    Column() {
      BaseCell({
        cellTitle: '会员权益',
        customBuilderParam: () => this.vipBenefits(),
      })
    }
  }
}