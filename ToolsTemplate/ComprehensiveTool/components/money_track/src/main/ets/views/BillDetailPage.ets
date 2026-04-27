import { BillDetail } from '../components/BillDetail';
import { ContainerColumn } from '../components/base/ContainerColumn';
import { BillDetailVM } from '../viewmodels/BillDetailVM';

@Builder
export function billDetailPageBuilder() {
  BillDetailPage();
}

@Entry
@ComponentV2
struct BillDetailPage {
  vm: BillDetailVM = new BillDetailVM();

  build() {
    NavDestination() {
      Column(){
        ContainerColumn() {
          if (this.vm.bill) {
            BillDetail({
              bill: this.vm.bill,
              handleDelete: () => {
                this.vm.deleteBill();
              },
              handleEdit: () => {
                this.vm.editBill();
              },
            });
          }
        };
      }
      .padding($r('app.string.space_l'))
    }
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .title('账单详情')
    .onBackPressed(() => {
      this.vm.stack.pop(1)
      return true;
    })
    .onReady((context) => {
      this.vm.initData(context.pathStack);
    });
  }
}