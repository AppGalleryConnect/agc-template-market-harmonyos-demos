import { WindowUtil } from 'lib_foundation'
import { ProductApis, ProductCardItem } from 'lib_network'
import { CommonConfirmDialog, NavTitleBar } from 'lib_widget'
import { ProductList } from '../components/ProductList'

@Builder
export function buildViewHistoryPage() {
  ViewHistoryPage()
}

@ComponentV2
export struct ViewHistoryPage {
  @Local
  productList: ProductCardItem[] = []
  @Local
  curPage: number = 1
  @Local
  isFinal: boolean = false;
  @Local
  isEdit: boolean = false
  @Local
  isLoading: boolean = false;

  build() {
    NavDestination() {
      NavTitleBar({
        title: '浏览历史',
      }) {
        Text(this.isEdit ? '取消' : '批量管理')
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('app.float.space_s') })
          .width($r('app.string.size_percent_full'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.isEdit = !this.isEdit
          })
      }

      ProductList({
        productList: this.productList,
        isEdit: this.isEdit,
        isLoading: this.isLoading,
        onReachEnd: async () => {
          await this.getViewHistoryList()
        },
        handleDelete: (list: string[]) => {
          CommonConfirmDialog.show({
            content: '是否确认删除浏览历史记录？',
            confirm: () => {
              ProductApis.deleteProductViewHistory(list).then((res) => {
                if (res.code === 0) {
                  WindowUtil.toast('删除成功！')
                  this.isEdit = false;
                  this.refresh()
                }
              })
            },
          })
        },
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onShown(() => {
      this.refresh()
    })
  }

  async refresh() {
    this.productList = []
    this.curPage = 1;
    this.isFinal = false;
    this.getViewHistoryList()
  }

  async getViewHistoryList() {
    if (this.isFinal || this.isLoading) {
      return;
    }
    this.isLoading = true
    const res = await ProductApis.getProductViewHistory({ curPage: this.curPage })
    if (res.code === 0) {
      this.productList.push(...res.list)
      this.isFinal = res.isFinal;
    }
    if (!this.isFinal) {
      this.curPage++;
    }
    this.isLoading = false;
  }
}