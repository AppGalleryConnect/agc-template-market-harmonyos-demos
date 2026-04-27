import { ValueType } from '@kit.ArkData';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  BaseViewModel,
  BreakpointNameEnum,
  CommonDialogUtil,
  EmitterUtils,
  HttpApi,
  PageStatus,
  RouterMap,
  RouterModule,
  Template,
  ToastLoading,
} from 'lib_foundation';
import { TemplateInfo } from '../models/Model';


@ObservedV2
export class TemplateListPageVM extends BaseViewModel {
  @Trace newTemplateList: TemplateInfo[] = []
  @Trace selectedTemplate: TemplateInfo | undefined;
  @Trace editName: string = '';
  // 页面状态
  @Trace pageStatus: PageStatus = PageStatus.IDLE;

  @Computed
  get listLanes() {
    const currentBreakpoint = this.breakPointModel.currentBreakpoint;
    switch (currentBreakpoint) {
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        return 2;
      default:
        return 1;
    }
  }

  // 获取模板列表
  public async getTemplateList() {
    this.pageStatus = PageStatus.LOADING;
    ToastLoading.open();
    HttpApi.queryTemplateList(this.userInfoModel.id).then((resp) => {
      this.newTemplateList = resp.map((item) => {
        return new TemplateInfo(item)
      });
      this.pageStatus = resp.length > 0 ? PageStatus.SUCCESS : PageStatus.EMPTY;
      ToastLoading.close();
    }).catch(() => {
      this.pageStatus = PageStatus.EMPTY;
      ToastLoading.close();
    })
  }

  // 新增模板
  addMyTemplate() {
    const params = {
      'isFromListAdd': true,
    } as Record<string, ValueType>
    RouterModule.replace({ url: RouterMap.TEMPLATE_PAGE, param: params })
  }

  // 编辑列表
  public editTemplate(template: TemplateInfo) {
    const params = {
      'id': template.id,
    } as Record<string, ValueType>
    RouterModule.push({ url: RouterMap.TEMPLATE_PAGE, param: params });
  }

  delete(template: TemplateInfo) {
    ToastLoading.open();
    HttpApi.deleteTemplate(template.id).then(() => {
      const index = this.newTemplateList.findIndex((item) => item.id === template.id);
      if (index !== -1) {
        this.newTemplateList.splice(index, 1);
      }
      ToastDialog.showToast({ message: '模板删除成功！' });
      EmitterUtils.emit('refresh_template');
      this.pageStatus = this.newTemplateList.length > 0 ? PageStatus.SUCCESS : PageStatus.EMPTY;
      ToastLoading.close();
    }).catch(() => {
      ToastLoading.close();
    })
  }

  // 删除列表
  public async deleteTemplate(template: TemplateInfo) {
    CommonDialogUtil.open({ content: '确定删除当前模板吗？' }, () => {
      this.delete(template);
    })
  }

  // 修改模板名称
  public async updateName(template: TemplateInfo) {
    if (!this.editName) {
      ToastDialog.showToast({ message: '请输入名称！' });
      return;
    }
    if (this.editName === template.name) {
      return;
    }
    const data = {
      id: template.id,
      name: this.editName,
      userId: template.userId,
    } as Template;
    HttpApi.updateTemplate(data).then(() => {
      ToastDialog.showToast({ message: '修改成功！' });
      template.name = this.editName;
      EmitterUtils.emit('refresh_template');
    })
  }

  // 去寄件
  public shipping(templateId: number) {
    // 清除路由栈中除Main页面之外的路由
    let pathNames: string[] = RouterModule.stack.getAllPathName();
    for (let i = pathNames.length - 1; i > 0; i--) {
      RouterModule.stack.removeByName(pathNames[i])
    }
    RouterModule.push({ url: RouterMap.EXPRESS_PAGE, param: templateId })
  }
}
