import { TemplateApi } from '../http/Api';
import { ITemplate } from '../http/Type';
import { emitter } from '@kit.BasicServicesKit';
import { Logger, toastUtil } from 'module_base';

@ObservedV2
export class TemplateListPageVM {
  private static _instance: TemplateListPageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace public templateList: ITemplate[] = []
  @Trace public selectedTemplate: ITemplate | undefined
  @Trace public editName: string = ''

  public static get instance() {
    if (!TemplateListPageVM._instance) {
      TemplateListPageVM._instance = new TemplateListPageVM();
    }
    return TemplateListPageVM._instance;
  }

  public async init() {
    this.getTemplateList()
  }

  setStack(stack: NavPathStack) {
    this.stack = stack;
  }

  public async getTemplateList() {
    const res = await TemplateApi.getTemplateList()
    this.templateList = res
  }

  public async deleteTemplate(id: number) {
    await TemplateApi.deleteTemplate(id)
    toastUtil.showToast('删除成功！');
    let template: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('template', template);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
    this.getTemplateList()
  }

  public async update(): Promise<boolean> {
    if (!this.editName) {
      toastUtil.showToast('请输入名称！');
      return false
    }
    if (!this.selectedTemplate) {
      toastUtil.showToast('修改失败！');
      return false
    }
    const data: ITemplate = {
      id: this.selectedTemplate.id,
      name: this.editName,
      sendAddress: this.selectedTemplate.sendAddress,
      getAddress: this.selectedTemplate.getAddress,
      goods: this.selectedTemplate.goods,
      shippingMethod: this.selectedTemplate.shippingMethod,
      paymentMethod: this.selectedTemplate.paymentMethod,
      weight: this.selectedTemplate.weight,
    }
    await TemplateApi.updateTemplate(data)
    toastUtil.showToast('修改成功！');
    this.editName = ''
    this.getTemplateList()

    let template: emitter.EventData = {
      data: {
        isFresh: true,
      },
    };
    try {
      emitter.emit('template', template);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    return true
  }

  public showEditButton(template: ITemplate): boolean {
    return template.id === this.selectedTemplate?.id
  }
}
