import { LayoutNewsDataSource } from './DataSource';

@ObservedV2
export class ListModel {
  @Trace dataSource: LayoutNewsDataSource = new LayoutNewsDataSource();
  @Trace count: number = 0;

  constructor(dataSource: LayoutNewsDataSource) {
    this.dataSource = dataSource;
  }
}