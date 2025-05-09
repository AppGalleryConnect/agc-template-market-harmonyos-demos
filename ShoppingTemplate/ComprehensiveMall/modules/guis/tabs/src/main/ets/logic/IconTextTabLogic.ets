import { IconTextTabModel } from '../model/IconTextTabModel';

@ObservedV2
export class IconTextTabLogic {

  private model: IconTextTabModel = new IconTextTabModel();

  private selected: boolean = false;

  @Trace
  public label: string = '';

  @Trace
  public icon: PixelMap | ResourceStr | DrawableDescriptor | ImageContent = '';

  @Trace
  public iconColor: ResourceColor = $r('app.color.tab_icon_inactive_color');

  @Trace
  public textColor: ResourceColor = $r('app.color.tab_text_inactive_color');

  public setSelected(selected: boolean): void {
    this.selected = selected;
    this.update();
  }

  public setModel(model: IconTextTabModel): void {
    this.model = model;
    this.update();
  }

  private update(): void {
    this.label = this.model.label;
    if (this.selected) {
      this.iconColor = $r('app.color.tab_icon_active_color');
      this.textColor = $r('app.color.tab_text_active_color');
      this.icon = this.model.activeIcon;
    } else {
      this.iconColor = $r('app.color.tab_icon_inactive_color');
      this.textColor = $r('app.color.tab_text_inactive_color');
      this.icon = this.model.inactiveIcon;
    }
  }

}
