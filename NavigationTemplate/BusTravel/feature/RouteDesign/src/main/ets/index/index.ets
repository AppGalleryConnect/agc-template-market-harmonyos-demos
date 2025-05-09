import { BusLinePlan } from '../page/BusLinePlan';
import { RealTimeBus } from '../page/realTimeBus';
import { RouteEntryVM } from 'common'

@Builder
export function RouteDesignBuilder() {
  RouteDesign()
}

@Component
export struct RouteDesign {
  vm: RouteEntryVM = RouteEntryVM.instance;

  build() {
    BusLinePlan()
  }
}