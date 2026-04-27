import { AccountDialogModel } from '../model/AccountDialogModel';
import { MockAccountSingleModel } from '../model/MockAccountSingleModel';
import { MockAccountSingleRow } from './MockAccountSingleRow';

@ComponentV2
struct MockAccountDialog {
  @Param @Require dialogVM: AccountDialogModel;

  build() {
    Row() {
      List() {
        Repeat<MockAccountSingleModel>(this.dialogVM.value)
          .each((ri: RepeatItem<MockAccountSingleModel>) => {
            // 默认模板
            ListItem() {
              MockAccountSingleRow({
                dialogVM: ri.item,
                selectUserId: this.dialogVM.currentUser.userId,
                onSelectClick: () => {
                  this.dialogVM.currentUser = ri.item;
                }
              })
            }
          })
          .key((item: MockAccountSingleModel): string => item.userId)
          .virtualScroll({
            totalCount: this.dialogVM.value.length
          })
          .templateId((): string => {
            return '';
          })
      }
      .cachedCount(2)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .height('100%')
      .width('100%')
    }
    .width('100%')
    .height($r('app.float.vp_88'))
  }
}

@Builder
export function dialogMockAccountBuilder(dialogVM: Object) {
  MockAccountDialog({ dialogVM: dialogVM as AccountDialogModel })
}