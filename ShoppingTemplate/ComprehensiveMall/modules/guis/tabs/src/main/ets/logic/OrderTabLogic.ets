

@ObservedV2
export class OrderTabLogic {

  private selected: boolean = false;

  @Trace
  public label: string = '';

  @Trace
  public textColor: ResourceColor = '#E6000000';

  public setSelected(selected: boolean): void {
    this.selected = selected;
    this.update();
  }

  public setLabel(label: string): void {
    this.label = label;
    this.update();
  }

  private update(): void {
    if (this.selected) {
      this.textColor = $r('app.color.tab_text_active_color');
    } else {
      this.textColor = '#E6000000';
    }
  }
}
