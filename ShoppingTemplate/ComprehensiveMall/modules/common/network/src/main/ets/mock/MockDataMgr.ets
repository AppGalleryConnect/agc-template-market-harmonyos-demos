import { CartDto, OrderCardDto } from '@common/customtypes';
import { PersistenceV2 } from '@kit.ArkUI';
import { MockDatabase } from './MockDatabase';

export class MockDataMgr {

  public static getCartData(): CartDto {
    let mockCart: MockCart = PersistenceV2.connect(MockCart, 'MockCart', () => new MockCart())!;
    if (mockCart.data) {
      return JSON.parse(mockCart.data) as CartDto;
    } else {
      return {
        version: 'mock_cart_version_empty',
        total: 0,
        cards: []
      };
    }
  }

  public static setCartData(cart: CartDto): void {
    let mockCart: MockCart = PersistenceV2.connect(MockCart, 'MockCart', () => new MockCart())!;
    mockCart.data = JSON.stringify(cart);
  }

  public static getOrderListData(): OrderCardDto[] {
    let list: MockOrderList = PersistenceV2.connect(MockOrderList, 'MockOrderList', () => new MockOrderList())!;
    if (!list.isInit) {
      list.isInit = true;
      list.data = JSON.stringify(MockDatabase.ORDER_LIST);
    }
    if (list.data) {
      return JSON.parse(list.data) as OrderCardDto[];
    } else {
      return [];
    }
  }

  public static setOrderListData(list: OrderCardDto[]): void {
    let mock: MockOrderList = PersistenceV2.connect(MockOrderList, 'MockOrderList', () => new MockOrderList())!;
    mock.data = JSON.stringify(list);
  }
}

@ObservedV2
export class MockCart {
  @Trace
  public data: string = '';
}

@ObservedV2
export class MockOrderList {
  @Trace
  public data: string = '';
  @Trace
  public isInit: boolean = false;
}
