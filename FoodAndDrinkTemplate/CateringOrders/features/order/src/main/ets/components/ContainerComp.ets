import { OrderListComp } from './OrderListComp';
import { TopComp } from './TopComp';

@Component
export struct ContainerComp{

  aboutToAppear(): void {
  }
  build() {
    Column(){
      TopComp()
      OrderListComp().layoutWeight(1)
    }
  }
}